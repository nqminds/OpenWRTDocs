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
#!wifi detect

wifi detect
```
to retrieve the correct option path. Set the correct option ssid and option key.

To restart the wifi connection use:

```
#!wifi

wifi
```

## Configure 3G Dongle ##

Copy **usb-mode.json** from the repository to /etc/usb-mode.json. The file sets the vendor and product id for the 3g Dongle.
