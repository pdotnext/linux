# Scanning, Auditing and Hardening

Date: 23.12.2025

## Installing and update ClamAV and maldet

maldet stands for Malware Detect or also known by name LMD </br>
LMD is not available on any of the repo. You have to directly  </br>
download it.Once installed, it uses inotify feature which keeps  </br>
checking the modification in file and directories It also creates  </br> 
a cronjon which will automatically download the signatures and  </br> update the software
You can also submit your own malware samples.

[Download link](https://www.rfxn.com/projects/linux-malware-detect/)

### Why we need ClamAV?
We need it because ClamAV is more efficient when scanning </br> 
large filesets ClamAV can also use malware signature from LMD.

### Installing ClamAV

```shell
sudo dnf install wget clamav clamav-update inotify-tools
# clamav-freshclam is basically new name for clamav-update
# --- enable service
sudo systemctl enable --now clamav-freshclam
```

#### Configuring ClamAV

We need to enable automatic update AV Database of clamav. </br> 
For that we need to enable and start the service.

```shell
# --- enable service
sudo systemctl enable --now clamav-freshclam
```

By default the update is every two hours as per </br> 
/etc/freshcalm.conf as shown below

```shell
# Number of database checks per day.
# Default: 12 (every two hours)
#Checks 24 <- [ACTION] - uncomment this line for every hour
```


### Installing LMD

```shell
# download the tar

sudo -i
wget https://www.rfxn.com/downloads/maldetect-current.tar.gz
tar -xvf maldetect-current.tar.gz
cd maldetect-1.6.6
./install.sh


# Created symlink /etc/systemd/system/multi-user.target.wants/maldet.service \
# → /usr/lib/systemd/system/maldet.service.

# installation completed to /usr/local/maldetect
# config file: /usr/local/maldetect/conf.maldet
# cron.daily: /etc/cron.daily/maldet
# maldet(6023): {sigup} performing signature update check...
# maldet(6023): {sigup} local signature set is version 20250225482944
# maldet(6023): {sigup} new signature set 202512223496934 available
# maldet(6023): {sigup} downloading https://cdn.rfxn.com/downloads/maldet-sigpack.tgz
# maldet(6023): {sigup} downloading https://cdn.rfxn.com/downloads/maldet-cleanv2.tgz
# maldet(6023): {sigup} verified md5sum of maldet-sigpack.tgz
# maldet(6023): {sigup} unpacked and installed maldet-sigpack.tgz
# maldet(6023): {sigup} verified md5sum of maldet-clean.tgz
# maldet(6023): {sigup} unpacked and installed maldet-clean.tgz
# maldet(6023): {sigup} signature set update completed
# maldet(6023): {sigup} 17638 signatures (14801 MD5 | 2054 HEX | 783 YARA | 0 USER)

```

In the above output, you see service with name maldet.service is created. </br> 
Cronjob is created by name maldet.
Signature is downloaded and updated.

#### Configure LMD

you need to edit two files to configure LMD.
- monitorpaths file
- maldet config files

Both the files are located under /usr/local/maldetech/{conf.maldet,monitor_paths}

Inside conf.maldet file we need to achieve following

- enable email alert
- configure infected files are quarantine
- monitor not users for paths

```shell
# Below is diff between configured file and backed up file
diff /usr/local/maldetect/conf.maldet \
/usr/local/maldetect/conf.maldet_2025-12-23-1040

16c16
< email_alert="1"
---
> email_alert="0"
21c21
< email_addr="zorro"
---
> email_addr="you@domain.com"
243c243
< quarantine_hits="1"
---
> quarantine_hits="0"
281,282c281,282
< # default_monitor_mode="users"
< default_monitor_mode="/usr/local/maldetect/monitor_paths"
---
> default_monitor_mode="users"
> # default_monitor_mode="/usr/local/maldetect/monitor_paths"
```

```shell
cat /usr/local/maldetect/monitor_paths
/root
/home
/tmp
/var/tmp
```

Since we changed the conf.maldet file, we must restart the service

```shell
sudo systemctl restart maldet
# output
# --- [Info] ---

# Dec 23 10:58:13 coco2 systemd[1]: maldet.service: Consumed 1min 3.979s CPU time.
# Dec 23 10:58:13 coco2 systemd[1]: Starting Linux Malware Detect monitoring - maldet...
# Dec 23 10:58:22 coco2 maldet[8469]: Linux Malware Detect v1.6.6
# Dec 23 10:58:22 coco2 maldet[8469]: (C) 2002-2023, R-fx Networks <proj@rfxn.com>
# Dec 23 10:58:22 coco2 maldet[8469]: (C) 2023, Ryan MacDonald <ryan@rfxn.com>
# Dec 23 10:58:22 coco2 maldet[8469]: This program may be freely redistributed under the terms of the GNU GPL v2
# Dec 23 10:58:22 coco2 maldet[8469]: maldet(8469): {mon} added /root to inotify monitoring array #<-- monitor paths are effective
# Dec 23 10:58:22 coco2 maldet[8469]: maldet(8469): {mon} added /home to inotify monitoring array #<--
# Dec 23 10:58:22 coco2 maldet[8469]: maldet(8469): {mon} added /tmp to inotify monitoring array #<--
# Dec 23 10:58:22 coco2 maldet[8469]: maldet(8469): {mon} added /var/tmp to inotify monitoring array #<--
# Dec 23 10:58:22 coco2 maldet[8469]: maldet(8469): {mon} starting inotify process on 4 paths, this might take awhile...
# Dec 23 10:58:24 coco2 maldet[8469]: maldet(8469): {mon} inotify startup successful (pid: 8573)
# Dec 23 10:58:24 coco2 maldet[8469]: maldet(8469): {mon} inotify monitoring log: /usr/local/maldetect/logs/inotify_log

```

Where to find the activities detected by LMD

```shell
# inotify log
sudo tail /usr/local/maldetect/logs/inotify_log
#
# --- [Info] ---
# /home/zorro/.local/share/fish/fish_history MODIFY 23 Dec 11:25:48
# /root/.lesshsQ CREATE 23 Dec 11:25:48
# /root/.lesshsQ MODIFY 23 Dec 11:25:48
# /root/.lesshsQ MOVED_FROM 23 Dec 11:25:48
# /root/.lesshst MOVED_TO 23 Dec 11:25:48
# /home/zorro/.local/share/fish/fish_history MODIFY 23 Dec 11:26:04
# /home/zorro/.local/share/fish/fish_history MODIFY 23 Dec 11:26:54
# /home/zorro/.local/share/fish/fish_history MODIFY 23 Dec 11:27:09
# /home/zorro/.local/share/fish/fish_history MODIFY 23 Dec 11:27:36
# /home/zorro/.local/share/fish/fish_history MODIFY 23 Dec 11:27:39
# 
# event log
sudo tail /usr/local/maldetect/logs/event_log 
#
# --- [Info] ---
# Dec 23 2025 11:16:52 coco2 maldet(8469): {mon} warning clamd service not running; force-set monitor mode file scanning to every 120s
# Dec 23 2025 11:17:09 coco2 maldet(8469): {mon} scanned 0 new/changed files with clamav engine
# Dec 23 2025 11:19:09 coco2 maldet(8469): {mon} warning clamd service not running; force-set monitor mode file scanning to every 120s
# Dec 23 2025 11:19:25 coco2 maldet(8469): {mon} scanned 2 new/changed files with clamav engine
# Dec 23 2025 11:21:25 coco2 maldet(8469): {mon} warning clamd service not running; force-set monitor mode file scanning to every 120s
# Dec 23 2025 11:21:42 coco2 maldet(8469): {mon} scanned 10 new/changed files with clamav engine
# Dec 23 2025 11:23:42 coco2 maldet(8469): {mon} warning clamd service not running; force-set monitor mode file scanning to every 120s
# Dec 23 2025 11:23:59 coco2 maldet(8469): {mon} scanned 1 new/changed files with clamav engine
# Dec 23 2025 11:25:59 coco2 maldet(8469): {mon} warning clamd service not running; force-set monitor mode file scanning to every 120s
# Dec 23 2025 11:26:15 coco2 maldet(8469): {mon} scanned 5 new/changed files with clamav engine

```

