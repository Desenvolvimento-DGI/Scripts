#!/bin/csh -ef
#  -e flag will cause the script to exit if any command fails
#  -f flag will keep current environment (skip re-sourcing the cshrc)
# 

if ($#argv != 2) then
    echo
    echo "usage: run_subsetter.csh <l0ra_interval_id><scene_id>"
    echo
    exit
else
    set l0ra_interval_id = $1
    set l0rp_scene_id = $2
endif
set curr_dir = $cwd

# Parse the year, path, and starting row from the interval ID provided
# so we can create the L0Ra location
set year = `echo $l0ra_interval_id | awk '{print substr($0, 13, 4)}'` 
set my_path = `echo $l0ra_interval_id | awk '{print substr($0, 4, 3)}'` 
set start_row = `echo $l0ra_interval_id | awk '{print substr($0, 7, 3)}'` 
set ingest_path = "/$year/$my_path/$start_row/$l0ra_interval_id"

if (!($?INGEST_OUTPUT_PATH)) then
    set l0ra_location = $curr_dir
else
    set l0ra_location = $INGEST_OUTPUT_PATH
endif
# Ingest interval data location
set l0ra_location = $l0ra_location$ingest_path

# If the Ingest interval location does not exist, cannot find the
# L0Ra data, cannot continue
if (!(-d $l0ra_location)) then
    echo
    echo "Ingest input location $l0ra_location does not exist"
    echo "Cannot continue."
    echo
    exit
endif

# Set up the Subsetter output data directory
if (!($?SUBSETTER_OUTPUT_PATH)) then
    set l0rp_location = $curr_dir
else
    set l0rp_location = $SUBSETTER_OUTPUT_PATH
endif
# Append the scene ID to the output location
set l0rp_location = $l0rp_location/$l0rp_scene_id

# *Caution* if the l0rp_location already exists, it will be
# deleted
if (-d $l0rp_location) then
    rm -rf $l0rp_location
endif
# Now create the directory
mkdir -p $l0rp_location

# Set IAS log level to warn
setenv IAS_LOG_LEVEL WARN

set curr_date = (`date`)
echo
echo "Starting Subsetter processing    $curr_date"
echo

# ot_subsetter must be in the path, start the subsetter processing
ot_subsetter $l0ra_interval_id $l0ra_location $l0rp_location \
    --scene $l0rp_scene_id

set curr_date = (`date`)
echo
echo "Subsetter processing completed    $curr_date"
echo
echo "L0Rp data located at $l0rp_location"
echo
