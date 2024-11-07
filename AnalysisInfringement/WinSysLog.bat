@echo off
:: 첫 번째 인수를 log_path로 설정
set log_path=%1
:: 실행한 위치
set script_path=%~dp0
:: 날짜 형식
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set datetime=%%I
set datetime=%datetime:~0,8%_%datetime:~8,6%
:: 로그 저장 경로를 따로 지정하지 않으면 기본 경로에 로그 생성
set log_dir=%script_path%log_%datetime%
:: 디렉토리 추출하여 폴더 확인 및 생성
if not exist %log_dir% mkdir %log_dir%
::==========================================================================
:: 개별 아티팩트별 로그 파일 경로 설정
@REM set log_system_info=%log_dir%\system_info.txt
@REM set log_network_config=%log_dir%\network_config.txt
@REM set log_process_list=%log_dir%\process_list.txt
@REM set log_services_list=%log_dir%\services_list.txt
@REM set log_startup_programs=%log_dir%\startup_programs.txt
@REM set log_firewall_rules=%log_dir%\firewall_rules.txt
@REM set log_user_accounts=%log_dir%\user_accounts.txt
set log_registry=%log_dir%\registry.txt
set log_services=%log_dir%\services.txt
set log_users=%log_dir%\users.txt

set log_prefetch=%log_dir%\prefetch_files.txt
set log_suspicious_files=%log_dir%\suspicious_files.txt
set log_browser_history=%log_dir%\browser_history.txt

set mft_log=%log_dir%\MFT_log_%datetime%.txt
set event_log=%log_dir%\Event_log_%datetime%.txt
set process_log=%log_dir%\Process_log_%datetime%.txt
::===============================================================
:: Prefetch Files
echo ==== Collecting Prefetch Files Information ==== > %log_prefetch%
if exist "C:\Windows\Prefetch" (
    dir /b "C:\Windows\Prefetch" >> %log_prefetch%
) else (
    echo No Prefetch files found. >> %log_prefetch%
)
echo Prefetch information saved in %log_prefetch%

:: Suspicious Files (EXE and DLL)
echo ==== Searching for Suspicious Files ==== > %log_suspicious_files%
echo === EXE Files === >> %log_suspicious_files%
dir /s /b C:\*.exe >> %log_suspicious_files%
echo === DLL Files === >> %log_suspicious_files%
dir /s /b C:\*.dll >> %log_suspicious_files%
echo Suspicious file information saved in %log_suspicious_files%
::===============================================================
:: Web Browser History
echo ==== Collecting Web Browser History ==== > %log_browser_history%

:: Check for sqlite3.exe file only for browser history extraction
if not exist "%script_path%sqlite3.exe" (
    echo sqlite3.exe file is missing. Please place sqlite3.exe in the same folder as this batch file to retrieve browser history records. >> %log_browser_history%
    goto skip_browser_history
)

:: Chrome History
echo Chrome History >> %log_browser_history%
if exist "C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\History" (
    sqlite3.exe "C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\History" "SELECT url, title, datetime((last_visit_time/1000000)-11644473600, 'unixepoch', 'localtime') FROM urls ORDER BY last_visit_time DESC;" >> %log_browser_history%
) else (
    echo Chrome history not found. >> %log_browser_history%
)

:: Firefox History
echo Firefox History >> %log_browser_history%
for /d %%i in ("C:\Users\%USERNAME%\AppData\Roaming\Mozilla\Firefox\Profiles\*") do (
    if exist "%%i\places.sqlite" (
        sqlite3.exe "%%i\places.sqlite" "SELECT url, title, datetime((visit_date/1000000), 'unixepoch', 'localtime') FROM moz_places INNER JOIN moz_historyvisits ON moz_places.id = moz_historyvisits.place_id ORDER BY visit_date DESC;" >> %log_browser_history%
    ) else (
        echo Firefox history not found in profile %%i >> %log_browser_history%
    )
)

:: Edge History
echo Edge History >> %log_browser_history%
if exist "C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\User Data\Default\History" (
    sqlite3.exe "C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\User Data\Default\History" "SELECT url, title, datetime((last_visit_time/1000000)-11644473600, 'unixepoch', 'localtime') FROM urls ORDER BY last_visit_time DESC;" >> %log_browser_history%
) else (
    echo Edge history not found. >> %log_browser_history%
)

:skip_browser_history
echo Browser history information saved in %log_browser_history%
::===============================================================
:: MFT 점검
echo Starting MFT check... 
fsutil usn readdata C:\Users\Administrator\Downloads\forecopy_handy\mft\$MFT >> %mft_log% 2>&1
echo MFT check completed. Results saved to %mft_log%.

:: 이벤트 로그 점검
echo Starting Event Log check... 
wevtutil qe System /f:text > %event_log% 2>&1
echo Event Log check completed. Results saved to %event_log%.

:: 프로세스 목록 점검
echo Starting Process check... >> %process_log%
tasklist > %process_log% 2>&1
echo Process check completed. Results saved to %process_log%.
::===============================================================
:: 서비스 리스트 로그화
sc query state= all > %log_services%
::==========================================================================
:: 1. 모든 사용자 계정 목록 확인
echo User Account List >> "%log_users%"
net user >> "%log_users%"
echo. >> "%log_users%"

:: 2. 사용자 계정별 상세 정보 수집
echo Information by User Account >> "%log_users%"
for /f "skip=4 tokens=1" %%u in ('net user') do (
    echo 사용자: %%u >> "%log_users%"
    net user %%u >> "%log_users%"
    echo. >> "%log_users%"
)
echo. >> "%log_users%"

:: 3. 로컬 그룹 목록 확인
echo Local Group List >> "%log_users%"
net localgroup >> "%log_users%"
echo. >> "%log_users%"

:: 4. 각 그룹의 사용자 목록 수집
echo List of users by group >> "%log_users%"
for /f "skip=4 tokens=1" %%g in ('net localgroup') do (
    echo 그룹: %%g >> "%log_users%"
    net localgroup %%g >> "%log_users%"
    echo. >> "%log_users%"
)
echo. >> "%log_users%"

:: 5. 현재 로그인한 사용자 및 상태 확인
echo Current login user and status >> "%log_users%"
query user >> "%log_users%"
echo. >> "%log_users%"
::==========================================================================
:: auto run 설정된 프로세스(레지스트리)에 해당하는 키들만 점검해도 된다
:: 루트 레지스트리 키 목록
@REM set registry_roots=HKLM HKCU HKCR HKU HKCC

@REM :: 레지스트리 점검 시작 메시지 출력
@REM echo Start a registry check. Results are stored in %log_registry%.
@REM echo Registry Check Results > %log_registry%

@REM :: 각 루트 키에 대해 모든 하위 키와 값을 순회하여 기록
@REM for %%R in (%registry_roots%) do (
@REM     echo ================================================== >> %log_registry%
@REM     echo [%%R] Registry information for the key >> %log_registry%
@REM     echo ================================================== >> %log_registry%
@REM     reg query %%R /s >> %log_registry% 2>&1
@REM )
::==========================================================================

pause
