#!/usr/bin/perl

my %config = do 'config.pl';
use Data::Dumper;
use DBI;
my $dbh = DBI->connect("DBI:mysql:database=".$config{db}.";host=".$config{dbserver}."", $config{user}, $config{password}) || die "Could not connect to database: $DBI::errstr";
my $sth = $dbh->prepare('SELECT * FROM log');
$sth->execute();
my $result = $sth->fetchall_hashref("id");

print "$_ $result{$_}\n" for (sort keys %$result);
#warn Dumper $result;