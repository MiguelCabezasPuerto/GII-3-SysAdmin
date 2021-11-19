use warnings;
use strict;
use Config::Crontab;

my $ct=new Config::Crontab;
my $block=new Config::Crontab::Block;

$block=new Config::Crontab::Block;
$block->last(new Config::Crontab::Comment( -data => '### checkea si ha habido alguna alta de usuarios cada minuto'));
$block->last(new Config::Crontab::Event( -command => 'perl /usr/lib/cgi-bin/revision.pl'));

$ct->last($block);

$ct->write;

print "\nCrontab activado. Escriba crontab -e para comprobarlo\n";
