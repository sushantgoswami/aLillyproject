#!/bin/bash
# Version:1.0
# Author : Sushant Goswami
# Script for LVM Administration in Linux

main_menu()
{
clear
echo "*=======================================================================*";
echo " This Script is intended for administrating Logical Volume"
echo " Management on Redhat Linux 5 and 6 Operating Systems"
echo "*=======================================================================*";
echo " 1. Display existing LV's, PV's, SCSI disk info       "
echo " 2. Scan for new devices (only for redhat 5)          "
echo " 3. PV Administration					                "
echo " 4. VG Administration							        "
echo " 5. LV Administration                                 "
echo " 6. Create and Mount filesystem                       "
echo " 7. Show devices in cache list in previous scan       "
echo " 0. Exit from script                                  "
echo "*=======================================================================*";
echo -n "Please choose a word [1,2,3,4,5,6,7,8 or 0 to exit]? "
read choice
if [ $choice -eq 0 ]; then
 echo "existing from script..."
 exit 0
fi
if [ $choice -eq 1 ]; then
 display_lvm_stat
fi
if [ $choice -eq 2 ]; then
 new_device_admin
fi
if [ $choice -eq 3 ]; then
 pv_admin
fi
if [ $choice -eq 4 ]; then
 vg_admin
else 
 main_menu
fi 
}

display_lvm_stat()
{
clear;
echo "*=======================================================================*";
echo "                   Displaying the PVS output                             ";
echo "*=======================================================================*";
pvs;
echo "*=======================================================================*";
echo "                   Displaying the LVS output                             ";
echo "*=======================================================================*";
lvs;
if [  `uname -r | cut -c 1-6` == "2.6.32" ]; then
echo "*=======================================================================*";
echo "                   Displaying the LSSCSI output                          ";
echo "*=======================================================================*";
lsscsi;
fi
echo "*=======================================================================*";
read -p "Press [Enter] key to go back to main menu"
main_menu
}

new_device_admin()
{
clear;
fdisk -l | grep -i disk | grep bytes | grep -v mapper > /tmp/disk-001.txt;
for i in `ls /sys/class/scsi_host`;
do echo "- - -" > /sys/class/scsi_host/$i/scan;
done
KERNEL_VER=`uname -r | cut -c 1-6`;
fdisk -l | grep -i disk | grep bytes | grep -v mapper > /tmp/disk-002.txt;
if [ $KERNEL_VER == 2.6.18 ] ; then
 echo "\####################################################";
 echo "Disk will be scanned and will show below in Redhat 5";
 echo "\####################################################";
 comm -2 -3 /tmp/disk-002.txt /tmp/disk-001.txt;
 echo "\####################################################";
fi
if [ $KERNEL_VER == 2.6.32 ] ; then
echo "\####################################################";
echo "Disk will be scanned and will show below in Redhat 6";
echo "\####################################################";
comm -2 -3 /tmp/disk-002.txt /tmp/disk-001.txt;
echo "\####################################################";
fi
comm -2 -3 /tmp/disk-002.txt /tmp/disk-001.txt > /tmp/disk-final.txt;
rm -rf /tmp/disk-002.txt;
rm -rf /tmp/disk-001.txt;
echo "*=======================================================================*";
read -p "Press [Enter] key to go back to main menu"
}

pv_admin()
{
clear;
echo "*=======================================================================*";
echo " Do you want create PV on new scanned devices or existing device";
echo " 1. Create PV on new scanned disk";
echo " 2. Create PV on existing scanned disk";
echo " 3. Go to VG administration";
echo " 4. Return to main menu";
echo "*=======================================================================*";
read value1;
if [ $value1 == "1" ] ; then
 clear;
 cat /tmp/disk-final.txt | awk '{print $2}' | cut -d ":" -f 1 > /tmp/disk-final-devices.txt;
 echo "*=======================================================================*";
 echo "                List of newly scanned devices                            ";
 echo "*=======================================================================*";
 cat /tmp/disk-final-devices.txt;
 echo "*=======================================================================*";
 echo "Are you sure to contineu with pvcreate on above newly scanned devices."
 read -r -p "Are you sure? [y/N] " response
 case $response in
    [yY][eE][sS]|[yY])
        for i in `cat /tmp/disk-final-devices.txt`;
        do pvcreate $i;
        done
        ;;
    *)
        echo "You have selected No, returning to previous PV menu";
        pv_admin
        ;;
 esac
fi
if [ $value1 == "2" ] ; then
 echo "*=======================================================================*";
 echo " Enter the device name to create PV. Example: /dev/sdc, /dev/mapper/mpathx";
 echo "*=======================================================================*";
 while true;
  do
   read DEVICE_NAME
   pvcreate $DEVICE_NAME
   read -r -p "Continue with more PV creation? [y/N] " response
        case $response in
    [yY][eE][sS]|[yY])
        echo "processing more PV creation";
                sleep 1;
        ;;
    *)
        pv_admin
        ;;
        esac
   done
fi
if [ $value1 == "3" ] ; then
vg_admin
fi
if [ $value1 == "4" ] ; then
clear;
main_menu
fi
}

