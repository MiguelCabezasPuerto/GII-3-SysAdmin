#!/usr/bin/perl

use strict;
use warnings;
use CGI qw();
use CGI::Session;
use DBI;
use Linux::usermod;
use File::Path;

my $base_datos="usuarios"; #Nombre de las base de datos
my $usuario="useradmin"; #Usuario de la BD
my $clave="rootadmin"; #Password de la BD
my $driver="mysql"; #Utilizamos el driver de mysql
my $tabla="borrados";
my $ERROR;

my $dbh = DBI->connect("dbi:$driver:database=$base_datos",$usuario,$clave) || die "\nError al abrir la base datos: $base_datos::errstr\n";

my $consulta= $dbh->prepare("SELECT * FROM $tabla;");
$consulta->execute();
while(my $ref = $consulta->fetchrow_hashref()){
	my $login=$ref->{login};
	my $path="/mnt/home/$login";
	my $pathMail="/var/mail/$login";
	Linux::usermod->del($login);
	rmtree($path) or die "Cannot rmtree '$path' : $!";
	rmtree($pathMail) or die "Cannot rmtree '$path' : $!";
	my $sth=$dbh->prepare("DELETE FROM $tabla where login='$login';");
	$sth->execute();
	$sth->finish;
	if($ERROR){
		print "Error";
		last;
	}	
}
$consulta->finish;
$dbh->disconnect();
