# SSH Hardening

## Disable Root login
By default in RHEL it is prohibit-password, </br>
which means you cannot login using password.

```shell
#PermitRootLogin prohibit-password <--this is default
PermitRootLogin no
```

## Disable SSH Protocol 1

Well all modern system had it disabled but i was wondering </br>
how to find which protocol is currently running

```shell
╰─>$ nc -v 192.168.56.92 22
```

```java
// -- output --
Ncat: Version 7.92 ( https://nmap.org/ncat )
Ncat: Connected to 192.168.56.92:22.
SSH-2.0-OpenSSH_8.7  // <-- We are interested in this //
```

Any changes in sshd_config file must be </br>
followed by sshd.service restart
```shell
sudo systemctl restart sshd.service
sudo systemctl status sshd.service | grep active
```

## Disable password based login
```shell
grep PasswordAuthentication /etc/ssh/sshd_config
sudo cp -v /etc/ssh/sshd_config{,_$(date +%F-%H%M)}
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
grep PasswordAuthentication /etc/ssh/sshd_config
sudo systemctl restart sshd.service
sudo systemctl status sshd.service | grep active
```
## How to configure session timeouts

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

## Creating Login and Pre-login banner

### Login Banner
This is simple and you can easily achieved by creating `.motd` file inside /etc/motd.d/49-nameofthefile.motd

```shell
echo "This system belongs to PDTN,INC" | sudo tee /etc/motd.d/49-postlogin.motd
```

### Pre-login Banner
This is bit involved. Pre-login banner is a message you get before you enter your credentials

```shell
# create a pre-login message and save it
echo "Unless you are authorized, do not login here" | sudo tee /etc/ssh/sshd-banner

# create backup copy of sshd, below makes sense only when you modifying this file once in day
sudo cp -v /etc/ssh/sshd_config{,_$(date +%F)}

# Update the Banner location in sshd_config file
sudo sed -i "s/#Banner none/Banner \/etc\/ssh\/sshd-banner/g" /etc/ssh/sshd_config

# Check if the file is updated
sudo grep Banner /etc/ssh/sshd_config

# Note: Everytime you modify sshd_config file,
# you MUST either reload or restart sshd service
sudo systemctl reload-or-restart sshd.service
```

## Other security measures

- Ensure `X11Forwarding` is disabled. Default is no
- Disable ssh tunnel, ensure the following values are set to no in sshd_config
```shell
    AllowTcpForwarding no # ( Default is yes)
    #GatewayPorts no (# Default is no)
    #PermitTunnel no (# Default is no)
    AllowStreamLocalForwarding no # (This value was not present in RHEL9 sshd_config file)
```

**Note: When to use AllowStreamLocalForwarding?** </br>

For instance, if you have a database application that uses Unix domain sockets and </br> you want to allow a remote user to connect to it securely over SSH, </br> you would enable AllowStreamLocalForwarding for that user.

## Reference
- [How to apply TMOUT for all users except for only one in RHEL](https://access.redhat.com/solutions/4134801)
- [How to set the session timeout in systemd-logind](https://access.redhat.com/solutions/7037840)