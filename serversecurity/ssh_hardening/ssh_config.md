# SSH Config file

Here is the sample ssh config file for my lab.

```shell
# contents of $HOME/.ssh/config

Host encserver
    HostName 192.168.56.70
    User    Zorro
    IdentityFile    ~/.ssh/id_vboxes
    AddKeysToAgent  yes
    IdentitiesOnly  yes
    Cipher aes256-gcm@openssh.com
Host github_private
    HostName github.com
    User    git
    IdentityFile    ~/.ssh/id_github_private
    AddKeysToAgent  yes
    IdentitiesOnly  yes
```

## Flags explanation
    - IdentitiesOnly - there is possibility that there are multiple keys are loaded into ssh keyring
        In this case, we are strictly asking the specific key to be used.
    - Cipher only use the algorithm mentioned. The list of the supported algorithm can be found using `ssh -Q cipher`
