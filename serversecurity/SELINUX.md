[[2025-10-26]] [[Security]]

SELINUX stands for the Security Enhanced Linux (SELINUX)
selinux needs three things
- selinux enabled kernel
- selinux userspace tool
- selinux policies

### But how do you know your kernel is complied with +SELINUX?

```shell
systemctl --version | grep +SELINUX
## --- output ---
# +PAM +AUDIT +SELINUX -APPARMOR +IMA +SMACK +SECCOMP +GCRYPT 
# +GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2
# -IDN -IPTC +KMOD +LIBCRYPTSETUP +LIBFDISK +PCRE2 -PWQUALITY 
# +P11KIT -QRENCODE +TPM2 +BZIP2 +LZ4 +XZ +ZLIB +ZSTD 
# -BPF_FRAMEWORK +XKBCOMMON +UTMP +SYSVINIT default-hierarchy=unified
```
### What is DAC and MAC ?
DAC stands for discretionary access control (DAC) and primary focuses on who is allowed to do what but it does not define how a file is used e.g. you do not want web directory to be used for purpose other than web hosting.
MAC stands for mandatory access control and defines the policies who is allowed to access which directory and for what purpose.

### selinux file context

selinux file context are defined on

- ports
- process
- files and directories

The database of this file context is maintained in `/etc/selinux/targeted/contexts/files` and it is text based database.



### Check the status of selinux

```shell
➤ sudo sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux # pseudo fs like /dev /proc,
									# selinux is mounted here which contains
									# runtime information about selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing # <- represents the current mode.
Mode from config file:          enforcing # <- represents the mode
											# under which system was booted.
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      35

# or there is another way to check selinux status
sudo getenforce

# another way
cat /sys/fs/selinux/enforce
```
#### Main configuration file
The main configuration file is stored in `/etc/selinux/config`

```shell
➤ grep ^[^#] /etc/selinux/config
SELINUX=enforcing
SELINUXTYPE=targeted

# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.

# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy.
#               Only selected processes are protected.
#     mls - Multi Level Security protection.
```

To put selinux in permissive mode, use the following commands.</br>
Remember how important it is to restrict sudo role to all.</br>
Because with this privilege, you can disable SELINUX during runtime.

```shell
sudo setenforce 1 # to enable
sudo setenforce 0 # to disable
```

### What is targeted policy?
Application developer define what actions are allowed on specific configuration and data file, binary file, port or resources. These policies are already defined for us and we do not have much work here to do.

#### Then what is confined and unconfined?
Applications which are running under targeted policy are considered confined and govern by the policy and therefore protected by selinux. In contrast, applications which do not have any policy defined are called unconfined and not protected by selinux.
#### selinux policies
selinux policies define how specific process accesses relevant files, directory and ports.</br>
Each resource entity (e.g. file, port, directory or process) has a label,</br> which is referred selinux context label.

```shell
ls -lZ $HOME/Documents/fonts.md
unconfined_u:object_r:user_home_t:s0
# For the file fonts.md we have the following selinux policy applied
	# unconfined_u: refers to selinux user
	# object_r: refers to role
	# user_home_t: refers to type
	# s0: refers to security level, 0 refers to lowest
		# possible security level.
```

If you have Apache installed, the `/var/www/html` has context type of `httpd_sys_context_t`  and similarly, for the temp directory it is `tmp_t` as shown below. Apache can access only directories which has the context `httpd_sys_context_t` defined, otherwise access is denied. In this case, web server is compromised and user tries to access file in different directory it won't be possible because selinux by default denies access.

```shell
➤ ls -ldZ /tmp
system_u:object_r:tmp_t:s0
```


```shell
ps -ZC dockerd
LABEL                               PID TTY          TIME CMD
system_u:system_r:container_runtime_t:s0 2323 ?  00:00:01 dockerd
# --- output ---
ps -ZC httpd
# --- output ---
# LABEL                               PID TTY          TIME CMD
# system_u:system_r:httpd_t:s0       1751 ?        00:00:00 httpd
# system_u:system_r:httpd_t:s0       1752 ?        00:00:00 httpd
# system_u:system_r:httpd_t:s0       1753 ?        00:00:00 httpd
# system_u:system_r:httpd_t:s0       1754 ?        00:00:00 httpd
# system_u:system_r:httpd_t:s0       1755 ?        00:00:00 httpd

ls -lZ /var/www/
total 0
system_u:object_r:httpd_sys_script_exec_t:s0 6 Jul 28 16:28 cgi-bin
system_u:object_r:httpd_sys_content_t:s0     6 Jul 28 16:28 html
```

#### Copy or Move
When you copy the file within the same file system, then file context is inherited from the destination to which it is copied and when you move the file, the file context of original file is moved. In other words, copy is safe but move can be cause problems.

```shell
sudo cp myindex.html /var/www/html/
ls -lZ /var/www/html/

### --- output ---
# unconfined_u:object_r:httpd_sys_content_t:s0 myindex.html

# When you move the file, the original label moves with it.
sudo mv myindex.html /var/www/html/

# lets check the output.
ls -lZ /var/www/html/

### --- output ---
# unconfined_u:object_r:user_home_t:s0 0 Oct 27 08:34 myindex.html
```

With `cp -p` or `cp --preserve=context` you can retain the original file context or with move i.e. `mv -Z` you can change the original file context i.e. it is same behavior as `cp`

