#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Time::HiRes qw(usleep ualarm gettimeofday tv_interval);
use XML::Simple;
use XML::Dumper;
use Data::Dumper;

#------------------------------------------------------------------------------
# IDFGenerator.pl:
#    - Generates an Interval Definition File (IDF). The IDF provides 
#      information about the interval including the list of files and their 
#      respective sizes. It also includes the list of scenes and a priority 
#      flag for each.
#
# NOTES:
#------------------------------------------------------------------------------
# Function prototypes
sub create_idf($$);
sub fix_idf($);
sub get_formatted_time_string();
sub read_checksums($);
sub find_root_files($$);
sub usage;

# Required input parameters
my $mission_data_dir;   # Directory where mission data resides
my $interval_id;        # Interval ID, landsat_interval_id or landsat_cal_interval_id
my $sts;                # Scene Transmit Schedule full path and name 

# Override parameter defaults
my $category = "VALIDATION";      # Default Data Category
my $collection = "EARTH_IMAGING"; # Default Collection Type
my $mode = "PRODUCTION";          # Default System Mode
my $off_nadir = "N";              # Default Off Nadir Flag
my $verbose = 0;                  # Default Verbose Flag to quiet

# Variables
my $help;                  # Flag indicating usage statement should be displayed
my $i;                     # Interval looping variable
my $j;                     # Rootfile looping variable
my $k;                     # File looping variable
my $num_int;               # Number of interval groups in STS XML file
my $num_root;              # Number of rootfile groups in STS XML file
my $num_scenes;            # Number of scene groups in STS XML file
my $interval_index = -1;   # Index into STS XML that matches root files in mission direcotry
my $file_name = "";        # Name of the rootfile from mission directory
my $file_rootfile_id = ""; # Rootfile ID extracted from rootfile name
my $sts_rootfile_id = "";  # Rootfile ID found in STS XML file
my $sensor_present = 0;       # Flag to indicate which sensors are present
my $sensor_id = "";        # Sensor ID for sensors present

# See if any options were provided on the command line
GetOptions
(
    "help"           => \$help,
    "category=s"     => \$category,
    "collection=s"   => \$collection,
    "mode=s"         => \$mode,
    "off_nadir=s"    => \$off_nadir,
    "-v"             => \$verbose
);

if ($help)
{
    usage();
    exit(1);
}

# Get the number of command line arguments, make sure there were at least 3
my $num_args = $#ARGV + 1;
if ($num_args < 3)
{
    print "Error in number of command line arguments\n";
    usage();
    exit(1);
}
# Get the mission data directory
$mission_data_dir = $ARGV[0];

# Get the interval id
$interval_id = $ARGV[1];

# Get the Scene Transmit Schedule name
$sts = $ARGV[2];

# Read STS XML file
my $sts_hash = XMLin($sts, ForceArray=>['interval','rootFile','scene']);
my %root_file_count = (); # file count for each root id
 
# Create IDF object
my $xml = XML::Simple->new();
my %idf_hash = ();  # Hash for IDF
my $idf_hash_ref = \%idf_hash;

# Read the checksum file and return the checksum file and hash reference 
my ($checksum_file, $num_files, $checksums_ref) = read_checksums($mission_data_dir);
my %checksums = %{$checksums_ref};
printf ("Checksum File %s  Num_files %d\n",$checksum_file, $num_files)if ($verbose);

# Make sure there were checksums returned, or error out
if (!(%checksums))
{
    print "ERROR: no checksums read from checksum file\n";
    exit(1);
}

my ($file_count, $file_ref) =  find_root_files($mission_data_dir, $checksums_ref);
my %file_hash = %{$file_ref};
if (!(%file_hash))
{
    print "ERROR: no root files found in " . $mission_data_dir;
    exit(1);
}

if ($num_files != $file_count)
{
    print "ERROR: Number of rootfiles do not match.   Checksum: " . $num_files .
          " Mission Directory: " . $file_count . "\n";
    exit(1);
}

