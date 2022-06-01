#!/bin/bash
############# Name : automation_var.sh ###############
############# Name : Automation of Var FS cleanup/maintinence ###############
#################### Version 0.1 ######################
# version 0.01 written by Sushant Goswami Dated 7-July-2021
# Revision
# Revision
# Revision

######################## Scope ######################
# The script is intended to check the highly utilization of /var filesystem
# 
# 1. If the main file and the file before UPDSUDO_HOUR_CHECK hours are having difference by more than SIZE_LIMIT Bytes than it will trigger email.
# 2. If there is a "vi" session opened for more than UPDSUDO_HOUR_CHECK hour than it will trigger email.
# 3. If the file is modified then the modification will be sent to PRIMARY_EMAIL
# the modification email will be sent only to PRIMARY_EMAIL
# 4. the script will maintain a log file which is set by LOGDIR and LOGFILE variable
# 5. Script will keep modified sudo file backup for 3 days
# 6. Script also keep backup of sudo file every 2 hour and for 3 days

##################### User Defined Variables #########################
ZONE=ALL
PRIMARY_EMAIL=Tcs_Platform_Linux@lists.lilly.com
SECONDARY_EMAIL=goswami_sushant@network.lilly.com
PRIMARY_MAIL_ENABLE=1
SECONDARY_MAIL_ENABLE=1
WORKDIR=/tmp
TMPDIR=/tmp
LOGDIR=/var/log
LOGFILE=Automation_var.log

############## Pre Fixed Variables ##############################
CURRENTDATE=`date | awk '{print $3"-"$2"-"$6}'`
CURRENTTIMESTAMP=`date | awk '{print $4}' | sed '$ s/:/./g'`
CURRENT_HOUR=`date | awk '{print $4}' | cut -d ":" -f 1`

###################### Help Menu ##########################################
if [ -z $1 ]; then
 echo "(MSG 000): No arguments passed, continuing to regular task" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
else
 if [ $1 == "-help" ]; then
  echo "(MSG HELP): The script is intended for Automation of Var FS cleanup/maintinence"
  exit 0;
 fi
fi
#################### Do not edit below this line, use variables above ###########################################
###------------------------------------------------------------------------------------------------------------###
########################## Duplicate instance check ######################################
CHECK_ID=""
CHECK_ID=`ps -ef | grep "automation_var.sh" | grep -v grep | grep -v tail | wc -l`
if [ $CHECK_ID -gt 4 ]; then
 echo "(MSG 001): Another intance of automation_var.sh is running on background, please check and terminate the first session" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $LOGDIR/$LOGFILE
 if [ $SECONDARY_MAIL_ENABLE == 1 ]; then
  echo "(MSG 001): Another intance of automation_var.sh is running on background, please check and terminate the first session" | mailx -s "Alert on $ZONE Master Sudo Server" $SECONDARY_EMAIL
 fi
 exit 0;
fi
CHECK_VI=""
CHECK_VI=`ps -ef | grep "vi automation_var.sh" | grep -v grep | wc -l`
if [ $CHECK_VI != 0 ]; then
 echo "(MSG 002): vi sessions are running on the background for automation_var.sh, please close the existing sessions" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $LOGDIR/$LOGFILE
 if [ $SECONDARY_MAIL_ENABLE == 1 ]; then
  echo "(MSG 002): vi sessions are running on the background for automation_var.sh, please close the existing sessions" | mailx -s "Alert on $ZONE Master Sudo Server" $SECONDARY_EMAIL
 fi
 exit 0;
fi
#################### copy the sudoers file to the alternate directory ############################################
if [ -z $LAST_FILE_DATE ] && [ -z LAST_FILE_HOUR ]; then
 echo "(MSG 003): Seems, this is the first time file going to be created in $WORKDIR/$AUTO_BACKUP_DIR" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
 cp $UPDSUDO_WORKDIR/$SUDO_FILE $WORKDIR/$AUTO_BACKUP_DIR/$SUDO_FILE-$CURRENTDATE-$CURRENTTIMESTAMP
 COPY_FLAG=1
