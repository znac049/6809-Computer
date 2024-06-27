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
    say("Hej!\n");
    return 0;
}