# Look for the rootfile ID in the STS that match the files in the mission
# directory to determine which interval in the STS is associated with the
# files
for ($k = 0; $k < $file_count; $k++)
{
    # Get the file name of the root file
    $file_name = $file_hash{$k}->{file_name};
    $file_rootfile_id = substr($file_name,0,3);

    # count the number of intervals in STS
    my $aref_int = $sts_hash->{fileBody}->{interval};
    $num_int = $#$aref_int + 1;

    for ($i = 0; $i < $num_int; $i++)
    {
        # count the number of root files in STS
        my $aref_root = $sts_hash->{fileBody}->{interval}[$i]->{rootFile};
        $num_root = $#$aref_root + 1;

        for ($j = 0; $j < $num_root; $j++)
        {
            # Get the roofile ID from the STS
            $sts_rootfile_id = 
                $sts_hash->{fileBody}->{interval}[$i]->{rootFile}[$j]{ROOT_FILE_ID};
            printf("STS_ROOT_FILE_ID = %s\n",$sts_rootfile_id) if ($verbose);

            # Look for a match
            if ($sts_rootfile_id eq $file_rootfile_id)
            {
                printf("    FOUND MATCH %s %s\n",$sts_rootfile_id, $file_rootfile_id) if ($verbose);
                # Found a match: Save the index to this matching interval
                if ( ( $interval_index < 0) or ($interval_index == $i) )
                {
                    $interval_index = $i;

                    # Capture which sensors are present
                    my $sensor = 
                        $sts_hash->{fileBody}->{interval}[$interval_index]->{rootFile}[$j]{RESOURCE};
                    if ($sensor eq "OLI")
                    {
                        $sensor_present = $sensor_present | 1;
                    }
                    elsif ($sensor eq "TIRS")
                    {
                        $sensor_present = $sensor_present | 2;
                    }
                }
                else
                {
                    # Reset in case there are multiple intervals with a duplicate rootfile ID
                    $interval_index = -1;
                    $sensor_present = 0;
                }
            } # Found match
        } # Each rootfile
    } # Each interval
} # Each file

printf("Interval Index %d Sensors Present %s\n",$interval_index, $sensor_present)if ($verbose);

# Set the sensor ID base on the sensor present flag
if ($sensor_present == 1)
{
    $sensor_id = "OLI";
}
elsif ($sensor_present == 2)
{
    $sensor_id = "TIRS";
}
elsif ($sensor_present == 3)
{
    $sensor_id = "OLI_TIRS";
}
else
{
    $sensor_id = "UNK";
}

# Get date string in the format:  YYYY:DOY:HH:MM:SS.SSS
my $formatted_date = get_formatted_time_string();
    
# Generate the header record in the IDF
$idf_hash_ref->{header}->{scid} = 
    $sts_hash->{primaryHeader}->{SCID};
$idf_hash_ref->{header}->{product_type} = "IDF";
$idf_hash_ref->{header}->{gen_time} = $formatted_date;
$idf_hash_ref->{header}->{source} = 
    "IC-" . $sts_hash->{secondaryHeader}->{DESTINATION}; 
$idf_hash_ref->{header}->{mode} = $mode;

# Create the interval record
$idf_hash_ref->{collection_type} = $collection;
$idf_hash_ref->{data_category}  = $category;
$idf_hash_ref->{gne_interval_complete_flag} = "Y";
$idf_hash_ref->{moe_interval_complete_flag} = "Y";
$idf_hash_ref->{moe_interval_id} =
    $sts_hash->{fileBody}->{interval}[$interval_index]->{MOE_INTERVAL_ID};
$idf_hash_ref->{offnadir_flag} = $off_nadir;
$idf_hash_ref->{priority_flag} = "N";
$idf_hash_ref->{sensor_id} = $sensor_id;
my $test_cal = substr($interval_id,5,1);
if ($test_cal =~ m/\d/)
{
    $idf_hash_ref->{landsat_interval_id} = $interval_id;
    $idf_hash_ref->{wrs_path} = substr($interval_id, 3, 3);
    $idf_hash_ref->{wrs_starting_row} = substr($interval_id, 6, 3);
    $idf_hash_ref->{wrs_ending_row} = substr($interval_id, 9, 3);
}
else
{
    $idf_hash_ref->{landsat_cal_interval_id} = $interval_id;
}

