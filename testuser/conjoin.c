/* conjoin.c - start processes joined by socketpair on fd 0 */

#if HAVE_CONFIG_H
#include "config.h"
#endif
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include "diod_log.h"

static void
usage (void)
{
    fprintf (stderr, "Usage: conjoin \"cmd1\" \"cmd2\"\n");
    exit (1);
}


int
main (int argc, char *argv[])
{
    int cs, s[2];
    char *cmd1, *cmd2;
    pid_t pid;

    if (argc != 3)
        usage ();
    cmd1 = argv[1];
    cmd2 = argv[2];

    diod_log_init (argv[0]);

    if (socketpair (AF_LOCAL, SOCK_STREAM, 0, s) < 0)
        err_exit ("socketpair");

    switch ((pid = fork ())) {
        case -1:
            err_exit ("fork");
            /*NOTREACHED*/
        case 0:     /* child (normally diod server) */
            close (s[0]);
            if (dup2 (s[1], 0) < 0)
                err_exit ("cmd2 dup2");
            if ((cs = system (cmd2)) == -1)
                err_exit ("cmd2 fork");
            if (!WIFEXITED (cs))
                msg_exit ("cmd2 terminated abnormally");
            if (WEXITSTATUS (cs) != 0)
                msg_exit ("cmd2 exited with rc=%d", WEXITSTATUS (cs));
            exit (0);
            /*NOTREACHED*/
        default:    /* parent (normally user space client) */
            close (s[1]);
            if (dup2 (s[0], 0) < 0) {
                err ("cmd1 dup2");
                break;
            }
            close (s[0]);
            if ((cs = system (cmd1)) == -1) {
                err ("cmd1 fork");
                break;
            }
            if (!WIFEXITED (cs)) {
                msg ("cmd1 terminated abnormally");
                break;
            }
            if (WEXITSTATUS (cs) != 0)
                msg ("cmd1 exited with rc=%d", WEXITSTATUS (cs));
            break;
    }

    /* reap child */
    close (0);
    if (waitpid (pid, &cs, 0) < 0)
        err_exit ("waitpid");
    exit (0);
}

/*
 * vi:tabstop=4 shiftwidth=4 expandtab
 */