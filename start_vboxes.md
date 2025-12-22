# Start vboxes

A simple script to start vagrant boxes

```shell
#!/usr/bin/fish
# Start the vagrant box using the name as input
# set the variable
set -gx boxname $(read -U -P 'enter the box name: ')
echo "I will start $boxname"
cd /$HOME/vboxes/$boxname
# Check if the vagrant up command is working.
vagrant up 2>/dev/null
if test $status -ne 0
       echo "Vagrant is not working, let me restart it"
       sudo bash /root/vboxmodules.sh
 end
 vagrant up
```