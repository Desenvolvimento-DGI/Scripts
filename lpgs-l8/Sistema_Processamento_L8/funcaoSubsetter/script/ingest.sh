#!/bin/csh -ef
#  -e flag will cause the script to exit if any command fails
#  -f flag will keep current environment (skip re-sourcing the cshrc)
# 

if ($#argv < 1) then
    echo "Sorry, but you entered too few parameters"
    echo "usage:  $0 arquivo.jpl" 
    exit
endif

set curr_dir = $cwd
set jpf = $1
# Obtain the L0R interval ID 
set l0r_output_path = `grep L0R_OUTPUT_PATH $jpf | awk -F'"' '{print $2}'`

# Obtain the L0R interval ID 
set l0r_interval_id = `grep L0R_INTERVAL_ID $jpf | awk -F'"' '{print $2}'`
# Obtain the L0R_TEMP_PATH from the jpf
set log_file_path = `grep L0R_TEMP_PATH $jpf | awk -F'"' '{print $2}'`
# Create the temp path if it does not already exist
if (!(-d $log_file_path)) then
    mkdir -p $log_file_path
endif
# Set up the log file name
set log_file_name = $log_file_path/mjp.log
# Obtain the L0R_WORK_PATH from the jpf
set working_path = `grep L0R_WORK_PATH $jpf | awk -F'"' '{print $2}'`
# Create working path if it does not already exist
if (!(-d $working_path)) then
    mkdir -p $working_path
endif
# Obtain the L0R_OUTPUT_PATH from the jpf
set output_path = `grep L0R_OUTPUT_PATH $jpf | awk -F'"' '{print $2}'`
# This has the interval directory on it, back up one and see if the
# output directory exists
set parent_output_directory = `echo $output_path:h`
if (!(-d $parent_output_directory)) then
    mkdir -p $parent_output_directory
endif
# Start the Ingest processing
echo
set curr_date = (`date`)
echo "Starting Ingest processing    $curr_date"
echo
echo "    Starting ADC"
/home/cdsr/Ingest_3_6_0/ADC $jpf >& $log_file_name 
echo "    ADC complete"
echo
echo "    Starting LG"
/home/cdsr/Ingest_3_6_0/LG  $jpf >& $log_file_name 
echo "    LG complete"
echo
echo "    Starting SFC"
/home/cdsr/Ingest_3_6_0/SFC $jpf >& $log_file_name 
echo "    SFC complete"
echo
echo "    Starting MG"
/home/cdsr/Ingest_3_6_0/MG $jpf >& $log_file_name 
echo "    MG complete"
# Does final location exist? If so remove it so we can move the newly
# created data into the final location
#set final_location = $parent_output_directory/$l0r_interval_id


set final_location = $l0r_output_path$l0r_interval_id
if (-d $final_location) then
    rm -rf $final_location
endif
mkdir -p $final_location
mv $working_path/* $final_location
set curr_date = (`date`)
echo
echo "Ingest processing complete    $curr_date"
echo
echo "L0Ra data located at: $final_location"
echo
