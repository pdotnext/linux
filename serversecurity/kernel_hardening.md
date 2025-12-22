# Kernel Hardening (RHEL only)

sysctl -a provides all settings configured.

By default dmesg can be ran by anyone because of this settings `kernel.dmesg_restrict = 1`

```shell
sudo sysctl -a | grep dmesg
#
# --- output ---
# Zero means OFF, which is default in RHEL
# kernel.dmesg_restrict = 0
# --- output
```

## dmesg restrict
when kernel.dmesg is turned on, then only root and CAP_SYSLOG can read kernel messages.
And kernel logs contains

- hardware information
- Boot parameters
- Driver errors

But RHEL has turned off because when UEFI secure boot is enabled, it needs to read </br>
kernel buffer especially verification process.

```quote
The kernel.dmesg_restrict setting in RHEL 9 is turned off to 
ensure compatibility with UEFI Secure Boot. This boot mechanism
requires the kernel and all loaded drivers to be signed by a
trusted key for the system to run kernel-mode code.
If dmesg_restrict were enabled, it would restrict the
output of kernel messages, potentially interfering with
the verification process of UEFI Secure Boot. Therefore, to
maintain the security and integrity provided by Secure Boot,
dmesg_restrict is kept disabled in RHEL 9.
```

## kernel.kptr_restrict
This kernel settings prevents `/proc` from accessing kernel address in memory.</br>
`kernel.kptr_restrict = 1` is to 1, which means only privilege accounts can access.</br>

## kernel.yama.ptrace_scope
This parameter restrict access to ptrace. By default in RHEL it is disabled </br>.
Value 1 | 2 | 3 are allowed.
- value of 1 refers to debugging only parent process
- value of 2 only privilege account can use ptrace

## Notes on Process isolation

Process isolation is possible using cgroups. cgroups is same as resource pool in Vmware world
If you to first enable it and allocate resources.

### Enabling accounting for CPU, Memory and IO

```shell
sudo systemctl set-property httpd.service CPUAccounting=1 MemoryAccounting=1 BlockIOAccounting=1

# Now once accounting is enabled, allocate them resources
sudo systemctl set-property httpd.service CPUQuota=50% MemoryLimit=500M
```
Once you enable and allocate, in RHEL at /etc/systemd/system.control/httpd.service following files are created.</br>
Do not edit these files.

```shell
/etc/systemd/system.control/
└── httpd.service.d
    ├── 50-BlockIOAccounting.conf
    ├── 50-CPUAccounting.conf
    ├── 50-CPUQuota.conf
    ├── 50-MemoryAccounting.conf
    └── 50-MemoryLimit.conf
```