# OpenWRT Device Configuration Steps #

1. Change root password
2. Upgrade firmware
3. Configure WiFi
4. Configure 3G dongle
5. Configure SD-CARD
6. Configure Cozy-email client
7. Configure Toby's app client
8. Configure startup script
9. Device management

## Change root password ##
Connect to WiFi: Linkit_Smart_7688_1C42E1 (the last 6 characters are board dependent).

Open a browser window and type: http://192.168.100.1

In the password field type the new password and press "Submit".

Login again with the new password.

## Upgrade Firmware ##
Open in browser http://192.168.100.1

Press "Upgrade Firmware"

Choose the file from the git repository: **lks7688.img**

Press "Upgrade and Restart"

After the upgrade login to: http://192.168.100.1/cgi-bin/luci

From the menu choose System/Backup/Flash Firmware

Restore backup:

Choose file from the repository: **backup-mylinkit-2016-06-27.tar.gz**. The restore backup options will copy all the files from the archive into the etc directory.

Press "Upload Archive"

Reconnect again to Linkit_Smart_7688_1C42E1 if it losses connection WiFi.

## Configure WiFi ##
LogIn into the shell with: ssh root@192.168.100.1

The configuration for the WiFi USB is located in /etc/config/wireless

A typical WiFi options:

       config wifi-device  radio3
       option type     mac80211                            
       option channel  11                                      
       option hwmode   11g                
       option path     '101c1000.ohci/usb2/2-1/2-1.1/2-1.1:1.0'
       option htmode   HT20                                
       option disabled 0

       config wifi-iface
       option device   'radio3'                            
       option network  'wan'                               
       option mode     'sta'                                   
       option ssid     'AMNET'
       option key '1234554321'                                 
       option encryption 'psk2'

The option path "101c1000.ohci/usb2/2-1/2-1.1/2-1.1:1.0" depends on where the WiFi USB is installed. Use

```
wifi detect
```
to retrieve the correct option path. Set the correct option ssid and option key.

To restart the wifi connection use:

```
wifi
```
Reconnect again to Linkit_Smart_7688_1C42E1 WiFi if it losses connection.

## Configure 3G Dongle ##
LogIn into the shell with: ssh root@192.168.100.1

Copy **usb-mode.json** from the repository to /etc/usb-mode.json. The file sets the vendor and product id for the 3g Dongle. Check with dmesg or lsusb commands. The 3G dongle should be in modem mode (3 serial ports) with /dev/ttyUSB0 as the main modem port. Restart the device if it doesn't show the modem mode.

Uncomment the following lines from /etc/config/network:

       config interface 'wan2'
       option ifname  ppp0
       option device  /dev/ttyUSB0
       option apn data641003
       option service umts
       option proto   3g

The option apn and option device is set for the Huawei 3G dongle.

Add wan2 to the option network 'wan wan6' in /etc/config/firewall:

        config zone
        option name 'wan'
        option output 'ACCEPT'
        option forward 'REJECT'
        option masq '1'
        option mtu_fix '1'
        option input 'ACCEPT'
        option network 'wan wan2 wan6'

Restart the wan interface:
```
ifup wan
```
Reconnect again to Linkit_Smart_7688_1C42E1 WiFi if it losses connection.

## Configure SD-CARD ##
LogIn into the shell with: ssh root@192.168.100.1

Find the SD-CARD partition:
```
fdisk -l
```
It is usually /dev/mmcblk0p1.

Format the SD-CARD to ext4:
```
mkfs.ext4 /dev/mmcblk0p1
```
Click on the default options.

Install block-mount package (interent connection required, WiFi or 3G Dongle):
```
opkg update
opkg install block-mount
```
Add to /etc/config/fstab the following:

        config 'mount'
        option 'device' '/dev/mmcblk0p1'
        option 'options' 'rw,async'
        option 'enabled_fsck' '0'
        option 'enabled' '1'
        option 'target' '/root'

Mount the SD-CARD to /root with:
```
/etc/init.d/fstab start
```

