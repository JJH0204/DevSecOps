#!/bin/bash

result_print() {
    # 입력된 인자를 배열로 저장
    local input=("$@")

    # 코드 점검내용과 전체 결과는 입력 배열의 첫 번째와 두 번째, 세 번째 항목
    local code="${input[0]}"
    local check_content="${input[1]}"
    local overall_result="${input[2]}"

    #출력 색상 정의
    red="\e[31m"
    green="\e[32m"
    yellow="\e[33m"
    reset="\e[0m"  # 색상 초기화

    # 항목의 짝수와 홀수 인덱스는 각각 세부항목과 요구사항
    echo -e "[${yellow}${code}${reset}] ${check_content}"
    echo "----------------------------------------------------------"
    # echo ": ${overall_result}"
    if [[ "$overall_result" == "취약" ]]; then
            echo -e ": ${red}${overall_result}${reset}"
        else
            echo -e ": ${green}${overall_result}${reset}"
        fi

    # 인덱스 3부터 시작해 세부항목과 결과를 쌍으로 묶어 출력
    local i=3
    while [ $i -lt ${#input[@]} ]; do
        local detail="${input[$i]}"
        local result="${input[$((i+1))]}"
        local requirement="${input[$((i+2))]}"
        
        # 출력 형식
        # echo -e "\t${detail}: ${result} (${requirement})"
        # 결과에 따라 색상 다르게 출력
        if [[ "$result" == "취약" ]]; then
            echo -e "\t${detail}: ${red}${result}${reset} (${requirement})"
        else
            echo -e "\t${detail}: ${green}${result}${reset} (${requirement})"
        fi

        # 인덱스를 세 개씩 증가시켜 다음 항목으로 이동
        i=$((i+3))
    done

    echo "=========================================================="
}

# 중복 검사 함수
is_in_array()
{
    local element="$1"
    shift
    local array=("$@")
    
    for item in "${array[@]}"; do
        if [[ "$item" == "$element" ]]; then
            return 0  # 배열에 값이 있으면 true (0) 반환
        fi
    done
    return 1  # 값이 없으면 false (1) 반환
}

# 배열을 순차적으로 출력하는 함수
print_array_elements()
{
    local array=("$@")  # 모든 인자를 배열로 받음
    local length=${#array[@]}  # 배열의 길이

    # 배열의 각 요소를 0부터 마지막까지 출력
    for ((i = 0; i < length; i++)); do
        echo "Element $i: ${array[$i]}"
    done
}

get_permission()
{
    index=${1}
    search_as=${2}
    string=${3}

    permission=0
    for (( i=${index}; i<=${search_as}; i++ )); do
        char="${string:$i:1}"
        if [[ "$char" == "r" ]]; then
            permission=$((permission + 4))
        elif [[ "$char" == "w" ]]; then
            permission=$((permission + 2))
        elif [[ "$char" == "x" ]]; then
            permission=$((permission + 1))
        else
            permission=$((permission + 0))
        fi
    done

    echo ${permission}
}

get_permission_result()
{
    permission=${1}
    # echo "${permission}"
    result=0

    result=$((result + $(get_permission 1 3 "${permission}") * 100))
    result=$((result + $(get_permission 4 6 "${permission}") * 10))
    result=$((result + $(get_permission 7 9 "${permission}")))

    echo ${result}
}

U_09()
{
    # 점검 코드 실행
    permission=`ls -l /etc/hosts | awk '{print $1}'`
    owner=`ls -l /etc/hosts | awk '{print $3}'`

    if [[ "$permission" == "-rw-------." && "$owner" == "root" ]]; then
        result="양호"
    else
        result="취약"
    fi

    code="U-09"

    if [ "$result" == "양호" ]; then
        order="요구사항_없음"
    else
        order="hosts 파일의 소유자를 root로, 권한을 600이하로 설정 필요"
    fi

    # 결과값 변수에 저장 ()
    desc="/etc/hosts 파일 소유자 및 권한 설정"
    total_result=$result
    detail_1=$code
    detail_1_result=$result
    detail_1_order=$order

    # 함수 실행 예시
    result_print $code "$desc" $total_result $detail_1 $detail_1_result "$detail_1_order"
}

U_10()
{
    # 점검 코드 실행
    Code1=`ls -l /etc/xinetd.conf 2>/dev/null | awk '{print $1}'`
    owner=`ls -l /etc/xinetd.conf 2>/dev/null | awk '{print $3}'`

    if [[ "$Code1" ==  "" ]]; then
        result="파일 없음"
    elif [[ "$Code1" == "-rw-------." && "$owner" == "root" ]]; then
        result="양호"
    else
        result="취약"
    fi

    code="U-10"

    if [[ "$result" == "양호" || "$result" == "파일 없음" ]]; then
        order="요구사항 없음"
    else
        order="/etc/inetd.conf 파일의 소유자 및 권한 설정 필요"
    fi

    # 결과값 변수에 저장 ()
    desc="/etc/(x)inetd.conf 파일 소유자 및 권한 설정"
    total_result=$result
    detail_1=$code
    detail_1_result=$result
    detail_1_order=$order


    # 함수 실행 예시
    result_print $code "$desc" "$total_result" $detail_1 "$detail_1_result" "$detail_1_order"
}

U_11()
{
    # 점검 코드 실행
    check=`ls -l /etc/rsyslog.conf | awk '{print $1}'`
    owner=`ls -l /etc/rsyslog.conf | awk '{print $3}'`

    if [[ "$check" == "-rw-r-----." && "$owner" == "root" ]]; then
        result="양호"
    else
        result="취약"
    fi

    code="U-11"

    if [[ "$result" == "양호" ]]; then
        order="요구사항 없음"
    else
        order="/etc/rsyslog.conf 파일의 소유자 및 권한 설정 필요"
    fi

    # 결과값 변수에 저장 ()
    desc="/etc/syslog.conf 파일 소유자 및 권한 설정"
    total_result=$result
    detail_1=$code
    detail_1_result=$result
    detail_1_order=$order


    # 함수 실행 예시
    result_print $code "$desc" $total_result $detail_1 $detail_1_result "$detail_1_order"
}

U_12()
{
    # 점검 코드 실행
    check=`ls -l /etc/services | awk '{print $1}'`
    owner=`ls -l /etc/services | awk '{print $3}'`

    if [[ "$check" == "-rw-r--r--." && ( "$owner" == "root" || "$owner" == "bin" || "$owner" == "sys" ) ]]; then
        result="양호"
    else
        result="취약"
    fi

    code="U-12"

    if [[ "$result" == "양호" ]]; then
        order="요구사항 없음"
    else
        order="/etc/services 파일의 소유자 및 권한 설정 필요"
    fi

    # 결과값 변수에 저장 ()
    desc="/etc/services 파일 소유자 및 권한 설정"
    total_result=$result
    detail_1=$code
    detail_1_result=$result
    detail_1_order=$order


    # 함수 실행 예시
    result_print $code "$desc" $total_result $detail_1 $detail_1_result "$detail_1_order"
}

U_13()
{
    # 점검 코드 실행
    check=`ls -alL /* | awk '{ print $1 }' | grep '^-rws'`

    if [[ "$check" == "" ]]; then
        result="양호"
    else
        result="취약"
    fi

    code="U-13"

    if [[ "$result" == "양호" ]]; then
        order="요구사항 없음"
    else
        order="SUID, SGID, 설정 파일 점검 필요"
    fi

    # 결과값 변수에 저장 ()
    desc="SUID, SGID, 설정 파일점검"
    total_result=$result
    detail_1=$code
    detail_1_result=$result
    detail_1_order=$order


    # 함수 실행 예시
    result_print $code "$desc" $total_result $detail_1 $detail_1_result "$detail_1_order"
}

U_14()
{
    # 점검 코드 실행
    owners=`ls -al /root/ | awk '{ print $3 }' | uniq`

    for owner in $owners; do
        if [[ "$owner" == "root" ]]; then
            result="양호"
        else
            result="취약"
        fi
    done

    code="U-14"

    if [[ "$result" == "양호" ]]; then
        order="요구사항 없음"
    else
        order="사용자 시스템 시작파일 및 환경파일 소유자 및 권한 설정 필요"
    fi

    # 결과값 변수에 저장 ()
    desc="사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정"
    total_result=$result
    detail_1=$code
    detail_1_result=$result
    detail_1_order=$order


    # 함수 실행 예시
    result_print $code "$desc" $total_result $detail_1 $detail_1_result "$detail_1_order"
}

U_15()
{
    # 점검 코드 실행
    check=`find / -type f -perm -2 -exec ls -l {} \; 2>/dev/null`

    if [[ "$check" == "" ]]; then
        result="양호"
    else
        result="취약"
    fi

    code="U-15"

    if [[ "$result" == "양호" ]]; then
        order="요구사항 없음"
    else
        order="world writable 파일 수정 및 삭제 필요"
        order2="find / -type f -perm -2 -exec ls -l {} \;"
    fi

    # 결과값 변수에 저장 ()
    desc="world writable 파일 점검"
    total_result=$result
    detail_1=$code
    detail_2=$code
    detail_1_result=$result
    detail_2_result="변경해야 할 목록"
    detail_1_order=$order
    detail_2_order=$order2

    # 함수 실행 예시
    if [[ "$result" == "양호" ]]; then
        result_print $code "$desc" $total_result $detail_1 $detail_1_result "$detail_1_order"
    else
        result_print $code "$desc" $total_result $detail_1 $detail_1_result "$detail_1_order" $detail_2 "$detail_2_result" "$detail_2_order"
    fi
}

U_17()
{
    # 점검 코드 실행
    check1=`ls -al $HOME/.rhosts 2>/dev/null | awk '{ print $1 }'`
    owner1=`ls -al $HOME/.rhosts 2>/dev/null | awk '{ print $3 }'`
    check2=`ls -al /etc/hosts.equiv 2>/dev/null | awk '{print $1}'`
    owner2=`ls -al /etc/hosts.equiv 2>/dev/null | awk '{print $3}'`

    code="U-17"

    if [[ "$check1" == "-rw-------." && "$check2" == "-rw-------." && "$owner1" == "root" && "$owner2" == "root" ]]; then
        result="양호"
    elif [[ "$check1" == "" || "$check2" == "" ]]; then
        result="파일 없음"
    else
        result="취약"
    fi

    if [[ "$result" == "양호" || "$result" == "파일 없음" ]]; then
        order="요구사항 없음"
    elif [[ "$result" == "파일 없음" ]]; then
        order="파일 없음"
    else
        order="/etc/hosts.equiv 파일, $HOME/.rhosts 파일 소유자 및 권한 변경 필요"
    fi

    # 결과값 변수에 저장 ()
    desc="$HOME/.rhosts, hosts.equiv 사용 금지"
    total_result=$result
    detail_1=$code
    detail_1_result=$result
    detail_1_order=$order


    # 함수 실행 예시
    result_print $code "$desc" "$total_result" $detail_1 "$detail_1_result" "$detail_1_order"
}

U_50()
{
    desc="관리자 그룹에 최소한의 계정 포함"
    detail=()
    total_result="양호"

    
    group_value=$(cat /etc/group | grep root | sed 's/root:x:0://')

    detail+=("Root Privileges Users")
    if echo "$group_value" | awk -F', ' '{for(i=1;i<=NF;i++) if($i != "root") exit 1}'; then
        detail+=("양호")
        detail+=("-")
    else
        detail+=("취약")
        detail+=("/etc/group 의 설정 파일 점검")
    fi

    if is_in_array "취약" "${detail[@]}"; then
        total_result="취약"
    fi

    # 함수 실행 예시
    result_print "U_50" "$desc" "$total_result" "${detail[@]}" #result $order
}

U_51()
{
    # 계정이 존재하지 않는 GID 금지
    # 그룹 설정 파일에 불필요한 그룹
        # 1. 계정이 없고 관리에 사용되지 않는 그룹
        # 2. 계정은 있지만 관리에 사용되지 않는 그룹
    # gshadow_name=$(cat /etc/gshadow | cut -d':' -f1)
    # group_name=$(cat /etc/group | cut -d':' -f1)

    # duplication_name=$(comm -3 $(echo ${gshadow_name}) $(echo ${group_name}))
    # echo "${duplication_name}"
    desc="계정이 존재하지 않는 GID 금지"
    detail=()
    total_result="양호"

    # gshadow와 group 파일에서 그룹 이름 추출
    gshadow_name=$(cut -d':' -f1 /etc/gshadow)
    group_name=$(cut -d':' -f1 /etc/group)
    # 사용중인 GID 모두 추출
    used_GID=$(cut -d':' -f4 /etc/passwd)
    # 모든 GID 리스트
    GID_list=$(cut -d':' -f3 /etc/group)


    # gshadow와 group 이름을 배열로 변환
    gshadow_array=(${gshadow_name})
    group_array=(${group_name})

    # 중복되지 않은 그룹 이름을 찾기 위한 배열 비교
    # gshadow 배열에서 group 배열에 없는 항목 출력
    detail+=("gshadow에만 있는 그룹")
    gshadow_state="양호"
    gshadow_gname=()
    for gname in "${gshadow_array[@]}"; do
        if [[ ! " ${group_array[@]} " =~ " ${gname} " ]]; then
            gshadow_state="취약"
            gshadow_gname+=("$gname")
        fi
    done
    # gshadow_comm="$gshadow_gname 그룹들을 점검하시오."
    if [[ ${gshadow_state} == "취약" ]]; then
        gshadow_comm="${gshadow_gname} 그룹들을 점검하시오."
    else
        gshadow_comm="-"
    fi


    detail+=("${gshadow_state}")
    detail+=("${gshadow_comm}")

    # group 배열에서 gshadow 배열에 없는 항목 출력
    # echo "group에만 있는 그룹:"
    detail+=("group에만 있는 그룹")
    group_state="양호"
    group_gname=()

    for gname in "${group_array[@]}"; do
        if [[ ! " ${gshadow_array[@]} " =~ " ${gname} " ]]; then
            group_state="취약"
            group_gname+=("$gname")
        fi
    done
    # 
    if [[ ${group_state} == "취약" ]]; then
        group_comm="${group_gname} 그룹들을 점검하시오."
    else
        group_comm="-"
    fi

    detail+=("${group_state}")
    detail+=("${group_comm}")

    ###########################################################
    used_GID_array=(${used_GID})
    GID_array=(${GID_list})

    detail+=("사용중이지 않는 GID")
    GID_state="양호"
    GID_check_list=()

    for _GID_ in "${GID_array[@]}"; do
        found=0  # GID가 사용 중인 배열에 있는지 여부를 나타내는 플래그
        for used_GID in "${used_GID_array[@]}"; do
            if [[ "$used_GID" -eq "$_GID_" ]]; then
                found=1
                break
            fi
        done

        # GID가 used_GID_array에 없으면 취약으로 설정
        if [[ $found -eq 0 ]]; then
            GID_state="취약"
            # GID_check_list+=("$_GID_")  # GID_check_list에 해당 GID 추가
        fi
    done

    if [[ ${GID_state} == "취약" ]]; then
        GID_comm="/etc/group의 사용중이지 않는 GID를 점검하시오."
    else
        GID_comm="-"
    fi

    detail+=("${GID_state}")
    detail+=("${GID_comm}")

    if is_in_array "취약" "${detail[@]}"; then
        total_result="취약"
    fi

    # 함수 실행 예시
    result_print "U_51" "$desc" "$total_result" "${detail[@]}" #result $order
}

U_52()
{
    desc="동일한 UID 금지"
    detail=()
    total_result="양호"

    duplicate_UID=$(cut -d':' -f3 /etc/passwd | sort | uniq -d)

    detail+=("UID 중복 사용 금지")

    # 변수에 값이 있는지 확인
    if [[ -z "$duplicate_UID" ]]; then
        detail+=("양호")
        detail+=("-")
    else
        detail+=("취약")
        detail+=("중복 사용 된 UID: $duplicate_UID")
    fi
    
    if is_in_array "취약" "${detail[@]}"; then
        total_result="취약"
    fi

    result_print "U_52" "$desc" "$total_result" "${detail[@]}" #result $order
}

U_53()
{
    # 사용자 shell 점검
    desc="사용자 shell 점검"
    detail=()
    total_result="양호"

    no_use_data=$(grep -E "^(daemon|bin|sys|adm|listen|nobody|nobody4|noaccess|diag|operator|games|gopher)" /etc/passwd | grep -v "admin")

    while IFS=: read -r name _ _ _ _ _ shell; do
        
        detail+=("$name")
        
        # 쉘이 /bin/false 또는 /sbin/nologin인지 검사
        if [[ "$shell" == "/bin/false" || "$shell" == "/sbin/nologin" ]]; then
            detail+=("양호")
            detail+=("-")
        else
            detail+=("취약")
            detail+=("계정에 /bin/false(/sbin/nologin) 쉘이 부여되지 않았습니다.")
        fi
    done <<< "$no_use_data"

    if is_in_array "취약" "${detail[@]}"; then
        total_result="취약"
    fi

    result_print "U_53" "$desc" "$total_result" "${detail[@]}" #result $order
}

U_54()
{
    # Session Timeout 설정
    desc="사용자 shell 점검"
    detail=()
    total_result="양호"

# TMOUT 설정이 작성되어 있는지
    TMOUT_set=$(cat /etc/profile | grep TMOUT)

    detail+=("session timeout 설정 여부")
    if [[ "$TMOUT_set" == "" ]]; then
        detail+=("취약")
        detail+=("Session Timeout 설정을 추가하십시오.")
    else
        detail+=("양호")
        detail+=("-")

# TMOUT 설정값이 600인지
        detail+=("session timeout 설정 값")
        TMOUT_value=$(echo "$TMOUT_set" | grep -Eo 'TMOUT=[0-9]+' | cut -d'=' -f2)

        # TMOUT_value가 숫자인지 확인
        if [[ "$TMOUT_value" =~ ^[0-9]+$ ]]; then
            if [[ "$TMOUT_value" -gt 600 ]]; then
                detail+=("취약")
                detail+=("Session Timeout 값을 600 이하로 설정하십시오.")
            else
                detail+=("양호")
                detail+=("-")
            fi
        else
            detail+=("취약")
            detail+=("Session Timeout 값이 잘못 설정되었습니다.")
        fi

        # if [[ "$TMOUT_value" -gt 600 ]]; then
        #     detail+=("취약")
        #     detail+=("Session Timeout 값을 600이하로 설정하십시오.")
        # else
        #     detail+=("양호")
        #     detail+=("-")
        # fi

# export TMOUT 가 작성되어 있는지
        detail+=("session timeout 적용 여부")
        TMOUT_export=$(cat /etc/profile | grep 'export TMOUT')
        if [[ "$TMOUT_export" == "" ]]; then
            detail+=("취약")
            detail+=("export TMOUT 명령어로 session timeout을 적용하세요.")
        else
            detail+=("양호")
            detail+=("-")
        fi
    fi

    if is_in_array "취약" "${detail[@]}"; then
        total_result="취약"
    fi

    result_print "U_54" "$desc" "$total_result" "${detail[@]}" #result $order
}

U_05()
{
    #변수 선언
    desc="root 홈, 패스 디렉터리 권한 및 패스 설정"
    detail=()
    total_result="양호"

    # root 검사
    detail+=("root")
    root_path=$PATH

    if [[ "$root_path" == *:*::* || "$root_path" == *:*.:* || "$root_path" == .* || "$root_path" == *:: ]]; then
        detail+=("취약")
        detail+=("환경변수 값에 . 또는 :: 포함 여부 확인")
    else
        detail+=("양호")
        detail+=("-")
    fi

    # 일반 사용자 검사
    for user_home in /home/*; do # 홈 디렉토리 기준으로 사용자를 검사하면 안되겠다. 삭제된 user 디렉토리가 남아 에러를 남긴다.
        if [[ -d "$user_home" ]]; then
            user=$(basename "$user_home")
            # 사용자의 PATH 변수 가져오기
            user_shell=$(grep "^${user}:" /etc/passwd | cut -d: -f7)

            # 만약 해당 사용자가 존재하지 않는다면 배열에 값 추가 하지 않는다.
            if [[ "$user_shell" != "" ]]; then
                detail+=("$user")
                if [[ -n "$user_shell" ]]; then
                    user_path=$(sudo -u "$user" "$user_shell" -c 'echo $PATH')

                    # PATH 변수에 . 또는 :: 가 포함되어 있는지 확인
                    if [[ "$user_path" == *:*::* || "$user_path" == *:*.:* || "$user_path" == .* || "$user_path" == *:: ]]; then
                        # 포함된 것을 인지
                        detail+=("취약")
                        detail+=("환경변수 값에 . 또는 :: 포함 여부 확인")
                    else
                        # 포함되지 않았다. 
                        detail+=("양호")
                        detail+=("-")
                    fi
                fi
            fi
        fi
    done

    # 최종 취약 여부 확인
    # local i=2
    # while [ $i -lt ${#detail[@]} ]; do
    #     if [[ $detail[$i] == "취약" ]]; then
    #         total_result="취약"
    #     fi
    #     # 인덱스를 세 개씩 증가시켜 다음 항목으로 이동
    #     i=$((i+3))
    # done
    if is_in_array "취약" "${detail[@]}"; then
        total_result="취약"
    fi

    # 함수 실행 예시
    result_print "U_05" "$desc" "$total_result" "${detail[@]}" #result $order
}

# 파일 및 디렉터리 소유자 설정
# 소유자가 존재하지 않는 파일과 동일한 UID로 설정을 바꾸게 되면 해당 파일의 소유권한을 갖게된다.
U_06()   
{
    desc="파일 및 디렉터리 소유자 설정"
    detail=()
    total_result="양호"

    find_nouser=($(find / -nouser 2>/dev/null)) # 소유자가 없는 파일 조사
    find_nogroup=($(find / -nogroup 2>/dev/null)) # 소유그룹이 없는 파일 조사

    # UID 검사
    detail+=("UID")
    if [ ${#find_nouser[@]} -eq 0 ]; then
        detail+=("양호")
        detail+=("-")
    else
        detail+=("취약")
        _UID_result=""
        _UIDs=()

        for user in "${find_nouser[@]}"; do
            _UID=$(ls -l "$user" | awk '{print $3}') # 찾은 파일의 _UID 값 임시 저장

            # 이미 저장한 _UID 값 저장하지 않는다.
            if ! is_in_array "$_UID" "${_UIDs[@]}"; then
                _UIDs+=("$_UID")
            fi
        done

        #결과값을 문자열로 저장
        for name in "${_UIDs[@]}"; do
            _UID_result+="$name/"
        done

        detail+=("$_UID_result, 사용자 점검")
    fi

    # GID 검사
    detail+=("GID")
    if [ ${#find_nogroup[@]} -eq 0 ]; then
        detail+=("양호")
        detail+=("-")

    else
        detail+=("취약")
        result=""
        _GIDs=()

        for group in "${find_nogroup[@]}"; do
            _GID=$(ls -l "$group" | awk '{print $4}') # 찾은 파일의 _GID 값 임시 저장

            # 이미 저장한 _GID 값 저장하지 않는다.
            if ! is_in_array "$_GID" "${_GIDs[@]}"; then
                _GIDs+=("$_GID")
            fi
        done

        #결과 값 저장
        for group in "${_GIDs[@]}"; do
            result+="$group/"
        done
        detail+=("$result, 그룹 번호 점검")
        # echo "$find_nogroup" | cut -d'/' -f3 | sort -u
    fi

    if is_in_array "취약" "${detail[@]}"; then
        total_result="취약"
    fi

    # 함수 실행 예시
    result_print "U_06" "$desc" "$total_result" "${detail[@]}"
}

U_07()
{
    desc="/etc/passwd 파일 소유자 및 권한 설정"
    detail=()
    total_result="양호"
    permission=($(ls -l /etc/passwd | awk '{print $1}'))
    owner=($(ls -l /etc/passwd | awk '{print $3}'))

    # echo "$permission" "$owner"
    # permission 값
    permission_value=($(get_permission_result "${permission}"))

    # echo "${permission_valu}"
    detail+=("Permission")
    # permission_value 값이 644 보다 크면?
    if ! [[ ${permission_value} -le 644 ]]; then
        detail+=("취약")
        detail+=("/etc/passwd 퍼미션 점검")
    else
        detail+=("양호")
        detail+=("-")
    fi

    detail+=("Owner")
    # owner 가 root가 아니면
    if [ ${owner} != "root" ]; then
        detail+=("취약")
        detail+=("/etc/passwd 소유자 점검")
    else
        detail+=("양호")
        detail+=("-")
    fi

    if is_in_array "취약" "${detail[@]}"; then
        total_result="취약"
    fi

    result_print "U_07" "$desc" "$total_result" "${detail[@]}"
}

U_08()
{
    desc="/etc/shadow 파일 소유자 및 권한 설정"
    detail=()
    total_result="양호"
    permission=($(ls -l /etc/shadow | awk '{print $1}'))
    owner=($(ls -l /etc/shadow | awk '{print $3}'))

    # echo "$permission" "$owner"
    # permission 값
    permission_value=($(get_permission_result "${permission}"))

    # echo "${permission_valu}"
    detail+=("Permission")
    # permission_value 값이 400 보다 크면?
    if ! [[ ${permission_value} -le 400 ]]; then
        detail+=("취약")
        detail+=("/etc/shadow 퍼미션 점검")
    else
        detail+=("양호")
        detail+=("-")
    fi

    detail+=("Owner")
    # owner 가 root가 아니면
    if [ ${owner} != "root" ]; then
        detail+=("취약")
        detail+=("/etc/shadow 소유자 점검")
    else
        detail+=("양호")
        detail+=("-")
    fi

    if is_in_array "취약" "${detail[@]}"; then
        total_result="취약"
    fi

    result_print "U_08" "$desc" "$total_result" "${detail[@]}"
}

server()
{
    os_ver=`grep . /etc/*rocky-release | perl -ane print`
    cur_time=`date`
    order=`who am i | awk '{print $1}'`
    echo "OS: $os_ver"
    echo "Current Time: $cur_time"
    printf "Order: $order"
    echo ", Inspector: t.Firewall"
}

if_root_User()
{
    if [[ $EUID -ne 0 ]]; then
        echo "You are not admin!!"
        exit 1
    fi
}

main()
{
    clear
    echo
    echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    echo 방화벽 팀 리눅스 시스템 점검 스크립트
    echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    echo
    ##초기 실행##########################
    if_root_User
    server
    ####################################
    echo
    echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    echo
    #####검사 함수 실행####################
    
    U_50; U_51; U_52; U_53; U_54; U_05; U_06; U_07; U_08 # 정재호
    
    U_09; U_10; U_11; U_12; U_13; U_14; U_15; U_17 # 장진영씨
    
    ######################################
    echo
    echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    echo
}

main