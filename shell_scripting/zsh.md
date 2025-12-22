# ZSH Shell

## How to find empty directories

```shell
#!/bin/zsh
cd /etc
ls -ld *(/^F)
```

## How to find only directories which are non-empty

```shell
#!/bin/zsh
cd /etc
ls -ld *(F)
```

## List the history with timestamp

```shell
history -f
```

## Escaping or meta characters

There are metacharacters which shell has its own internal meaning.
In case you wish shell to treat them what they are i.e. literally,
then you need to escape them using `\`

```shell
* ( ) $  / \ ! ~ & ´ '
```

```shell
14:10:15 ~ $ ls -l *.sh
#
# --- Output
# -rw-r--r--. 1 zorro zorro 680 Dec 14 10:49 anothersvc.sh

14:13:43 ~ $ ls -l \*.sh
# ls: cannot access '*.sh': No such file or directory


echo I have 5 million \$ Dollars
# I have 5 million $ Dollars

14:27:39 ~ $ name=walter

14:27:51 ~ $ echo '$name' # not interpreted
# $name
14:27:57 ~ $ echo "$name" # interpreted
# walter

```