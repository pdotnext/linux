# Configure whitelists within sshd_config

In the sshd_config file, the following options are available.
They are mentioned in the oder of precedence

- DenyUsers
- AllowUsers
- DenyGroups
- AllowGroups

```shell
#!/bin/fish
# Step:01 create a group, if it is not already created
set -gx groupname webadmins # <- Set the variable
sudo groupadd $groupname

# use for loop to create users
for i in {harry,matter,sonie};
    sudo useradd -G $groupname $i;
end
# set the expiring password for the users
set -gx userpass BMW#2025 # <- set the variable
for i in {harry,matter,sonie};
    echo $i:$userpass | sudo chpasswd;
    sudo passwd --expire $i;
end
```

Inside the sshd_config file at the end add `AllowGroups` as mentioned below.

```shell
sudo cp -v /etc/ssh/sshd_config{,_$(date +%F)} # <- make a copy before changing ->
echo "AllowGroups webadmins" | sudo tee /etc/ssh/sshd_config
# restart sshd service
sudo systemctl restart sshd.service
sudo systemclt status sshd.service
```

>Note: Tested on RHEL9