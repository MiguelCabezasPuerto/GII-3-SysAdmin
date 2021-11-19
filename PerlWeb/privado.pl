#!/usr/bin/perl -w

use strict;
use warnings;

use CGI;
use CGI::Session;
##use CGI::Carp qw(fatalsToBrowser);
use DBI;

#print "Content-type: text/html\n\n";
my $IP="172.20.1.73";
#crear objeto cgi
my $cgi=new CGI;

#crear objeto session
my $session= new CGI::Session;

#Cargamos los datos de la sesion
$session->load();

#creamos array con los datos de sesion

my @autenticar= $session->param;

if(@autenticar eq 0){ #no existen datos de sesion, destruimos sesion abierta
	$session->delete();	
	$session->flush();
	my $session2= new CGI::Session;
	print $session2->header(-location=> "http://$IP/login.html");
	print "Content-type: text/html\n\n";
	print "<h3 style='color: red;'>Usted no tiene permisos </h3>";
}
elsif($session->is_expired){
	$session->delete();	
	$session->flush();
	#print $cgi->header("text/html");
	my $session3= new CGI::Session;
	print $session3->header(-location=> "http://$IP/login.html");
	print "Content-type: text/html\n\n";
	print "<h3 style='color:red'>Su sesion ha expirado</h3>";
}
else{
#print $cgi->header("text/html");
#print "<h3>Bienvenido ". $session->param("login") . " a su cuenta</h3>";
#print "<br><br>";
my $login= $session->param("login");
print $session->header(-location=> "http://$IP/~$login/index.html");
#print "<a href='/home/$login/index.html'>Espacio personal</a>";
#print "<a href='logout.pl'>Salir</a>";
}