vg_admin()
{
clear;
echo "*=======================================================================*";
echo " Do you want add new scanned devices on new VG or existing VG";
echo " 1. Create new VG with new scanned disk, add disk on existing VG";
echo " 2. Go to LV administration";
echo " 3. Return to main menu";
echo "*=======================================================================*";
read value2
clear;
if [ $value2 == "1" ] ; then
echo "*=======================================================================*";
echo " To create a new VG, select below any defined VG or create your own name";
echo " 1. specify and add disk to oraclevg";
echo " 2. specify and add disk to auxvg";
echo " 3. specify and add disk to mqmvg";
echo " 4. specify you own VG";
echo " 5. Return to VG administration";
echo "*=======================================================================*";
 read value3
 if [ $value3 == "1" ] ; then
  clear;
  echo "*=======================================================================*";
  echo " 1. Create oraclevg and add all new disk on it";
  echo " 2. specify the disk and add to oraclevg";
  echo "*=======================================================================*";
  read value4
  if [ $value4 == "1" ] ; then
   DISK1=`cat /tmp/disk-final-devices.txt | head -1`;
   vgcreate oraclevg $DISK1;
   cat /tmp/disk-final-devices.txt | tail -n +2 > /tmp/alldiskleft;
   for i in `cat /tmp/alldiskleft`;
   do vgextend oraclevg $i;
   done
  fi
  if [ $value4 == "2" ] ; then  
    while true;
  do
   read DEVICE_NAME
   vgextend oraclevg $DEVICE_NAME
   read -r -p "Continue with more device addition on oraclevg? [y/N] " response
        case $response in
    [yY][eE][sS]|[yY])
        echo "processing more disk addition";
                sleep 1;
        ;;
    *)
        vg_admin
        ;;
        esac
   done
  fi
 fi
 if [ $value3 == "2" ] ; then
  clear;
  echo "*=======================================================================*";
  echo " 1. Create auxvgvg and add all new disk on it";
  echo " 2. specify the disk and add to auxvg";
  echo "*=======================================================================*";
  read value5
  if [ $value5 == "1" ] ; then
   DISK1=`cat /tmp/disk-final-devices.txt | head -1`;
   vgcreate auxvg $DISK1;
   cat /tmp/disk-final-devices.txt | tail -n +2 > /tmp/alldiskleft;
   for i in `cat /tmp/alldiskleft`;
   do vgextend auxvg $i;
   done
  fi
  if [ $value5 == "2" ] ; then  
    while true;
  do
   read DEVICE_NAME
   vgextend auxvg $DEVICE_NAME
   read -r -p "Continue with more device addition on oraclevg? [y/N] " response
        case $response in
    [yY][eE][sS]|[yY])
        echo "processing more disk addition";
                sleep 1;
        ;;
    *)
        vg_admin
        ;;
        esac
   done
  fi
 fi
 if [ $value3 == "3" ] ; then
  clear;
  echo "*=======================================================================*";
  echo " 1. Create mqmvg and add all new disk on it";
  echo " 2. specify the disk and add to mqmvg";
  echo "*=======================================================================*";
  read value6
  if [ $value6 == "1" ] ; then
   DISK1=`cat /tmp/disk-final-devices.txt | head -1`;
   vgcreate mqmvg $DISK1;
   cat /tmp/disk-final-devices.txt | tail -n +2 > /tmp/alldiskleft;
   for i in `cat /tmp/alldiskleft`;
   do vgextend mqmvg $i;
   done
  fi
  if [ $value6 == "2" ] ; then  
    while true;
  do
   read DEVICE_NAME
   vgextend mqmvg $DEVICE_NAME
   read -r -p "Continue with more device addition on oraclevg? [y/N] " response
        case $response in
    [yY][eE][sS]|[yY])
        echo "processing more disk addition";
                sleep 1;
        ;;
    *)
        vg_admin
        ;;
        esac
   done
  fi
 fi
 if [ $value3 == "4" ] ; then
  clear;
  echo "*=======================================================================*";
  echo " 1. Create you own VG and add all new disk on it";
  echo " 2. specify the disk and add to oraclevg";
  echo "*=======================================================================*";
  read value7
  if [ $value7 == "1" ] ; then
   DISK1=`cat /tmp/disk-final-devices.txt | head -1`;
   echo "Enter the Volume group name";
   read customvg
   vgcreate $customvg $DISK1;
   cat /tmp/disk-final-devices.txt | tail -n +2 > /tmp/alldiskleft;
   for i in `cat /tmp/alldiskleft`;
   do vgextend $customvg $i;
   done
  fi
  if [ $value7 == "2" ] ; then 
   echo "Enter the Volume group name";   
   read customvg
   echo "Enter the device full path to add in VG";
   while true;
   do
    read DEVICE_NAME
    vgextend $customvg $DEVICE_NAME;
    read -r -p "Continue with more device addition on oraclevg? [y/N] " response
    case $response in
    [yY][eE][sS]|[yY])
    echo "processing more disk addition";
    sleep 1;
        ;;
    *)
        vg_admin
        ;;
        esac
   done
  fi
 fi
 if [ $value3 == "5" ] ; then
 vg_admin
 fi
fi
if [ $value2 == "2" ] ; then
 lv_admin
fi
if [ $value2 == "3" ] ; then
 main_menu
fi
}

lv_admin()
{
echo "function for lv administration"
}

sleep 2
main_menu
