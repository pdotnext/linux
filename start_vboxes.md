# Start vboxes

A simple script to start vagrant boxes

```shell
#!/usr/bin/bash
# Start the vagrant box using the name as input
# set the variable
set -gx boxname $(read -U -P 'enter the box name: ')
echo $boxname
cd /$HOME/vboxes/$boxname
pwd
# Check if the vagrant up command is working.
vagrant up 2>/dev/null

if test $status -ne 0
       sudo bash /root/vboxmodules.sh
 end
 vagrant up
```