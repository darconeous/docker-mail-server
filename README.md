Based on <https://github.com/lava/dockermail> and <https://github.com/adaline/dockermail>.

Neither quite behaved like I wanted them to, so I started work on this version.

Usernames and passwords go in `/etc/mail-config/passwd`. To generate the passwd string, use:

    doveadm pw -s SHA256-CRYPT


