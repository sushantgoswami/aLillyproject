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
OS_VERSION=`cat /etc/redhat-release`
echo " Current OS is: $OS_VERSION";
MAC_VER=`lspci | grep VMware | head -1`;
if [ -z "$MAC_VER" ]; then
 echo " Current Platform is: Physical Server"
else
 echo " Current Platform is: Vmware Guest Server"
fi
echo "*=======================================================================*";
echo "*============================= Main Menu ===============================*";
echo "*=======================================================================*";
echo " 1. Display existing LV's, PV's, SCSI disk info       "
echo " 2. Scan for new devices          "
echo " 3. PV Administration                                                     "
echo " 4. VG Administration                                                             "
echo " 5. LV Administration                                 "
echo " 6. Create and Mount filesystem                       "
echo " 7. Show devices in cache list in previous scan       "
echo " 9. Show multipath devices                        "
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
fi
if [ $choice -eq 5 ]; then
 lv_admin
fi
if [ $choice -eq 6 ]; then
 create_mount_fs
fi
if [ $choice -eq 9 ]; then
 multipath_out
 read -p "Press [Enter] key to go back to Main menu"
 main_menu
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
echo "*=======================================================================*";
echo " The script will now scan the operating system version and platform";
echo "*=======================================================================*";
read -p "Press [Enter] key to continue";
MAC_VER=`lspci | grep VMware | head -1`;
if [ -z "$MAC_VER" ]; then
  echo "*=======================================================================*";
  echo " The Server is a physical hardware";
  echo "*=======================================================================*";
  sleep 2;
  KERNEL_VER=`uname -r | cut -c 1-6`;
   if [ $KERNEL_VER == 2.6.18 ] || [ $KERNEL_VER == 2.6.32 ] ; then
    fdisk -l | grep -i disk | grep bytes | grep -v mapper | sort -k 2 > /tmp/disk-00001.txt;
    echo " Server is ready to detect the new storage, Inform storage team to add";
    echo " the storage";
    echo "*=======================================================================*";
    read -p "Press [Enter] key to continue, when storage is added"
    for i in `ls /sys/class/scsi_host`;
    do echo "- - -" > /sys/class/scsi_host/$i/scan;
    done
    fdisk -l | grep -i disk | grep bytes | grep -v mapper | sort -k 2 > /tmp/disk-00002.txt;
    echo "*=======================================================================*";
    echo " Below are the new scanned devices";
    echo "*=======================================================================*";
    comm -2 -3 /tmp/disk-00002.txt /tmp/disk-00001.txt;
        rm -rf /tmp/disk-00002.txt; rm -rf /tmp/disk-00001.txt;
    echo "*=======================================================================*";
   else
    echo "*=======================================================================*";
    echo " Scan devices is only appreciable on Redhat 5 and 6";
    echo "*=======================================================================*";
   fi
else
  echo "*=======================================================================*";
  echo " The Server is a VMware machine";
  echo "*=======================================================================*";
  KERNEL_VER=`uname -r | cut -c 1-6`;
   if [ $KERNEL_VER == 2.6.18 ] || [ $KERNEL_VER == 2.6.32 ] ; then
    fdisk -l | grep -i disk | grep bytes | grep -v mapper | sort -k 2 > /tmp/disk-00001.txt;
    echo " Server is ready to detect the new storage, Open Vcenter and add Luns";
    read -p "Press [Enter] key to contineu, when storage is added"
    for i in `ls /sys/class/scsi_host`;
    do echo "- - -" > /sys/class/scsi_host/$i/scan;
    done
    fdisk -l | grep -i disk | grep bytes | grep -v mapper | sort -k 2 > /tmp/disk-00002.txt;
    echo "*=======================================================================*";
    echo " Below are the new scanned vmdk devices";
    echo "*=======================================================================*";
    comm -2 -3 /tmp/disk-00002.txt /tmp/disk-00001.txt;
        rm -rf /tmp/disk-00002.txt; rm -rf /tmp/disk-00001.txt;
    echo "*=======================================================================*";
   else
    echo "*=======================================================================*";
    echo " Scan devices is only applicable on Redhat 5 and 6";
    echo "*=======================================================================*";
   fi
