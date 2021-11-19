#!/usr/bin/perl -w

use strict;
use warnings;

use CGI qw();
use CGI::Session;
##use CGI::Carp qw(fatalsToBrowser);

#print "Content-type: text/html\n\n";
my $IP="172.20.1.73";
my $session=new CGI::Session;
$session->load();
$session->delete();
$session->flush();
print $session->header(-location=> "http://$IP/login.html");
exit;
