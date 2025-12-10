# Configure chroot environment for SFTP Users

```shell
# create a group
sudo groupadd sftpusers

# create user
set -gx USERID hryx501
set -gx PASSWD SAP#2026
sudo useradd -G sftpusers -c "SFTP User" $USERID
echo $USERID:$PASSWD | sudo chpasswd
sudo passwd --expire $USERID
# backup sshd_config file
sudo cp -v /etc/ssh/sshd_config{,_$(date +%F-%H%M)}

# replace /usr/libexec/openssh/sftp-server with internal-sftp
sudo sed -i 's/\/usr\/libexec\/openssh\/sftp-server/internal-sftp/g' /etc/ssh/sshd_config
sudo grep internal-sftp /etc/ssh/sshd_config
printf "%s\n
Match Group sftpusers
    ChrootDirectory /vcfbackup
    AllowTCPForwarding no
    AllowAgentForwarding no
    X11Forwarding no
    ForceCommand internal-sftp
" | sudo tee --append /etc/ssh/sshd_config

```

### Create a directory with full permission for sftpusers

For chroot `/vcfbackup` directory must be own by root.
Otherwise it won't allow sftpusers to login.

```shell
sudo -pv /vcfbackup/site-muc/

# change the ownership of ONLY site-muc folder
sudo chown -Rv hryx501:sftpuser /vcfbackup/site-muc/

# Check the ownership
sudo ls -ld /vcfbackup # <-- must be own by root
sudo ls -ld /vcfbackup/site-muc/ # <- check if the ownership is reflected

# Give full permission to user and group and remove permissions for others
sudo chmod -Rv ug=rwX,o-rwx /vcfbackup/site-muc/
# Note: Capital X refers to execute permission only for the directories
```

## Summary
The contents of the file `/etc/ssh/sshd_config`

```shell
subsystem sftp internal-sftp
Match Group sftpusers
    ChrootDirectory /vcfbackup
    AllowTCPForwarding no
    AllowAgentForwarding no
    X11Forwarding no
    ForceCommand internal-sftp
```
`Subsystem sftp internal-sftp` in the above snippet `sshd_config` file, </br> tells the SSH server to use its built-in SFTP server for handling SFTP connections, </br>  rather than an external SFTP server daemon.

The brief explanation of the terms
- **Subsystem**: This allows you to specify a subsystem to handle specific types of connections.
- **sftp**: This is the name of the subsystem for SFTP.
- **internal-sftp**: This specifies that the internal SFTP server provided by OpenSSH should be used to handle SFTP connections.

Using the internal SFTP server has several advantages:

- **Simplicity**: It eliminates the need to install and manage a separate SFTP server daemon.
- **Security**: Since it's part of the SSH server, it benefits from the same security features and updates.
- **Configuration**: It's straightforward to configure and manage within the existing SSH server settings.

`ForceCommand` in the sshd_config file allows you to specify a command that will be executed automatically when a client connects to the SSH server.

