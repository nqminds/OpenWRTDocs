# OpenWRT configs for BYOD project

## OpenWRT Device Configuration Steps #

1. Change root password
2. Upgrade firmware
3. Configure WiFi
4. (a)Configure 3G dongle (PPP option)
4. (b)Configure 3G dongle (CDC Ethernet option)
5. Configure SD-CARD
6. Configure Cozy-email client
7. Configure Toby's app client
8. Configure startup script
9. Device management
10. Apps

## 1. Change root password ##
Connect to WiFi: Linkit_Smart_7688_1C42E1 (the last 6 characters are board dependent).

Open a browser window and type: http://192.168.100.1

In the password field type the new password and press "Submit".

Login again with the new password.

## 2. Upgrade Firmware ##
Open in browser http://192.168.100.1 Login with the password from the previous step. 

Press "Upgrade Firmware"

Choose one of the image files from the OpenWRTDocs git repository (clone it on your host PC):

1. **lks7688.img** (for the 3G dongle in PPP mode)

2. **lks7688_cdc_ether.img** (for the 3G dongle in CDC Ethernet mode)

Press "Upgrade and Restart"

After the upgrade login to: http://192.168.100.1/cgi-bin/luci

From the menu choose System/Backup/Flash Firmware

Restore backup:

Choose file from the OpenWRtDocs git repository: **backup-mylinkit-2016-06-27.tar.gz**. The restore backup options will copy all the files from the archive into the Linkit Smart /etc/ directory.

Press "Upload Archive"

Reconnect again to Linkit_Smart_7688_1C42E1 if it losses connection WiFi. After the restoring the backup the password is set to: 1234554321. Use the backup password to set a new password.

## 3. Configure WiFi ##
Login into the shell with: sudo ssh root@192.168.100.1. Connect the WiFi dongle to the 4 port hub and check with 'lsusb' command if the device detects the dongle.

The configuration for the WiFi USB is located in /etc/config/wireless

A typical WiFi options:
```
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
```
The option path "101c1000.ohci/usb2/2-1/2-1.1/2-1.1:1.0" depends on which port the WiFi USB is installed. Use

```
wifi detect
```
to retrieve the correct option path. Set the correct option ssid and option key.

To restart the wifi connection use:
```
wifi
```
Reconnect again to Linkit_Smart_7688_1C42E1 WiFi if it losses connection. To check for internet connectivity use:
```
ifconfig
```
There should be a similar entry to the following:
```
wlan455   Link encap:Ethernet  HWaddr 00:13:EF:B0:11:76  
          inet addr:192.168.0.7  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::213:efff:feb0:1176/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1548 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1326 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:392714 (383.5 KiB)  TX bytes:308049 (300.8 KiB)
```  
The address wlan455 might differ. If there is internet connection inet addr field will show a valid IP address.

## 4. (a) Configure 3G Dongle (PPP mode) ##
Before following the instructions make sure that you uploaded the image **lks7688.img** in step 2.

Login to shell with: ssh root@192.168.100.1. Check that there's internet connection:
```
ifconfig
```
Download the comgt package:
```
opkg update
opkg install comgt
```
Copy **usb-mode.json** from the repository to /etc/usb-mode.json. The file sets the vendor and product id for the 3g Dongle. Check with dmesg or lsusb commands. The 3G dongle should be in modem mode (3 serial ports) with /dev/ttyUSB0 as the main modem port. Restart the device if it doesn't show the modem mode.

Uncomment the following lines from /etc/config/network:
```
config interface 'wan2'
       option ifname  ppp0
       option device  /dev/ttyUSB0
       option apn data641003
       option service umts
       option proto   3g
```
The option apn and option device is set m2mpod sim and Huawei 3g Dongle. For a different sim set the option apn and the username and password options if required in /etc/config/network:
```
option username yourusername
option password yourpassword
```