# Generate rootfile records
$num_root = $sts_hash->{fileBody}->{interval}[$interval_index]->{NUM_ROOT_FILE};
$idf_hash_ref->{rootFile} = ();
for ($j = 0; $j < $num_root; $j++)
{
    $sts_rootfile_id = 
        $sts_hash->{fileBody}->{interval}[$interval_index]->{rootFile}[$j]{ROOT_FILE_ID};
    $idf_hash_ref->{rootFile}[$j]->{landsat_interval_id} = $interval_id;
    $idf_hash_ref->{rootFile}[$j]->{priority_flag} = "N";
    $idf_hash_ref->{rootFile}[$j]->{root_file_complete_flag} = "Y";
    $idf_hash_ref->{rootFile}[$j]->{root_file_id} = $sts_rootfile_id;
    $idf_hash_ref->{rootFile}[$j]->{sensor_id} = 
        $sts_hash->{fileBody}->{interval}[$interval_index]->{rootFile}[$j]{RESOURCE};

    # Generate the file records
    my $nfile = 0;
    for ($k = 0; $k < $file_count; $k++)
    {
        $file_name = $file_hash{$k}->{file_name};
        if ($sts_rootfile_id eq substr($file_name, 0, 3) )
        {
            $idf_hash_ref->{rootFile}[$j]->{file}[$nfile]->{file_name} = $file_name;
            $idf_hash_ref->{rootFile}[$j]->{file}[$nfile]->{file_size} =
                $file_hash{$k}->{file_size};
            $idf_hash_ref->{rootFile}[$j]->{file}[$nfile]->{station_id} = 
                $file_hash{$k}->{station_id};
            $idf_hash_ref->{rootFile}[$j]->{file}[$nfile]->{file_checksum} = $checksums{$file_name};
            $nfile++;
        }
    }
    $root_file_count{$sts_rootfile_id} = $nfile;
}

#Generate the scene records
$num_scenes = $sts_hash->{fileBody}->{interval}[$interval_index]->{NUM_SCENES};
$idf_hash_ref->{scene} = ();
for ($i = 0; $i < $num_scenes; $i++)
{
    $idf_hash_ref->{scene}[$i]->{wrs_path} = 
        $sts_hash->{fileBody}->{interval}[$interval_index]->{scene}[$i]{PATH};
    $idf_hash_ref->{scene}[$i]->{wrs_row}  =
        $sts_hash->{fileBody}->{interval}[$interval_index]->{scene}[$i]{ROW};
    $idf_hash_ref->{scene}[$i]->{sensor_id}  = $sensor_id;
    $idf_hash_ref->{scene}[$i]->{priority_flag}  = "N";
}

# Finish the header record by adding the record count
$idf_hash_ref->{header}->{num_recs} = $file_count + $num_root + $num_scenes;

# Create the IDF XML file
my $idf_name = create_idf($checksum_file, $idf_hash_ref);

# Fix root XML tag to add XML name space attribute
fix_idf($idf_name);

