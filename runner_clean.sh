####################################################
############# BEGINNING OF MAIN ####################
####################################################

# Define usage message
usage="$(basename "$0") [-h] [-c|--cache n] [-l|--logs n] [-b|--bad n] -- Script erase cache file, logs files related and badfiles in according to the retention period

where:
    -c|--cache set mtime_cache > retention days for cache files (default: 10)
    -l|--logs set mtime_logs > retention days for workflow/session log files (default: 30)
    -b|--bad set mtime_bad > retention days for bad files (default: 7)
    -h|--help > script usage
	"

# SET default value for parameters
mtime_cache="+"10
mtime_logs="+"30
mtime_bad="+"7

# SET default value for variables
count=0
count_tot=0
count_wc=0
check_error=0

# mkdir -p foo

# QUERY the system for the working directory
# It change depending on the solution
actual_path=${PWD##*/}

# CHECK if the current working directory correspond to the standard path of the solution
if [ "$actual_path" == "home" ]
then
actual_path=$(dirname $(pwd))
actual_path=${actual_path##*/}
fi

count_wc=$(echo $actual_path | wc -m)

# REMOVE dev/prd/stg/qar suffix
if [ $count_wc -le 4 ];
then sub_actual_path=$actual_path
else sub_actual_path=$(echo $actual_path | rev | cut -c 4- | rev)
fi

# CONVERT long parameters to short parameters
for arg in "$@"; do
  shift
  case "$arg" in
    "--help") set -- "$@" "-h" ;;
    "--cache") set -- "$@" "-c" ;;	
    "--logs") set -- "$@" "-l" ;;
    "--bad")   set -- "$@" "-b" ;;
    *)        set -- "$@" "$arg"
  esac
done

# CONTROL parameters passed through shell
while getopts 'c:l:b:h' option; do
  case "$option" in
    h|elp) echo "$usage"
       exit
       ;;
	c) mtime_cache="+"${OPTARG};;
	l) mtime_logs="+"${OPTARG};;
	b) mtime_bad="+"${OPTARG};;
    :) printf "missing argument for -%s\n" "$OPTARG" | 2>&1 tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
       echo "$usage" | 2>&1 tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" | 2>&1 tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
       echo "$usage" | 2>&1 tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
       exit 1
       ;;
  esac
done
# IF the parameters are not correct an error message will be displayed into log and shell

# CACHE deletion for all the files oldest than -mtime parameter and write the result into a log file 
# CACHE summary deletion will be write into a log file and also to the screen
count=$(find $sub_actual_path/cache -xdev -maxdepth 5 -name '*.dat[[:digit:]]' -type f -mtime $mtime_cache -print -follow | wc -l)
count_tot=$((count_tot + count))
echo "Found $count dat files in cache for the retention period of $mtime_cache day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find $sub_actual_path/cache -xdev -maxdepth 5 -name '*.dat[[:digit:]]' -type f -mtime $mtime_cache -print -follow -exec rm -f {} \; >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1