Add wan2 to the option network 'wan wan6' in /etc/config/firewall:
```
config zone
        option name 'wan'
        option output 'ACCEPT'
        option forward 'REJECT'
        option masq '1'
        option mtu_fix '1'
        option input 'ACCEPT'
        option network 'wan wan2 wan6'
```
Replace the text in /etc/chatscripts/3g.chat with:
```
ABORT   BUSY
ABORT   'NO CARRIER'
ABORT   ERROR
REPORT  CONNECT
TIMEOUT 10
""      "AT&F"
OK      "ATE1"
OK      'AT+CGDCONT=1,"IP","$USE_APN"'
SAY     "Calling UMTS/GPRS"
TIMEOUT 30
OK      "ATD*99***1#"
CONNECT ' '
```
Restart the wan interface or reboot:
```
ifup wan2
```
Reconnect again to Linkit_Smart_7688_1C42E1 WiFi if it losses connection.

Check the modem connection with:
```
logread
```
There should be the following lines:
```
Fri Jul  1 16:57:13 2016 daemon.notice pppd[25926]: pppd 2.4.7 started by root, uid 0
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: abort on (BUSY)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: abort on (NO CARRIER)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: abort on (ERROR)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: report (CONNECT)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: timeout set to 10 seconds
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: send (AT&F^M)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: expect (OK)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: AT&F^M^M
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: OK
Fri Jul  1 16:57:14 2016 local2.info chat[25928]:  -- got it
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: send (ATE1^M)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: expect (OK)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: ^M
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: ATE1^M^M
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: OK
Fri Jul  1 16:57:14 2016 local2.info chat[25928]:  -- got it
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: send (AT+CGDCONT=1,"IP","data641003"^M)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: timeout set to 30 seconds
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: expect (OK)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: ^M
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: AT+CGDCONT=1,"IP","data641003"^M^M
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: OK
Fri Jul  1 16:57:14 2016 local2.info chat[25928]:  -- got it
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: send (ATD*99***1#^M)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: expect (CONNECT)
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: ^M
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: ATD*99***1#^M^M
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: CONNECT
Fri Jul  1 16:57:14 2016 local2.info chat[25928]:  -- got it
Fri Jul  1 16:57:14 2016 local2.info chat[25928]: send ( ^M)
Fri Jul  1 16:57:14 2016 daemon.info pppd[25926]: Serial connection established.
Fri Jul  1 16:57:14 2016 kern.info kernel: [  499.500000] 3g-wan2: renamed from ppp0
Fri Jul  1 16:57:14 2016 daemon.info pppd[25926]: Using interface 3g-wan2
Fri Jul  1 16:57:14 2016 daemon.notice pppd[25926]: Connect: 3g-wan2 <--> /dev/ttyUSB0
```

If the modem doesn't connect change the line 'OK "ATD*99***1#"' from /etc/chatscripts/3g.chat to 'OK "ATD*99#"'. The line defines the dialup number for the modem. Restart the connection with 'ifup wan2'.

Check the internet connectivity with:
```
ifconfig
```
There should be the entry 3g-wan2.

If with 'logread' you see the following lines:
```
Fri Jul  1 16:57:18 2016 kern.info kernel: [  503.540000] usb 2-1: USB disconnect, device number 67
Fri Jul  1 16:57:18 2016 kern.err kernel: [  503.550000] option1 ttyUSB0: usb_wwan_indat_callback: resubmit read urb failed. (-19)
Fri Jul  1 16:57:18 2016 kern.err kernel: [  503.570000] option1 ttyUSB0: usb_wwan_indat_callback: resubmit read urb failed. (-19)
Fri Jul  1 16:57:18 2016 kern.err kernel: [  503.590000] option1 ttyUSB0: usb_wwan_indat_callback: resubmit read urb failed. (-19)
Fri Jul  1 16:57:18 2016 kern.err kernel: [  503.600000] option1 ttyUSB0: usb_wwan_indat_callback: resubmit read urb failed. (-19)
Fri Jul  1 16:57:18 2016 kern.info kernel: [  503.620000] usb 2-1.1: USB disconnect, device number 68
Fri Jul  1 16:57:18 2016 kern.info kernel: [  503.630000] usb 2-1.3: USB disconnect, device number 69
Fri Jul  1 16:57:18 2016 kern.info kernel: [  503.650000] option1 ttyUSB0: GSM modem (1-port) converter now disconnected from ttyUSB0
Fri Jul  1 16:57:18 2016 kern.info kernel: [  503.660000] option 2-1.3:1.0: device disconnected
Fri Jul  1 16:57:18 2016 kern.info kernel: [  503.670000] option1 ttyUSB1: GSM modem (1-port) converter now disconnected from ttyUSB1
Fri Jul  1 16:57:18 2016 kern.info kernel: [  503.690000] option 2-1.3:1.1: device disconnected
Fri Jul  1 16:57:18 2016 kern.info kernel: [  503.700000] option1 ttyUSB2: GSM modem (1-port) converter now disconnected from ttyUSB2
Fri Jul  1 16:57:18 2016 kern.info kernel: [  503.710000] option 2-1.3:1.2: device disconnected
Fri Jul  1 16:57:18 2016 daemon.notice pppd[25926]: Modem hangup
Fri Jul  1 16:57:18 2016 daemon.notice pppd[25926]: Connection terminated.
```
then the modem can't connect to the network.

