# How to create a shared directory

There are multiple way but this one is based on SUID and SGID I learned in filepermissions.md

Ensure you have group created
Ensure you have users added to the group.
I have used create_users.sh script which is based on bash.

Step: 01 - create directory

Step: 02 - assign permissions to the directory so that only owner can create and delete his file. And all files belong to the group

```shell

# create a directory
set -gx GRPNAME dreamteam
set -gx SHAREDDIR opengroup

sudo mkdir -pv /$SHAREDDIR

# change the ownership
sudo chown -v nobody:$GRPNAME /$SHAREDDIR

# check the permissions for others
ls -ld /$SHAREDDIR
stat -c %a /$SHAREDDIR

# assign sticky bit permissions
sudo chmod -v 3775 /$SHAREDDIR

# check the permissions again.
ls -ld /$SHARDIR
stat -c %a /$SHAREDDIR

# check if it is working as expected
su -jose
touch /$SHAREDDIR/jose_info.txt
