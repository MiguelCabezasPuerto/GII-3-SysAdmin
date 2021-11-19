#!/usr/bin/perl -w

use strict;
use warnings;

my $fichero = "copias_config.txt";
my $configuracion;
my @arrayConf;
my $fecha = localtime();
my $separacion = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++";
my $directorio;
my $puerto;
my $conexion;
my $destino;
my $ipServidor;
my $usuario;
my $ficheroMariaDB = "copiaMariaDB.sql";

open(my $manejador, '<:encoding(UTF-8)', $fichero)
	or die "No se pudo abrir el fichero de configuracion $fichero";

$configuracion = <$manejador>;

close($manejador);

@arrayConf = split("#", $configuracion);

$directorio = $arrayConf[0];
$puerto = $arrayConf[1];
$conexion = $arrayConf[2];
$destino =  $arrayConf[3];
$ipServidor = $arrayConf[4];
$usuario = $arrayConf[5];

if(scalar @arrayConf < 6){
	print "\nRevise el fichero de configuracion copias_config ayudandose de manual_copias\n";
	print "Código de error (1)\n";
	exit 1;
}

if($directorio eq '' || $puerto eq '' || $conexion eq '' || $destino eq '' || $ipServidor eq ''){
	print "\nRevise el fichero de configuracion copias_config ayudandose de manual_copias\n";
	print "Código de error (2)\n";
	exit 1;
}

my $orden = "echo $separacion >> /var/log/copias.log && echo $fecha >> /var/log/copias.log && rsync -e \"$conexion -p $puerto -i ~/.ssh/id_rsa\" -avz $directorio $usuario\@$ipServidor:$destino >> /var/log/copias.log  && rsync -e \"$conexion -p $puerto -i ~/.ssh/id_rsa\" -avz copiaMariaDB.sql $usuario\@$ipServidor:$destino >> /var/log/copias.log";

print "\n\nAnte cualquier error para cambiar la configuracion de las copias edite el fichero copias_config ayudandose de manual_copias\n\n";

system($orden);

unlink($ficheroMariaDB);
