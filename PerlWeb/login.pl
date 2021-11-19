#!/usr/bin/perl -w

use strict;
use warnings;

use CGI qw();
use CGI::Session;
##use CGI::Carp qw(fatalsToBrowser);
use DBI;
use MIME::Base64;


my $IP="172.20.1.73";
my $cgi=new CGI;
my $elUsuario=$cgi->param("login");
my $usuario=$cgi->param("login",$elUsuario);
my $laContrasena=$cgi->param("password");
my $contrasena=$cgi->param("password",$laContrasena);


my $base_datos="usuarios"; #Nombre de las base de datos
my $usuario="useradmin"; #Usuario de la BD
my $clave="rootadmin"; #Password de la BD
my $driver="mysql"; #Utilizamos el driver de mysql
my $tabla="definitivos"; #Nombre de la tabla de ejemplo


#Conectamos con la BD, si no podemos, ponemos un mensaje de error
my $dbh = DBI->connect("dbi:$driver:database=$base_datos",$usuario,$clave) || die "\nError al abrir la base datos: $base_datos::errstr\n";

my $encoded = encode_base64($laContrasena);
my $consulta=$dbh->prepare("SELECT * FROM $tabla where login='$elUsuario' and password='$encoded';");
$consulta->execute();
my $encontrar = 0;
while($consulta->fetch()){#buscar por filas en la BD
$encontrar=1;
}

if($encontrar eq 1){
my $session= new CGI::Session;
$session->save_param($cgi);
$session->expires("+1h");
$session->flush();
print $session->header(-location=> "privado.pl");
#print "<h3>Autenticacion correcta</h3>";
}
else{
my $session2= new CGI::Session;
#print $cgi->header("text/html");
print $session2->header(-location=> "http://$IP/login.html");
print "Content-type: text/html\n\n";
print "<h3 style='color:red'>Datos incorrectos...</h3>";
}
$dbh->disconnect();


#Recogemos la peticion


