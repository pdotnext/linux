# Installing and configuring Rootkit hunters

lets install rootkit hunter program called Rootkit hunter (rkh) . </br>
But the best defence against rootkit is to see that </br>
they do not find any way or loophole to get installed on linux os.


```shell

# check the info

sudo dnf info rkhunter

# install 

sudo dnf install rkhunter

# update

sudo rkhunter --update

```

## Scanning with rkhunter


```shell
# Most basic way it to run without any flag except c
# --- [explaination]
# -c stands for check, which perform actual system checks
rkhunter -c

# Little advance method is which only provides warning
# --- [explaination]
# --rwo Report Warning Only, 
rkhunter -c --rwo

# And another one is to run it as cronjob
# --- [explaination]
# --cronjob disables interactive prompts
rkhunter -c --rwo --cronjob

# --- [output] ---

# Warning: Checking for prerequisites               [ Warning ]
#         The file of stored file properties (rkhunter.dat) does not exist, and should be created. To do this type in 'rkhunter --propupd'.
# Warning: WARNING! It is the users responsibility to ensure that when the '--propupd' option
#         is used, all the files on their system are known to be genuine, and installed from a
#         reliable source. The rkhunter '--check' option will compare the current file properties
#         against previously stored values, and report if any values differ. However, rkhunter
#         cannot determine what has caused the change, that is for the user to do.
# Warning: The command '/usr/bin/egrep' has been replaced by a script: /usr/bin/egrep: a /usr/bin/sh script, ASCII text executable
# Warning: The command '/usr/bin/fgrep' has been replaced by a script: /usr/bin/fgrep: a /usr/bin/sh script, ASCII text executable
# Warning: The SSH and rkhunter configuration options should be the same:
#         SSH configuration option 'PermitRootLogin': yes
#         Rkhunter configuration option 'ALLOW_SSH_ROOT_USER': unset
```


```shell
# Most suitable, practical is to create cronjob to run at specific time
sudo crontab -e -u root

# Add the following text
30 22 * * * /usr/bin/khunter -c --rwo --cronjob >/var/log/rkhunter/cronjob_log_$(date +%F-%H%M).log
```

