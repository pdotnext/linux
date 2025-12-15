# Access control via firewalld

In the older world (or non RHEL world) it is referred as whitlisting using TCP Wrappers.
By default ssh is exposed on public zone and public zone is default on RHEL Firewall.

```shell
## Step:01 Remove service from the public zone of the firewall
sudo firewall-cmd --remove-service ssh --zone public

## Step:02 Create a new zone e.g. serverzone
sudo firewall-cmd --new-zone=serverzone --permanent # Note : Permanent flag is must here.

## Step:03 add ssh service to the serverzone
sudo firewall-cmd --reload # Note: Firewall must be reloaded
sudo firewall-cmd --add-service ssh --zone serverzone
sudo firewall-cmd --add-source <ServerZoneIPSubnet> # e.g. 10.10.25.0/24

## Step:04 when testing is complete, do not forget
sudo firewall-cmd --runtime-to-permanent

## Step:04 Finally check all is configured as intended
sudo firewall-cmd --info-zone serverzone
```
```output
##############OUTPUT#################
# serverzone (active)               #
#   target: default                 #
#   icmp-block-inversion: no        #
#   interfaces:                     #
#   sources: 10.81.1.0/24           #
#   services: ssh                   #
#   ports:                          #
#   protocols:                      #
#   forward: no                     #
#   masquerade: no                  #
#   forward-ports:                  #
#   source-ports:                   #
#   icmp-blocks:                    #
#   rich rules                      #
##############OUTPUT#################
```