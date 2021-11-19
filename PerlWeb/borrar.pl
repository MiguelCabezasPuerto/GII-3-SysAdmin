#!/usr/bin/perl

use strict;
use warnings;
use CGI qw();
use CGI::Session;
use DBI;
use Linux::usermod;
use File::Path;
use MIME::Base64;
use Email::Send::SMTP::Gmail;
print "Content-type: text/html\n\n";

my $ERROR;
my $peticion=CGI->new;
my $IP="172.20.1.73";

my $login=$peticion->param('login');
my $passwd=$peticion->param('password');



my $base_datos="usuarios"; #Nombre de las base de datos
my $usuario="useradmin"; #Usuario de la BD
my $clave="rootadmin"; #Password de la BD
my $driver="mysql"; #Utilizamos el driver de mysql
my $tabla="definitivos"; #Nombre de la tabla de ejemplo
my $tabla2="verificados";
my $tabla3="temporales";
my $tabla4="borrados";



#Conectamos con la BD, si no podemos, ponemos un mensaje de error
my $dbh = DBI->connect("dbi:$driver:database=$base_datos",$usuario,$clave) || die "\nError al abrir la base datos: $base_datos::errstr\n";

my $encoded = encode_base64($passwd);

my $consulta=$dbh->prepare("SELECT * FROM $tabla where login='$login' and password='$encoded';");
$consulta->execute();
my $encontrar = 0;
while($consulta->fetch()){#buscar por filas en la BD
$encontrar=1;
}


if($encontrar eq 1){
$consulta->finish;
my $consulta13=$dbh->prepare("INSERT INTO $tabla4(login) values('$login');");
$consulta13->execute();
$consulta13->finish;
my $consulta2=$dbh->prepare("DELETE FROM $tabla where login='$login' and password='$encoded';");
$consulta2->execute();
$consulta2->finish;
my $consulta3=$dbh->prepare("DELETE FROM $tabla2 where login='$login' and password='$encoded';");
$consulta3->execute();
$consulta3->finish;
my $consulta4=$dbh->prepare("DELETE FROM $tabla3 where login='$login' and password='$encoded';");
$consulta4->execute();
$consulta4->finish;
$dbh->disconnect();
my $mensaje="Se ha dado de baja el usuario: $login";
my $email='miguelcabezaspuerto@gmail.com';
my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com',-login=>'miguelcabezaspuerto@gmail.com',
                                        -pass=>'soyelputoamoyelmejor',-layer=>'ssl');
 
$mail->send(-from=>'admin@admin.com', -to=>$email, -subject=>'Baja de usuario',
            -body=>$mensaje);
$mail->bye;
print "<h3 style='color:red'>Cuenta borrada</h3>";
print "<a href='http://$IP/registrar.html'>Registro</a>";
exit;
}
else{
$consulta->finish;
$dbh->disconnect();
print "<h3 style='color:red'>Datos incorrectos...</h3>";
print "<a href='http://$IP/borrar.html'>Borrar cuenta</a>";
exit;
}
