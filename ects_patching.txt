#!/bin/bash
#-------------------------------------------------------------------------------
#- Original Author...: Sushant Goswami
#- Creation Date.....: 03 July 2018
#- Purpose...........: Script is intended to patch the ECTS servers	
#- Notes.............: Creation of script via CHG1290158
#-------------------------------------------------------------------------------
#-            (C) Copyright 2018 Eli Lilly and Company
#-                       All Rights Reserved
#-------------------------------------------------------------------------------
# description: ects_patching_script.sh
#-------------------------------------------------------------------------------                                                                                          
                                                             
case "$1" in
  check)
    echo "Checking the current repository and server configuration"
	CURRENT_REPO=`subscription-manager identity | tail -1 | awk '{print $3}' | cut -d "/" -f 1`
	
	if [ $CURRENT_REPO == "MDITCurrent" ]; then
	 echo "The Repo attached to the server is $CURRENT_REPO, which is correct repo. You can proceed with patching"
	else 
	 echo "The Server is not subscribed by MDITCurrent, it is $CURRENT_REPO"
	 echo "You can disconnect the current repo and attach to the MDITCurrent repo"
	 echo "Below the process to attach the correct MDITCurrent repo"
	fi 
    ;;
  start_patch)
    echo "Starting patching"
    ;;
  *)
    echo "Usage: ects_patching_script.sh {check|start_patch}"
    exit 1
esac
                                                                                              
exit 0
