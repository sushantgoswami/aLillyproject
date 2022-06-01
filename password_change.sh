#!/bin/bash
clear
echo "####################################################################"
echo "This script is intended to change GRUB, ILO, TERMINAL and VCS server"
echo "####################################################################"
echo "1. Enter 1 for GRUB password change"
echo "2. Enter 2 for ILO password change"
echo "3. Enter 3 for Terminal Server password change"
echo "4. Enter 4 for VCS password change"
read value1
if [ $value1 == 1 ]; then
echo "Please enter the path of file, which contain list of servers:";
read SERVER_PATH_LIST;
echo "Please enter the Password:";
read PASSWORD_TO_BE_CHANGE;
PASSWORD_TO_BE_CHANGE=`echo -e "$CRYPTVALUE\n$CRYPTVALUE"|/sbin/grub-md5-crypt 2> /dev/null|tail -n1`;
echo "The md5 password is $PASSWORD_TO_BE_CHANGE";
echo "The file path is $SERVER_PATH_LIST";
CURRENTDATE=`date | awk '{print $3$2$6}'`;
echo "PASSWORD_TO_BE_CHANGE=$PASSWORD_TO_BE_CHANGE" >grub-password.sh;
echo "SERVER_PATH_LIST=$SERVER_PATH_LIST" >>grub-password.sh;
echo "CURRENTDATE=$CURRENTDATE" >>grub-password.sh;
cat <<'EOF' >>grub-password.sh
### Script to modify grub password ###
for i in `cat "$SERVER_PATH_LIST"`;
do
ssh -q $i << 'ENDOFSCRIPT'
if [ "$(uname)" == "Linux" ] && ( grep -q -i "release 6" /etc/redhat-release || grep -q -i "release 5" /etc/redhat-release )
then
NEW_PASS=`echo -e "Eu$e#b10\nEu$e#b10"|/sbin/grub-md5-crypt 2> /dev/null | cut -d":" -f3|tr -d '\n'`
cp -p /tmp/grub.conf /tmp/grub.conf"$CURRENTTIME" ;sed -i s:^password.*:"password --md5 "$NEW_PASS": /tmp/grub.conf
elif  grep -q -i "release 7" /etc/redhat-release
then
echo "`hostname` server is RHEL7"
else
echo "`hostname` server is not Linux"
fi
ENDOFSCRIPT
done
EOF
fi