else
 LAG_HOUR=`expr $CURRENT_HOUR - $LAST_FILE_HOUR`
 if [ $CURRENTDATE == $LAST_FILE_DATE ] && [ $LAG_HOUR -le 1 ]; then
  echo "(MSG 004): There is a auto backup file created one hour before or $WORKDIR/$AUTO_BACKUP_DIR is not available, not taking backup of file" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
 else
  echo "(MSG COPY): copying the master sudoers file to $WORKDIR/$AUTO_BACKUP_DIR" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
  cp $UPDSUDO_WORKDIR/$SUDO_FILE $WORKDIR/$AUTO_BACKUP_DIR/$SUDO_FILE-$CURRENTDATE-$CURRENTTIMESTAMP
  COPY_FLAG=1
 fi
fi
#################### Compare the file with last backup ########################################################
ERROR_FLAG=0
LAST_FILE_SIZE=`ls -ltr $WORKDIR/$AUTO_BACKUP_DIR | tail -1 | awk '{print $5}'`
LAST1_FILE_SIZE=`ls -ltr $WORKDIR/$AUTO_BACKUP_DIR | tail -2 | head -1 | awk '{print $5}'`
MASTER_SUDO_SIZE=`ls -ltr $UPDSUDO_WORKDIR/$SUDO_FILE | tail -1 | awk '{print $5}'`
if [ $COPY_FLAG == 0 ]; then
 CHECK_SIZE=`expr $MASTER_SUDO_SIZE - $LAST_FILE_SIZE`
  if [ $CHECK_SIZE -lt 0 ]; then
   CHECK_SIZE=${CHECK_SIZE#-}
  fi
  if [ $CHECK_SIZE -gt $SIZE_LIMIT ]; then
   ERROR_FLAG=1
   echo "(MSG 005): Master sudoers file in $ZONE is modified by $SIZE_LIMIT bytes on dated $CURRENTDATE at $CURRENTTIMESTAMP, Please check at your end" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
   if [ $PRIMARY_MAIL_ENABLE == 1 ]; then
    echo "(MSG 005): Master sudoers file in $ZONE is modified by $SIZE_LIMIT bytes on dated $CURRENTDATE at $CURRENTTIMESTAMP, Please check at your end" | mailx -s "Alert on $ZONE Master Sudo Server" $PRIMARY_EMAIL
   fi
   if [ $SECONDARY_MAIL_ENABLE == 1 ]; then
    echo "(MSG 005): Master sudoers file in $ZONE is modified by $SIZE_LIMIT bytes on dated $CURRENTDATE at $CURRENTTIMESTAMP, Please check at your end" | mailx -s "Alert on $ZONE Master Sudo Server" $SECONDARY_EMAIL
   fi
  fi
fi
if [ ! -z $LAST1_FILE_SIZE ] && [ $COPY_FLAG == 1 ]; then
 CHECK_SIZE=`expr $MASTER_SUDO_SIZE - $LAST1_FILE_SIZE`
  if [ $CHECK_SIZE -lt 0 ]; then
   CHECK_SIZE=${CHECK_SIZE#-}
  fi
  if [ $CHECK_SIZE -gt $SIZE_LIMIT ]; then
   ERROR_FLAG=1
   echo "(MSG 006): Master sudoers file in $ZONE is modified by $SIZE_LIMIT bytes on dated $CURRENTDATE at $CURRENTTIMESTAMP, Please check at your end" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
   if [ $PRIMARY_MAIL_ENABLE == 1 ]; then
    echo "(MSG 006): Master sudoers file in $ZONE is modified by $SIZE_LIMIT bytes on dated $CURRENTDATE at $CURRENTTIMESTAMP, Please check at your end" | mailx -s "Alert on $ZONE Master Sudo Server" $PRIMARY_EMAIL
   fi
   if [ $SECONDARY_MAIL_ENABLE == 1 ]; then
    echo "(MSG 006): Master sudoers file in $ZONE is modified by $SIZE_LIMIT bytes on dated $CURRENTDATE at $CURRENTTIMESTAMP, Please check at your end" | mailx -s "Alert on $ZONE Master Sudo Server" $SECONDARY_EMAIL
   fi
  fi
fi
###################### email send for modification #################
if [ $CHECK_SIZE -gt 0 ]; then
 if [ $COPY_FLAG == 0 ]; then
  LAST_FILE=`ls -ltr $WORKDIR/$AUTO_BACKUP_DIR | tail -1 | awk '{print $NF}'`
  sort $WORKDIR/$AUTO_BACKUP_DIR/$LAST_FILE > $WORKDIR/$TEMPDIR/tempsudofile1.txt
  sort $UPDSUDO_WORKDIR/$SUDO_FILE > $WORKDIR/$TEMPDIR/tempsudofile2.txt
  comm -2 -3 $WORKDIR/$TEMPDIR/tempsudofile1.txt $WORKDIR/$TEMPDIR/tempsudofile2.txt > $WORKDIR/$TEMPDIR/tempsudofile3.txt
  echo "##############################################################" >> $WORKDIR/$TEMPDIR/tempsudofile3.txt
  comm -2 -3 $WORKDIR/$TEMPDIR/tempsudofile2.txt $WORKDIR/$TEMPDIR/tempsudofile1.txt >> $WORKDIR/$TEMPDIR/tempsudofile3.txt
  cp $WORKDIR/$TEMPDIR/tempsudofile3.txt $WORKDIR/$CHANGE_DIR/changes-$CURRENTDATE-$CURRENTTIMESTAMP.txt
 fi
 if [ $COPY_FLAG == 1 ]; then
  LAST_FILE=`ls -ltr $WORKDIR/$AUTO_BACKUP_DIR | tail -2 | head -1 | awk '{print $NF}'`
  sort $WORKDIR/$AUTO_BACKUP_DIR/$LAST_FILE > $WORKDIR/$TEMPDIR/tempsudofile1.txt
  sort $UPDSUDO_WORKDIR/$SUDO_FILE > $WORKDIR/$TEMPDIR/tempsudofile2.txt
  comm -2 -3 $WORKDIR/$TEMPDIR/tempsudofile1.txt $WORKDIR/$TEMPDIR/tempsudofile2.txt > $WORKDIR/$TEMPDIR/tempsudofile3.txt
  echo "##############################################################" >> $WORKDIR/$TEMPDIR/tempsudofile3.txt
  comm -2 -3 $WORKDIR/$TEMPDIR/tempsudofile2.txt $WORKDIR/$TEMPDIR/tempsudofile1.txt >> $WORKDIR/$TEMPDIR/tempsudofile3.txt
  cp $WORKDIR/$TEMPDIR/tempsudofile3.txt $WORKDIR/$CHANGE_DIR/changes-$CURRENTDATE-$CURRENTTIMESTAMP.txt
 fi
 if [ $CHECK_SIZE -gt 0 ] && [ $PRIMARY_MAIL_ENABLE == 1 ]; then
  echo "(MSG MODIFICATION): Master sudoers file in $ZONE is modified by $CHECK_SIZE bytes on dated $CURRENTDATE at $CURRENTTIMESTAMP, following lines have beed modified" > $WORKDIR/$TEMPDIR/tempmailfile.txt
  echo "###############################################" >> $WORKDIR/$TEMPDIR/tempmailfile.txt
  cat $WORKDIR/$TEMPDIR/tempsudofile3.txt >> $WORKDIR/$TEMPDIR/tempmailfile.txt
  echo "(MSG MODIFY): Someone modified the master sudo file within one hour" | mailx -s "Alert on $ZONE Master Sudo Server" $PRIMARY_EMAIL
#  uuencode $WORKDIR/$TEMPDIR/tempmailfile.txt tempmailfile.txt | mailx -s "Alert on $ZONE Master Sudo Server" $PRIMARY_EMAIL
  mailx -a $WORKDIR/$TEMPDIR/tempmailfile.txt -s "Alert on $ZONE Master Sudo Server" $PRIMARY_EMAIL
#  >$WORKDIR/$TEMPDIR/tempmailfile.txt
 fi
fi
#################### Function declaration for Check id of open updsudo file #######################################
updsudo_id_check()
{
CHECK_PR=""
CHECK_PR=`ps -ef | grep -v grep | grep /etc/msudoers/updsudo | tail -1 | awk '{print $2}'`
if [ -z $CHECK_PR ]; then
 echo "(MSG 012): No /usr/local/bin/updsudo process found the ps output" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"
-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
else
 CHECK_ID=""
 CHECK_ID=`pstree $CHECK_PR | grep " -ksh" | awk '{print $1}'`
  if [ -z $CHECK_ID ]; then
  CHECK_USER=""
  CHECK_USER=`ps -ef | grep $CHECK_ID | grep ksh | awk '{print $1}'`
   if [ -z $CHECK_USER ]; then
    echo "(MSG 013): Below user need to be informed for open updsudo file" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
    #logins -x -l $CHECK_USER | head -1  | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
    getent passwd $CHECK_USER >> $WORKDIR/$LOGDIR/$LOGFILE
   fi
  fi
fi
}
#################### check open vi sessions and visudo for updsudo for more than an hour #######################################
UPDSUDO_CHECK=`ps -ef | grep "/etc/msudoers/updsudo" | grep -v grep | tail -1 | awk '{print $2}'`
VISUDO_CHECK=`ps -ef | grep "/usr/sbin/visudo -s -f /etc/msudoers/master.sudoers" | grep -v grep | tail -1 | awk '{print $2}'`
if [ ! -z $UPDSUDO_CHECK ]; then
 TIME1=""
 TIME2=""
 TIME3=""
 TIME1=`ps -o etime= -p $UPDSUDO_CHECK | cut -d ":" -f 1`
 TIME2=`ps -o etime= -p $UPDSUDO_CHECK | cut -d ":" -f 2`
 TIME3=`ps -o etime= -p $UPDSUDO_CHECK | cut -d ":" -f 3`
 if [ ! -z $TIME3 ] && [ ! -z $TIME2 ] && [ $TIME1 -gt $UPDSUDO_HOUR_CHECK ]; then
  echo "(MSG 007): Atleast one instance of updsudo is running from more than $UPDSUDO_HOUR_CHECK hour, please check" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
  if [ $PRIMARY_MAIL_ENABLE == 1 ]; then
   echo "(MSG 007): Atleast one instance of updsudo is running from more than $UPDSUDO_HOUR_CHECK hour, please check" | mailx -s "Alert on $ZONE Master Sudo Server" $PRIMARY_EMAIL
  fi
 fi
fi
if [ ! -z $VISUDO_CHECK ]; then
 TIME1=""
 TIME2=""
 TIME3=""
 TIME1=`ps -o etime= -p $UPDSUDO_CHECK | cut -d ":" -f 1`
 TIME2=`ps -o etime= -p $UPDSUDO_CHECK | cut -d ":" -f 2`
 TIME3=`ps -o etime= -p $UPDSUDO_CHECK | cut -d ":" -f 3`
 if [ ! -z $TIME3 ] && [ ! -z $TIME2 ] && [ $TIME1 -gt $UPDSUDO_HOUR_CHECK ]; then
  echo "(MSG 008): Atleast one instance of visudo is running from more than $UPDSUDO_HOUR_CHECK hour, please check" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
  if [ $PRIMARY_MAIL_ENABLE == 1 ]; then
   echo "(MSG 008): Atleast one instance of visudo is running from more than $UPDSUDO_HOUR_CHECK hour, please check" | mailx -s "Alert on $ZONE Master Sudo Server" $PRIMARY_EMAIL
  fi
 fi
fi
#################### Clean up old backup copies before 3 days #############################################
if [ ERROR_FLAG == 1 ]; then
 echo "(MSG 009): Since there is an Error in size limit. Hence, not removing any file" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
 if [ $PRIMARY_MAIL_ENABLE == 1 ]; then
  echo "(MSG 010): Since there is an Error in size limit. Hence, not removing any file" | mailx -s "Alert on $ZONE Master Sudo Server" $PRIMARY_EMAIL
 fi
else
 TOTAL_FILES=`find $WORKDIR/$AUTO_BACKUP_DIR/master.sudoers-* | wc -l`
 if [ $TOTAL_FILES -lt 36 ]; then
  echo "(MSG 011): Last 3 days (less then 36 files) backup is only available, not removing any file" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
 else
 find $WORKDIR/$AUTO_BACKUP_DIR/sudoers-* -ctime 3 -exec rm {} \;
 echo "(MSG 012): Last files before 36 copies are removed." | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
 fi
fi
##################################################################################