Execute on device startup:
```
/etc/init.d/fstab enable
```
Check if the SD-CARD mounted with:
```
df -h
```
## Configure Cozy-Email Client ##
Clone the cozy-email repo into /root:
```
cd /root
git clone https://user@github.com/nqminds/cozy-emails.git
```
Replace 'user' in the above command with the git account username. 

## Configure Toby's App Client ##
Clone the Toby's app client repo into /root:
```
cd /root
git clone https://user@github.com/nqminds/nqm-remote-device-wrt.git
```
Replace 'user' in the above command with the git account username. 

## Configure Startup Script##
Install coreutils-nohup package:
```
opkg update
opkg install coreutils-nohup
```

Add the following lines to /etc/rc.local:
```
export HOME=/root
export DEBUG=*
nohup /root/cozy-emails/bin/emails > /root/cozy-emails.log 2>&1 &
nohup node --harmony_proxies /root/nqm-remote-device-wrt/index.js > /root/toby-app.log 2>&1 &

```
The above line will start the apps in background when the device starts and saves the output in a log file *.log. To ommit the log file use:
```
export HOME=/root
export DEBUG=*
nohup /root/cozy-emails/bin/emails > /dev/null 2>&1 &
nohup node --harmony_proxies /root/nqm-remote-device-wrt/index.js > /dev/null 2>&1 &
```

[Optional] If nedded the cozy-email-run.sh restarts the cozy-email node app if it crashes.

[Optional] Copy **cozy-email-run.sh** from the git repository to /root and execute the following commands.
```
cd /root
chmod +x cozy-email-run.sh
```
[Optional] Add the following lines to /etc/rc.local:
```
export HOME=/root
export DEBUG=*
nohup /root/cozy-email-run.sh > /root/cozy-emails.log 2>&1 &
nohup node --harmony_proxies /root/nqm-remote-device-wrt/index.js > /dev/null 2>&1 &
```

## Device Management ##
Connect to the device WiFi.

### Apps ###
When the device restarts there will be the following apps available from the broser:

1. Cozy-emails:
       [mylinkit.local:9125](http://mylinkit.local:9125)
2. NQM-Remote-Device:
       [mylinkit.local:8125](http://mylinkit.local:8125)
3. LUCI interface:
       [mylinkit.local/cgi-bin/luci](http://mylinkit.local/cgi-bin/luci)
4. Linkit Smart interface:
       [mylinkit.local](http://mylinkit.local)

### WiFi ###
One can change the WiFi SSID and password by following the instructions in step 3. However for everyday use the easist way is to login into LUCI interface: [mylinkit.local/cgi-bin/luci](http://mylinkit.local/cgi-bin/luci). Then go to the menu Network/WiFi. There press on the "Edit" button for Generic 802.11 Wireless Controller (radio3). In the "General setup" for "Interface configuration" edit ESSID (name of the WiFi network) and in "Wireless security" edit Key (WiFi network password). Then press "Save & Apply" button.

## Useful Commands ##
Show the kernel logs:
```
dmesg, logread
```

Clean "/" directory if it gets corrupted (OpenWRT bug):
```
cd /
find . -maxdepth 1 -type f -exec rm -f {} \;
```
Execute the above command form the root directory.

Package list update:
```
opkg update
```

Package list install:
```
opkg install packagename
```

Text editor:
```
vi
```

## Links ##
**[OpenWRT commands](https://wiki.openwrt.org/doc/howto/user.beginner.cli)**

**[3G Dongle Setup for OpenWRT](https://wiki.openwrt.org/doc/recipes/3gdongle)**

**[Linkit Manual](http://labs.mediatek.com/fileMedia/download/87c801b5-d1e6-4227-9a29-b5421f2955ac)**

**[LinkIt FAQ](http://labs.mediatek.com/fileMedia/download/47ddd4c6-044f-406d-b395-a108f0aa6b42)**

**[LinkIt WiFi Setup](https://home.labs.mediatek.com/using-mediatek-linkit-smart-7688-as-a-wi-fi-router-how-to-use-a-wi-fi-dongle/)**

**[Kernel Compilation Instructions](https://github.com/MediaTek-Labs/linkit-smart-7688-feed)**
