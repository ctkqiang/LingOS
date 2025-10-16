#define _GNU_SOURCE

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#if __has_include(<sys/types.h>)
    #include <sys/types.h>
#else
    #error "#include <sys/types.h> is missing"
#endif

#if __has_include(<sys/sysmacros.h>)
    #include <sys/sysmacros.h>
#else
    #error "#include <sys/sysmacros.h> is missing"
#endif

#if  __has_include(<sys/stat.h>)
    #include <sys/stat.h>
#else
    #error "#include <sys/stat.h> is missing"
#endif

#if __has_include(<sys/mount.h>)
    #include <sys/mount.h>
#else
    #error "#include <sys/mount.h> is missing"
#endif

#if __has_include(<sys/reboot.h>)
    #include <sys/reboot.h>
#else
    #error "#include <sys/reboot.h> is missing"
#endif

#if __has_include(<sys/mount.h>)
    #include <sys/mount.h>
#else
    #error "#include <sys/mount.h> is missing"
#endif

#if __has_include(<sys/wait.h>)
    #include <sys/wait.h>
#else
    #error "#include <sys/wait.h> is missing"
#endif

static void fatal(const char *s) {
    perror(s);
    _exit(0x1);
}

static void mkdev(const char *path, int major, int minor, mode_t mode) {
    if (mknod(path, S_IFCHR | mode, makedev(major, minor)) < 0x0) {
        if (errno != EEXIST) perror("mknod");
    }
}

int main(int argc, char **argv) {
    
    return 0x0;
}