#### chcon, Restorecon and fcontext
chcon is temporary method to change the context of the file. Only recommended for troubleshooting purposes. Here is an example

```shell
sudo touch /virtual/index.html

# --- Check the result
ls -lZ /virtual/
### --- output ---
# unconfined_u:object_r:default_t:s0 index.html
# Here the default context default_t is inheireted
# Now lets change the context using chcon

sudo chcon --recursive --type=httpd_sys_content_t /virtual
# --- Check the result
ls -lZ /virtual
### --- output ---
# unconfined_u:object_r:httpd_sys_content_t:s0 0 Oct 27 08:50 index.html

# Now see what happens with restorecon
sudo restorecon -vRF /virtual
### --- output ---
Relabeled /virtual from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:default_t:s0

### --- output ---

ls -lZ /virtual
unconfined_u:object_r:default_t:s0 0 Oct 27 08:50 index.html

# ~ restorecon has restore the context, because
# with chcon you must use a flag -p for permanent.
```

Another best flag in chcon is --reference
```shell
sudo chcon --reference anotherindex.html index.html
```

### Recommended steps to apply selinux context is

1. Check if directory has right label, this can be checked using `semanage fcontext -l | grep www` and then apply the right label using the following command

```shell
sudo semanage fcontext --add --type httpd_sys_content_t '/virtual(/.*)?'
#
# ~ The regular expression is needed because there no recursive
# option in this command.
# Always remember there is NO forward slash before this regex begins
# Once the label is applied, using restorecon to apply the label.


sudo restorecon -RFvv /virtual/

# Finally check if the changes are in effect.

sudo semanage fcontext --list --locallist

#
# --- output ---
# SELinux fcontext   type               Context
# /virtual(/.*)?     all files          system_u:object_r:httpd_sys_content_t:s0

# And now check the label

ls -lZ /virtual/

#
# --- output ---
# system_u:object_r:httpd_sys_content_t:s0 Oct 27 08:50 index.html
```

### Prerequisites

Before you start, please install the following tools

```shell
sudo dnf install setools policycoreutils policycoreutils-python-utils setroubleshoot selinux-policy-doc
sudo service auditd restart # <- This is the only way to restart auditd service while systemctl it fails
sudo mandb
```

`seinfo` and man pages for application specific

## SEBOOLEAN

Application developer can enable or disable specific function using boolean. </br> e.g. you can enable user's `homedir` to be browseable using `seboolean`

### Main commands

1. `getsebool -a`  This the only flag available with the command and </br>
its purpose it to list more than one boolean.
2. `semanage boolean -l`

```shell
getsebool -a | grep httpd_enable_

#
# --- output ---
# httpd_enable_cgi --> on <- This should be turned off
# httpd_enable_ftp_server --> off
# httpd_enable_homedirs --> off

# In case you know the name of the settings
sudo getsebool httpd_enable_cgi

#################
# --- output ---
# httpd_enable_cgi --> on

# One can get same output as above using setsebool
sudo semanage boolean -l | grep httpd_enable_

#################
# --- output ---
# httpd_enable_cgi               (on   ,   on)  Allow httpd to enable cgi
# httpd_enable_ftp_server        (off  ,  off)  Allow httpd to enable ftp server
# httpd_enable_homedirs          (off  ,  off)  Allow httpd to enable homedirs
```

> In front of `httpd_enable_cgi`, there are two `on`, which means the runtime and booted value for `httpd_enable_cgi` is same.

You can change the boolean value using setsebool or semanage boolean.
```shell
# enable
sudo semanage boolean --modify httpd_enable_homedirs --on
# list
sudo semanage boolean --list | grep httpd_enable_homedirs

#################
# --- output ---
# httpd_enable_homedirs          (on   ,   on)  Allow httpd to enable homedirs
```
 The reason i prefer `semanage boolean` in comparison with `setsebool` is, in `setsebool` </br> we have to use `-P` for permanent changes.

### SEBOOLEAN and httpd

By default `httpd_unified` is turned off but it might be needed for </br>
application which needs read and execute permissions on web content. </br>
When it is turned on, then the following context is also enabled.

```shell
httpd_sys_content_t # read only web content
httpd_sys_rw_content_t # writable web content
httpd_sys_script_exec_t # Script execution esp. PHP, CGI
```

`httpd_can_sendmail` is default off but might be needed to turn off when web application needs to send email.

## SEMANAGE port - protecting network ports

semanage port provides the method for protecting ports. </br>
In case, you wish to find out on which port `httpd` service is allowed, you can use `--list`flag

```shell

sudo semanage port --list | grep http
#################
# --- output ---
# http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
```

So if you change the port in the list mentioned above, httpd service will start but if you change to something e.g 82 it won't work. Lets say you wish to add different port, then you must changes in httpd.conf file and update semanage

```shell
sudo semanage port --add --type http_port_t --proto tcp 82

# check if all is there as expected
sudo semanage port --list | grep ^http_port_t

#
#################
# --- output ---
# http_port_t                tcp      82, 80, 81, 443, 488, 8008, 8009, 8443, 9000
```

Rolling back the change
```shell
sudo semanage port --delete --type http_port_t --proto tcp 82
# -- check if the change was properly implemented
sudo semanage port --list | grep ^http_port_t

#
#################
# --- output ---
# http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
```

## Troubleshooting

Tools at hands are

- `ausearch`
- `/var/log/messages` when `auditd` is not installed
- `/var/log/audit/audit.log`

```shell

ausearch -m avc --start recent -i

```