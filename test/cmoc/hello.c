#include <cmoc.h>

void say(const char *msg)
{
    while (*msg) {
        putchar(*msg);
        msg++;
    }
}

int main()
{
    return 0;
}