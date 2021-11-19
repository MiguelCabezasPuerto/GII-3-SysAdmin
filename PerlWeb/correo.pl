#!/usr/bin/perl
use strict;
use warnings;
use CGI qw();
use Email::Send::SMTP::Gmail;
use Email::Valid;

my $peticion=CGI->new;
my $correo=$peticion->param('email');
my $mensaje= $peticion->param('mensaje');
my $IP= "172.20.1.73";

my $cuerpo;

print "Content-type: text/html\n\n";

if(!Email::Valid->address($correo)){
print "<h3 style='color:red'>Email no valido </h3>";
print "<a href='http://$IP/contacto.html'>Volver a intentar</a>";
exit;
}

$cuerpo="De: $correo\n\nMensaje:\n$mensaje\n";

my $mail= Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com' , -login=>'miguelcabezaspuerto@gmail.com' , -pass=>'soyelputoamoyelmejor' , -layer=>'ssl');
$mail->send( -from=>'miguelcabezaspuerto@gmail.com', -to=>'miguelcabezaspuerto@gmail.com' , -subject=>'Consulta web', -body=>$cuerpo );
$mail->bye;

print "<a href='http://$IP/contacto.html'> Volver </a>" ;
