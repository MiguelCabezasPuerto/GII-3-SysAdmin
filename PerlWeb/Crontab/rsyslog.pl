#!/usr/bin/perl

use strict;
use warnings;
use Email::Send::SMTP::Gmail;

my $encoding = ":encoding(UTF-8)";
my $log = "/var/log/auth.log";
my $apache = "/var/log/apache2/access.log";
my $ficheroAccesos = "accesos.txt";
my $ficheroApache = "apache.txt";
my $handle1;
my $handle2;
my $handle3;
my $handle4;
my $email = "halbertoh3\@gmail.com";
my $accesosFallidos = "ACCESOS FALLIDOS";
my $accesosCorrectos = "ACCESOS CORRECTOS";
my $accesoRemoto = "ACCESOS REMOTOS";
my $desconexionesRemotas = "DESCONEXIONES REMOTAS";
my $intentosFallidos = "INTENTOS DE ACCESO REMOTO FALLIDOS";
my $intentoAcceso = "SUPERADO MAXIMO DE INTENTOS REMOTOS";
my $fallo = "FAILED";
my $separacion = "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
my $linea;
my $info = "Informacion sobre los accesos";
my $correcto = "Successful";
my $ssh = "sshd:session";
my $desconexion = "Received disconnect";
my $falloContrasena = "Failed password";
my $maximo = "more authentication failures";
my $apacheRegistro = "USUARIOS REGISTRADOS";
my $apacheVerificacion = "USUARIOS VERIFICADOS";
my $registro = "registrar.pl";
my $verificar = "verificar.pl";
my $login = "login.pl";
my $apacheLogin = "Usuarios logeados";

open($handle1, "<$encoding", $log);
while($linea = <$handle1>){
	chomp($linea);
	if($linea =~ m/$fallo/){
		$accesosFallidos = $accesosFallidos . "\n" . $linea;
	}

	if($linea =~ m/$correcto/){
		$accesosCorrectos = $accesosCorrectos . "\n" . $linea;
	}

	if($linea =~ m/$ssh/){
		$accesoRemoto = $accesoRemoto . "\n" . $linea;
	}

	if($linea =~ m/$desconexion/){
		$desconexionesRemotas = $desconexionesRemotas . "\n" . $linea;
	}

	if($linea =~ m/$falloContrasena/){
		$intentosFallidos = $intentosFallidos . "\n" . $linea;
	}

	if($linea =~ m/$maximo/){
		$intentoAcceso = $intentoAcceso . "\n" . $linea;
	}
}
close($handle1);

open($handle2, ">>$encoding", $ficheroAccesos);
print $handle2 $separacion;
print $handle2 $accesosFallidos;
print $handle2 $separacion;
print $handle2 $accesosCorrectos;
print $handle2 $separacion;
print $handle2 $accesoRemoto;
print $handle2 $separacion;
print $handle2 $desconexionesRemotas;
print $handle2 $separacion;
print $handle2 $intentosFallidos;
print $handle2 $separacion;
print $handle2 $intentoAcceso;
print $handle2 $separacion;
close($handle2);

open($handle3, "<$encoding", $apache);
while($linea = <$handle3>){
	chomp($linea);
	if($linea =~ m/$registro/){
		$apacheRegistro = $apacheRegistro . "\n" . $linea;
	}

	if($linea =~ m/$verificar/){
		$apacheVerificacion = $apacheVerificacion . "\n" . $linea;
	}

	if($linea =~ m/$login/){
		$apacheLogin = $apacheLogin . "\n" . $linea;
	}
}
close($handle3);

open($handle4, ">>$encoding", $ficheroApache);
print $handle4 $separacion;
print $handle4 $apacheRegistro;
print $handle4 $separacion;
print $handle4 $apacheVerificacion;
print $handle4 $separacion;
print $handle4 $apacheLogin;
print $handle4 $separacion;
close($handle4);

my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com',-login=>'miguelcabezaspuerto@gmail.com',
                                        -pass=>'soyelputoamoyelmejor',-layer=>'ssl');
 
$mail->send(-from=>'miguelcabezaspuerto@gmail.com', -to=>$email, -subject=>'Accesos al sistema',
            -body=>$info, -attachments=>$ficheroAccesos);

$mail->send(-from=>'miguelcabezaspuerto@gmail.com', -to=>$email, -subject=>'Accesos Apache',
            -body=>$info, -attachments=>$ficheroApache);

$mail->bye;

unlink $ficheroAccesos;
unlink $ficheroApache;

open($handle1, "<$encoding", $log);
print $handle1 "";
close($handle1);

open($handle3, "<$encoding", $apache);
print $handle3 "";
close($handle3);