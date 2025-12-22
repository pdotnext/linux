# File permissions (advance)

## SPEcial permissions in short

### 4775 SUID

4775 - special permission on file e.g. passwd
```shell
ls -l /usr/bin/passwd
```

```java
// output
-rwsr-xr-x 1 root root 80856 Jun 27 09:35 /usr/bin/passwd*
```

### 2775 SGID
It’s a bit of a security risk to set either the SUID or SGID permissions on files,
especially on executable files. But it is both completely safe and very useful to set SGID on a shared
directory.SGID behavior on a directory is completely different from SGID behavior on a file. 
On a directory, SGID will cause any files that anybody creates to be associated with the same group with which the
directory is associated

### 1775
1775 - special permission on folder, where person who creates file is the own e.g. /tmp directory

```shell
ls -ld /tmp/
```

```java
//output //
drwxrwxrwt 17 root root 380 Oct  6 15:35 /tmp/
```

## Find files with 4000 and 2000 permissions

```shell
# Note: we have escaped the round brackets
sudo find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null -ls
```

```output
 67126690     24 -rwxr-sr-x   1 root     tty         23968 Jan 16  2025 /usr/bin/write
 67109637     44 -rwx--s--x   1 root     slocate     41032 Aug 10  2021 /usr/bin/locate
 67180946     16 -rwx--s--x   1 root     utmp        16056 Aug 10  2021 /usr/libexec/utempter/utempter
134645481    336 -r-xr-sr-x   1 root     ssh_keys   341264 Jul 22 16:01 /usr/libexec/openssh/ssh-keysign
 67127019     72 -rwsr-xr-x   1 root     root        73704 Aug  5 14:22 /usr/bin/chage
 67127020     80 -rwsr-xr-x   1 root     root        78016 Aug  5 14:22 /usr/bin/gpasswd
 67127023     44 -rwsr-xr-x   1 root     root        41744 Aug  5 14:22 /usr/bin/newgrp
 67126681     56 -rwsr-xr-x   1 root     root        57112 Jan 16  2025 /usr/bin/su
 67546837     48 -rwsr-xr-x   1 root     root        48648 Jan 16  2025 /usr/bin/mount
 67546843     36 -rwsr-xr-x   1 root     root        36280 Jan 16  2025 /usr/bin/umount
 67135086     56 -rwsr-xr-x   1 root     root        57112 May 14  2025 /usr/bin/crontab
 67870256     32 -rwsr-xr-x   1 root     root        32648 Aug 10  2021 /usr/bin/passwd
 67871534    184 ---s--x--x   1 root     root       185304 Jun 30 12:25 /usr/bin/sudo
 67871156     32 -rwsr-xr-x   1 root     root        31928 Aug  7 12:16 /usr/bin/pkexec
134645345     16 -rwsr-xr-x   1 root     root        15448 Oct  8 09:55 /usr/sbin/grub2-set-bootflag
151110494     16 -rwsr-xr-x   1 root     root        15496 Aug  6 08:40 /usr/sbin/pam_timestamp_check
151110496     24 -rwsr-xr-x   1 root     root        23840 Aug  6 08:40 /usr/sbin/unix_chkpwd
134755014     44 -rws--x--x   1 root     root        44520 Jul  9 10:40 /usr/sbin/userhelper
151110457     20 -rwsr-xr-x   1 root     root        19728 Aug  7 12:16 /usr/lib/polkit-1/polkit-agent-helper-1
    96030    384 -rwsr-xr-x   1 root     root       390048 Oct 17 09:54 /opt/VBoxGuestAdditions-7.2.4/bin/VBoxDRMClient
```

We all know Sticky bit permissions and how to set. However, any user who owns the file can set SUID or SGID
It has its own security risks. Hence you can restrict this by mounting specific partition using nosuid flag as shown below.

```conf file /etc/fstab
UUID=4aa1c77b-4d3f-4156-9a5f-0688c2041a9c /secrets xfs nosuid 0 0
```

### Search all conf files and change their permission to 600

You can do this with find command. find command is inherintly recursive. You can restrict that using -depth flag

```shell
# do not execute this command, this is pure for demo purpose
# And every time you wild card search, always use quotes
find / -type f -iname '*.conf' -exec chmod 600 {} \;
```

