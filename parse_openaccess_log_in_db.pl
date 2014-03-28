#!/usr/bin/perl
# store it in crontab, e.g. 
# * * * * * root perl /home/pi/parse_openaccess_log_in_db.pl /home/access/scripts/access_log.txt

use Tie::File;
use Data::Dumper;
use DBI;

if ($#ARGV == -1) { 
    print "ARGV = $#ARGV. Please, specify log file to process, e.g. \"parse_in_db.pl /home/access/scripts/access_log.txt\"\n";
    exit 1 
}

my $openaccess_log_file = @ARGV[0];
my %config = do 'config.pl'; 

tie my @file, 'Tie::File', $openaccess_log_file or die $!;

my $hash;   ### temp hash for one item from file
my @arr;

for my $linenr (0 .. $#file) {             # loop over line numbers
    if ($file[$linenr] =~ /^(\d{1,2}:\d{1,2}:\d{1,2})\s{2}(\d{1,2}\/\d{1,2}\/\d{1,2})\s([A-Z]{3})\sUser\s(\d{7})\spresented\stag\sat\sreader\s(\d{1})/) {
    	#print "date: ".$2." time :".$1." day : ".$3." user : ".$4." tag : ".$5."\n";
     	my @date = split('/', $2);
     	if ( length $date[0] == 1 )  { $date[0] = "0".$date[0]; }
		if ( length $date[1] == 1 )  { $date[1] = "0".$date[1]; }
     	my $true_date = "20".$date[2]."-".$date[0]."-".$date[1];
     	#$true_date =~ s/\//\-/g;
     	my @time = split(':', $1);
     	for (@time) { 
     		if (length $_ == 1) { $_ = "0".$_ ; } 
     	}

     	my $true_time = $time[0].":".$time[1].":".$time[2];

     	$hash->{'created'} = $true_date." ".$true_time;
     	$hash->{'tag'} = $4;
     	$hash->{'reader'} = $5;

     	if ($file[$linenr+1] =~ /User\s(\d{1,3})\sauthenticated/) {
			$hash->{'user'} = $1;
		}

		if ($file[$linenr+1] =~ /User\snot\sfound/) {
			$hash->{'user'} = "null";
			$hash->{'type'} = "0";			
		}

		if ($file[$linenr+2] =~ /granted access/) {
			$hash->{'type'} = "1";	# entrance
		}
 	
 	push @arr, $hash;
    $hash={};
    }
    
}
untie @file;

print "Find ".scalar @arr." new items \n";

########  Clear openaccess log file for avoid duplicated entries
open (FILE, ">", $openaccess_log_file) or die "Unable to open file, $!";
print "Clearing $openaccess_log_file...\n";
#truncate(FILE,0);
close FILE or warn "Unable to close the file handle: $!";

############################

my $from_file = { map { $_->{'created'} => $_ } @arr };
warn Dumper $from_file;

###### Insert it in DB #######

my $dbh = DBI->connect("DBI:mysql:database=".$config{db}.";host=".$config{dbserver}."", $config{user}, $config{password}) || die "Could not connect to database: $DBI::errstr";
my $i=0;

for (sort keys %$from_file ) {
    $sth = $dbh->prepare("INSERT into log (created,tag,user,reader,type) VALUES (?, ?, ?, ?, ?)") or die $dbh->errstr;
    $sth->execute($from_file->{$_}->{'created'}, $from_file->{$_}->{'tag'}, $from_file->{$_}->{'user'}, $from_file->{$_}->{'reader'}, $from_file->{$_}->{'type'})  or die $sth->errstr;
    $sth->finish();
    $i++;
	}

$dbh->disconnect();

print mysql_timestamp()." - Find ".scalar @arr." new items, ";
print scalar $i." items inserted in db \n";
print "Execution result will stored in $config{log}\n";

###############################

sub mysql_timestamp() {
        my($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
        my($result)=sprintf("%4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
        return $result;
}

##### Store results in log for checking cron exec

open (FILE, ">>", $config{log}) or die "Unable to open file, $!";
print FILE mysql_timestamp()." - Find ".scalar @arr." new items, ";
print FILE scalar $i." 0 items inserted in db \n";
close FILE or warn "Unable to close the file handle: $!";