To diagnose any issues with the 3g Dongle use:
```
gcom -d /dev/ttyUSB2 info
```
where /dev/ttyUSB2 is the debug serial port for the Huawei 3G dongle.

## 5. (b) Configure 3G Dongle (CDC Ethernet mode) ##
Before following the instructions make sure that you uploaded the image **lks7688_cdc_ether.img** in step 2. Also make sure that the 3G dongle together with the SIM card works properly in CDC Ethrenet mode (there is a new network interface eth* with IP address 192.168.x.x) on a Linux machine, i.e., there is internet connection.

Replace the contents of /etc/usb-mode.json from the device with **usb-modep-cdc.json** from the git repository. The file sets the vendor and product id for the 3G Dongle. Reboot and check with lsusb command whether the 3G dongle is in the CDC Ethernet mode:
```
Bus 002 Device 019: ID 12d1:14dc Huawei Technologies Co., Ltd.
```
Check with 'dmesg' command if there modem is in the rigth mode:
```
[   31.290000] cdc_ether 2-1.3:1.0 eth1: register 'cdc_ether' at usb-101c1000.ohci-1.3, CDC Ethernet Device, 00:1e:10:1f:00:00
[   31.330000] cdc_ether 2-1.3:1.0 eth1: kevent 12 may have been dropped
[   31.350000] cdc_ether 2-1.3:1.0 eth1: kevent 11 may have been dropped
[   31.380000] cdc_ether 2-1.3:1.0 eth1: kevent 11 may have been dropped
[   31.410000] usb-storage 2-1.3:1.2: no of_node; not parsing pinctrl DT
```
The new registered network interface for the 3G dongle is eth1.

Add to /etc/config/network the following lines:
```
config interface 'wwan'
        option ifname eth1
        option proto 'dhcp'
```

Add wwan to the option network 'wan wan6' in /etc/config/firewall:
```
config zone
        option name 'wan'
        option output 'ACCEPT'
        option forward 'REJECT'
        option masq '1'
        option mtu_fix '1'
        option input 'ACCEPT'
        option network 'wan wwan wan6'
```

Check with 'ifconfig' that there is the new 'eth1' network interface.

## 6. Configure SD-CARD ##
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
## 7. Configure Cozy-Email Client ##
Clone the cozy-email repo into /root:
```
cd /root
git clone https://user@github.com/nqminds/cozy-emails.git
```
Replace 'user' in the above command with the git account username. 

## 8. Configure Toby's App Client ##
Clone the Toby's app client repo into /root:
```
cd /root
git clone https://user@github.com/nqminds/nqm-remote-device-wrt.git
```
Replace 'user' in the above command with the git account username. 

## 9. Configure Startup Script##
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

## 10. Device Management ##
Connect to the device's WiFi network if the internet is not shared between the device and the user (for instace when the device is connected to a 3G Dongle). If the device and the user share the same internet connection (through the same WiFi router) one doesn't need to connect to the device's WiFi network to access the apps, etc. 

### 11. Apps ###
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

### 3G Dongle ###
If the PPP mode of the 3G dongle is not working properly then use the CDC Ethernet mode. The 3g Dongle Ethernet mode does not reset the USB connection of the WiFi dongle so both of them can be used at the same time. 

To shutdown the connectcion for the 3G dongle go to http://mylinkit.local/cgi-bin/luci then Network/Interface and press on the Stop button for the WWAN connection.

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
