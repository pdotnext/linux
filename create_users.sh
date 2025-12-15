    #!/bin/fish
    # Step:01 create a group, if it is not already created
    set -gx groupname dreamteam # <- Set the variable
    sudo groupadd $groupname

    # use for loop to create users
    for i in {aaron,jose,walter};
        sudo useradd -G $groupname $i;
    end
    # set the expiring password for the users
    set -gx userpass BMW#2025 # <- set the variable
    for i in {aaron,jose,walter};
        echo $i:$userpass | sudo chpasswd;
        sudo passwd --expire $i;
    end