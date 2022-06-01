#!/bin/bash
# Vers Date         CHG          Author
# 001  23-Mar-2017  XXXXXXXXXX  Arun Singh
CURRENTDATE=`date | awk '{print "<"$3"-"$2"-"$6"-"$4">"}'`
CURRENTHOST=`uname -a | awk '{print $2}'`
EMAIL_ID=TCS_DM_ORACLE@lists.lilly.com
mkdir /tmp/tempdir-$CURRENTDATE
TEMP_DIR=/tmp/tempdir-$CURRENTDATE
LOG_FILE=$TEMP_DIR/rsync-migration-logs-$CURRENTDATE

mainscript()
{
choice=100
clear
echo "####################################################################################"
echo "##### The Script is intended to Rsync the data from one server to another  #########"
echo "####################################################################################"
echo "## Below are the options to choose the operations                                 ##"
echo "## ==============================================                                 ##"
echo "## 1. Check password less login to the target  server                             ##"
echo "## 2. Check and match the filesystems between source and target server            ##"
echo "## 3. Check UID and GID of oracle user on source and target server                ##"
echo "## 4. Shutdown the all Oracle databases on the server                             ##"
echo "## 5. Rsync the ORA (Oracle) filesystem  from source to target server             ##"
echo "## 0. To exit from the Script                                                     ##"
echo "## ==============================================                                 ##"
echo "## Enter your option 1,2,3,4 or 0 key to exit                                     ##"
echo "## ==============================================                                 ##"
echo "####################################################################################"
read choice
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
echo "Sorry Integers only accepted"
read -n 1 -s -p "Press any key to continue"
mainscript
fi
if [ $choice -eq 1 ]; then
echo "############################################################################"
echo "### Script will try to login to the another server and grab its name #######"
echo "############################################################################"
echo "Please enter the target server hostname only (No domain name Required)"
read TARGET_HOST
 if [ -z $TARGET_HOST ]; then
  echo "Target host must be passed, you can't leave it blank, returning to main menu"
  read -p "Press enter to continue"
  mainscript
 fi
echo "trying to login to the target and grab its hostname, if it ask for password"
echo "then you have to setup the proxy (password less authentication through oracle user"
sleep 2
TARGET_FIND=`ssh -q oracle@$TARGET_HOST uname -n`
if [ -z $TARGET_FIND ]; then
 echo "Something is wrong, I didnt get the another server hostname"
 echo "You should try to copy the ssh keys again"
 echo "I will now try verbose login so you can see the erroris, may be it will ask for password"
 read -p "Press enter to continue"
 echo "####################################################################################"
 ssh oracle@$TARGET_HOST
 echo "####################################################################################"
 read -p "Press enter to continue"
 echo "should I check for ssh-keys available on this server, answer y to yes, any key to back to menu"
 read choice2
 if [[ $choice2 == 'y' ]]; then
  sleep 1
  echo "Looking for keys in home directory"
  if [ -f /oracle/.ssh/id_rsa.pub ]; then
   echo "Found one RSA key id in home directory"
   echo "printing the RSA public key"
   echo "####################################################################################"
   echo "Printing /oracle/.ssh/id_rsa.pub"
   cat /oracle/.ssh/id_rsa.pub
   echo "####################################################################################"
  fi
  if [ -f /home/oracle/.ssh/id_rsa.pub ]; then
   echo "Found one RSA key id in home directory"
   echo "printing the RSA public key"
   echo "####################################################################################"
   echo "Printing /home/oracle/.ssh/id_rsa.pub"
   cat /home/oracle/.ssh/id_rsa.pub
   echo "####################################################################################"
  fi
 fi
fi
if [[ $TARGET_FIND == $TARGET_HOST ]]; then
 echo "The hostname matches you entered matches the hostname I got from another node"
 echo "Cheers, your keyless auth is working"
fi
read -p "Press enter to back to main script"
mainscript
fi
################################ End of Choice 1 ################################
if [ $choice -eq 2 ]; then
echo "###################################################################################"
echo "##### Script will try to pull up the oracle file systems from another server ######"
echo "###################################################################################"
echo "Please enter the target server hostname (No Domain Name Required)"
read TARGET_HOST
sleep 1
 if [ -n $TARGET_HOST ]; then
  clear
  echo "############################ File systems on target host ##########################"
  df -Phl | head -1
  ssh -q $TARGET_HOST df -Phl | egrep "ora|arch|redo"
  echo "###################################################################################"
  echo " "
  echo " "
  echo "############################ File systems on local host ###########################"
  df -Phl | head -1
  df -Phl | egrep "ora|arch|redo"
  echo "###################################################################################"
 fi
read -p "Press enter to back to main script"
mainscript
fi
################################ End of Choice 2 ################################
if [ $choice -eq 3 ]; then
echo "This portion is in progress"
read -p "Press enter to continue"
mainscript
fi
################################ End of Choice 3 ################################
if [ $choice -eq 4 ]; then
 if [ -f /oracle/local/scripts/oracle_shutdown.ksh ]; then
  echo "###################################################################################"
  echo "Do you want to stop all databases running on the server, Press y to contineu"
  echo "Any other key to exit"
  echo "###################################################################################"
  read choice4
   if [[ $choice4 == 'y' ]]; then
   echo "############## stopping all databases ###################"
   /oracle/local/scripts/oracle_shutdown.ksh
   echo "############## stopping all databases ###################"
   echo "############## checking the database if they are running #############"
   PID_CHECK=`ps -ef | grep pmon | grep -v grep | awk '{print $1}'`
    if [ -z $PID_CHECK ]; then
     echo "no databases found running on the server"
     echo "############## checking the database if they are running #############"
     read -p "Press enter to continue"
     mainscript
    else
     echo "found below database still running on the server"
     ps -ef | grep pmon | grep -v grep
     echo "############## checking the database if they are running #############"
    fi
   fi
 else
  echo "/oracle/local/scripts/oracle_shutdown.ksh script not found"
  read -p "Press enter to continue"
  mainscript
 fi
fi
################################ End of Choice 4 ################################
if [ $choice -eq 5 ]; then
clear
echo "###################################################################################"
echo "##### Script will try to sync the target server ORA filesystem using RSYNC method ##"
echo "###################################################################################"
read -p "Press enter to continue"
echo "###################################################################################"
echo "##### 1. Sync/Copy all ORACLE filesystem using RSYNC without exclusion ############"
echo "##### 2. Sync/Copy only selected Filesystem usin RSYNC (with exclude list) ########"
echo "##### 3. Sync/Copy using RSYNC with Batch mode (Maximum 5 Batch jobs) #############"
echo "##### 9. Exit to mainscript                                       #################"
echo "##### 0. Exit from the script                               #######################"
echo "###################################################################################"
read choice
 if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
 echo "Sorry Integers only accepted"
 read -n 1 -s -p "Press any key to continue"
 mainscript
 fi
 if [ $choice -eq 1 ]; then
 clear
 echo "###################################################################################"
 echo "##### Script will try to Sync/copy the FS using Rsync method ######################"
 echo "###################################################################################"
 echo "##### Enter the Source Filesystem Name from this server ex- /oracle  ##############"
 echo "###################################################################################"
 read SOURCE_DIR
 echo "###################################################################################"
 echo "##### Enter the Destination Filesystem Name to sync/copy from this server #########"
 echo "###################################################################################"
 read DEST_DIR
 echo "###################################################################################"
 echo "##### Enter the Destination Server Name ###########################################"
 echo "###################################################################################"
 read TARGET_HOST
 if [ -z $TARGET_HOST ]; then
  echo "Target host must be passed, you can't leave it blank, returning to main menu"
  read -p "Press enter to continue"
  mainscript
 fi
 echo "###################################################################################"
 echo "##### The script will execute below command on this server ########################"
 echo "###################################################################################"
 ACTUAL_DEST_DIR=`echo $DEST_DIR | rev | cut -d "/" -f 2,3,4,5 | rev`
 ACTUAL_DEST_DIR=`echo $DEST_DIR | rev | cut -d "/" -f 2,3,4,5 | rev`
 if [ -z $ACTUAL_DEST_DIR ]; then
 ACTUAL_DEST_DIR=/
 fi
 echo "rsync -avrp --exclude 'lost+found' --exclude '/oracle/backups' $SOURCE_DIR oracle@$TARGET_HOST:$ACTUAL_DEST_DIR" | tee -a "$LOG_FILE"
 echo "###################################################################################"
 echo "Do you want to copy using above command, press y to contineu, any key to exit"
 read choice4
  if [[ $choice4 == 'y' ]]; then
  echo "############## starting data copy ###################"
  rsync -avrp --exclude 'lost+found' --exclude '/oracle/backups' $SOURCE_DIR oracle@$TARGET_HOST:$DEST_DIR
  echo "############## End of data copy #####################"
  fi
 read -p "Press enter to back to main menu"
 mainscript
 fi
 if [ $choice -eq 2 ]; then
 clear
 echo "###################################################################################"
 echo "##### Script will try to copy the FS using Rsync method with exclude list #########"
 echo "###################################################################################"
 echo "##### Enter the Source Filesystem Name from this server ###########################"
 echo "###################################################################################"
 read SOURCE_DIR
 echo "###################################################################################"
 echo "##### Enter the Destination Filesystem Name to sync/copy from this server ####################"
 echo "###################################################################################"
 read DEST_DIR
 echo "###################################################################################"
 echo "##### Enter the Destination Server Name ###########################################"
 echo "###################################################################################"
 read TARGET_HOST
 if [ -z $TARGET_HOST ]; then
  echo "Target host must be passed, you can't leave it blank, returning to main menu"
  read -p "Press enter to continue"
  mainscript
 fi
 echo "###################################################################################"
 echo "##### Enter the exclude Filesystems/Directories one by one and press control + d when finish ##"
 echo "###################################################################################"
 rm -rf /tmp/rsync-exclude-list.txt
 cat > /tmp/rsync-exclude-list.txt
 echo "###################################################################################"
 echo "##### Below is the Exclusion list in /tmp/rsync-exclude-list.txt ##################"
 echo "###################################################################################"
 cat /tmp/rsync-exclude-list.txt
 echo "###################################################################################"
 echo "##### The script will execute below command on this server ########################"
 echo "###################################################################################"
 ACTUAL_DEST_DIR=`echo $DEST_DIR | rev | cut -d "/" -f 2,3,4,5 | rev`
 if [ -z $ACTUAL_DEST_DIR ]; then
 ACTUAL_DEST_DIR=/
 fi
 echo "rsync -avrp --exclude 'lost+found' --exclude '/oracle/backups' --exclude-from '/tmp/rsync-exclude-list.txt' $SOURCE_DIR oracle@$TARGET_HOST:$ACTUAL_DEST_DIR"
 echo "###################################################################################"
 echo "Do you want to copy using above command, press y to contineu, any key to exit"
 read choice4
  if [[ $choice4 == 'y' ]]; then
  echo "############## starting data copy ###################"
  rsync -avrp --exclude-from '/tmp/rsync-exclude-list.txt' $SOURCE_DIR oracle@$TARGET_HOST:$DEST_DIR
  echo "############## End of RSYNC/Data Copy  #####################"
  fi
 read -p "Press enter to back to main menu"
 mainscript
 fi
 if [ $choice -eq 3 ]; then
 clear
 rm -rf /tmp/rsync-list.sh
 echo "###################################################################################"
 echo "##### Script will try to copy the FS using Rsync in batch mode (max 5 FS) #########"
 echo "###################################################################################"
 a=0
 while [ $a -le 5 ]
 do
 a=$(($a+1))
 echo "##### Add more directories, y to contineu, any other key to exit" #################"
 read choice6
 if [[ $choice6 -eq 'y' ]]; then
  continue
 else
  break
 fi
 echo "##### Enter the Source Directory to copy from this server #########################"
 echo "###################################################################################"
 read SOURCE_DIR
 echo "###################################################################################"
 echo "##### Enter the Destination Directory to copy from this server ####################"
 echo "###################################################################################"
 read DEST_DIR
 ACTUAL_DEST_DIR=`echo $DEST_DIR | rev | cut -d "/" -f 2,3,4,5 | rev`
 if [ -z $ACTUAL_DEST_DIR ]; then
 ACTUAL_DEST_DIR=/
 fi
 echo "###################################################################################"
 echo "##### Enter the Destination Server Name ###########################################"
 echo "###################################################################################"
 read TARGET_HOST
 if [ -z $TARGET_HOST ]; then
  echo "Target host must be passed, you can't leave it blank, returning to main menu"
  read -p "Press enter to continue"
  mainscript
 fi
 echo "rsync -avrp --exclude 'lost+found' --exclude '/oracle/backups' $SOURCE_DIR oracle@$TARGET_HOST:$ACTUAL_DEST_DIR" >> /tmp/rsync-list.sh
 done
 echo "###################################################################################"
 echo "##### The script will execute below command on this server ########################"
 echo "###################################################################################"
 cat /tmp/rsync-list.sh
 echo "###################################################################################"
 echo "Do you want to copy using above command, press y to contineu, any key to exit"
 read choice4
  if [[ $choice4 == 'y' ]]; then
  echo "############## starting data copy ###################"
  chmod a+x /tmp/rsync-list.sh
  /tmp/rsync-list.sh
  echo "############## End of data copy #####################"
  fi
 read -p "Press enter to back to main menu"
 fi
 if [ $choice -eq 9 ]; then
 mainscript
 fi
 if [ $choice -eq 0 ]; then
 exit 0;
 fi
fi
############################### End of Choice 5 ################################
if [ $choice -eq 0 ]; then
exit 0;
fi
}
mainscript
