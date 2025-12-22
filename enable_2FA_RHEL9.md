# How to enable 2FA on RHEL9

Now why I'm mentioning RHEL here. Because `ChallengeResponseAuthentication` is not present in RHEL9
You can search for this settings in RHEL man page. It says skipping

Step:01 Edit /etc/pam.d/sshd_config

add the following line at the end of the file
```shell
auth    required    pam_google_authenticator.so secret=/home/${USER}/.ssh/google_authenticator
# and comment the following line as shown below.
#auth       substack     password-auth
```

Step: 02 Ediz /etc/ssh/sshd_config
Add the following at the end
```shell
ChallengeResponseAuthentication yes
```



