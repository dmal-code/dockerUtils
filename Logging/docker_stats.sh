#!/bin/bash

#---------------- include helper scripts --------
source ./helper_functions.sh

#---------------- main logic --------------------
log_threshold=288
log_file_count=5
logfile_name_service_memory=servicesMemoryUsage.csv
logfile_name_service_cpu=servicesCPUUsage.csv
logfile_name_service_network=servicesNetUsage.csv
logfile_name_service_block=servicesBlockUsage.csv
log_db_file=docker_log.db
cd "$(dirname "$0")"

if check_required_tools; then
  echo "not all required tools are available in order to run this script"
  exit 0
fi

if [ ! -f $log_db_file ]; then
    echo "rotation_count: 0"  > $log_db_file
fi

if [ ! -f $logfile_name_service_memory ]; then
    (docker stats --all --no-trunc --no-stream --format "{{.Name}} ," | sort -; echo "timestamp ,")  > $logfile_name_service_memory
fi

if [ ! -f $logfile_name_service_cpu ]; then
    (docker stats --all --no-trunc --no-stream --format "{{.Name}} ," | sort -; echo "timestamp ,") > $logfile_name_service_cpu
fi

if [ ! -f $logfile_name_service_network ]; then
    (docker stats --all --no-trunc --no-stream --format "{{.Name}} ," | sort -; echo "timestamp ,") > $logfile_name_service_network
fi

if [ ! -f $logfile_name_service_block ]; then
    (docker stats --all --no-trunc --no-stream --format "{{.Name}} ," | sort -; echo "timestamp ,") > $logfile_name_service_block
fi

(docker stats --all --no-trunc --no-stream --format "{{.Name}}  {{ .MemPerc }}," | sort -; echo "timestamp `date +%s%N`,")  | join $logfile_name_service_memory - > temp.csv && rm $logfile_name_service_memory && mv temp.csv $logfile_name_service_memory
(docker stats --all --no-trunc --no-stream --format "{{.Name}}  {{ .CPUPerc }}," | sort -; echo "timestamp `date +%s%N`,") | join $logfile_name_service_cpu - > temp.csv && rm $logfile_name_service_cpu && mv temp.csv $logfile_name_service_cpu
(docker stats --all --no-trunc --no-stream --format "{{.Name}}  {{ .NetIO }}," | sort -; echo "timestamp `date +%s%N`,") | join $logfile_name_service_network - > temp.csv && rm $logfile_name_service_network && mv temp.csv $logfile_name_service_network
(docker stats --all --no-trunc --no-stream --format "{{.Name}}  {{ .BlockIO }}," | sort -; echo "timestamp `date +%s%N`,") | join $logfile_name_service_block - > temp.csv && rm $logfile_name_service_block && mv temp.csv $logfile_name_service_block

#perform rotation if required (note that we add one to log_threshold in order to compensate for the row title)
rotate_file $logfile_name_service_memory $(($log_threshold+1)) $log_file_count $log_db_file
rotate_file $logfile_name_service_cpu $(($log_threshold+1)) $log_file_count $log_db_file
rotate_file $logfile_name_service_network $(($log_threshold+1)) $log_file_count $log_db_file
rotate_file $logfile_name_service_block $(($log_threshold+1)) $log_file_count $log_db_file