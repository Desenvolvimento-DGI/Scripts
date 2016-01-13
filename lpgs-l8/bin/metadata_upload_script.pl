#!/usr/bin/perl -w
# Disclaimer: This software is provided "As Is", without a warranty or
# support of any kind. The software is public-domain.
#
# This is an example of how to script downloads, see the
# "Configurable parameters" section below.

use strict;
use vars qw($opt_h $opt_v $opt_X);
use Getopt::Std;
use LWP;
use Crypt::SSLeay;
use HTTP::Request::Common;
use HTTP::Cookies;
use HTML::Parser;
getopts("h:vX") || die(<<"END_USAGE");
Usage: $0 [-h hostname] [-v] [-X] files...
Where
	-h hostname	host name, default is landsat.usgs.gov
	-v		verbose: list files being retrieved
	-X		debug: print HTTP headers
	files...	one or more files to be uploaded
END_USAGE
$opt_h ||= "landsat.usgs.gov";

#
# Configurable parameters
#
my $username = "ivanmbarbosa";		# replace with your login username
my $password = "hpnc8430";		# replace with your login password
my $station_name = "CUB";	# replace with station name, e.g. ASA, JSA, etc.
# Use this for uploading metadata
my $upload = "/IGS/?q=validate_metadata";
#
# End of Configurable parameters
#

my $login_url = "https://$opt_h/up_login.php";
my $request;
my $response;

# Check the file names
foreach my $file (@ARGV) {
    unless ($file =~ m/\.xml$/) {
        print STDERR "Invalid filename extension.  $file must have a .xml extension\n";
        print STDERR "No files were uploaded.\n";
        exit(1);
    }
}

my $ua = new LWP::UserAgent;
my $cjar = new HTTP::Cookies;
$ua->max_redirect(0);
$request = new HTTP::Request(POST => $login_url);
$request->content_type("application/x-www-form-urlencoded");
$request->content("username=$username&password=$password");
$response = $ua->request($request);
$cjar->extract_cookies($response);
print "Status: ", $response->code(), "\n" if $opt_X;
if ($response->code() != 302) {
	die("Invalid username/password");
}
my $cookie = $response->header("Set-Cookie");
unless ($cookie =~ m/(landsat_up_private=\w+)/) {
	die("Unable to establish session");
}
my $session_id = $1;
print "Found session cookie: $session_id\n" if $opt_X;
my $check_session = $response->header("Location");
print "Location: $check_session\n" if $opt_X;
$request = new HTTP::Request(GET => $check_session);
$cjar->add_cookie_header($request);
$response = $ua->request($request);
if ($opt_X) {
	print "Status: ", $response->code(), "\n";
	print "\nResponse headers:\n";
	print_headers($response);
	print "\n";
}
$cjar->extract_cookies($response);
if ($response->code() == 302) {
	my $d = $response->header("Location");
	$d =~ s"\.\./\.\."http://$opt_h";
	$request = new HTTP::Request(GET => $d);
	$request->header("Cookie", $session_id);
	$response = $ua->request($request);
	$cjar->extract_cookies($response);
	if ($opt_X) {
		print "Status: ", $response->code(), "\n";
		print "\nResponse headers:\n";
		print_headers($response);
		print "\n";
		print "Cookie jar: ", $cjar->as_string(), "\n";
	}
}
print "session_id=$session_id\n" if $opt_X;
my @success = ();
my @fail = ();
my @c = ('ic_name' => $station_name,
    'DQA' => 'jshaw@usgs.gov');
foreach my $file (@ARGV) {
    push(@c, 'fileup[]' => ["$file"]);
}
$HTTP::Request::Common::DYNAMIC_FILE_UPLOAD = 1;
$request = POST "http://$opt_h$upload",
    Content_Type => "form-data",
    Content      => \@c,
    ;
my $gen = $request->content();
die("gen=$gen") unless ref($gen) eq "CODE";
$request->content(
    sub {
        my $chunk = &$gen();
        return $chunk;
    }
);
$cjar->add_cookie_header($request);
$ua->max_redirect(0);
$response = $ua->request($request);
if ($opt_X) {
    print "Status: ", $response->code(), "\n";
    print "Request headers:\n";
    print_headers($request);
    print "\nResponse headers:\n";
    print_headers($response);
    print "\n";
    print "Response content:\n", $response->content(), "\n";
}

my $found_div = 0;
my $parser = HTML::Parser->new(api_version => 3,
    start_h => [\&div_start_handler, "self,tagname,attr"],
    end_h => [\&div_end_handler, "self,tagname,attr"],
    text_h => [\&text_handler, "dtext"],
    report_tags => [qw(div)]);
$parser->parse($response->content());
$parser->eof();

sub div_start_handler
{
    my($self, $tag, $attr) = @_;
    return unless ($tag eq "div")
        && (exists $attr->{class})
        && ($attr->{class} eq "field-item even");
    $found_div = 1;
}
sub div_end_handler
{
    my($self, $tag, $attr) = @_;
    print "\n" if $found_div;
    $found_div = 0;
}
sub text_handler
{
    print shift if $found_div;
}

sub print_headers
{
	my $response = shift;
	foreach my $h ($response->header_field_names()){
		print "$h: ", $response->header($h), "\n";
	}
}

