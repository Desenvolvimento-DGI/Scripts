#!/usr/bin/perl -w
use strict;
use vars qw($opt_a $opt_d $opt_v $opt_T $opt_f $opt_s $opt_q $opt_t $opt_V);
use Getopt::Std;
getopts("d:vTm:fs:qMt:Vh:b:") || die(<<END_USAGE);
Usage:
	$0 [-a dir] [-d destdir] [-v] [-T] [-f] [-s srcdir] [-t tmpdir] [-q] sceneid...
Where:
	-a dir	archive directory (optional)
	-d dir	use "dir" as the destination directory
	-s dir	source directory
	-t dir	temporary directory for generating browse
	-v	verbose...
	-q	quiet
	-T	test mode
	-f	force: update an existing browse
Looks for scene IDs on the command line
END_USAGE
$opt_s ||= "/sno01/upe/l1_location";
$opt_t ||= "/tmp";
$opt_d ||= "/browse/landsat_8";

umask(002);
$ENV{'PATH'}= "/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin:$ENV{HOME}/bin:$ENV{HOME}/gdal/bin";
$ENV{'LD_LIBRARY_PATH'} = ":$ENV{HOME}/gdal/lib";
$ENV{'PYTHONPATH'} = "/usr/lib/python2.4:$ENV{HOME}/gdal/lib64/python2.4/site-packages";