#------------------------------------------------------------------------------
# create_idf:
#     - writes the xml to the idf
#------------------------------------------------------------------------------
sub create_idf($$)
{
    my $checksum_file = shift; # Checksum file name
    my $idf_hash_ref  = shift; # Hash reference for the template information

    # Determine IDF name based off of checksum file name
    my $idf_name = substr($checksum_file, 0, rindex($checksum_file, "_"));
    $idf_name .= "_IDF.xml";

    # Open IDF
    open (IDF, ">$idf_name") or die ("Can't open $idf_name\n");

###############################################################################
# Print xml to IDF ---> Perl does not store hashes in a specific order (not 
#     even the order of creation).  So, the normal way to create XML output 
#     using XMLout is to let the routine sort the keys.  However, the IDF 
#     format checker is requiring the order as given in the Mission Data DFCB.
#     So, short of rewriting the hashing to maintain a specific order (and then
#     adding the nosort option to XMLOut), we'll hardcode the output.
# -----------------------------------------------------------------------------
#    print IDF $xml->XMLout( $idf_hash_ref, noattr=>1, suppressempty=>1, 
#        xmldecl => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
###############################################################################

    print IDF "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n";
    print IDF "<idf xsi:schemaLocation=\"http://ldcm.usgs.gov/schema/idf IDF.xsd\""
             .  " xmlns=\"http://ldcm.usgs.gov/schema/idf\""
             .  " xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n";
    print IDF "    <header>\n";
    print IDF "       <scid>" . $idf_hash_ref->{header}->{scid} . "</scid>\n"; 
    print IDF "       <product_type>" . $idf_hash_ref->{header}->{product_type} . "</product_type>\n"; 
    print IDF "       <gen_time>" . $idf_hash_ref->{header}->{gen_time} . "</gen_time>\n"; 
    print IDF "       <source>" . $idf_hash_ref->{header}->{source} . "</source>\n"; 
    print IDF "       <mode>" . $idf_hash_ref->{header}->{mode} . "</mode>\n"; 
    print IDF "    </header>\n";
    print IDF "    <moe_interval_id>" . $idf_hash_ref->{moe_interval_id} . "</moe_interval_id>\n";
    print IDF "    <landsat_interval_id>" . $idf_hash_ref->{landsat_interval_id} . "</landsat_interval_id>\n";
    print IDF "    <priority_flag>" . $idf_hash_ref->{priority_flag} . "</priority_flag>\n";
    print IDF "    <sensor_id>" . $idf_hash_ref->{sensor_id} . "</sensor_id>\n";
    print IDF "    <offnadir_flag>" . $idf_hash_ref->{offnadir_flag} . "</offnadir_flag>\n";
    print IDF "    <collection_type>" . $idf_hash_ref->{collection_type} . "</collection_type>\n";
    print IDF "    <data_category>" . $idf_hash_ref->{data_category} . "</data_category>\n";
    print IDF "    <wrs_path>" . $idf_hash_ref->{wrs_path} . "</wrs_path>\n";
    print IDF "    <wrs_starting_row>" . $idf_hash_ref->{wrs_starting_row} . "</wrs_starting_row>\n";
    print IDF "    <wrs_ending_row>" . $idf_hash_ref->{wrs_ending_row} . "</wrs_ending_row>\n";
    
    for (my $j = 0; $j < $num_root; $j++)
    {
       print IDF "    <rootfile>\n";
       print IDF "       <root_file_id>" . $idf_hash_ref->{rootFile}[$j]->{root_file_id} 
                      . "</root_file_id>\n";
       print IDF "       <root_file_complete_flag>" . $idf_hash_ref->{rootFile}[$j]->{root_file_complete_flag} 
                      . "</root_file_complete_flag>\n";
       print IDF "       <sensor_id>" . $idf_hash_ref->{rootFile}[$j]->{sensor_id} . "</sensor_id>\n"; 
       print IDF "       <landsat_interval_id>" . $idf_hash_ref->{rootFile}[$j]->{landsat_interval_id} 
                      . "</landsat_interval_id>\n";
       print IDF "       <priority_flag>" . $idf_hash_ref->{rootFile}[$j]->{priority_flag} . "</priority_flag>\n";

       my @files = $idf_hash_ref->{rootFile}[$j]->{file};
       my $root_id = $idf_hash_ref->{rootFile}[$j]->{root_file_id};
       my $file_count = $root_file_count{$root_id};
       for (my $nfile = 0; $nfile < $file_count; $nfile++ )
       {
          print IDF "       <file>\n";
          print IDF "          <file_name>" . $idf_hash_ref->{rootFile}[$j]->{file}[$nfile]->{file_name} 
                           . "</file_name>\n";
          print IDF "          <station_id>" . $idf_hash_ref->{rootFile}[$j]->{file}[$nfile]->{station_id}  
                           . "</station_id>\n";
          print IDF "          <file_checksum>" . $idf_hash_ref->{rootFile}[$j]->{file}[$nfile]->{file_checksum}
                           . "</file_checksum>\n";
          print IDF "          <file_size>" . $idf_hash_ref->{rootFile}[$j]->{file}[$nfile]->{file_size} 
                           . "</file_size>\n";
          print IDF "       </file>\n";
       }
       print IDF "    </rootfile>\n";
    }
    for ($i = 0; $i < $num_scenes; $i++)
    {
       print IDF "    <scene>\n";
       print IDF "        <wrs_path>" . $idf_hash_ref->{scene}[$i]->{wrs_path} . "</wrs_path>\n"; 
       print IDF "        <wrs_row>" . $idf_hash_ref->{scene}[$i]->{wrs_row} . "</wrs_row>\n";
       print IDF "        <sensor_id>" . $idf_hash_ref->{scene}[$i]->{sensor_id} . "</sensor_id>\n";
       print IDF "        <priority_flag>" . $idf_hash_ref->{scene}[$i]->{priority_flag} . "</priority_flag>\n";
       print IDF "    </scene>\n";
    }
    print IDF "</idf>\n";

    # Close IDF
    close (IDF);

    # Return idf name 
    return $idf_name;
}

