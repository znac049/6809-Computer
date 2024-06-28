#include <cmoc.h>

int x=0;

void say(const char *msg)
{
    while (*msg) {
        putchar(*msg);
        msg++;
    }
}

int main()
{
    int x=7;

    say("Hej!\r\n");
    printf("x=%d\r\n", x);
    return 42;;
}