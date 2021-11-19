#!/usr/bin/perl

use strict;
use warnings;
use CGI qw();
use DBI;
use Email::Valid;
use CGI::Session;
use Email::Send::SMTP::Gmail;
use MIME::Base64;


my $IP="172.20.1.73";
my $peticion=CGI->new;
my $session= new CGI::Session;
#Recogemos los parametros del formulario
my $login=$peticion->param('nombreUsuario');
my $passwd=$peticion->param('contrasena');
my $confirmacion =$peticion->param("confirmacionContrasena");
my $nombre=$peticion->param('nombrePersona');
my $apellidos=$peticion->param('apellidoPersona');
my $email=$peticion->param('email');
my $postal =$peticion->param("direccion");
my $ERROR=0;

if(!$login || !$passwd || !$confirmacion || !$nombre || !$apellidos || !$email || !$postal ){
	#comprobamos que todos los campos estan rellenos

	
		#print $peticion->header("text/html");
		#print "<META HTTP-EQUIV='Refresh' CONTENT='3; URL='http://localhost/registrar.html'>";
		print "Content-type: text/html\n\n";
		print "<h3 style='color:red'>Campos vacios</h3>";
		print "<a href='http://$IP/registrar.html'>Registro</a>";
		exit;

}

if(!($passwd eq $confirmacion)){
		#print $peticion->header("text/html");
		#print "<META HTTP-EQUIV='Refresh' CONTENT='3; URL='http://localhost/registrar.html'>";
		print "Content-type: text/html\n\n";
		print "<h3 style='color:red'>Las contraseñas no coinciden</h3>";
		print "<a href='http://$IP/registrar.html'>Registro</a>";
		exit;
}

if(!Email::Valid->address($email)){
	
	#print $peticion->header("text/html");
	#print "<META HTTP-EQUIV='refresh' CONTENT='3; URL='http://localhost/registrar.html'>";
	print "Content-type: text/html\n\n";
	print "<h3 style='color:red'>Email no valido</h3>";
	print "<a href='http://$IP/registrar.html'>Registro</a>";
	exit;
}
if($login !~ /^[a-z0-9]+$/){
	
	#print $peticion->header("text/html");
	#print "<META HTTP-EQUIV='refresh' CONTENT='3; URL='http://localhost/registrar.html'>";
	print "Content-type: text/html\n\n";
	print "<h3 style='color:red'>Usuario no valido, solo permitidos caracteres alfanumericos en minuscula</h3>";
	print "<a href='http://$IP/registrar.html'>Registro</a>";
	exit;	
}
my $base_datos="usuarios"; #Nombre de las base de datos
my $usuario="useradmin"; #Usuario de la BD
my $clave="rootadmin"; #Password de la BD
my $driver="mysql"; #Utilizamos el driver de mysql
my $tabla="temporales"; #Nombre de la tabla de ejemplo

my $dbh = DBI->connect("dbi:$driver:database=$base_datos",$usuario,$clave,{'RaiseError'=>1}); 

my $sth=$dbh->prepare("SELECT * from $tabla");
$sth->execute();

while(my $ref = $sth->fetchrow_hashref()){
	if($login eq $ref->{login}){
	
		#print $peticion->header("text/html");
	#print "<META HTTP-EQUIV='refresh' CONTENT='3; URL='http://localhost/registrar2.html'>";
	print "Content-type: text/html\n\n";
	print "<h3 style='color:red'>El usuario ya existe</h3>";
	print "<a href='http://$IP/registrar.html'>Registro</a>";
	$sth->finish;
	exit;
	}
	if($ERROR){
		last;
		exit;
	}
}
$sth->finish;


my $tabla2="verificados"; #Nombre de la tabla de ejemplo
 

my $sth2=$dbh->prepare("SELECT * from $tabla2");
$sth2->execute();

while(my $ref2 = $sth2->fetchrow_hashref()){
	if($login eq $ref2->{login}){

		#print $peticion->header("text/html");
	#print "<META HTTP-EQUIV='refresh' CONTENT='3; URL='http://localhost/registrar2.html'>";
	print "Content-type: text/html\n\n";
	print "<h3 style='color:red'>El usuario ya existe</h3>";
	print "<a href='http://$IP/registrar.html'>Registro</a>";
	exit;
	}
	if($ERROR){
		last;
	}
}
$sth2->finish;


my $tabla3="definitivos"; #Nombre de la tabla de ejemplo
 
my $sth3=$dbh->prepare("SELECT * from $tabla3");
$sth3->execute();

while(my $ref3 = $sth3->fetchrow_hashref()){
	if($login eq $ref3->{login}){
	
		#print $peticion->header("text/html");
	#print "<META HTTP-EQUIV='refresh' CONTENT='3; URL='http://localhost/registrar2.html'>";
	print "Content-type: text/html\n\n";
	print "<h3 style='color:red'>El usuario ya existe</h3>";
	print "<a href='http://$IP/registrar.html'>Registro</a>";
	exit;
	}
	if($ERROR){
		last;
	}
}
$sth3->finish;

#INSERTAR AL USUARIO EN LA BASE DE DATOS
my $encoded = encode_base64($passwd);
 my $sth4 = $dbh->prepare("INSERT INTO $tabla(login,password,nombre,apellidos,email,direccion,tipo) values('$login','$encoded','$nombre','$apellidos','$email','$postal','cliente');");
 #Realizamos la etapa de ejecución de la sentencia
 $sth4->execute();
#Realizamos la etapa de liberación de recursos ocupados por la sentencia
$sth4->finish();

$dbh->disconnect;


#print "Content-type: text/html\n\n";
#print "<h3 style='color:blue'>Registrado con exito, revise su correo para confirmar su cuenta</h3>";


my $session3= new CGI::Session;
print $session3->header(-location=> "http://$IP/verificar.html");#Poner la IP del servidor en vez de localhost para probar desde otra maquina en la misma red

my $campo;
my @datos=("$login","$passwd","$nombre","$apellidos","$email","$postal","cliente");
my @registro=join(",",@datos);

my @BASE = ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','X','Y','Z',
'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','x','y','z','1',
'2','3','4','5','6','7','8','9','0','?','@','#');
my $LONGITUD_DEFECTO=15;

my $verificacion='';
    while($LONGITUD_DEFECTO--) {
        $verificacion.=$BASE[rand 63];
    }


my $txt='txt';
my $prefix='/home/www-data/';
my $fileD= $prefix . $login . '.' .$txt;

open (Usuario,">>$fileD");

print Usuario $verificacion;
close (Usuario);

#MANDAR MAIL CON CODIGO DE VERIFICACION

#my ($remitente, $destinatario, $asunto, $mensaje) = @_;
  #  open(MAIL, "|/usr/lib/sendmail -oi -t");
   # print MAIL "From: admin\n";
   # print MAIL "To: $email\n";
    #print MAIL "Subject: Codigo de verificacion\n\n";
    #print MAIL "$verificacion\n";
    #close(MAIL);

my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com',-login=>'miguelcabezaspuerto@gmail.com',
                                        -pass=>'soyelputoamoyelmejor',-layer=>'ssl');


my $cuerpo="Login: $login\nPassword: $passwd\nNombre: $nombre\nApellidos: $apellidos\nEmail: $email\nDireccion postal: $postal\nCODIGO DE VERIFICACION: $verificacion";
 
$mail->send(-from=>'admin@admin.com', -to=>$email, -subject=>'Codigo de verificacion',
            -body=>$cuerpo);
$mail->bye;

exit;