#------------------------------------------------------------------------------
# fix_idf:
#     - fixes minor things in the idf, such as changing the default <opt> to
#       <idf>
#------------------------------------------------------------------------------
sub fix_idf($)
{
    my $idf = shift; # IDF name 
    my $line;        # Looping variable for each line in the IDF

    # Create temporary IDF file by appending _tmp
    my $new_idf = $idf."_tmp";

    my @IDFInfo = ();
   
    # Open IDF and read all lines into a file
    open (IDF, "$idf") or die ("Can't open $idf\n");
    @IDFInfo = <IDF>;
    close (IDF);

    # Open the new temp IDF
    open (IDF_NEW, ">$new_idf") or die ("Can't open $new_idf\n");

    # Fix the old IDF lines if necessary and write to new IDF
    for ($line = 0; $line < @IDFInfo; $line++)
    {
        if ($IDFInfo[$line] =~ /<opt>/)
        {
           $IDFInfo[$line] =~ 
                    s/<opt>/<idf xmlns=\"http:\/\/ldcm.usgs.gov\/schema\/idf\">/;
        }
        elsif ($IDFInfo[$line] =~ /<\/opt>/)
        {
            $IDFInfo[$line] =~ s/opt/idf/;
        }
        print IDF_NEW $IDFInfo[$line]; 
    }
    close (IDF_NEW);
    
    # Rename the temporary IDF
    rename ($new_idf, $idf); 
}

