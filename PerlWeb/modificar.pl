#!/usr/bin/perl

use strict;
use warnings;
use CGI qw();
use DBI;
use Email::Valid;
use CGI::Session;
use Linux::usermod;
use MIME::Base64;
use Email::Send::SMTP::Gmail;

my $peticion=CGI->new;
my $session= new CGI::Session;
#Recogemos los parametros del formulario
my $login=$peticion->param('nombreUsuario');
my $passwd=$peticion->param('antigua');
my $passwdNueva=$peticion->param('contrasena');
my $confirmacion =$peticion->param("confirmacionContrasena");
my $nombre=$peticion->param('nombrePersona');
my $apellidos=$peticion->param('apellidoPersona');
my $email=$peticion->param('email');
my $postal =$peticion->param("direccion");
my $ERROR=0;
my $tipo;
my $IP="172.20.1.73";
print "Content-type: text/html\n\n";

if(($passwdNueva) && ($confirmacion) && !($passwdNueva eq $confirmacion)){
		print "Content-type: text/html\n\n";
		print "<h3 style='color:red'>Las contraseñas no coinciden</h3>";
		print "<a href='http://$IP/modificar.html'>Modificar</a>";
		exit;
}



my $base_datos="usuarios"; #Nombre de las base de datos
my $usuario="useradmin"; #Usuario de la BD
my $clave="rootadmin"; #Password de la BD
my $driver="mysql"; #Utilizamos el driver de mysql
my $tabla="definitivos"; #Nombre de la tabla de ejemplo
my $tabla2="modificados";
my $tabla3="temporales";
my $tabla4="verificados";


my $dbh = DBI->connect("dbi:$driver:database=$base_datos",$usuario,$clave,{'RaiseError'=>1});

my $sth=$dbh->prepare("SELECT * from $tabla;");
$sth->execute();
my $decoded;
my $encoded = encode_base64($passwdNueva);
my $encoded_vieja=encode_base64($passwd);
while(my $ref = $sth->fetchrow_hashref()){
	if(($login eq $ref->{login}) && ($encoded_vieja eq $ref->{password})){
	if(!$passwdNueva){
	$passwdNueva=$ref->{password};
	$encoded=$passwdNueva;
	}
	if(!$nombre){
	$nombre=$ref->{nombre};
	}
	if(!$apellidos){
	$apellidos=$ref->{apellidos};
	}
	if(!$email){
	$email=$ref->{email};
	}
	if(!$postal){
	$postal=$ref->{direccion};
	}
	$tipo=$ref->{tipo};
	my $consulta13=$dbh->prepare("INSERT INTO $tabla2(login,password) values('$login','$encoded');");
	$consulta13->execute();
	$consulta13->finish;
	my $sth2=$dbh->prepare("UPDATE $tabla SET password='$encoded',nombre='$nombre',apellidos='$apellidos',email='$email',direccion='$postal',tipo='$tipo' where login='$login' and password='$encoded_vieja';");
	$sth2->execute();
	$sth2->finish;
	my $sth33=$dbh->prepare("UPDATE $tabla3 SET password='$encoded',nombre='$nombre',apellidos='$apellidos',email='$email',direccion='$postal',tipo='$tipo' where login='$login' and password='$encoded_vieja';");
	$sth33->execute();
	$sth33->finish;
	my $sth44=$dbh->prepare("UPDATE $tabla4 SET password='$encoded',nombre='$nombre',apellidos='$apellidos',email='$email',direccion='$postal',tipo='$tipo' where login='$login' and password='$encoded_vieja';");
	$sth44->execute();
	$sth44->finish;
	if($ERROR){
		last;
		exit;
	}
	$sth->finish;
	$dbh->disconnect;
	my $mensaje="Se ha modificado la informacion del usuario: $login";
	my $email='miguelcabezaspuerto@gmail.com';
	my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com',-login=>'miguelcabezaspuerto@gmail.com',
                                        -pass=>'soyelputoamoyelmejor',-layer=>'ssl');
 
	$mail->send(-from=>'admin@admin.com', -to=>$email, -subject=>'Modificacion usuario',
            -body=>$mensaje);
	$mail->bye;
	print "<h3 style='color:blue'>Datos modificados correctamente</h3>";
	print "<a href='http://$IP/modificar.html'>Seguir modificando</a>";
}

}
$sth->finish;
print "<h3 style='color:red'>Login y/o contrasena incorrectos</h3>";
print "<a href='http://$IP/modificar.html'>Volver</a>";

$dbh->disconnect;
exit;
