read -sp 'Enter Password: ' PASS
echo
read -sp 'Enter Password Again: ' PASSTMP
echo;echo

if [[ ! "$PASS" ]]
then
echo -e "Password is empty !!TRY Again"
exit
fi

if [[ "$PASS" != "$PASSTMP" ]]
then
echo -e "Passwords do not match!! TRY Again"
exit
fi


HOME=/tmp/rishabh/grub_password_change
ARCHPATH=/tmp/rishabh/grub_password_change/backup
GRUBFILE56=/boot/grub/grub.conf
CURRENTTIME=$(date +%d%b%Y)
LOGPATH=$HOME/log.$CURRENTTIME
TPATH=$HOME/TMP
mkdir -p /tmp/rishabh/grub_password_change 2>/dev/null
mkdir -p $ARCHPATH 2>/dev/null
mkdir -p $TPATH 2>/dev/null
mkdir -p $LOGPATH 2>/dev/null


/usr/bin/wget -O $TPATH/allhosts http://gcrs.am.lilly.com/altiris/query.php?mode=prod\&race_dump --no-check-certificate 2> /dev/null
cat $TPATH/allhosts |egrep -vi 'RETIRED|suse|Netezza|Appliance|workstation'|egrep -i 'linux|rhel|redhat|unix'|\
awk -F'~' '{if ($5 !~ /[7-9]\.[0-9]/) print $1"."$2}' >$TPATH/alllinux

#######creating child script

echo " for servers  in \`cat $TPATH/alllinux\` " >$HOME/maingrub.sh
echo 'do' >>$HOME/maingrub.sh
echo " ssh -o ConnectTimeout=5 -o BatchMode=yes \$servers << 'EOF' " >>$HOME/maingrub.sh
echo 'CURRENTTIME=$(date +%d%b%Y)' >>$HOME/maingrub.sh
echo 'if [ "$(uname)" == "Linux" ] && ( grep -q -i "release 6" /etc/redhat-release || grep -q -i "release 5" /etc/redhat-release )'>>$HOME/maingrub.sh
echo 'then' >>$HOME/maingrub.sh
echo "NEW_PASS=\`echo -e \"$PASS\\n$PASS\"|/sbin/grub-md5-crypt 2> /dev/null | cut -d":" -f3|tr -d '\n'\`" >>$HOME/maingrub.sh
echo "while [[ \$NEW_PASS == *:* ]] ; do NEW_PASS=\`echo -e \"$PASS\n$PASS\"|/sbin/grub-md5-crypt 2> /dev/null | cut -d":" -f3|tr -d '\n'\` ; done ">>$HOME/maingrub.sh
echo 'cp -p /tmp/grub.conf /tmp/grub.conf"$CURRENTTIME" && sed -i s:^password.*:"password --md5 $NEW_PASS": /tmp/grub.conf'>>$HOME/maingrub.sh || echo "`hostname` grub password change fail"
echo 'elif  grep -q -i "release 7" /etc/redhat-release'>>$HOME/maingrub.sh
echo 'then'>>$HOME/maingrub.sh
echo 'echo "`hostname` server is RHEL7"'>>$HOME/maingrub.sh
echo 'else'>>$HOME/maingrub.sh
echo 'echo "`hostname` server is not Linux"'>>$HOME/maingrub.sh
echo 'fi'>>$HOME/maingrub.sh
echo EOF >>$HOME/maingrub.sh
echo 'done' >>$HOME/maingrub.sh
[root@saarthi c188578]#
