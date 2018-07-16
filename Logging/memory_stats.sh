#!/bin/bash

#---------------- include helper scripts --------
source ./helper_functions.sh

#---------------- main logic --------------------
log_threshold=288
log_file_count=5
logfile_name=systemMemoryUsage.csv
log_db_file=memory_log.db
cd "$(dirname "$0")"

if check_required_tools; then
  echo "not all required tools are available in order to run this script"
  exit 0
fi

if [ ! -f $log_db_file ]; then
    echo "rotation_count: 0"  > $log_db_file
fi

if [ ! -f $logfile_name ]; then
  (echo "total ,"; echo "used ,"; echo "free ,"; echo "shared ,"; echo "buffers ,"; echo "cache ,"; echo "available ,"; echo "swap_total ,"; echo "swap_used ,"; echo "swap_free ,"; echo "timestamp ,")  > $logfile_name
fi

(echo "total `free -wb | awk 'NR==2{print $2}'`,"; echo "used `free -wb | awk 'NR==2{print $3}'`,"; echo "free `free -wb | awk 'NR==2{print $4}'`,"; echo "shared `free -wb | awk 'NR==2{print $5}'`,"; echo "buffers `free -wb | awk 'NR==2{print $6}'`,"; echo "cache `free -wb | awk 'NR==2{print $7}'`,"; echo "available `free -wb | awk 'NR==2{print $8}'`,"; echo "swap_total `free -wb | awk 'NR==3{print $2}'`,"; echo "swap_used `free -wb | awk 'NR==3{print $3}'`,"; echo "swap_free `free -wb | awk 'NR==3{print $4}'`,"; echo "timestamp `date +%s%N`,")  | join $logfile_name - > temp2.csv && rm $logfile_name && mv temp2.csv $logfile_name

#perform rotation if required (note that we add one to log_threshold in order to compensate for the row title)
rotate_file $logfile_name $(($log_threshold+1)) $log_file_count $log_db_file