# CACHE deletion for all the files not in standard path oldest than -mtime parameter and write the result into a log file
# CACHE summary deletion will be write into a log file and also to the screen
check_error=$(tail -n 1 "$(date +"%Y%m%d")_$sub_actual_path".log | grep "No such" | wc -l)
if [ $check_error -eq 1 ]
then
count=$(find */* -xdev -maxdepth 5 -name '*.dat[[:digit:]]' -type f -mtime $mtime_cache -print | wc -l)
count_tot=$((count_tot + count))
echo "Alternative script Found $count dat files in cache for the retention period of $mtime_cache day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find */* -xdev -maxdepth 5 -name '*.dat[[:digit:]]' -type f -mtime $mtime_cache -print -exec rm -f {} \; | grep -v "loop" >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1
fi

count=0
count=$(find $sub_actual_path/cache -xdev -maxdepth 5 -name '*.idx[[:digit:]]' -type f -mtime $mtime_cache -print -follow | wc -l)
count_tot=$((count_tot + count))
echo "Found $count idx files in cache for the retention period of $mtime_cache day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find $sub_actual_path/cache -xdev -maxdepth 5 -name '*.idx[[:digit:]]' -type f -mtime $mtime_cache -print -follow -exec rm -f {} \; >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1

check_error=$(tail -n 1 "$(date +"%Y%m%d")_$sub_actual_path".log | grep "No such" | wc -l)
if [ $check_error -eq 1 ]
then
count=$(find */* -xdev -maxdepth 5 -name '*.idx[[:digit:]]' -type f -mtime $mtime_cache -print | wc -l)
count_tot=$((count_tot + count))
echo "Alternative script Found $count idx files in cache for the retention period of $mtime_cache day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find */* -xdev -maxdepth 5 -name '*.idx[[:digit:]]' -type f -mtime $mtime_cache -print -exec rm -f {} \; | grep -v "loop" >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1
fi

# SESSION BIN and WORKFLOW BIN deletion for all the files oldest than -mtime parameter and write the result into a log file
# SESSION BIN and WORKFLOW BIN summary deletion will be write into a log file and also to the screen
count=0
count=$(find $sub_actual_path/sesslogs -xdev -maxdepth 5 -name '*[[:digit:]].bin' -type f -mtime $mtime_logs -print -follow | wc -l)
count_tot=$((count_tot + count))
echo "Found $count bin files in sesslogs for the retention period of $mtime_logs day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find $sub_actual_path/sesslogs -xdev -maxdepth 5 -name '*[[:digit:]].bin' -type f -mtime $mtime_logs -print -follow -exec rm -f {} \; >>  "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1 

count=0
count=$(find $sub_actual_path/workflowlogs -xdev -maxdepth 5 -name '*[[:digit:]].bin' -type f -mtime $mtime_logs -print -follow | wc -l)
count_tot=$((count_tot + count))
echo "Found $count bin files in workflowlogs for the retention period of $mtime_logs day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find $sub_actual_path/workflowlogs -xdev -maxdepth 5 -name '*[[:digit:]].bin' -type f -mtime $mtime_logs -print -follow -exec rm -f {} \; >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1

# SESSION BIN and WORKFLOW BIN deletion for all the files not in standard path oldest than -mtime parameter and write the result into a log file
# SESSION BIN and WORKFLOW BIN summary deletion will be write into a log file and also to the screen
check_error=$(tail -n 1 "$(date +"%Y%m%d")_$sub_actual_path".log | grep "No such" | wc -l)
if [ $check_error -eq 1 ]
then
count=$(find */* -xdev -maxdepth 5 -name '*[[:digit:]].bin' -type f -mtime $mtime_logs -print | wc -l)
count_tot=$((count_tot + count))
echo "Alternative script Found $count bin files in sesslogs and workflowlogs for the retention period of $mtime_logs day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find */* -xdev -maxdepth 5 -name '*[[:digit:]].bin' -type f -mtime $mtime_logs -print -exec rm -f {} \; | grep -v "loop" >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1
fi


# SESSION LOGS and WORKFLOW LOGS deletion for all the files oldest than -mtime parameter and write the result into a log file
# SESSION LOGS and WORKFLOW LOGS summary deletion will be write into a log file and also to the screen
count=0
count=$(find $sub_actual_path/sesslogs -xdev -maxdepth 5 -name '*.log.[[:digit:]]*' -type f -mtime $mtime_logs -print -follow | wc -l)
count_tot=$((count_tot + count))
echo "Found $count log files in sesslogs for the retention period of $mtime_logs day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find $sub_actual_path/sesslogs -xdev -maxdepth 5 -name '*.log.[[:digit:]]*' -type f -mtime $mtime_logs -print -follow -exec rm -f {} \; >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1 

count=0
count=$(find $sub_actual_path/workflowlogs -xdev -maxdepth 5 -name '*.log.[[:digit:]]*' -type f -mtime $mtime_logs -print -follow | wc -l)
count_tot=$((count_tot + count))
echo "Found $count log files in workflowlogs for the retention period of $mtime_logs day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find $sub_actual_path/workflowlogs -xdev -maxdepth 5 -name '*.log.[[:digit:]]*' -type f -mtime $mtime_logs -print -follow -exec rm -f {} \; >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1

# SESSION LOGS and WORKFLOW LOGS deletion for all the files not in standard path oldest than -mtime parameter and write the result into a log file
# SESSION LOGS and WORKFLOW LOGS summary deletion will be write into a log file and also to the screen
check_error=$(tail -n 1 "$(date +"%Y%m%d")_$sub_actual_path".log | grep "No such" | wc -l)
if [ $check_error -eq 1 ]
then
count=$(find */* -xdev -maxdepth 5 -name '*.log.[[:digit:]]*' -type f -mtime $mtime_logs -print | wc -l)
count_tot=$((count_tot + count))
echo "Alternative script Found $count log files in sesslogs and workflowlogs for the retention period of $mtime_logs day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find */* -xdev -maxdepth 5 -name '*.log.[[:digit:]]*' -type f -mtime $mtime_logs -print -exec rm -f {} \; | grep -v "loop" >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1
fi

# BADFILES deletion for all the files oldest than -mtime parameter and write the result into a log file
# BADFILES summary deletion will be write into a log file and also to the screen
count=0
count=$(find $sub_actual_path/badfiles -xdev -maxdepth 5 -name '*.bad*' -o -name '*.nzlog' -type f -mtime $mtime_bad -print -follow | wc -l)
count_tot=$((count_tot + count))
echo "Found $count bad files in badfiles for the retention period of $mtime_bad day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find $sub_actual_path/badfiles -xdev -maxdepth 5 -name '*.bad*' -o -name '*.nzlog' -type f -mtime $mtime_bad -print -follow -exec rm -f {} \; >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1

# BADFILES deletion for all the files not in standard path oldest than -mtime parameter and write the result into a log file
# BADFILES summary deletion will be write into a log file and also to the screen
check_error=$(tail -n 1 "$(date +"%Y%m%d")_$sub_actual_path".log | grep "No such" | wc -l)
if [ $check_error -eq 1 ]
then
count=$(find */* -xdev -maxdepth 5 -name '*.bad*' -o -name '*.nzlog' -type f -mtime $mtime_bad -print | wc -l)
count_tot=$((count_tot + count))
echo "Alternative script Found $count badfiles for the retention period of $mtime_bad day/s" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log
find */* -xdev -maxdepth 5 -name '*.bad*' -o -name '*.nzlog' -type f -mtime $mtime_bad -print -exec rm -f {} \; | grep -v "loop" >> "$(date +"%Y%m%d")_$sub_actual_path".log 2>&1
fi

echo "Found and erased $count_tot files" | tee -a "$(date +"%Y%m%d")_$sub_actual_path".log

# SCRIPT LOG FILES deletion for all the files oldest than -mtime parameter - rotation log files
find -xdev -maxdepth 1 -type f -name '*_$sub_actual_path.log' -mtime +7 -exec rm {} \;