#!/bin/csh -e
if ($#argv < 2) then
    echo "Sorry, but you entered too few parameters"
    echo "usage:  $0 PATH ROW" 
    exit
endif

setenv HOME /home/cdsr
setenv NOVAS_HOME  /home/cdsr/COTS64/novas3.1
setenv  NOVASLIB  /home/cdsr/COTS64/novas3.1/lib/
setenv NOVASINC  /home/cdsr/COTS64/novas3.1/include/
setenv JPLDE421 /home/cdsr/COTS64/novas3.1/data/lnxp1900p2053.421
# QT
setenv QTDIR /usr/local/Trolltech/Qt-4.8.4/
setenv QTINC /usr/local/Trolltech/Qt-4.8.4/include
setenv QTLIB /usr/local/Trolltech/Qt-4.8.4/lib

# Oracle
setenv ORACLE_SID LPGS
# LPGS
alias lpgsenv 'setenv BUILDROOT /home/cdsr/LPGS_2_4_0; setenv SRCROOT $BUILDROOT; source $SRCROOT/ias_lib/setup/setup_db lpgs-l8.dgi.inpe.br; source $SRCROOT/ias_lib/setup/iaslib_setup --enable-dev --64 $BUILDROOT/build_ias; source $SRCROOT/ias_base/setup/iasbase_setup /home/cdsr/LPGS_2_4_0/root_proc_dir; source $SRCROOT/lpgs/setup/lpgs_setup;'
lpgsenv

setenv PROCESSING_CENTER INPE
setenv IAS_SERVICES "http://localhost:8080/"


if ( -d /etc/profile.d ) then
   set nonomatch
   foreach i ( /etc/profile.d/*.csh )
   if ( -r $i ) then
      source $i
   endif
   end
   unset i nonomatch
endif
setenv  PATH  /home/cdsr/bin/:/home/cdsr/LPGS_2_4_0/include/:/home/cdsr/SBS_3_0_0/OTS:/home/cdsr/COTS64/hdf5/include/:/home/cdsr/COTS64/gctp3/:/usr/local/Trolltech/Qt-4.8.4/bin/:/usr/local/Trolltech/Qt-4.8.4/lib:${PATH}

setenv PATH /usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:$PATH
setenv PATH /usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:$PATH
setenv PATH /usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:$PATH
setenv PATH /usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:$PATH
setenv PATH /usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:$PATH

setenv PATH /dados/L1T_WORK/2015_05/LO82150640752015126CUB00/LO82150652015126CUB00/source_dem.h5:$PATH


# If needed, create an additional script to call here to write a
# setup_work_order.odl file tailored to a specific work order.  It would need
# to provide the L0R_FILENAME, CAL_PARM_FILENAME, BIAS_PARM_FILENAME_OLI,
# BIAS_PARM_FILENAME_TIRS, and RLUT filename.

# Do the initial work order setup.  This includes retrieving the CPF, BPFs,
# and RLUT.  Uses the L0R metadata to calculate the area covered by the data
# for future use by the DEM and GCP retrieval.  Determines the target UTM zone
# if the target projection is UTM.  Writes the initial OMF file.
echo  "\e[31mSTARTING  setup_work_order\e[0m"
setup_work_order setup_work_order.odl

# Retrieve the DEM data defined by the bounding box in the OMF file.  Selects
# the best DEM source based on the bounding box.  If needed, mosaics DEM tiles
# together and subsets the correct area from it.  Writes the DEM file and
# updates the OMF file with the DEM filename and elevation range.
echo  "\e[31mSTARTING  retrieve_elevation\e[0m"
/home/cdsr/LPGS_2_4_0/build_ias/bin/retrieve_elevation retrieve_elevation.odl

# Retrieves the GCPs in the area defined by the bounding box in the OMF file
# and puts them in a subdirectory in the work order directory.  The GCPs are
# resampled to be in the target projection UTM zone if they are not already.
# Writes the GCP subdirectory name to the OMF file.
### WORKAROUND: since we are running the demo without any database connections,
# copy in a previously created gcp_lib directory for this scene.
#get_gcps.pl generate_gcps.odl
#cp -r ../../saved_gcp_lib gcp_lib
cp -r /L0_LANDSAT8/AncillaryFiles/GCP/$1/$2/ gcp_lib
tar -C gcp_lib -zxvf gcp_lib/image_chips.tgz

sed -e 's/END_OBJECT/  GCP_DIRECTORY = \"gcp_lib\"\nEND_OBJECT/' L1.omf > L1_new.omf
mv L1_new.omf L1.omf

# Process the spacecraft ancillary data in the L0R file.  Extracts the correct
# subset of ephemeris and attitude data and does any error correction and
# smoothing required.  Writes the processed ancillary to a file.  Updates the
# OMF with the name of the ancillary file.
echo  "\e[31mSTARTING  ancillary_data_preprocessor\e[0m"
ancillary_data_preprocessor ancillary_data_preprocessor.odl

# Create the Line-of-sight model using the ancillary file and the sensor L0R
# ancillary data.  Writes the LOS model file and updates the OMF with the
# filename.
echo  "\e[31mSTARTING  create_los_model\e[0m"
create_los_model create_los_model.odl

# Performs radiometric characterizations and corrections on all the bands
# present in the L0R.  Writes the L1R file and update the OMF file with the L1R
# filename.
echo  "\e[31mSTARTING  create_l1r\e[0m"
create_l1r create_l1r.odl

# Using the LOS model, elevation range, target projection and other inputs
# to calculate the resampled image frame and generate the LOS projection model
# commonly called the "grid".  At this time, only band 6 of the grid is created
# since that is the band used to create a precision model.   Writes the grid
# file and updates the OMF with the filename.
echo  "\e[31mSTARTING  create_grid\e[0m"
create_grid create_grid_pass_1.odl

# The next two steps create a resampling grid to resample the DEM data to be
# co-registered with the L1G frame calculated by create_grid and then resamples
# the DEM.  The OMF is updated with the name of the resampled DEM file.
echo  "\e[31mSTARTING  makegeomgrid\e[0m"
makegeomgrid makegeomgrid_pass_1.odl
echo  "\e[31mSTARTING  geomresample\e[0m"
geomresample geom_resample_pass_1.odl

# Resample band 6 to a terrain corrected systematic image (L1GT).  Updates the
# OMF with the name of the image file.
echo  "\e[31mSTARTING  resample\e[0m"
resample resample_pass_1.odl

# Correlate the GCP points to band 6 of the L1GT image.  The correlation 
# results are written to an output filename and the name of the file written
# to the OMF.
echo  "\e[31mSTARTING  gcpcorrelate\e[0m"
gcpcorrelate gcpcorrelate_pass_1.odl

# Using the GCP correlation results, attempt to calculate a precision
# correction and create a precision model.  If the precision model can not be
# calculated, use the systematic model instead.  The OMF is updated with the
# LOS model file to use and an indication whether precision correction
# succeeded.
echo  "\e[31mSTARTING  correct_los_model\e[0m"
correct_los_model correct_los_model.odl

# Perform the geodetic characterization to determine how good the fit was from
# the precision model (if it was created).  The primary reason for running this
# is to collection characterization data for the IAS to analyze.  It likely is
# not needed by others, so it is commented out.
#geodetic geodetic.odl

# Using the best model available (precision or systematic), create the LOS
# projection model for all the bands in the input image.  This is the same 
# process as the earlier step, only this time it is for all bands and uses
# a different framing option.
echo  "\e[31mSTARTING  create_grid_2\e[0m"
create_grid create_grid_pass_2.odl

# Create another version of the DEM that is co-registered to the frame 
# calculated in the grid created in the previous step.  This is necessary 
# because the resampler needs a co-registered DEM and the framing is likely
# different for the precision model and different framing option.
echo  "\e[31mSTARTING  makegeomgrid_2\e[0m"
makegeomgrid makegeomgrid_pass_2.odl
echo  "\e[31mSTARTING  geomresample_2\e[0m"
geomresample geom_resample_pass_2.odl

# Perform the final resampling step to create the L1T (if a precision model
# is available) or L1GT (if a systematic model is available) for all the
# bands present in the L1R.
echo  "\e[31mSTARTING  resample_2\e[0m"
resample resample_pass_2.odl

# The next two steps correlate the validation set of GCPs to band 6 of the
# final L1T to provide metadata for the geometric RMSE.  Commented out since
# this is optional and probably not of interest to most people.
#gcpcorrelate gcpcorrelate_pass_2.odl
#geometric geometric.odl

# Using the grid and DEM information, create a mask for which pixels in the
# L1T are occluded by elevation features between the sensor and the point on
# the ground.
echo  "\e[31mSTARTING  terrain_occlusion\e[0m"
terrain_occlusion terrain_occlusion.odl

# Perform cloud cover assessment on the L1T/L1GT image.  A cloud cover mask
# is created and merged with the terrain occlusion mask to make the quality
# band.  The overall cloud cover score is calculated and stored in the OMF.
echo  "\e[31mSTARTING assess_cloud_cover \e[0m"
assess_cloud_cover assess_cloud_cover.odl

# Convert the L1T/L1GT image to the GeoTIFF format (one band per file) and
# generate the metadata (MTL) file.  Also collect the data to store in the 
# inventory and write it to a file.
echo  "\e[31mSTARTING format_and_package \e[0m"
format_and_package format_and_package.odl
