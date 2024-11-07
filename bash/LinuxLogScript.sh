#! /bin/bash
CurrentDatetime=$(date "+%y-%m-%d %H-%M-%S")

mkdir "./log_$CurrentDatetime"

get_SysInfo()
{
    uname -a >> "./log_$CurrentDatetime/SysInfo.log"
}
get_CurrentUsers()
{
    w >> "./log_$CurrentDatetime/Logedin.log"
}
get_SetUIDGID()
{
    find / -type f -perm 6000 -ls 2>/dev/null >> "./log_$CurrentDatetime/SetUIDBit.log"
    find / -type f -perm 4000 -ls 2>/dev/null >> "./log_$CurrentDatetime/SetGIDBit.log"
}
get_TimeByFile()
{
    find / -atime 5 2>/dev/null >> "./log_$CurrentDatetime/FileAccessHistory.log"
    find / -ctime 5 2>/dev/null >> "./log_$CurrentDatetime/FileMadeHistory.log"
    find / -mtime 5 2>/dev/null >> "./log_$CurrentDatetime/FileFixHistory.log"
}
get_crontab()
{
    crontab -l >> "./log_$CurrentDatetime/Crontab.log"
}
get_Integrity()
{
    rpm -Va >> "./log_$CurrentDatetime/Integrity.log"
}
get_history()
{
    history >> "./log_$CurrentDatetime/History.log"
}
#==================================
# 1. 현재 날짜 및 시간 수집 함수
CurrentDateTime() {
    echo "=== Current Date and Time ===" > "./log_$CurrentDatetime/CurrentDateTime.log"
    date >> "./log_$CurrentDatetime/CurrentDateTime.log"
}

# 2. 마지막 접속 기록 수집 함수
LoginRecords() {
    echo "=== Last Login Records ===" > "./log_$CurrentDatetime/LoginRecords.log"
    last >> "./log_$CurrentDatetime/LoginRecords.log"
    echo "=== Failed Login Attempts ===" >> "./log_$CurrentDatetime/LoginRecords.log"
    lastb >> "./log_$CurrentDatetime/LoginRecords.log"
    echo "=== Last Logins for All Users ===" >> "./log_$CurrentDatetime/LoginRecords.log"
    lastlog >> "./log_$CurrentDatetime/LoginRecords.log"
}

# 3. 현재 런 레벨 확인 함수
RunLevelInfo() {
    echo "=== Current Run Level ===" > "./log_$CurrentDatetime/RunLevel.log"
    runlevel >> "./log_$CurrentDatetime/RunLevel.log"
}

# 4. 사용자 및 그룹 정보 수집 함수
UserGroupInfo() {
    echo "=== User Information (/etc/passwd) ===" > "./log_$CurrentDatetime/UserGroupInfo.log"
    cat /etc/passwd >> "./log_$CurrentDatetime/UserGroupInfo.log"
    echo "=== Shadow File (Password Information) ===" >> "./log_$CurrentDatetime/UserGroupInfo.log"
    cat /etc/shadow 2>/dev/null >> "./log_$CurrentDatetime/UserGroupInfo.log"
    echo "=== Group Information (/etc/group) ===" >> "./log_$CurrentDatetime/UserGroupInfo.log"
    cat /etc/group >> "./log_$CurrentDatetime/UserGroupInfo.log"
}

# 5. 특정 사용자 권한이 있는 파일 검사 함수
PermissionCheck() {
    echo "=== World-writable Files Owned by Root ===" > "./log_$CurrentDatetime/PermissionCheck.log"
    find / -type f -perm -002 -user 0 2>/dev/null >> "./log_$CurrentDatetime/PermissionCheck.log"
}

# 6. 프로세스 점검 함수
ProcessInfo() {
    echo "=== Process List (ps -ef) ===" > "./log_$CurrentDatetime/ProcessInfo.log"
    ps -ef >> "./log_$CurrentDatetime/ProcessInfo.log"
    echo "=== Process Tree (pstree) ===" >> "./log_$CurrentDatetime/ProcessInfo.log"
    pstree >> "./log_$CurrentDatetime/ProcessInfo.log"
    echo "=== Real-time Process Monitoring (top -b -n 1) ===" >> "./log_$CurrentDatetime/ProcessInfo.log"
    top -b -n 1 | head -n 20 >> "./log_$CurrentDatetime/ProcessInfo.log"
    echo "=== Process List with Thread Group (ps -ejH) ===" >> "./log_$CurrentDatetime/ProcessInfo.log"
    ps -ejH >> "./log_$CurrentDatetime/ProcessInfo.log"
}