fi
read -p "Press [Enter] key to return to Main Menu";
}

pv_admin()
{
clear;
echo "*=======================================================================*";
echo "*================== Main Menu > PV Administration ======================*";
echo "*=======================================================================*";
echo " 1. Create PV on scanned disk through file (/tmp/pv-devices.txt)";
echo " 2. Create PV on existing scanned disk, Interactive mode";
echo " 3. Create PV in batch mode";
echo " 4. Remove PV in batch mode";
echo " 5. Go to VG Administration";
echo " 6. Go to Main Menu";
echo " 9. Show multipath devices"
echo " 0. Exit from script";
echo "*=======================================================================*";
echo -n "Please choose a word [1,2,3,4,5,6,7,8 or 0 to exit]? ";
read value1;
if [ $value1 == "1" ] ; then
 clear;
 echo "*=======================================================================*";
 echo " Below are the devices found in /tmp/pv-devices.txt";
 echo "*=======================================================================*";
 cat /tmp/pv-devices.txt;
 echo "*=======================================================================*";
 echo "Are you sure to continue with pvcreate on above newly scanned devices."
 read -r -p "Are you sure? [y/N] " response
 case $response in
    [yY][eE][sS]|[yY])
        for i in `cat /tmp/pv-devices.txt`;
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
 echo "*=======================================================================*";
 echo " Create: Please enter the devices, one by one with full path, press ctrl + d, ";
 echo " when finished.";
 echo "*=======================================================================*";
 for i in `cat`; do pvcreate $i; done;
 read -p "Press [Enter] key to go back to PV menu";
 pv_admin
fi
if [ $value1 == "4" ] ; then
 echo "*=======================================================================*";
 echo " Removal: Please enter the devices, one by one with full path, press ctrl + d, ";
 echo " when finished.";
 echo "*=======================================================================*";
 for i in `cat`; do pvremove $i; done;
 read -p "Press [Enter] key to go back to PV menu";
 pv_admin
fi
if [ $value1 == "5" ] ; then
 clear;
 vg_admin
fi
if [ $value1 == "6" ] ; then
 clear;
 main_menu
fi
if [ $value1 == "9" ] ; then
 multipath_out
 read -p "Press [Enter] key to go back to PV Administration"
 pv_admin
fi
if [ $value1 == "0" ]; then
  echo "existing from script..."
  exit 0
fi
pv_admin
}

