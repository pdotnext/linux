# Security Linux (SELinux)

## When to set SELinux in permissive mode?

When you are unable to see any logs in the `/var/log/messages or /var/log/audit/audit.log` then your only choice </br>
is to set the selinux in permissive mode. When multiple selinux problems are encountered, it may happen </br>
no logs are seen in the respective log location.

### What happens in permissive mode?
In permissive mode, even though you service or your task work through, but it logs the message.
And this message description helps you to find where exactly the problem is.

## Where to see the logs?

First place is always in the messages. Search for sealert.

```shell
sudo grep sealert -A 3 /var/log/messages
```

```log
Dec 15 17:18:11 encserver setroubleshoot[6730]: SELinux is preventing /usr/sbin/httpd from read access on the file /var/www/html/index.html. For complete SELinux messages run: sealert -l 525882cd-e7e3-4d97-97ac-df968a100586
Dec 15 17:18:11 encserver setroubleshoot[6730]: SELinux is preventing /usr/sbin/httpd from read access on the file /var/www/html/index.html.#012#012*****  Plugin catchall_boolean (89.3 confidence) suggests   ******************#012#012If you want to allow httpd to read user content#012Then you must tell SELinux about this by enabling the 'httpd_read_user_content' boolean.#012#012Do#012setsebool -P httpd_read_user_content 1#012#012*****  Plugin catchall (11.6 confidence) suggests   **************************#012#012If you believe that httpd should be allowed read access on the index.html file by default.#012Then you should report this as a bug.#012You can generate a local policy module to allow this access.#012Do#012allow this access for now by executing:#012# ausearch -c 'httpd' --raw | audit2allow -M my-httpd#012# semodule -X 300 -i my-httpd.pp#012
Dec 15 17:18:21 encserver systemd[1]: dbus-:1.1-org.fedoraproject.SetroubleshootPrivileged@1.service: Deactivated successfully.
Dec 15 17:18:21 encserver systemd[1]: setroubleshootd.service: Deactivated successfully.
```

Then run the command as shown above
```shell
sealert -l 525882cd-e7e3-4d97-97ac-df968a100586
```

You can also look into ausearch

```shell
sudo ausearch -m avc --start today -i
```

But none of them provide the solution you are looking for. You need to understand some basics.

`SELinux is preventing /usr/sbin/httpd from read access on the file /var/www/html/index.html`

Tells us the something is wrong with /var/www/html/index.html. As first step try
creating a simple file in the same directory e.g. anotherindex.html

```shell
ls -lZ /var/www/html/ | awk '{print $5,$10}'
```

```output
system_u:object_r:httpd_sys_content_t:s0 anotherindex.html
unconfined_u:object_r:user_home_t:s0 index.html
```
### How to fix
you can use either restorecon, chcon
```shell
sudo chcon --reference /var/www/html/anotherindex.html /var/www/html/index.html 
sudo ls -lZ /var/www/html/ | awk {'print $5,$10'}
```

```output
system_u:object_r:httpd_sys_content_t:s0 anotherindex.html
system_u:object_r:httpd_sys_content_t:s0 index.html
```