#!/usr/bin/perl

use strict;
use warnings;
use Email::Send::SMTP::Gmail;

my $encoding = ":encoding(UTF-8)";
my $log = "/var/log/mysql/mysql.log";
my $handle1;
my $handle2;
my $conexion = "Connect";
my $accesos = "Accesos";
my $separacion = "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
my $accesosSQL = "accessSQL.txt";
my $linea;
my $info = "Acceso a la base de datos";
my $email = "halbertoh3\@gmail.com";

open($handle1, "<$encoding", $log);
while($linea = <$handle1>){
	chomp($linea);
	if($linea =~ m/$conexion/){
		$accesos = $accesos . $separacion . $linea;
	}
}
close($handle1);

if($accesos ne "Accesos"){
	open($handle2, ">>$encoding", $accesosSQL);
	print $handle2 $accesos;
	close($handle2);

	my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com',-login=>'miguelcabezaspuerto@gmail.com',
                                        -pass=>'soyelputoamoyelmejor',-layer=>'ssl');
 
	$mail->send(-from=>'miguelcabezaspuerto@gmail.com', -to=>$email, -subject=>'Accesos a MariadDB',
            -body=>$info, -attachments=>$accesosSQL);

	$mail->bye;

	open($handle1, ">$encoding", $log);
	print $handle1 "";
	close($handle1);

	unlink $accesosSQL;
}