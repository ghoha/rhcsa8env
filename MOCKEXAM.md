# RCHSA Mock Exam
## Introduction

This practice exam is for those that have gone through an RHCSA course/book and want to test their knowledge before sitting the RHCSA 8 exam.

## Systems SetUp

Ensure all the tasks are implemented with firewalld and SELinux enabled.
Your server should be able to survive a reboot.
Be sure that the journal will be permanent across all the reboots.

Configure server1 and server2 with the following network settings,
Don't change existing network profile

**Hostname - server1.eight.example.com**
```
Network ID - extenal
IP - 192.168.55.150/24
DNS - 8.8.8.8
GW - 192.168.5.1
Firewall Zone - work
```
**Hostname - server2.eight.example.com**
```
Network ID - external
IP - 192.168.55.151/24
DNS - 8.8.8.8
GW - 192.168.5.1
Firewall Zone - work
```
>***NOTE***
*The below questions assume you’re using the automated deployment but you can also use a practice environment you created.
However, you will have to set up your own repo, change host names, IP addresses, etc to reflect your own environment details.*

<details>
 <summary>Suggestion
 </summary>
Both serveres are stuck in a reboot loop to fix it you need to stop the normal boot process and change the default target (could be a good idea completing also #Task1

```bash
#During the boot process at the GRUB menu press "e" to edit boot parameteres
#in the linux line, add rd.break  at the end.
#in the subsequent emergency shell
mount -o remount, rw /sysroot
chroot /sysroot
systemctl set-default multi-user.target

#Set Selinux
[root@server1 ~]\> sed -i 's/permissive/enforcing/g' /etc/selinux/config

#Set Firewalld
[root@server1 ~]\> systemctl status firewalld.service
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2020-05-25 08:46:05 UTC; 14h ago
     Docs: man:firewalld(1)
 Main PID: 778 (firewalld)
    Tasks: 2 (limit: 5076)
   Memory: 34.5M
   CGroup: /system.slice/firewalld.service
           └─778 /usr/libexec/platform-python -s /usr/sbin/firewalld --nofork --nopid

May 25 08:46:02 server1.eight.example.com systemd[1]: Starting firewalld - dynamic firewall daemon...
May 25 08:46:05 server1.eight.example.com systemd[1]: Started firewalld - dynamic firewall daemon.

[root@server1 ~]\> firewall-cmd --get-default-zone
public
[root@server1 ~]\> firewall-cmd --set-default-zone=work
success
[root@server1 ~]\> firewall-cmd --list-all
work (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth2
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

#Set Network Profile
[root@server1 ~]\> nmcli device status
DEVICE  TYPE      STATE         CONNECTION
eth0    ethernet  connected     internal
eth2    ethernet  connected     ansible
eth1    ethernet  disconnected  --
lo      loopback  unmanaged     --

[root@server1 ~]\> nmcli connection add type ethernet ifname eth1 con-name external autoconnect yes
Connection 'external' (dce27208-f96b-42cd-8cf7-1e7b2fbd1673) successfully added.
[root@server1 ~]\> nmcli connection modify external ipv4.addresses 192.168.55.150/24 ipv4.gateway 192.168.5.1\
ipv4.dns 8.8.8.8 ipv4.dns-search eight.example.com

[root@server1 ~]\> nmcli connection down external ; nmcli connection up external
Connection 'external' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/3)
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/4)


[root@server1 ~]\> ip address list eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:48:77:fa brd ff:ff:ff:ff:ff:ff
    inet 192.168.55.150/24 brd 192.168.55.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet 192.168.56.217/24 brd 192.168.56.255 scope global dynamic noprefixroute eth1
       valid_lft 598sec preferred_lft 598sec
    inet6 fe80::eab0:b238:6244:b70f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

#Hostname
[root@server1 ~]\> hostnamectl
   Static hostname: server1.eight.example.com
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 97ef1bae5db1434eb9fc5fd2bf763651
           Boot ID: 1905855861f041229a193cf005a8697d
    Virtualization: oracle
  Operating System: Red Hat Enterprise Linux 8.0 (Ootpa)
       CPE OS Name: cpe:/o:redhat:enterprise_linux:8.0:GA
            Kernel: Linux 4.18.0-80.el8.x86_64
      Architecture: x86-64


```
</details>

## Exam
#### *Task1*
On server1 and server2
Interrupt the boot process and reset the root password.
Change it to “wander” to gain access to the system.

<details>
 <summary>Solution
 </summary>

```bash
#During the boot process at the GRUB menu press "e" to edit boot parameteres
#in the linux line, add rd.break  at the end.
#in the subsequent emergency shell
mount -o remount, rw /sysroot
chroot /sysroot
passwd and set new root passwd
touch /.autorelabel
exit
exit

```
</details>

#### *Task2*
On server1 and server2
Configure the following repositories:
- http://repo.eight.example.com/BaseOS
- http://repo.eight.example.com/AppStream

<details>
 <summary>Solution
 </summary>

```bash
#Create the repo file
[root@server1 ~]\> vim /etc/yum.repos.d/exam.repo
[ExamRepo] #Don't use space here
name=examrepo
baseurl=http://repo.eight.example.com/BaseOS
enabled=1

[ExameAppStream] #Don't use space here
name=examappstream
baseurl=http://repo.eight.example.com/AppStream
enabled=1

#Check that the repo you configured are working
[root@server1 ~]\> yum repolist --all
Updating Subscription Management repositories.
Unable to read consumer identity
This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
Last metadata expiration check: 0:02:33 ago on Sat 02 May 2020 10:47:56 PM UTC.
repo id						repo name						status
ExamRepo					examrepo						enabled: 1,658
ExameAppStream				examappstream					enabled: 4,672

```
</details>

#### *Task3*
On server1 and server2
The system time should be set to your (or nearest to you) timezone and ensure NTP sync is configured.
Configure the system to sync with pool.ntp.org
<details>
 <summary>Solution
 </summary>

```bash
#Install Chrony
[root@server1 ~]\> yum install chronyd -y
#Verify chronyd status
[root@server1 ~]\> systemctl status chronyd
#Enable and start chronyd
[root@server1 ~]\> systemctl enable chronyd; systemctl start chronyd

#Verifying, listing and changin timezone
[root@server1 ~]\> timedatectl
[root@server1 ~]\> timedatectl list-timezones
[root@server1 ~]\> timedatectl set-timezone Europe/Dublin

#Modify chrony configuration file with the new pool
[root@server1 ~]\> sed -i 's/^pool.*$/pool pool.ntp.org iburst/g' /etc/chrony.conf
#Restart the daemon
[root@server1 ~]\> systemctl restart chronyd.service
#Verify your changes
[root@server1 ~]\> chronyc sources
```
</details>

#### *Task4*
On server1
Add the following secondary IP addresses statically to your eth1 interface.
Do this in a way that doesn’t compromise your existing settings:
- IPV4 - 10.0.0.5/24
- IPV6 - fd01::100/64

<details>
 <summary>Solution
 </summary>

```bash
#Identify which profile is using eth1
[root@server1 ~]\> nmcli con show
NAME      UUID                                  TYPE      DEVICE
external  9c92fad9-6ecb-3e6c-eb4d-8a47c6f50c04  ethernet  eth1
internal  5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  eth0

#Modify the profile accordingly
[root@server1 ~]\> nmcli con mod external +ipv4.addresses 10.0.0.5/24 ipv6.method manual +ipv6.addresses fd01::100/64
#Restart the connection profile
[root@server1 ~]\> nmcli con down external ; nmcli con up external
#Check your changes
[root@server1 ~]\> ip a ls
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ec:6d:66 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 45679sec preferred_lft 45679sec
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ad:ca:74 brd ff:ff:ff:ff:ff:ff
    inet 192.168.55.150/24 brd 192.168.55.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet 10.0.0.5/24 brd 10.0.0.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fd01::100/64 scope global noprefixroute
       valid_lft forever preferred_lft forever
    inet6 fe80::f77a:d66b:6b42:a59f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

```
</details>

#### *Task5*
Enable packet forwarding on system1.
This should persist after reboot.
<details>
 <summary>Solution
 </summary>

```bash
#Add "net.ipv4.ip_forward = 1" to system configuration file
[root@server1 ~]\> echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
#Reboot
[root@server1 ~]\> systemctl reboot
#Verify your changes
[root@server1 ~]\> sysctl -p

```
</details>

#### *Task6*
Both servers should boot into the multiuser target by default and boot messages should be present (not silenced).
<details>
 <summary>Solution
 </summary>

```bash

 #Verify current default target
[root@server1 ~]\> systemctl get-default
 #If needed change the default target
[root@server1 ~]\> systemctl set-default multi-user.target

#Edit grub configuration file deleting "rhgb quiet"
#from the line starting with "GRUB_CMDLINE_LINUX"
[root@server1 ~]\> vim /etc/default/grub

#Generate the new grub.cfg file
[root@server1 ~]\> grub2-mkconfig -o /boot/grub2/grub.cfg

#Reboot and verify using the console your changes
[root@server1 ~]\> systemctl reboot
```
</details>

#### *Task7*
On server2
Create a new 2GB volume group named “vgprac”.
Create a 500MB logical volume named “lvprac” inside the “vgprac” volume group.
The “lvprac” logical volume should be formatted with the xfs filesystem and mount persistently on the /mnt/lvprac directory.
Extend the xfs filesystem on “lvprac” by 500MB.
Make sure to create a GPT partition table.
<details>
 <summary>Solution
 </summary>

```bash
#Install gdisk to create gtptpartition tabl
[root@server2 ~]\> yum install gdisk -y
yum install gdisk -y

[root@server2 ~]\> gdisk /dev/sdb
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.

Command (? for help): n
Partition number (1-128, default 2): 1
First sector (34-16777182, default = 4196352) or {+-}size{KMGTP}:
Last sector (4196352-16777182, default = 16777182) or {+-}size{KMGTP}: +2G
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300): 8e00
Changed type of partition to 'Linux LVM'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/sdb.
Warning: The kernel is still using the old partition table.
The new table will be used at the next reboot or after you
run partprobe(8) or kpartx(8)
The operation has completed successfully.

[root@server2 ~]\> partprobe

#Create physical device, volume group and logical volume
[root@server2 ~]\> pvcreate /dev/sdb1
  Physical volume "/dev/sdb1" successfully created.
[root@server2 ~]\> vgcreate vgprac /dev/sdb1
  Volume group "vgprac" successfully created
[root@server2 ~]\> lvcreate -n lvprac -L 500M vgprac
  Logical volume "lvprac" created.
 #Create xfs filesystem
[root@server2 ~]\> mkfs.xfs /dev/vgprac/lvprac
[root@server2 ~]\> udevadm settle
#Check for UIID, edit fstab, create the mount point, and mount it
[root@server2 ~]\> blkid
[root@server2 ~]\> vim /etc/fstab
[root@server2 ~]\> mkdir -p /mnt/lvprac
[root@server2 ~]\> mount -a


```
</details>

#### *Task8*
On server2
Use the appropriate utility to create a 5TiB thin provisioned volume. Create an xfs filesytem and mount it in /mnt/thin
<details>
 <summary>Solution
 </summary>

```bash

#VDO is one tool that offer thin provisioned storage
[root@server2 ~]\> yum install vdo kmod-kvdo -y

#Create the partition
[root@server2 ~]\> gdisk /dev/sdb
[root@server2 ~]\> gdisk /dev/sdb
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.

Command (? for help): n
Partition number (2-128, default 2): 2
First sector (34-16777182, default = 4196352) or {+-}size{KMGTP}:
Last sector (4196352-16777182, default = 16777182) or {+-}size{KMGTP}: +4G
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300): 8300
Changed type of partition to 'Linux filesystem'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/sdb.
Warning: The kernel is still using the old partition table.
The new table will be used at the next reboot or after you
run partprobe(8) or kpartx(8)
The operation has completed successfully.

[root@server2 ~]\> partprobe

#Create the VDO
#I have disabled compression and deduplication cause they are not metioned in the task.
#The default SlabSize is 2G if youdon't modify it with a 2G partition you are going to get an outof space error
[root@server2 ~]\> vdo create --name thinvdo --device /dev/sdb2 --vdoSlabSize 128M --vdoLogicalSize 5T --deduplication disabled --compression disabled
Creating VDO thinvdo
Starting VDO thinvdo
VDO instance 1 volume is ready at /dev/mapper/thinvdo


#Create xfs filesystem
[root@server2 ~]\> mkfs.xfs -K /dev/mapper/thinvdo
[root@server2 ~]\> udevadm settle
#Check for UIID, edit fstab, create the mount point, and mount it
[root@server2 ~]\> blkid
#Check the options here they are  mandatory for vdo to work during the boot
[root@server2 ~]\> vim /etc/fstab
UUID="372bb634-318f-4098-b0bc-e9f7a93eb411"     /mnt/thin       xfs     defaults,x-systemd.device-timeout=0,x-systemd.requires=vdo.service,_netdev       0 0
[root@server2 ~]\> mkdir -p /mnt/thin
[root@server2 ~]\> mount -a
#Alternative way to make VDO work at boot
#A VDO device needs that vdo is started before it could be mounted, as a network device needs the network.
#Creating a systemd unit for me is a really interesting way to manage it .
#Here the doc /usr/share/doc/vdo/examples/systemd/VDO.mount.example
#The name of the unit is important and related to the mount point.
[root@server2 ~]\> vim /etc/systemd/system/mnt-thin.mount
[Unit]
Description = Mount filesystem that lives on thinvdo
name = mnt-thin.mount
Requires = vdo.service systemd-remount-fs.service
After = multi-user.target
Conflicts = umount.target

[Mount]
What = /dev/mapper/thinvdo
Where = /mnt/thin
Type = xfs
Options = discard

[Install]
WantedBy = multi-user.target

[root@server2 ~]\> systemctl enable mnt-thin.mount
```
Reference
[https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/deduplicating_and_compressing_storage/deploying-vdo_deduplicating-and-compressing-storage](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/deduplicating_and_compressing_storage/deploying-vdo_deduplicating-and-compressing-storage)
</details>

#### *Task9*
On server1
Configure a basic web server that displays “Welcome to the web server” once connected to it.
Ensure the firewall allows the http/https services.
<details> “Welcome to the web server”
 <summary>Solution
 </summary>

```bash
#Install httpd
[root@server1 ~]\> yum install httpd -y
#Create Index page
[root@server1 ~]\> echo  “Welcome to the web server” >> /var/www/html/index.html
#Enable and start httpd
[root@server1 ~]\> systemctl enable httpd ; systemctl start httpd
#Configure firewall
[root@server1 conf.d]# firewall-cmd --zone=work --add-service=http
success
[root@server1 conf.d]# firewall-cmd --zone=work --add-service=https
success
[root@server1 conf.d]# firewall-cmd --zone=work --add-service=https --permanent
success
[root@server1 conf.d]# firewall-cmd --zone=work --add-service=http --permanent
success
#Test from server2
[root@server2 ~]# curl http://server1.eight.example.com
“Welcome to the web server”
```
</details>

#### *Task10*
On server1
Find all files that are larger than 5MB in the /etc directory and copy them to /find/largefiles
<details>
 <summary>Solution
 </summary>

```bash

[root@server1 conf.d]# mkdir -p /find/largefiles
[root@server1 conf.d]# find /etc -size +5M -exec cp -ap {} /find/largefiles \;
[root@server1 conf.d]# ls -l /find/largefiles
total 17164
-r--r--r--. 1 root root 9143418 Sep 19  2019 hwdb.bin
-rw-r--r--. 1 root root 8428248 May  3 00:48 policy.31

```
Reference:
man find
</details>

#### *Task11*
Write a script named awesome.sh on server1.
When awesome.sh is issued,
- If “me” is given as an argument, then the script should output “Yes, I’m awesome.”
- If “them” is given as an argument, then the script should output “Okay, they are awesome.”
- If the argument is empty then the script should output  "Usage ./awesome.sh me|them"
- If the argrument is anything else is given, the script should output "Sorry, I don't know him/her"

<details>
 <summary>Solution
 </summary>

```bash
#Create the script
[root@server1 ~]\> vim /usr/bin/awesome.sh
#!/bin/bash

case $1 in
	"" )
		echo "Usage ./awesome.sh me|them"
                ;;
	me )
		echo "Yes, I'm awesome."
		;;
	them )
		echo "Okay, they are awesome."
		;;
	* )
		echo "Sorry, I don't know him/her"
                ;;
esac

#Make the script executable
[root@server1 ~]\> chmod +x /usr/bin/awesome.sh

#Test all the scenarios
[root@server1 ~]\> awesome.sh
Usage ./awesome.sh me|them

[root@server1 ~]\> awesome.sh me
Yes, I'm awesome.

[root@server1 ~]\> awesome.sh them
Okay, they are awesome.

[root@server1 ~]\> awesome.sh fdsfsf
Sorry, I don't know him/her

```
</details>

#### *Task12*
On server1
Create users phil, laura, stewart, and kevin:

- laura home folder should be /data/accounting
- stewart homefolder should be /data/marketing
- phil account should expire in 60 days
- kevin should not have login shell

All new users should have a file named “Welcome” in their home folder after account creation.
All user passwords should  be atleast 8 characters in length.
phil and laura should be part of the “accounting” group.  The group ID should be 1100
stewart and kevin should be part of the “marketing” group. The group ID should be 1200

<details>
 <summary>Solution
 </summary>

```bash
#Create groups with specific gid
[root@server1 ~]\> groupadd -g 1100 accounting
[root@server1 ~]\> groupadd -g 1200 marketing

#Edit /etc/login.defs
PASS_MIN_LEN 8

#Create Welcome file
[root@server1 ~]\> touch /etc/skel/Welcome

#Create users,groups, and configure goups membership

[root@server1 ~]\> useradd -m -d /data/accounting laura
[root@server1 ~]\> useradd -m -d /data/marketing stewart

[root@server1 ~]\> useradd phil
[root@server1 ~]\> chage -E $(date -d +60days +%Y-%m-%d) phil
[root@server1 ~]\> chage -l phil
Last password change					: May 11, 2020
Password expires					: May 11, 2020
Password inactive					: never
Account expires						: Jul 11, 2020
Minimum number of days between password change		: 0
Maximum number of days between password change		: 0
Number of days of warning before password expires	: 7

[root@server1 ~]\> useradd -s /sbin/nologin kevin

[root@server1 ~]\> gpasswd -M phil,laura accounting
[root@server1 ~]\> gpasswd -M stewart,kevin marketing

```
</details>



#### *Task13*
On server1
- Only members of the marketing group should have access to the “/data/marketing” directory.
- Members of group "accounting" should have full access to everithyng in “/data/marketing/budget".
- All files created in "/data/marketing" should be writable for all members of "marketing".
- Make the "marketing" group the group owner of the “/data/marketing” directory
- Only the file creator should have the permissions to delete their own files.

Make stewart the owner of this directory.
<details>
 <summary>Solution
 </summary>

```bash

[root@server1 ~]\> mkdir -p /data/marketing/budget
#Make the marketing group the group owner of the “/data/marketing” directory
root@server1 ~]\> chown -R :marketing /data/marketing
#Only members of the marketing group should have access to the “/data/marketing” directory.
#All files created in /data/marketing should be writable for all members of "marketing"
#Only the file creator should have the permissions to delete their own files.
[root@server1 ~]\> chmod -R 3770 /data/marketing
#Members of group a "accounting" should have full access to everithyng in “/data/marketing/budget"
[root@server1 ~]\> setfacl -d -m g:accounting:rwx /data/marketing/budget
[root@server1 ~]\> setfacl -d -m g:accounting:x /data/marketing

```
</details>

#### *Task14*
On server1
Create a cron job that writes
"This practice exam was easy and I’m ready to ace my RHCSA"
to /var/log/messages at 12pm only on weekdays.
<details>
 <summary>Solution
 </summary>

```bash
[root@server1 conf.d]\> crontab -e
00 12 * * 1-5  echo "This practice exam was easy and I’m ready to ace my RHCSA" >> /var/log/messages
```
</details>

#### *Task15*
On server2
Create a 1G swap partition which take effect automatically at boot-start, and it should not affect the original swap partition.
<details>
 <summary>Solution
 </summary>

```bash
[root@server2 vagrant]\> gdisk /dev/sdb
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.

Command (? for help): p
Disk /dev/sdb: 16777216 sectors, 8.0 GiB
Model: VBOX HARDDISK
Sector size (logical/physical): 512/512 bytes
Disk identifier (GUID): 91FC15AD-56DC-0D4F-89CF-505B8442271B
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 33
First usable sector is 2048, last usable sector is 16777182
Partitions will be aligned on 2048-sector boundaries
Total free space is 4192223 sectors (2.0 GiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048         4196351   2.0 GiB     8300
   2         4196352        12584959   4.0 GiB     8300  Linux filesystem

Command (? for help): n
Partition number (3-128, default 3):
First sector (12584960-16777182, default = 12584960) or {+-}size{KMGTP}:
Last sector (12584960-16777182, default = 16777182) or {+-}size{KMGTP}: +1G
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300): 8200
Changed type of partition to 'Linux swap'

Command (? for help): wq

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): y
OK; writing new GUID partition table (GPT) to /dev/sdb.
Warning: The kernel is still using the old partition table.
The new table will be used at the next reboot or after you
run partprobe(8) or kpartx(8)
The operation has completed successfully.
[

root@server2 vagrant]\> partprobe


[root@server2 vagrant]\> mkswap /dev/sdb3

[root@server2 vagrant]\> blkid
/dev/sda1: UUID="4dd44b69-0feb-4b10-9b16-758d1b8c37c7" TYPE="xfs" PARTUUID="333cb9dc-01"
/dev/sda2: UUID="4dOwrJ-X4Gm-j9kh-qhkN-MDmQ-sUG2-Fxb9pY" TYPE="LVM2_member" PARTUUID="333cb9dc-02"
/dev/sdb1: UUID="IXEm5K-QqON-1J9i-6OAx-UeU1-7sd3-Io1Zea" TYPE="LVM2_member" PARTUUID="f683469d-2e74-5140-a2ec-1e70132b666a"
/dev/sdb2: UUID="9397d175-7977-4ffd-a5a5-476edac0d2da" TYPE="vdo" PARTLABEL="Linux filesystem" PARTUUID="c76f6c16-2bcd-4634-be77-e1eb46f1f66c"
/dev/sdb3: UUID="b114bd9c-1dc7-4017-bfb4-181d099b2a0f" TYPE="swap" PARTLABEL="Linux swap" PARTUUID="135f55a5-456b-4984-8246-3dd0c4db798e"
/dev/mapper/rhel_rhel8-root: UUID="5e08291c-d64e-4477-b06a-4555dc4591f8" TYPE="xfs"
/dev/mapper/rhel_rhel8-swap: UUID="1a1b9299-975a-4112-9b4f-4ae1af7c916e" TYPE="swap"
/dev/mapper/vgprac-lvprac: UUID="addc3c8d-6244-4f0c-b93a-e9726444b61d" TYPE="xfs"
/dev/mapper/thinvdo: UUID="bee1b082-73b4-4b21-bf41-fd33a6435764" TYPE="xfs"

[root@server2 vagrant]\> vim /etc/fstab
UUID=b114bd9c-1dc7-4017-bfb4-181d099b2a0f	swap	swap defaults,pri=10	0 0

[root@server2 vagrant]\> swapon -a
[root@server2 vagrant]\> swapon -s
Filename				Type		Size	Used	Priority
/dev/dm-1                              	partition	2170876	63820	-2
/dev/sdb3                              	partition	1048572	0	10


```
</details>


#### *Task16*
Make sure that you can connect from server1 to server2 and opposite without using a password
Securely copy /find/largefiles files from "server1" to “server2” to /shared directory.
<details>
 <summary>Solution
 </summary>

```bash


```
</details>


#### *Task17*
Modify the web server on server2:
- Change root directory to /dir
- Change listening port to 1080
- Enable user's homes
- Make sure the WebServer displays "This webserver is on port 1080"

<details>
 <summary>Solution
 </summary>

```bash

[root@server2 ~]\> vim /etc/httpd/conf/httpd.conf

Listen 192.168.55.151:1080

DocumentRoot "/dir"

#
# Relax access to content within /var/www.
#
<Directory "/dir">
    AllowOverride None
    # Allow open access:
    Require all granted
</Directory>



[root@server2  ~]\> vim /etc/httpd/conf.d/userdir.conf

<IfModule mod_userdir.c>
    #
    # UserDir is disabled by default since it can confirm the presence
    # of a username on the system (depending on home directory
    # permissions).
    #
    #UserDir disabled

    #
    # To enable requests to /~user/ to serve the user's public_html
    # directory, remove the "UserDir disabled" line above, and uncomment
    # the following line instead:
    #
    UserDir public_html
</IfModule>

[root@server2 ~]\> mkdir -p /dir
[root@server2 ~]\> echo "Document root of this WebServer is /dir" >> /dir/index.html
[root@server2 ~]\> semanage port --add -t http_port_t -p tcp 1080
[root@server2 ~]\> semanage port -m -t http_port_t -p tcp 1080
[root@server2 ~]\> setsebool -P httpd_enable_homedirs 1
[root@server2 ~]\> semanage fcontext --add -t httpd_sys_content_t '/dir(/.*)?'
[root@server2 ~]\> restorecon -RFv /dir
[root@server2 vagrant]\> firewall-cmd --add-port=1080/tcp --zone=work --permanent


```
**These commands are going to create man pages for SELinux booleans
You can use them in case you don't remember a specific configuration**
```
[root@server2 ~]\> yum install python3-policycoreutils-2.8-16.1.el8.noarch policycoreutils-devel-2.8-16.1.el8.x86_64 -y
[root@server2 ~]\> sepolicy manpage -a -p /usr/share/man/man8
[root@server2 ~]\> mandb
[root@server2 ~]\> man -k _selinux | grep http
```
</details>

#### *Task18*
Configure system1 and system2 to use "balanced" profile:

<details>
 <summary>Solution
 </summary>

```bash
[root@server1 ~]\> yum install tuned -y
[root@server1 ~]\> systemctl enable tuned ; systemctl start tuned
[root@server1 ~]\> tuned-adm active
Current active profile: virtual-guest
[root@server1 ~]\> tuned-adm profile balanced
[root@server1 ~]\> tuned-adm active
Current active profile: balanced

```
</details>


#### *Task19*

Make sure that server2 act as ipa client for ipa server ipa.eight.exmaple.com is exporting NFS /ldaphome
Configure server2 to authenticate with ipa.eight.example.com, be sure that the users home is mounted
Ldap users home is configured to be /home/ldap/username
LDAP: ldaps://ipa.eight.example.com
REALM: EIGH.EXAMPLE.COM
http://ipa.eight.example.com/ca.crt

User:admin
Password:password



<details>
 <summary>Solution
 </summary>

```bash
[root@ipa ~]\> yum install -y nfs-utils.x86_64
[root@ipa ~]\> vim /etc/exports
/ldaphome *.*(rw,sync,no_root_squash)

[root@ipa ~]\> systemctl enable nfs-server.service ; systemctl start nfs-server.service

[root@ipa ~]\> firewall-cmd --add-service=nfs
[root@ipa ~]\> firewall-cmd --add-service=mountd
[root@ipa ~]\> firewall-cmd --add-service=rpc-bind
[root@ipa ~]\> firewall-cmd --add-service=nfs --permanent
[root@ipa ~]\> firewall-cmd --add-service=mountd --permanent
[root@ipa ~]\> firewall-cmd --add-service=rpc-bind --permanent

[root@server2 ~]\>  yum install -y autofs
[root@server2 ~]\>  vim /etc/auto.master
/home/ldap /etc/auto.home

[root@server2 ~]\> vim /etc/auto.home
* -rw ipa:/ldaphome/&

[root@server2 ~]\>  systemctl enable autofs ; systemctl start autofs

[root@server2 ~]\> yum install realmd -y
[root@server2 ~]\> realm discover ipa.eight.example.com
eight.example.com
  type: kerberos
  realm-name: EIGH.EXAMPLE.COM
  domain-name: eight.example.com
  configured: kerberos-member
  server-software: ipa
  client-software: sssd
  required-package: ipa-client
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  login-formats: %U
  login-policy: allow-realm-logins

[root@server2 ~]\> yum install ipa-client oddjob oddjob-mkhomedir sssd
[root@server2 ~]\> realm join ipa.eight.example.com


```
</details>

#### *Task20*
Extend the thin volume physica size of 1G and the logical size of 5T


<details>
 <summary>Solution
 </summary>

```bash


```
</details>
