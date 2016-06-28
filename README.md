# OpenWRT Image configuration steps: #

1. Change root password
2. Upgrade firmware
3. Configure WiFi
4. Configure 3G dongle
5. Configure SD-CARD
6. Configure Cozy-email client
7. Configure Toby's app client
8. Configure startup

## Change root password ##
Connect to WiFi: Linkit_Smart_7688_1C42E1 (the last 6 characters are board dependent).

Open a browser window and type: http://192.168.100.1 (http://mylinkit.local)

In the password field type the new password and press "Submit".

Login again with the new password.

## Upgrade Firmware ##
LogIn into http://mylinkit.local

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

Copy **usb-mode.json** from the repository to /etc/usb-mode.json. The file sets the vendor and product id for the 3g Dongle. Check with dmesg or lsusb commands. The 3G dongle should be in modem mode (3 serial ports) with /dev/ttyUSB0 as the main modem port. Restart the device if it doesn't show the modem mode.

Uncomment the following lines from /etc/config/network:

       config interface 'wan2'

       option ifname  ppp0

       option device  /dev/ttyUSB0

       option apn data641003

       option service umts

       option proto   3g

The option apn and option device is set for the Huawei 3G dongle.

## Useful Commands ##
Show the kernel logs:
```
dmesg, logread
```

Clean root directory if it gets corrupted (OpenWRT bug):
```
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
**[3G Dongle Setup for OpenWRT](https://wiki.openwrt.org/doc/recipes/3gdongle)**

**[Linkit Manual](http://labs.mediatek.com/fileMedia/download/87c801b5-d1e6-4227-9a29-b5421f2955ac)**

**[LinkIt FAQ](http://labs.mediatek.com/fileMedia/download/47ddd4c6-044f-406d-b395-a108f0aa6b42)**

**[LinkIt WiFi Setup](https://home.labs.mediatek.com/using-mediatek-linkit-smart-7688-as-a-wi-fi-router-how-to-use-a-wi-fi-dongle/)**

**[Kernel Compilation Instructions](https://github.com/MediaTek-Labs/linkit-smart-7688-feed)**