vg_admin()
{
clear;
echo "*=======================================================================*";
echo "*============== Main Menu > VG Administration ==========================*";
echo "*=======================================================================*";
echo " 1. Create new/exist pre-defined VG and add disk (oraclevg, auxvg, mqmvg)";
echo " 2. Create new/exist VG by your own and add disk";
echo " 3. Remove disk from existing VG"
echo " 4. Remove VG from the server"
echo " 5. Go to LV Administration"
echo " 6. Return to Main Menu";
echo " 9. Show multipath devices";
echo " 0. Exit from script";
echo "*=======================================================================*";
echo -n "Please choose a word [1,2,3,4,5,6,7,8 or 0 to exit]? "
read value2
clear;
if [ $value2 == "1" ] ; then
echo "*=======================================================================*";
echo "*=======================================================================*";
echo "*=======================================================================*";
echo " 1. specify and add disk to new oraclevg/ existing oraclevg";
echo " 2. specify and add disk to new auxvg/ existing auxvg";
echo " 3. specify and add disk to new mqmvg/ existing mqmvg";
echo " 4. Return to VG administration";
echo " 5. Return to Main Menu";
echo " 9. Show multipath devices";
echo " 0. Exit from script";
echo "*=======================================================================*";
echo -n "Please choose a word [1,2,3,4,5,6,7,8 or 0 to exit]? "
 read value3
 if [ $value3 == "1" ] ; then
  clear;
  echo "*=======================================================================*";
  echo "*=======================================================================*";
  echo "*=======================================================================*";
  echo " 1. Create oraclevg and add all  disk on it in batch mode";
  echo " 2. Add disk to existing oraclevg";
  echo " 3. Return to VG administration";
  echo " 4. Return to Main Menu";
  echo " 9. Show multipath devices";
  echo " 0. Exit from script";
  echo "*=======================================================================*";
  echo -n "Please choose a word [1,2,3,4,5,6,7,8 or 0 to exit]? "
  read value4
  if [ $value4 == "1" ] ; then
   echo "*=======================================================================*";
   echo " Please enter all of the disk to add in oraclevg; hit enter if none.";
   echo " Please enter the devices, one by one with full path, press ctrl + d, ";
   echo " when finished.";
   echo "*=======================================================================*";
   cat /dev/null > /tmp/oraclevg-00001.txt;
   for i in `cat`;
   do echo $i >> /tmp/oraclevg-00001.txt;
   done
   if [ -z /tmp/oraclevg-00001.txt ]; then
    echo "No disk entered, returning to VG menu";
        vg_admin
   else
   FIRSTDISK=`head -1 /tmp/oraclevg-00001.txt`;
   vgcreate oraclevg $FIRSTDISK;
   tail -n +2 /tmp/oraclevg-00001.txt > /tmp/oraclevg-00002.txt;
   for i in `cat /tmp/oraclevg-00002.txt`;
    do vgextend oraclevg $i;
   done
   fi
   rm -rf /tmp/oraclevg-00001.txt; rm -rf /tmp/oraclevg-00002.txt;
   read -p "Press [Enter] key to go back to VG Administration";
   vg_admin
  fi
  if [ $value4 == "2" ] ; then
   echo "*=======================================================================*";
   echo " Please enter the devices, one by one with full path, press ctrl + d, ";
   echo " when finished.";
   echo "*=======================================================================*";
   for i in `cat`;
   do vgextend oraclevg $i;
   done
   vg_admin
  fi
  if [ $value4 == "3" ] ; then
   vg_admin
  fi
  if [ $value4 == "4" ] ; then
   main_menu
  fi
  if [ $value4 == "9" ] ; then
  multipath_out
  read -p "Press [Enter] key to go back to VG menu"
  vg_admin
  fi
  if [ $value4 == "0" ]; then
  echo "existing from script..."
  exit 0
  fi
 fi
 if [ $value3 == "2" ] ; then
  clear;
  echo "*=======================================================================*";
  echo "*=======================================================================*";
  echo "*=======================================================================*";
  echo " 1. Create auxvg and add all  disk on it in batch mode";
  echo " 2. Add disk to existing auxvg";
  echo " 3. Return to VG administration";
  echo " 4. Return to Main Menu";
  echo " 9. Show multipath devices";
  echo " 0. Exit from script";
  echo "*=======================================================================*";
  echo -n "Please choose a word [1,2,3,4,5,6,7,8 or 0 to exit]? "
  read value4
  if [ $value4 == "1" ] ; then
   echo "*=======================================================================*";
   echo " Please enter all of the disk to add in auxvg; hit enter if none.";
   echo " Please enter the devices, one by one with full path, press ctrl + d, ";
   echo " when finished.";
   echo "*=======================================================================*";
   cat /dev/null > /tmp/auxvg-00001.txt;
   for i in `cat`;
   do echo $i >> /tmp/auxvg-00001.txt;
   done
   if [ -z /tmp/auxvg-00001.txt ]; then
    echo "No disk entered, returning to VG menu";
        vg_admin
   else
   FIRSTDISK=`head -1 /tmp/auxvg-00001.txt`;
   vgcreate auxvg $FIRSTDISK;
   tail -n +2 /tmp/auxvg-00001.txt > /tmp/auxvg-00002.txt;
   for i in `cat /tmp/auxvg-00002.txt`;
    do vgextend auxvg $i;
   done
   fi
   rm -rf /tmp/auxvg-00001.txt; rm -rf /tmp/auxvg-00002.txt;
   read -p "Press [Enter] key to go back to VG Administration";
   vg_admin
  fi
  if [ $value4 == "2" ] ; then
   echo "*=======================================================================*";
   echo " Please enter the devices, one by one with full path, press ctrl + d, ";
   echo " when finished.";
   echo "*=======================================================================*";
   for i in `cat`;
   do vgextend auxvg $i;
   done
   vg_admin
  fi
  if [ $value4 == "3" ] ; then
   vg_admin
  fi
  if [ $value4 == "4" ] ; then
   main_menu
  fi
  if [ $value4 == "9" ] ; then
  multipath_out
  read -p "Press [Enter] key to go back to VG menu"
  vg_admin
  fi
  if [ $value4 == "0" ]; then
  echo "existing from script..."
  exit 0
  fi
 fi
 if [ $value3 == "3" ] ; then
  clear;
  echo "*=======================================================================*";
  echo "*=======================================================================*";
  echo "*=======================================================================*";
  echo " 1. Create mqmvg and add all  disk on it in batch mode";
  echo " 2. Add disk to existing mqmvg";
  echo " 3. Return to VG administration";
  echo " 4. Return to Main Menu";
  echo " 9. Show multipath devices";
  echo " 0. Exit from script";
  echo "*=======================================================================*";
  echo -n "Please choose a word [1,2,3,4,5,6,7,8 or 0 to exit]? "
  read value4
  if [ $value4 == "1" ] ; then
   echo "*=======================================================================*";
   echo " Please enter all of the disk to add in mqmvg; hit enter if none.";
   echo " Please enter the devices, one by one with full path, press ctrl + d, ";
   echo " when finished.";
   echo "*=======================================================================*";
   cat /dev/null > /tmp/mqmvg-00001.txt;
   for i in `cat`;
   do echo $i >> /tmp/mqmvg-00001.txt;
   done
   if [ -z /tmp/mqmvg-00001.txt ]; then
    echo "No disk entered, returning to VG menu";
        vg_admin
   else
   FIRSTDISK=`head -1 /tmp/mqmvg-00001.txt`;
   vgcreate mqmvg $FIRSTDISK;
   tail -n +2 /tmp/mqmvg-00001.txt > /tmp/mqmvg-00002.txt;
   for i in `cat /tmp/mqmvg-00002.txt`;
    do vgextend mqmvg $i;
   done
   fi
   rm -rf /tmp/mqmvg-00001.txt; rm -rf /tmp/mqmvg-00002.txt;
   read -p "Press [Enter] key to go back to VG Administration";
   vg_admin
  fi
  if [ $value4 == "2" ] ; then
   echo "*=======================================================================*";
   echo " Please enter the devices, one by one with full path, press ctrl + d, ";
   echo " when finished.";
   echo "*=======================================================================*";
   for i in `cat`;
   do vgextend mqmvg $i;
   done
   vg_admin
  fi
  if [ $value4 == "3" ] ; then
   vg_admin
  fi
  if [ $value4 == "4" ] ; then
   main_menu
  fi
  if [ $value4 == "9" ] ; then
  multipath_out
  read -p "Press [Enter] key to go back to VG menu"
  vg_admin
  fi
  if [ $value4 == "0" ]; then
  echo "existing from script..."
  exit 0
  fi
 fi
 if [ $value3 == "4" ] ; then
  vg_admin
 fi
 if [ $value3 == "5" ] ; then
  main_menu
 fi
 if [ $value3 == "9" ] ; then
  multipath_out
  read -p "Press [Enter] key to go back to VG menu"
  vg_admin
 fi
 if [ $value3 == "0" ]; then
  echo "existing from script..."
  exit 0
 fi
fi
if [ $value2 == "2" ] ; then
 echo "*=======================================================================*";
 echo " Please enter the VG name to create:"
 echo "*=======================================================================*";
 read VGNAME
 echo "*=======================================================================*";
 echo " Please enter all of the disk to add in $VGNAME; hit enter if none.";
 echo " Please enter the devices, one by one with full path, press ctrl + d, ";
 echo " when finished.";
 echo "*=======================================================================*";
 cat /dev/null > /tmp/customvg-00001.txt;
 for i in `cat`;
 do echo $i >> /tmp/customvg-00001.txt;
 done
 if [ -z /tmp/customvg-00001.txt ]; then
 echo "No disk entered, returning to VG menu";
 vg_admin
 else
 FIRSTDISK=`head -1 /tmp/customvg-00001.txt`;
 vgcreate $VGNAME $FIRSTDISK;
 tail -n +2 /tmp/customvg-00001.txt > /tmp/customvg-00002.txt;
 for i in `cat /tmp/customvg-00002.txt`;
  do vgextend $VGNAME $i;
 done
 fi
 rm -rf /tmp/customvg-00001.txt; rm -rf /tmp/customvg-00002.txt;
fi
if [ $value2 == "3" ] ; then
 echo "*=======================================================================*";
 echo " Please enter the VG name for removal the disk:"
 echo "*=======================================================================*";
 read VGNAME
 echo "*=======================================================================*";
 echo " Please enter the all of the disk in VG $VGNAME: press ctrl + d "
 echo " when finished"
 echo "*=======================================================================*";
 for i in `cat`; do vgreduce $VGNAME $i; done
 sleep 1;
 read -p "Press [Enter] key to go back to VG Administration";
 vg_admin
fi
if [ $value2 == "4" ] ; then
 echo "*=======================================================================*";
 echo " Please enter the VG name in which you want to remove"
 echo "*=======================================================================*";
 read VGNAME
 vgremove $VGNAME;
 sleep 1;
 read -p "Press [Enter] key to go back to VG Administration";
 vg_admin
fi
if [ $value2 == "5" ] ; then
 lv_admin
fi
if [ $value2 == "6" ] ; then
 main_menu
fi
if [ $value2 == "9" ] ; then
 multipath_out
 read -p "Press [Enter] key to go back to VG menu"
 vg_admin
fi
if [ $value2 == "0" ]; then
  echo "existing from script..."
  exit 0
fi
}