#------------------------------------------------------------------------------
# find_root_files:
#     - finds the root file records i
#------------------------------------------------------------------------------
sub find_root_files($$)
{
    my $mission_data_dir = shift;    # Directory where the mission data resides
    my $sumsref          = shift;    # Checksum file hash

    my $file;            # Looping variable for each file in mission data dir
    my $file_count = 0;  # File counter
    my $full_file_name;  # File name with full path
    my $rootfile;        # Root file name 
    my %file_info = ();  # Hash for files read from mission directory

    # Expand out the checksum reference
    my %checksums = %{$sumsref};

    # Open the mission data directory
    opendir (MISSION, "$mission_data_dir") 
        or die ("Can't open $mission_data_dir\n");

    # Loop through each file in the mission data directory
    foreach $file (readdir(MISSION))
    {
        # Ignore files beginning with '.'
        next if ($file =~ /^\./); 

        # Look for files that are named correctly
        # 3 digits- . - 3 digits - .- 16 digits - . - 3 Upper case characters 
        #       189.003.2014286134743213.LGS
        if ($file =~ /^\d{3}?\.\d{3}?\.\d{16}?\.[A-Z]{3}/)
        {
            $rootfile = substr($file, 0 , 7);
           
            # Get full file name with mission data directory so the file size
            # can be obtained
            $full_file_name = $mission_data_dir."/".$file;

            # Set file record name
            $file_info{$file_count}{'file_name'} = $file;

            # Set file record file size
            $file_info{$file_count}{'file_size'} = -s $full_file_name;

            # Set file record station id 
            $file_info{$file_count}{'station_id'} = substr($file, length($file) - 3, 3);

            # Set the file checksum
            $file_info{$file_count}{'file_checksum'} = $checksums{$file};

            # Increment file count for next time thru loop
            $file_count++;
        }
    }
    closedir(MISSION);

    return ($file_count, \%file_info);
}
#------------------------------------------------------------------------------
# get_formatted_time_string:
#     - returns a time formatted as:  YYYY:DOY:HH:MM:SS.mmm
#------------------------------------------------------------------------------
sub get_formatted_time_string()
{
    my @date_array = gettimeofday;
    my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, 
        $dayOfWeek, $dayOfYear, $daylightSavings) = localtime(time);
    my $millisec = substr(sprintf("%.3f", "0." . $date_array[1]), 2);

    my $year = 1900 + $yearOffset;
    
    return sprintf("%04d:%03d:%02d:%02d:%02d.%03d", 
        $year, $dayOfYear, $hour, $minute, $second, $millisec);
}
#------------------------------------------------------------------------------
# read_checksums:
#     - reads the checksums files and returns a hash
#------------------------------------------------------------------------------
sub read_checksums($)
{
    my $mission_directory = shift; # Directory where mission data resides

    my $checksum;        # Individual checksum read from file
    my $checksum_file;   # Checksum file name
    my $file;            # Looping variable for each file in mission data dir
    my $file_name;       # Corresponding file for checksum
    my $full_checksum_file; # Checksum file name with full path
    my $num_files = 0;   # Total number of files encountered
    my %checksums = ();  # Hash for checksums read from checksum file
    
    # Open mission data directory
    opendir (MISSION, "$mission_directory") 
        or die ("Can't open $mission_directory\n");

    # Go thru each file in the mission data directory, searching for the
    # checksum file
    foreach $file (readdir(MISSION))
    {
        # Ignore files beginning with '.'
        next if ($file =~ /^\./); 

        # Found the checksum file
        if ($file =~ /MD5/)
        {
            # Create full checksum file name with path
            $full_checksum_file = $mission_directory."/".$file;

            # Save full checksum file name to return 
            $checksum_file = $full_checksum_file;

            # Open the checksum file
            open (CHECKSUM, "$full_checksum_file")
                or die ("Can't open $full_checksum_file\n");
            while (<CHECKSUM>)
            {
                # Go thru each checksum in file, make the file name the key in
                # the hash, and the checksum the value
                chomp;
                $checksum = undef;
                # two spaces or a space and an asterisk separate the csum from 
                # the filename
                ($checksum, $file_name) = split (/[ \*]+/); 
                $checksums{$file_name}  = $checksum;
                # in case there's an IDF listed in the MD5 file (there shouldn't be)
                # don't count it.
                $num_files++ unless ($file_name =~ /IDF/);
            }
        }
        else
        {
            next;
        }
    }
    closedir(MISSION);

    # Return the checksum file name and a reference to the checksum hash
    return ($checksum_file, $num_files, \%checksums);
}

#------------------------------------------------------------------------------
# usage:
#     - prints a usage message
#------------------------------------------------------------------------------
sub usage()
{
    print "\n";
    print "usage: IDFGenerator.pl <mission_data_dir> <interval_id> <sts_file>           \n";
    print "       -category <cat> -collection <c> -mode <m> -off_nadir <x> -v           \n";
    print "\n";
    print "Optional override parameters:\n";
    print "    -category      Where <cat> is VALIDATION, EXCHANGE, DIAGNOSTIC, NOMINAL, \n";
    print "                   or ENGINEERING.  The default is VALIDATION.               \n";
    print "    -collection    Where <c> is SHUTTER, LUNAR, LAMP, SOLAR, SIDE_SLITHER,   \n";
    print "                   STELLAR, OLI_TEST_PATTERN, SSR_PN_TEST_SEQUENCE,          \n";
    print "                   TIRS_LINEARITY, CALIBRATION, TIRS_NORMAL_CALIBRATION,     \n";
    print "                   or the default value EARTH_IMAGING                        \n";
    print "    -mode          Where valid values are TEST or PRODUCTION                 \n";
    print "    -off_nadir     Either Y or N The default is N                            \n";
    print "    -v             Verbose flag to print out extra processing information    \n";
    print "\n";
}
