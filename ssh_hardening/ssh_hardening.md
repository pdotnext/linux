# How to configure session timeouts

When you user is idle e.g. one 5 minutes his SSH (or console session) should automatically timeout.</br>
But this works only when you mention the bash shell (as far I have expiremented) </br>
Create a file inside `/etc/profile.d/autologin.sh`
You do not have to make this file executable.

```shell
#!/bin/bash
if [ $EUID -eq $(id -u charlie) ]; then
    TMOUT=0
    export TMOUT
else
    TMOUT=600 # 5 minutes
    # it is important because \
    # then no one can override this value
    readonly TMOUT
    export TMOUT
```
## In case you wish to automate this.
```shell
printf %s\n "
#!/bin/bash
# if [ \$EUID = \$(id -u charlie) ]; then
    TMOUT=0
    readonly TMOUT
    export TMOUT
else
    TMOUT=600 # 5 minutes
    # it is important because \
    # then no one can override this value
    readonly TMOUT
    export TMOUT" | sudo tee /etc/profile.d/autologout.sh
```


If you login with userid other than charlie (e.g. maggie)
```output
╰─>$ ssh maggie@encserver
maggie@192.168.56.90's password:
#### omitted ####
timed out waiting for input: auto-logout
Connection to 192.168.56.90 closed.
```

## Using SSHD parameters for timeouts

sshd_config file offers two parameters

- ClientAliveInterval
- ClientAliveCountMax

```shell
# check
╰─>$ sudo grep -i Client /etc/ssh/sshd_config
#ClientAliveInterval 0
#ClientAliveCountMax 3

# Make a copy
sudo cp -v /etc/ssh/sshd_config{,_$(date +%F)}

# Replace the values

ClientAliveInterval 60 # seconds
ClientAliveCountMax 3 # 3 x 60 = 180, ssh session will timeout

sudo sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 60/g' /etc/ssh/sshd_config
sudo sed -i 's/#ClientAliveInterval 0/ClientAliveCountMax 3/g' /etc/ssh/sshd_config

sudo systemctl restart sshd.service

```
### RHEL9 and above

RHEL stopped using ClientAliveInterval instead there is `StopIdleSessionSec` which is by default set to infinity.
Change this value to your choice.

```shell
# step:01 Backup the file
sudo cp -v /etc/systemd/logind.conf{,_$(date +%F)}
# search and change the value
sudo sed -i 's/#StopIdleSessionSec=infinity/StopIdleSessionSec=600/g'  /etc/systemd/logind.conf
# Check the results
sudo grep StopIdleSessionSec /etc/systemd/logind.conf
# Restart the service
sudo systemctl restart systemd-logind.service
# check the status
sudo systemctl status systemd-logind.service | head -n 5

```

## Reference
- [How to apply TMOUT for all users except for only one in RHEL](https://access.redhat.com/solutions/4134801)
- [How to set the session timeout in systemd-logind](https://access.redhat.com/solutions/7037840)