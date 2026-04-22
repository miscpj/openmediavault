# Open Media Vault

## Changing the login splash scren after timeout
In /var/www/openmediavault
```
vi __custom.css

/* Add css link <link rel="stylesheet" href="__custom.css"> to /var/www/openmediavault/index.html */

/* To disable the animation but keep the matrix background */

body .omv-login-page .background {
 -webkit-animation-name:none !important;
 animation-name:none !important;
 -webkit-animation-duration:0s !important;
 animation-duration:0s !important;
 -webkit-animation-iteration-count:0 !important;
 animation-iteration-count:0 !important;
}

/* Or to install my own background */
/*
body .omv-login-page .background {
content:url(/assets/images/myownbackground.jpg) !important;
-webkit-animation-name:none !important;
animation-name:none !important;
-webkit-animation-duration:0s !important;
animation-duration:0s !important;
-webkit-animation-iteration-count:0 !important;
animation-iteration-count:0 !important;
}
*/
```

Add a line to index.html to load the css
```
vi index.html
<link rel="stylesheet" href="__custom.css">
```

#### Note
It doesn't seem to work.

## Sending email from openvault
I had to create an [app password](https://support.google.com/mail/answer/185833?hl=en-GB&sjid=3623814072379207560-EU)

Maybe a better alternative would have been to use [restricted Gmail SMTP server](https://support.google.com/a/answer/176600?hl=en&sjid=3623814072379207560-EU)



## Migration from RPI OMV 6 to mini-hp PC OMV 8 (current version in 2026 04 12)

Unfortunately I could use **omv-release-upgrade** to upgrade OMV 6 to OMV 7,  and then from 7 to 8 on RPI, 6 being too old

### OMV 6 before migrating

#### On RPI
uname -a
Linux omv-nas 6.1.21-v8+ #1642 SMP PREEMPT Mon Apr  3 17:24:16 BST 2023 aarch64 GNU/Linux

What's new in [OMV 8](https://www.youtube.com/watch?v=fdKdsX2Socw)

#### Making sure the current system is up-to-date
```
sudo apt update
sudo apt full-upgrade
```


#### omv-regen utility to backup and restore OMV configuration

What is [omv-regen](https://github.com/xhente/omv-regen?tab=readme-ov-file#-omv-regen-1) and how to use it.

#### State of the old file system

NAS FS
Data:
pjmd@omv-nas:/srv/dev-disk-by-uuid-a77d5d6f-f6d9-436a-a5a7-12810fa8cc53/data $ ll
total 144
drwxrwsr-x+ 5 root    users   4096 Aug 28  2025 .
drwxr-xr-x  9 root    root    4096 Nov 22 15:41 ..
drwxr-sr-x  6 appuser users   4096 Apr 12 14:50 backups
drwxr-sr-x  2 root    users 126976 Apr 12 16:50 ipcam_repo/*.mkv files
drwxr-sr-x  2 root    root    4096 Jan  7  2024 media

AppData:
```
pjmd@omv-nas:/srv/dev-disk-by-uuid-a77d5d6f-f6d9-436a-a5a7-12810fa8cc53/appdata $ ll
total 28
drwxrwsr-x+ 6 root users 4096 Aug 28  2025  .
drwxr-xr-x  9 root root  4096 Nov 22 15:41  ..
drwxrwxr-x+ 3 root users 4096 Sep 13  2025  IPcam
drwxrwxr-x+ 4 root users 4096 Jan 15  2025 'UrBackup server'
-rwxrwxr-x+ 1 root users   35 Jan  7  2024  global.env
drwxrwxr-x+ 2 root users 4096 Sep 13  2025  ipcam-dockerfile
drwxrwxr-x+ 3 root users 4096 Nov  2 16:19  jellyfin
pjmd@omv-nas:/srv/dev-disk-by-uuid-a77d5d6f-f6d9-436a-a5a7-12810fa8cc53/appdata $ ll ipcam-dockerfile/
total 24
drwxrwxr-x+ 2 root users 4096 Sep 13  2025 .
drwxrwsr-x+ 6 root users 4096 Aug 28  2025 ..
-rwxrwxr-x+ 1 root users 2157 Sep  5  2025 Dockerfile
-rwxrwxr-x+ 1 root users 1922 Sep 13  2025 save-monitor-rtsp-stream.sh
-rwxrwxr-x+ 1 root users 1607 Sep  5  2025 save-monitor-rtsp-stream.sh.bak
-rwxrwxr-x+ 1 root users  759 Aug 30  2025 save-rtsp-stream.sh
```

```
appuser@omv-nas:/home/pjmd$ id
uid=1002(appuser) gid=100(users) groups=100(users)

/home/pjmd$ su jelly
Password:
$ id
uid=1005(jelly) gid=100(users) groups=100(users)
```

In /etc/passwd:

```
admin 998::100
omv-notify 997::991
omv-webui 999:992
pjmd 1000::100
Beverly 1001::100
appuser 1002
minimac 1003
pjmd2 1004
jelly 1005
```

### OMV8

On OMV 8 the default **docker FS** is:
```
sudo ls -l /var/lib/docker/
[sudo] password for pjmd:
total 44
drwx--x--x 4 root root 4096 Apr 13 21:33 buildkit
drwx--x--- 2 root root 4096 Apr 13 21:33 containers
-rw------- 1 root root   36 Apr 13 21:33 engine-id
drwx------ 3 root root 4096 Apr 13 21:33 image
drwxr-x--- 3 root root 4096 Apr 13 21:33 network
drwx--x--- 3 root root 4096 Apr 13 21:33 overlay2
drwx------ 3 root root 4096 Apr 13 21:33 plugins
drwx------ 2 root root 4096 Apr 13 21:33 runtimes
drwx------ 2 root root 4096 Apr 13 21:33 swarm
drwx------ 2 root root 4096 Apr 13 21:33 tmp
drwx-----x 2 root root 4096 Apr 13 21:33 volumes
```

I decided to move it to the old location **/srv/dev-disk-by-uuid-a77d5d6f-f6d9-436a-a5a7-12810fa8cc53/docker/**

From the doc it seems like a good idea to not put on the OS FS the docker folder.

#### Adding users to new system

The user ids didn't match the old system so I manually change them in /etc/passwd
```
pjmd:x:1000:100:philippe,,,:/home/pjmd:/usr/bin/bash
minimac:x:1001:100::/home/minimac:/usr/bin/sh
beverly:x:1002:100::/home/beverly:/usr/bin/sh   -->old appuser
appuser:x:1003:100::/home/appuser:/usr/bin/bash
jelly:x:1004:100::/home/jelly:/usr/bin/bash      -->old 1005
pjmd2:x:1005:100::/home/pjmd2:/usr/bin/bash
```

#### OMV8 Issues

* 1) Error booting the machine
Selected Boot Image Did Not Authenticate  
Solution: https://support.hp.com/us-en/document/ish_8680345-8679627-16  
Follow instruction except do unCheck Enable MS UEFI CA key. 

Better solution:
https://support.hp.com/us-en/document/ish_9642671-9641393-16

* 2) jellyfin
```
lscr.io/linuxserver/jellyfin:latest exited  
Exited (255) 5 minutes ago  
disabled  
/srv/dev-disk-by-uuid-a77d5d6f-f6d9-436a-a5a7-12810fa8cc53/data/media
/srv/dev-disk-by-uuid-a77d5d6f-f6d9-436a-a5a7-12810fa8cc53/appdata/jellyfin/config
```
   * 2.1) format error is due to the container/image were arm (RPI aarch64) insteadof amd64

   * 2.2) the version set in compose file was latest at the time 10.10.7 now in 2026/04 latest is 10.11.8 and the migration breaks.  
     To migrate it seems necessary to transit by some other version.
   
     Solution: reinstalled the backup copies of system.xml and migrations.xml to the current files and the versiom to 10.10.7

* 3) Timemachine
     I decided to limit user minimac to 1 TB on timemachine FS. It was a mistake because timemachine would backup up 42 GB and fail.

     To set Timamachine up I had tO:
     * to map an network drive on the mac for user minimac to FS timemachine
     * Encryption was for use minimac as well

## Jellyfin

I decided to upgrade jellyfin to the latest version which is a this time 2026/04/20 10.11.8
admin being pjmd.

## Timemachine

* Mapped an network drive on the mac for **user minimac** to **FS timemachine**
  I didn't map the drive from **Finder** but directly from **Time machine Settings**.
  I actually re-mapped a drive I created and deleted previously.
  It gave me the opportunity to **disable encryption** and set up a **quota to 1TB**
* Did not set a quota in OMV **Storage | File Systems | Quota**

It is also possible to set a timemachine quota from the mac terminal
```
sudo tmutil setquota {ID} {SIZE_IN_GB}

You can determine the ID with

sudo tmutil destinationinfo
```
