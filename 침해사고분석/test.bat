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
::===============================================================
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

@REM :: 완료 메시지
@REM echo All registry checks have been completed. Results have been saved to %log_registry%.

::============================================================================================
:: 서비스 리스트 로그화
sc query state= all > %log_services%
::============================================================================================
:: 1. 모든 사용자 계정 목록 확인
echo [1] 사용자 계정 목록 >> "%log_users%"
net user >> "%log_users%"
echo. >> "%log_users%"

:: 2. 사용자 계정별 상세 정보 수집
echo [2] 사용자 계정별 정보 >> "%log_users%"
for /f "skip=4 tokens=1" %%u in ('net user') do (
    echo 사용자: %%u >> "%log_users%"
    net user %%u >> "%log_users%"
    echo. >> "%log_users%"
)
echo. >> "%log_users%"

:: 3. 로컬 그룹 목록 확인
echo [3] 로컬 그룹 목록 >> "%log_users%"
net localgroup >> "%log_users%"
echo. >> "%log_users%"

:: 4. 각 그룹의 사용자 목록 수집
echo [4] 그룹별 사용자 목록 >> "%log_users%"
for /f "skip=4 tokens=1" %%g in ('net localgroup') do (
    echo 그룹: %%g >> "%log_users%"
    net localgroup %%g >> "%log_users%"
    echo. >> "%log_users%"
)
echo. >> "%log_users%"

:: 5. 현재 로그인한 사용자 및 상태 확인
echo [5] 현재 로그인 사용자 및 상태 >> "%log_users%"
query user >> "%log_users%"
echo. >> "%log_users%"
::============================================================================================

pause