# 7. 악성 프로그램 검사 함수
MalwareCheck() {
    echo "=== chkrootkit Scan ===" > "./log_$CurrentDatetime/MalwareCheck.log"
    if command -v chkrootkit >/dev/null 2>&1; then
        chkrootkit >> "./log_$CurrentDatetime/MalwareCheck.log"
    else
        echo "chkrootkit is not installed. Skipping rootkit check." >> "./log_$CurrentDatetime/MalwareCheck.log"
    fi
}

# 8. 네트워크 상태 점검 함수
NetworkInfo() {
    echo "=== Network Connections (netstat -an) ===" > "./log_$CurrentDatetime/NetworkInfo.log"
    netstat -an >> "./log_$CurrentDatetime/NetworkInfo.log"
    echo "=== ARP Table (arp -a) ===" >> "./log_$CurrentDatetime/NetworkInfo.log"
    arp -a >> "./log_$CurrentDatetime/NetworkInfo.log"
    echo "=== IP Address Information (ip addr) ===" >> "./log_$CurrentDatetime/NetworkInfo.log"
    ip addr >> "./log_$CurrentDatetime/NetworkInfo.log"
    echo "=== Routing Table (route) ===" >> "./log_$CurrentDatetime/NetworkInfo.log"
    route >> "./log_$CurrentDatetime/NetworkInfo.log"
    echo "=== Open Files and Network Connections (lsof) ===" >> "./log_$CurrentDatetime/NetworkInfo.log"
    lsof | head -n 50 >> "./log_$CurrentDatetime/NetworkInfo.log"
}

# 9. 주요 로그 파일 확인 함수
LogFiles() {
    echo "=== System Logs in /var/log ===" > "./log_$CurrentDatetime/LogFiles.log"
    ls -lah /var/log >> "./log_$CurrentDatetime/LogFiles.log"
    echo "=== sulog (Superuser Command Usage Log) ===" >> "./log_$CurrentDatetime/LogFiles.log"
    cat /var/log/sulog 2>/dev/null >> "./log_$CurrentDatetime/LogFiles.log"
}

# 10. 보안 로그 수집 함수
SecurityLogs() {
    echo "=== Auth Logs (Authentication Records) ===" > "./log_$CurrentDatetime/SecurityLogs.log"
    cat /var/log/auth.log 2>/dev/null | tail -n 50 >> "./log_$CurrentDatetime/SecurityLogs.log"
    echo "=== Secure Logs (for CentOS/RHEL systems) ===" >> "./log_$CurrentDatetime/SecurityLogs.log"
    cat /var/log/secure 2>/dev/null | tail -n 50 >> "./log_$CurrentDatetime/SecurityLogs.log"
}

# 11. 파일 핸들러 확인 함수
FileHandlerCheck() {
    echo "=== File Handlers in Use (fuser) ===" > "./log_$CurrentDatetime/FileHandlerCheck.log"
    fuser -v / >> "./log_$CurrentDatetime/FileHandlerCheck.log" 2>/dev/null
}

# 12. 관리자 권한 계정 확인 함수
AdminAccountsCheck() {
    echo "=== Accounts with UID=0 in /etc/passwd ===" > "./log_$CurrentDatetime/AdminAccountsCheck.log"
    awk -F: '$3 == 0 {print $1}' /etc/passwd >> "./log_$CurrentDatetime/AdminAccountsCheck.log"
}

# 13. 숨김 파일 및 dev 디렉터리 검색 함수
HiddenFilesCheck() {
    echo "=== Hidden Files (find / -name '.*') ===" > "./log_$CurrentDatetime/HiddenFilesCheck.log"
    find / -name ".*" -print >> "./log_$CurrentDatetime/HiddenFilesCheck.log" 2>/dev/null
    echo "=== Files in /dev (find /dev -type f) ===" >> "./log_$CurrentDatetime/HiddenFilesCheck.log"
    find /dev -type f -print >> "./log_$CurrentDatetime/HiddenFilesCheck.log"
}
#==================================
# 함수 호출
CurrentDateTime
LoginRecords
RunLevelInfo
UserGroupInfo
PermissionCheck
ProcessInfo
MalwareCheck
NetworkInfo
LogFiles
SecurityLogs
FileHandlerCheck
AdminAccountsCheck
HiddenFilesCheck
#==================================
get_SysInfo
get_CurrentUsers
get_SetUIDGID
get_TimeByFile
get_crontab
get_Integrity
get_history

# nmap 검사 / 삭제된 파일 검사는 사용자가 직접 해야 겠다.

# 스크립트 종료
echo "Linux System Incident Analysis Script - Finished at: $(date)"