Let me explain the section after -exec

- We are saying please execute chmod 600 on file which is represented by `{}`
- Every `-exec` clause must end with `;` semicolon but then we must escape it hence `\;`
- exec flag does not ask for confirmation, if you wish to have that option using `-ok` flag

## Setting ACL permissions (getfacl | setfacl)

When you set ACL permissions, permissions show up in the group section and denoted by + sign.

### User permissions

```shell
# first step is create a file
mkdir -pv /groupinfo
touch /groupinfo/readable_content.txt

# set facl
setfacl -m u:maggie:r /groupinfo/readable_content.txt

[maggie@encserver ~]$ ll /groupinfo/readable_content.txt
```
```java
// output //
-rw-r-----+ 1 zorro zorro 42 Dec 11 11:17 /groupinfo/readable_content.txt
```

```shell
getfacl /groupinfo/readable_content.txt
```

```java
// output //
# file: groupinfo/readable_content.txt
# owner: zorro
# group: zorro
user::rw-
user:maggie:r--
group::---
mask::r--
other::---
```

You can also give another user e.g. charlie rw permissions

```shell
setfacl -m u:charlie:rw /groupinfo/readable_content.txt
```
Check the permissions

```shell
getfacl /groupinfo/readable_content.txt
```

```java
// output //
# file: groupinfo/readable_content.txt
# owner: zorro
# group: zorro
user::rw-
user:charlie:rw-
user:maggie:r--
group::---
mask::rw-
other::---
```
With ls -l, you can see group permission is changed from r to rw

```shell
ls -l /groupinfo/readable_content.txt
```
```java
// output //
# -rw-rw----+ 1 zorro zorro 42 Dec 11 11:17 /groupinfo/readable_content.txt
```

### Group Permissions
You can also provide group, instead of users

```shell
# setfacl for a group, webadmins
setfacl -m g:webadmins:r /groupinfo/readable_content.txt
```

Do file listing, nothing has changed
```shell
ls -l /groupinfo/readable_content.txt
-rw-rw----+ 1 zorro zorro 42 Dec 11 11:17 /groupinfo/readable_content.txt
```

Check facl
```shell
getfacl /groupinfo/readable_content.txt
```

```java
// output //
# file: groupinfo/readable_content.txt
# owner: zorro
# group: zorro
user::rw-
user:charlie:rw-
user:maggie:r--
group::---
group:webadmins:r-- # <-- group is seen here
mask::rw-
other::---
```

### Enable permission inheritance
Here it more on directory creation and enabling permission inheritance inside the directory.
You need to just add `d:` flag before the user or group name.

```shell
setfacl -m d:u:charlie:r /groupinfo
```
Now when you create a file inside this directory, charlie will have read permission on all files and directories inside.

### Remove permissions

To remove the permission you have to use `-x` flag

```shell
# check the existing permissions
getfacl /groupinfo/readable_content.txt
```

```java
// here is the output //
getfacl: Removing leading '/' from absolute path names
# file: groupinfo/readable_content.txt
# owner: zorro
# group: zorro
user::rw-
user:charlie:rw-
user:maggie:r-- //<- we will remove maggie
group::---
group:webadmins:r--
mask::rw-
other::---
```

```shell
# lets remove maggie, -x removes all permissions
setfacl -x u:maggie /groupinfo/readable_content.txt
```

```shell
# check the new permissions
getfacl /groupinfo/readable_content.txt
```

```java
// here is the output //
getfacl: Removing leading '/' from absolute path names
# file: groupinfo/readable_content.txt
# owner: zorro
# group: zorro
user::rw-
user:charlie:rw-
group::---
group:webadmins:r--
mask::rw-
other::---
```

### Backup with acl
when you backup your data using tar, you must `--acl` otherwise all acl flags are lost.

```shell
# backup using --acl flag
tar -cJvf directoryName.tar.xz directoryName.tar --acl

# restore using --acl flag
tar -xJvf directoryName.tar.xz --directory='/locationWhereYouWishToRestore' --acl
```

## Reference
[Linux permissions: SUID, SGID, and sticky bit](https://www.redhat.com/en/blog/suid-sgid-sticky-bit)