lv_admin()
{
clear;
echo "*=======================================================================*";
echo "*============== Main Menu > LV Administration ==========================*";
echo "*=======================================================================*";
echo " 1. Create new LV on existing VG";
echo " 2. Mount/Unmount the Filesystem";
echo " 3. Remove LV from existing VG"
echo " 4. Extend LV without 100% PVS"
echo " 5. Extend LV with 100% PVS"
echo " 6. Return to Main Menu";
echo " 7. Return to PV Administration";
echo " 8. Return to VG Administration";
echo " 9. Show multipath devices";
echo " 0. Exit from script";
echo "*=======================================================================*";
echo -n "Please choose a word [1,2,3,4,5,6,7,8 or 0 to exit]? "
read value1
if [ $value1 == "0" ]; then
  echo "existing from script..."
  exit 0
fi
if [ $value1 == "9" ]; then
 multipath_out
 read -p "Press [Enter] key to go back to LV Administration"
 lv_admin
fi
if [ $value1 == "8" ]; then
 vg_admin
fi
if [ $value1 == "7" ]; then
 pv_admin
fi
if [ $value1 == "6" ]; then
 main_menu
fi
if [ $value1 == "1" ]; then
 echo "*=======================================================================*";
 echo " Please enter the VG name where you want to create LV";
 echo " Currently available VG are";
 echo "*=======================================================================*";
 vgs | awk '{print $1}' | tail -n +2;
 echo "*=======================================================================*";
 read VGNAME
 echo "*=======================================================================*";
 echo " Please enter the LV name, existing LV in selected VG are below";
 echo "*=======================================================================*";
 lvs | grep $VGNAME | awk '{print $1}'
 echo "*=======================================================================*";
 read LVNAME
 echo " Please enter the size of LV ( Example 10g 10m )";
 read LVSIZE
 echo " You have given the details as below";
 echo "*=======================================================================*";
 echo " VGNAME = $VGNAME";
 echo " LVNAME = $LVNAME";
 echo " SIZE OF LV = $LVSIZE";
 echo "*=======================================================================*";
 echo " Continue with LV creation, press y to confirm, any other key to LV Administration";
  read value2
  if [ $value2 == "y" ]; then
   lvcreate -n $LVNAME -L +$LVSIZE $VGNAME;
   if [ $? == "0" ]; then
   echo "*=======================================================================*";
   echo " Do you want to format the current LV, Press y to proceed or any other";
   echo " key to return to LV Administration";
   echo "*=======================================================================*";
   read CONFIRMATION
    if [ $CONFIRMATION == "y" ]; then
     echo "*=======================================================================*";
     echo " Please specify the filesystem type to format the LV";
     echo " 1. ext3             4. xfs";
     echo " 2. ext4             5. vxfs";
     echo " 3. swap";
     echo "*=======================================================================*";
     read FSTYPE
      case $FSTYPE in
       1) mkfs.ext3 /dev/$VGNAME/$LVNAME ;;
       2) mkfs.ext4 /dev/$VGNAME/$LVNAME ;;
       3) mkswap /dev/$VGNAME/$LVNAME ;;
       4) mkfs.xfs /dev/$VGNAME/$LVNAME ;;
       5) mkfs.vxfs /dev/$VGNAME/$LVNAME ;;
       *) lv_admin ;;
      esac
    fi
   fi
   read -p "Press [Enter] key to go back to LV Administration";
   lv_admin
  else
   echo "Returning to LV Administration"; sleep 1;
   lv_admin
  fi
