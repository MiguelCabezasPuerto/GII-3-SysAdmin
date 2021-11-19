#!/usr/bin/perl

use strict;
use warnings;
use CGI qw();
use CGI::Session;
use DBI;
use MIME::Base64;

#AQUI LEER LO DEL HTML , LEER EL FICHERO CON NOMBRE LOGIN_USUARIO.TXT Y COMPROBAR QUE EL CODIGO DE VERIFICACION INTRODUCIDO POR EL USUARIO ES EL MISMO DEL FICHERO
my $ERROR;
my $peticion=CGI->new;
my $session= new CGI::Session;
my $session2= new CGI::Session;
#Recogemos los parametros del formulario

my $login=$peticion->param('login');
my $codigo=$peticion->param('codigo');

my $txt='txt';
my $prefix='/home/www-data/';
my $file= $prefix . $login . '.' .$txt;
my $code;
my $IP="172.20.1.73";
print "Content-type: text/html\n\n";

 if (-e $file){
open my $info, $file or die "Could not open $file: $!";



while( my $line = <$info>)  {   
	chomp($line);  
   $code=$line;
}

close ($info);


if($codigo eq $code){
my $base_datos="usuarios"; #Nombre de las base de datos
my $usuario="useradmin"; #Usuario de la BD
my $clave="rootadmin"; #Password de la BD
my $driver="mysql"; #Utilizamos el driver de mysql
my $tabla="verificados"; #Nombre de la tabla de ejemplo
my $tabla3="temporales";
my $dbh = DBI->connect("dbi:$driver:database=$base_datos",$usuario,$clave,{'RaiseError'=>1}); 



my $sth5=$dbh->prepare("SELECT * from $tabla");
$sth5->execute();


while(my $ref5 = $sth5->fetchrow_hashref()){
	if($login eq $ref5->{login}){
		$sth5->finish;
		$dbh->disconnect;
		print "<h3 style='color:blue'>Usted ya se ha verificado una vez</h3>";
		print "<a href='http://$IP/login.html'>Login</a>";
		exit;
	}
	if($ERROR){
		last;
		print "<h3 style='color:red'>Error de conexion</h3>";
		print "<a href='http://$IP/verificar.html'>Intentar de nuevo</a>";
		exit;
	}
}

$sth5->finish;

my $sth3=$dbh->prepare("SELECT * from $tabla3");
$sth3->execute();


while(my $ref3 = $sth3->fetchrow_hashref()){
	if($login eq $ref3->{login}){
		my $passwd=$ref3->{password};
		my $decoded = decode_base64($passwd);
		my $nombre=$ref3->{nombre};
		my $apellidos=$ref3->{apellidos};
		my $email=$ref3->{email};
		my $postal=$ref3->{direccion};
		$sth3->finish;
my $encoded = encode_base64($decoded);
		my $sth4 = $dbh->prepare("INSERT INTO $tabla			(login,password,nombre,apellidos,email,direccion,tipo) values	('$login','$encoded','$nombre','$apellidos','$email','$postal','cliente');");
 #Realizamos la etapa de ejecución de la sentencia
 $sth4->execute();
#Realizamos la etapa de liberación de recursos ocupados por la sentencia
$sth4->finish();
$dbh->disconnect;
unlink $file;
print "<h3 style='color:blue'>Registrado con exito,espere un minuto para loguearse</h3>";
print "<a href='http://$IP/login.html'>Login</a>";

	exit;
	}
	if($ERROR){
		last;
		print "<h3 style='color:red'>Error de conexion</h3>";
		print "<a href='http://$IP/verificar.html'>Intentar de nuevo</a>";
		exit;
	}
}

}
else{
#print $peticion->header("text/html");
print "<h3 style='color:red'>Codigo incorrecto</h3>";
print "<a href='http://$IP/verificar.html'>Intentar de nuevo</a>";
exit;
}

exit;

}

else{
print "<h3 style='color:red'>Login incorrecto</h3>";
print "<a href='http://$IP/verificar.html'>Intentar de nuevo</a>";
exit;
}
