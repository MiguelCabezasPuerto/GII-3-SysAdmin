#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Email::Send::SMTP::Gmail;

my $base_datos="usuarios";
my $usuario="useradmin";
my $clave="rootadmin";
my $driver="mysql";
my $tabla="definitivos";

my $dbh=DBI->connect("dbi:$driver:database=$base_datos",$usuario,$clave,{'RaiseError'=>1});

my $sth=$dbh->prepare("SELECT * from $tabla");
$sth->execute();

my $fichero="quotas.txt";

while(my $ref = $sth->fetchrow_hashref()){
	my $login= $ref->{login};
	my $email= $ref->{email};
	system("quota $login | awk 'NR == 3 {print \$2}' > quotas.txt");
	system("quota $login | awk 'NR == 3 {print \$4}' >> quotas.txt ");
	open FICHERO,$fichero or die "No existe ".$fichero;
	my $i=0;
	my $usado;
	my $limite;
	my $linea;
	while($linea=<FICHERO>){
		chomp($linea);
		if($i==0){
			$usado=$linea;
		}	
		else{
			$limite=$linea;
		}
		$i=$i+1;
	}
	my $diferencia=$limite - $usado;
	my $porcentaje= $diferencia * 100;
	$porcentaje= $porcentaje / $limite;
	$diferencia=$diferencia/1000;
	#print "Espacio: $diferencia MB\n";
	my $aproximado=sprintf("%.2f",$porcentaje);
	#print "$aproximado % restante\n";
	my $mail= Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com' , -login=>'miguelcabezaspuerto@gmail.com' , -pass=>'soyelputoamoyelmejor' , -layer=>'ssl' );
	my $cuerpo="Saludos $login\n Su espacio disponible es $diferencia MB ( $aproximado % del total )\n";
	$mail->send(-from =>'miguelcabezaspuerto@gmail.com', -to=>$email , -subject=>'Informe espacio disponible', -body=>$cuerpo);
	$mail->bye;
}
close(FICHERO);
unlink($fichero);
$sth->finish;
$dbh->disconnect;
