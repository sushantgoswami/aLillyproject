#!/bin/bash
# Version:1.0
# Author : Sushant Goswami
# Script for LVM Administration in Linux
# Declare variable choice and assign value 9
clear
mainscript()
choice=9
# Print to stdout
 echo "1. Display existing LV's PV's VG's info"
 echo "2. Scan for new devices, Create extend VG"
 echo "3. Display the devices available to create PV's"
 echo "4. Create Physical Volume"
 echo "5. Create Volume Group"
 echo "6. Create Logical Volume"
 echo "7. Create filesystem "
 echo "8. Extend existing filesystem "
 echo "9. mount  filesystem "
 echo -n "Please choose a word [1,2,3,4,5,6,7 or 8]? "
##############
while [ $choice -eq 9 ]; do
# read user input
read choice
# bash nested if/else
if [ $choice -eq 1 ] ; then
        echo "===========Displaying the PVS output===========";
        pvs;
        echo "===========Displaying the LVS output===========";
        lvs;
else
if [ $choice -eq 2 ] ; then
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
        comm -2 -3 /tmp/disk-001.txt /tmp/disk-002.txt;
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
        echo "Do you want create a new VG on above disk or add the disk in existing VG";
		echo "1. Create PV on above disk"
		echo "2. To return to main menu"
		echo "Any other key to exit"
        read value1;
        if [ $value1 == "1" ] ; then
		clear;
        cat /tmp/disk-final.txt | awk '{print $2}' | cut -d ":" -f 1 > /tmp/disk-final-devices.txt;
        for i in `cat /tmp/disk-final-devices.txt`;
                do pvcreate $i;
                done
        fi
		if [ $value1 == "2" ] ; then
		clear;
		mainscript
		fi
        echo "Do you want create a new VG on above disk or add the disk in existing VG";
		echo "1. Create a new Volume Group"
		echo "2. Add disk on existing Volume Group"
		echo "3. To return to main menu"
		echo "Any other key to exit"
		read value2
		if [ $value2 == 1 ] ; then
		echo "Create new Volume Group, Enter the VG name";
		echo "1. To create auxvg"
		echo "2. To create oraclevg"
		echo "3. To create mqmvg"
		echo "4. To create own named Volume Group"
		echo "5. To return to main menu"
		echo "Any other key to exit"
		read value3
		if [ $value3 == 1 ] ; then
		disk1=`cat /tmp/disk-final-devices.txt | head -1`;
		vgcreate auxvg $disk1;
		cat /tmp/disk-final-devices.txt | tail -n +2 > /tmp/alldiskleft
		for i in `cat /tmp/alldiskleft`;
		do vgextend auxvg $i;
        done
        fi
		if [ $value3 == 2 ] ; then
		disk1=`cat /tmp/disk-final-devices.txt | head -1`;
		vgcreate oraclevg $disk1;
		cat /tmp/disk-final-devices.txt | tail -n +2 > /tmp/alldiskleft
		for i in `cat /tmp/alldiskleft`;
		do vgextend oraclevg $i;
        done
        fi
		if [ $value3 == 3 ] ; then
		disk1=`cat /tmp/disk-final-devices.txt | head -1`;
		vgcreate mqmvg $disk1;
		cat /tmp/disk-final-devices.txt | tail -n +2 > /tmp/alldiskleft
		for i in `cat /tmp/alldiskleft`;
		do vgextend mqmvg $i;
        done
        fi
		if [ $value3 == 4 ] ; then
		disk1=`cat /tmp/disk-final-devices.txt | head -1`;
		echo "Please enter the Volume Group name :"
		read vgvalue1
		vgcreate $vgvalue1 $disk1;
		cat /tmp/disk-final-devices.txt | tail -n +2 > /tmp/alldiskleft;
		for i in `cat /tmp/alldiskleft`;
		do vgextend $vgvalue1 $i;
        done
        fi	
		if [ $value3 == 5 ] ; then
		mainscript
        fi	
		fi
		if [ $value2 == 2 ] ; then
		echo "Listing the VGS output you have to choose and give the VGname to add all disk";
		vgs;
		echo "=============================================================================";
		echo "Enter the VG name:"
		read vgvalue2
		for i in `cat /tmp/disk-final-devices.txt`;
		do vgextend $vgvalue2 $i;
		done
		fi
		if [ $value2 == 3 ] ; then
		mainscript
        fi
		rm -rf /tmp/alldiskleft;	
		rm -rf /tmp/disk-final.txt;
        rm -rf /tmp/disk-final-devices.txt;
else
if [ $choice -eq 3 ] ; then

else
if [ $choice -eq 4 ] ; then
                        /home/pilankar/LVM_scripts/vgc.sh
else
if [ $choice -eq 5 ] ; then
                        /home/pilankar/LVM_scripts/lvc.sh
else
if [ $choice -eq 6 ] ; then
                        /home/pilankar/LVM_scripts/fsc.sh
else
if [ $choice -eq 7 ] ; then
                        /home/pilankar/LVM_scripts/lv_fs_resize.sh
else
if [ $choice -eq 8 ] ; then
                        /home/pilankar/LVM_scripts/mount.sh
else
echo "Please make a choice between 1-8 !"
echo "1. Display existing LV's PV's VG's info"
echo "2. Display the devices available to create PV's"
echo "3. Create Physical Volume"
echo "4. Create Volume Group"
echo "5. Create Logical Volume"
echo "6. Create filesystem "
echo "7. Extend existing filesystem "
echo "8. mount  filesystem "
echo -n "Please choose a word [1,2,3,4,5,6,7 or 8]? "
choice=9
fi
fi
fi
fi
fi
fi
fi
fi
done