fi
}

multipath_out()
{
 cat /dev/null > /tmp/multipath-001.txt; cat /dev/null > /tmp/multipath-002.txt; cat /dev/null > /tmp/multipath-003.txt; cat /dev/null > /tmp/multipath-004.txt;
 pvs | grep lvm | grep -v rootvg | sort -k 1 > /tmp/multipath-003.txt;
 fdisk -l | grep Disk | grep -v mapper | grep -v identifier > /tmp/multipath-004.txt;
 MAC_VER=`lspci | grep VMware | head -1`;
 if [ -z "$MAC_VER" ]; then
  multipath -l | grep mpath | awk '{print $1}' > /tmp/multipath-001.txt;
  for i in `cat /tmp/multipath-001.txt`; do fdisk -l /dev/mapper/$i | grep /dev/mapper/$i; done | sort -k 2 >> /tmp/multipath-002.txt;
  echo "*==============================================================================================================*";
  echo "  All multipath Devices              Size                  LVM PV Devices     VG    Type      PV-Size  PV-Free  ";
  echo "*==============================================================================================================*";
  paste /tmp/multipath-002.txt /tmp/multipath-003.txt;
 else
  echo "*==============================================================================================================*";
  echo "  All VMDK Devices              Size                  LVM PV Devices     VG    Type      PV-Size  PV-Free       ";
  echo "*==============================================================================================================*";
  paste /tmp/multipath-004.txt /tmp/multipath-003.txt;
 fi
  cat /dev/null > /tmp/multipath-001.txt; cat /dev/null > /tmp/multipath-002.txt; cat /dev/null > /tmp/multipath-003.txt; cat /dev/null > /tmp/multipath-004.txt;
  echo "*==============================================================================================================*";
}
sleep 2
main_menu
