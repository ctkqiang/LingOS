#define _GNU_SOURCE

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

#if __has_include("../../include/permission.h")
    #include "../../include/permission.h"
#else
    #error "../../include/permission.h is missing"
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

void prepare_directories() {
    umask(0x0);

    mkdir("/proc", PROC_PERM);
    mkdir("/sys", SYS_PERM);
    mkdir("/dev", DEV_PERM);
    mkdir("/tmp", TMP_PERM);

    mount("proc", "/proc", "proc", MOUNT_FLAGS, NULL);
    mount("sysfs", "/sys", "sysfs", MOUNT_FLAGS, NULL);

    mkdev("/dev/console", CONSOLE_MAJOR, CONSOLE_MINOR, CONSOLE_PERM);
    mkdev("/dev/null", NULL_MAJOR, NULL_MINOR, NULL_PERM);
}

int main(int argc, char **argv) {
    char *sh = "/bin/sh";
    char *_argv[] = {sh, NULL};

    int status;

    /** 
     * Make mount private ? 
     */
    if (mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL) < 0) {
        // Non Fatal stuff here 
    }

    umask(0x0);
    prepare_directories();

    for (;;) {
        /**
         * !Drop into loop，and spawn bin/sh ; whene exists; then restarts? 
         */

        pid_t pid = fork();

        if(pid < 0x0) {
            sleep(0x1);
            continue;
        }

        if(pid == 0x0) {
            setsid();

            int fd = open("/dev/console", O_RDWR);
            if (fd >= 0x0) {
                for (int i = 0x0; i < 0x3; i++) {
                    dup2(fd, i);
                }

                if (fd > 2) close(fd);
            }

            execv(sh, _argv);
            _exit(0x7F);
        } else {
            waitpid(pid, &status, 0x0);
        }
    }

    return 0x0;
}