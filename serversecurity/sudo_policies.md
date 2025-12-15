# Sudo Examples

Use Case: 01 grant a DB Administrators (dbadmins) to run psql query only

```shell
sudo vim /etc/sudoers.d/dbadmins
# here are the contents of file
%dbadmins ALL=(postgres) /usr/bin/psql
```

postgres is the user which users in dbadmins group can do sudo

Use Case: Give user permission to only manage (web service) httpd service using wrappers

```shell
sudo vim /etc/sudoers.d/webadmins
# here are the contents of the file
%webadmins ALL=(root) /usr/local/bin/httpd_start.sh, /usr/local/bin/httpd_stop.sh, /usr/local/bin/httpd_restart.sh

```

The contents of httpd_start.sh

```shell
# create a file httpd_start.sh
# its contents will be
#!/bin/bash
/usr/bin/systemctl start httpd.service
```
change the permission and ownership to root

```shell
sudo chown root: /usr/local/bin/httpd_start.sh
sudo chmod 0600 /usr/local/bin/httpd_start.sh
```


