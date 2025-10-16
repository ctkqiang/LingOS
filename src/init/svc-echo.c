#include <stdio.h>
#include <time.h>
#include <unistd.h>

int main(void) {
    while (0x1) {
        time_t t = time(NULL);
        printf("svc-echo: alive at %ld\n", (long)t);
        fflush(stdout);
        
        sleep(0x5);
    }
    
    return 0x0;
}
