#include <syslog.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/stat.h>

// mkdir -p helper
static int mkdir_p(const char *path)
{
    if (!path || path[0] == '\0') return 0;

    char *tmp = strdup(path);
    if (!tmp) return -1;

    // Walk path and mkdir each component
    for (char *p = tmp + 1; *p; p++) {
        if (*p == '/') {
            *p = '\0';
            if (mkdir(tmp, 0755) == -1 && errno != EEXIST) {
                free(tmp);
                return -1;
            }
            *p = '/';
        }
    }
    if (mkdir(tmp, 0755) == -1 && errno != EEXIST) {
        free(tmp);
        return -1;
    }
    free(tmp);
    return 0;
}

static int ensure_parent_dir(const char *filepath)
{
    // Find last '/'
    const char *slash = strrchr(filepath, '/');
    if (!slash) return 0;              // no directory part
    if (slash == filepath) return 0;   // parent is "/"

    size_t len = (size_t)(slash - filepath);
    char *dir = (char *)malloc(len + 1);
    if (!dir) return -1;

    memcpy(dir, filepath, len);
    dir[len] = '\0';

    int rc = mkdir_p(dir);
    free(dir);
    return rc;
}

int main(int argc, char *argv[])
{
    openlog("writer", LOG_PID, LOG_USER);

    if (argc != 3) {
        syslog(LOG_ERR, "Invalid arguments. Usage: writer <writefile> <writestr>");
        closelog();
        return 1;
    }

    const char *writefile = argv[1];
    const char *writestr  = argv[2];

    if (ensure_parent_dir(writefile) != 0) {
        syslog(LOG_ERR, "Failed to create parent directory for %s: %s", writefile, strerror(errno));
        closelog();
        return 1;
    }

    int fd = open(writefile, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) {
        syslog(LOG_ERR, "Failed to open %s: %s", writefile, strerror(errno));
        closelog();
        return 1;
    }

    syslog(LOG_DEBUG, "Writing '%s' to '%s'", writestr, writefile);

    size_t len = strlen(writestr);
    const char *buf = writestr;
    while (len > 0) {
        ssize_t w = write(fd, buf, len);
        if (w < 0) {
            syslog(LOG_ERR, "Write failed for %s: %s", writefile, strerror(errno));
            close(fd);
            closelog();
            return 1;
        }
        buf += (size_t)w;
        len -= (size_t)w;
    }

    close(fd);
    closelog();
    return 0;
}
