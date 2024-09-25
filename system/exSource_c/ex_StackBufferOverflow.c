# include <stdio.h>

int main(int argc, char* argv[])
{
    char cBuf[0x100] = {0, };   // 버퍼 역할을 할 배열 할당(인덱스 값 8)

    printf("Input: ");
    gets(cBuf);                  // BOF Attack에 취약한 함수 사용

    return 0;
}