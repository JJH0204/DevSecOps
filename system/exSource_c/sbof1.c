#include <stdio.h>
#include <string.h>
#include <unistd.h>


int main(int argc, char* argv[])
{
    char secret[16] = "secret message";
    char barrier[4] = {};
    char name[8] = {};
    memset(barrier, 0, 4);
    printf("Your Name: ");
    read(0, name, 12);
    printf("Your Name is %s\n", name);

    return 0;
}