if ($opt_V) {
	print "$0 version UP_4_2_0\n";
}
foreach my $scene (@ARGV)
	{
	unless ($scene =~ m/L([COT])8(\d\d\d)(\d\d\d)(\d\d\d\d)(\d\d\d)/)
		{
		print STDERR "malformed scene ID ignored: $scene\n";
		next;
		}
	my ($instr, $path, $row, $year, $doy) = ($1, $2, $3, $4, $5);
	my $destdir = "$opt_d/$year/$path/$row";
	my $destfile = "$destdir/$scene.jpg";
	my $browse_destdir = "landsat_8/$year/$path/$row";
	my $archdir_frb = "$opt_a/frb/$year/$path/$row" if defined($opt_a);
	my $archdir_qb = "$opt_a/qb/$year/$path/$row" if defined($opt_a);
	if (!$opt_f && -s $destfile)
		{
		print STDERR "$destfile exists, skipped\n" unless $opt_q;
		next;
		}

	unless (-f "$opt_s/$scene.tar.gz")
		{
		print STDERR "$opt_s/$scene.tar.gz missing, skipped\n" unless $opt_q;
		next;
		}
	my $workingdir = "$opt_t/tmp$$";
	mkdir("$workingdir") || die("$workingdir: $!");
	execute("(cd $workingdir;gunzip | tar xBf -) < $opt_s/$scene.tar.gz");

	my @bands;
	my $qb_band = undef;
	if ($opt_T)
		{
		for my $i (1..11)
			{
			$bands[$i] = "${scene}_B${i}.TIF";
			}
		}
	else
		{
		opendir(TMP, "$workingdir") || die("$workingdir: $!");
		my $file;
		while (defined($file = readdir(TMP)))
			{
			if ($file =~ m/B(\d+)\.TIF/i)
				{
				$bands[$1] = $file;
				}
			elsif ($file =~ m/QA.TIF/i)
				{
				$qb_band = $file;
				}
			}
		closedir(TMP);
		}
	my @rgb = (6,5,4);
	execute("mkdir -p $destdir/reduced");
	execute("mkdir -p $archdir_frb $archdir_qb") if defined($opt_a);
	unless ($instr eq "T") {
		my @gain;
		my @bias;
		get_gain_bias("$workingdir/${scene}_MTL.txt", \@gain, \@bias);
		my $merge_cmd = "cd $workingdir; gdal_merge.py -o ${scene}.tif -separate";
		foreach my $band (@rgb) {
			execute("cd $workingdir; scaleTOAgamma 2.0 $gain[$band] $bias[$band] ${scene}_B$band.TIF tmp_b$band.tif");
			$merge_cmd .= " tmp_b$band.tif";
		}
		execute($merge_cmd);
		execute("gdal_translate -of JPEG -co worldfile=true $workingdir/${scene}.tif $destdir/$scene.jpg");
	}
	unless ($instr eq "O") {
		execute("cd $workingdir; scaleLinear 2 2 $bands[10] ${scene}_TIR.tif");
		execute("gdal_translate -of JPEG -co worldfile=true $workingdir/${scene}_TIR.tif $destdir/${scene}_TIR.jpg");
	}
	if (defined($qb_band)) {
		execute("cd $workingdir; qb $qb_band $destdir/${scene}_QB.png");
		# GDAL doesn't support generating a world file with a PNG, so copy the OLI or TIRS
		my $world_file = ($instr eq "T" ? "${scene}_TIR.wld" : "$scene.wld");
		execute("cd $destdir;cp -p $world_file ${scene}_QB.wld");
	} else {
		print STDERR "Missing quality band for $scene\n";
	}
	execute("cd $destdir;cp -p $scene.* ${scene}_TIR.* $archdir_frb") if defined($opt_a);
	execute("cd $destdir;cp -p ${scene}_QB.* $archdir_qb") if defined($opt_a);

	my @gdalinfo = ($instr eq "T") ? 
		`gdalinfo $workingdir/${scene}_TIR.tif`
		:
		`gdalinfo $workingdir/${scene}.tif`;
	my $zone = "xx";
	my $srs = "EPSG:4326 EPSG:3857 EPSG:900913";
	my ($minx, $miny, $maxx, $maxy) = (0, 0, 100, 100);
	my ($width, $height) = (0,0);
	my $date = cvtdate($year, $doy);
	foreach (@gdalinfo)
		{
		if (m/UTM zone (\d+)N/)
			{
			$zone = $1;
			$srs = sprintf("EPSG:326%02d EPSG:326%02d EPSG:326%02d $srs", $zone, $zone-1, $zone+1);
			}
		elsif (m/Lower Left\s*\(\s*([-0-9\.]+)\s*,\s*([-0-9\.]+)/)
			{
			$minx = $1;
			$miny = $2;
			}
		elsif (m/Upper Right\s*\(\s*([-0-9\.]+)\s*,\s*([-0-9\.]+)/)
			{
			$maxx = $1;
			$maxy = $2;
			}
		elsif (m/Size is\s*(\d+)\s*,\s*(\d+)/)
			{
			$width = $1;
			$height = $2;
			}
		}

	# Now that we have the width and height, generate the reduced resolution versions
	my $r_width;
	my $r_height;
	my $thumb_width;
	my $thumb_height;
	if ($width > $height) {
		$r_width = 1024;
		$r_height = int(1024 * $height / $width);
		$thumb_width = 64;
		$thumb_height = int(64 * $height / $width);
	} else {
		$r_height = 1024;
		$r_width = int(1024 * $width / $height);
		$thumb_height = 64;
		$thumb_width = int(64 * $width / $height);
	}
	execute("gdal_translate -of JPEG -co worldfile=false -outsize $r_width $r_height $workingdir/${scene}.tif $destdir/reduced/$scene.jpg") unless ($instr eq "T");
	unlink("$destdir/reduced/$scene.jpg.aux.xml");
	execute("gdal_translate -of JPEG -co worldfile=false -outsize $r_width $r_height $workingdir/${scene}_TIR.tif $destdir/reduced/${scene}_TIR.jpg") unless ($instr eq "O");
	unlink("$destdir/reduced/${scene}_TIR.jpg.aux.xml");
	execute("gdal_translate -of JPEG -co worldfile=false -outsize $r_width $r_height -expand rgb $destdir/${scene}_QB.png $destdir/reduced/${scene}_QB.jpg");
	unlink("$destdir/reduced/${scene}_QB.jpg.aux.xml");

	execute("rm -fr $workingdir");
	}

# Call "system" with the supplied parameters, unless the -T option is
# set, in which case just print the command.
sub execute
	{
	print "@_\n" if $opt_T || $opt_v;
	system @_ unless $opt_T;
	}

# Convert year and day of year to YYYY-MM-DD (ISO 8601)
sub cvtdate
	{
	my ($year, $day) = @_;
	my $month;
	my @dayspermonth = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	if ((($year % 4) == 0) && ((($year % 100) != 0) || ($year % 400 == 0)))
		{
		$dayspermonth[2] = 29;
		}
	for ($month = 1; $month <= 12; $month++)
		{
		last if ($day <= $dayspermonth[$month]);
		$day -= $dayspermonth[$month];
		}
	return sprintf("$year-%02d-%02d", $month, $day);
	}

# Read the gain and bias parameters from the MTL file
sub get_gain_bias {
	my ($mtl_file, $gain, $bias) = @_;
	unless (open(MTL, "<$mtl_file")) {
		print STDERR "Warning: can't open $mtl_file, using defaults for gain/bias\n";
		foreach my $i (1, 2, 3, 4, 5, 6, 7, 8, 9) {
			$gain->[$i] = "2.00E-05";
			$bias->[$i] = "-0.10000";
		}
		return;
	}
	while (<MTL>) {
		if (m/REFLECTANCE_MULT_BAND_(\d+)\s*=\s*(\S+)/) {
			$gain->[$1] = $2;
		} elsif (m/REFLECTANCE_ADD_BAND_(\d+)\s*=\s*(\S+)/) {
			$bias->[$1] = $2;
		}
	}
	close(MTL);
}
