#--------- helper functions ----------------

#check if required tools are available
function check_required_tools {
    if hash free 2>/dev/null && hash awk 2>/dev/null && hash sort 2>/dev/null && hash tail 2>/dev/null && hash join 2>/dev/null && hash docker 2>/dev/null; then
        return 1
    else
        return 0
    fi
}

#rotate the file, parameters are $1=logfile, $2=logthreshold, $3=logfile_count and $4=log_db_file
function rotate_file {
	columns_in_file=$(awk -F "," '{print NF}' $1 | sort -nu | tail -n 1)
	
	if [ $columns_in_file -ge $2 ]; then
	  rotation_count=$(awk -F " " '{print $NF}' $4)
	  file_suffix=$(( ($rotation_count) % $3))
	  echo "rotation_count: $((rotation_count+1))"  > $4
	  mv $1 $1$file_suffix
	fi
}