import base64

def multi_base64_encode(input_string, times=20):
    encoded = input_string.encode()
    for _ in range(times):
        encoded = base64.b64encode(encoded)
    return encoded.decode()

def replace_special_characters(encoded_string):
    replacements = {
        "1": "!",
        "2": "@",
        "3": "$",
        "4": "^",
        "5": "&",
        "6": "*",
        "7": "(",
        "8": ")"
    }
    for key, value in replacements.items():
        encoded_string = encoded_string.replace(key, value)
    return encoded_string

# 입력 받기
input_string = input()

# 20번 base64 인코딩하기
result = multi_base64_encode(input_string)

# 특수문자로 치환하기
result = replace_special_characters(result)

# 결과 출력
print("20번 인코딩된 결과:")
print(result)
