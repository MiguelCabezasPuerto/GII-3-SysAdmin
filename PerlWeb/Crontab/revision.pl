#!/usr/bin/perl

use strict;
use warnings;


use DBI;
use Linux::usermod;
#use File::Copy;
use Quota;
use MIME::Base64;

#print "Content-type: text/html\n\n";

#my $cron= new Schedule::Cron(\&dispatcher);

my $base_datos="usuarios"; #Nombre de las base de datos
my $usuario="useradmin"; #Usuario de la BD
my $clave="rootadmin"; #Password de la BD
my $driver="mysql"; #Utilizamos el driver de mysql
my $tabla="definitivos"; #Nombre de la tabla de ejemplo
my $tabla2="verificados";
my $ERROR;



#$cron->add_entry("0-59/1 * * * *",\&verificar_nuevo_usuario);

#$cron->run(detach=>1, pid_file=>"/var/run/scheduler.pid");

#$cron->run();

#1;



#sub verificar_nuevo_usuario{
my $dbh = DBI->connect("dbi:$driver:database=$base_datos",$usuario,$clave) || die "\nError al abrir la base datos: $base_datos::errstr\n";

my $sth= $dbh->prepare("SELECT COUNT(*) from $tabla;");
$sth->execute();

my($count) = $sth->fetchrow_array;

my $pregunta= $dbh->prepare("SELECT COUNT(*) from $tabla2;");
$pregunta->execute();

my($cuantos)=$pregunta->fetchrow_array;

my $nuevos_usuarios=$cuantos -$count;

if(0 == $nuevos_usuarios){ #No se ha verificado ningun usuario mas
print "Es cero: $cuantos - $count = $nuevos_usuarios";
}
elsif(0 < $nuevos_usuarios){ #Se ha verificado algun usuario mas en el ultimo minuto. Hay mas en verificados que en definitivos
print "No es cero:$cuantos - $count = $nuevos_usuarios";
#Meter las filas ultimas metidas en la BD definitivos y a esos usuarios en el sistema
my $consulta= $dbh->prepare("SELECT * FROM $tabla2 ORDER BY id DESC LIMIT $nuevos_usuarios;");
$consulta->execute();
while(my $ref = $consulta->fetchrow_hashref()){
	my $login=$ref->{login};
	print "\n$login\n\n";
	my $passwd=$ref->{password};
	my $decoded = decode_base64($passwd);
	my $encoded = encode_base64($decoded);
	my $nombre=$ref->{nombre};
	my $apellidos=$ref->{nombre};
	my $email=$ref->{email};
	my $postal=$ref->{direccion};
 	my $sth4 = $dbh->prepare("INSERT INTO $tabla(login,password,nombre,apellidos,email,direccion,tipo) values('$login','$encoded','$nombre','$apellidos','$email','$postal','cliente');");
 #Realizamos la etapa de ejecución de la sentencia
 	$sth4->execute();
#Realizamos la etapa de liberación de recursos ocupados por la sentencia
	$sth4->finish();
	my $home="/mnt/home/$login";
	my $publi="/mnt/home/$login/public_html";
	my $navegador="www-data";
	my $groupNavegador="33";
	mkdir $home;
	mkdir $publi;
	my $grupito="1001";
	Linux::usermod->add($login,$decoded,'',$grupito,'',$home,'/bin/bash');
	my $elUsuario=Linux::usermod->new($login);
	my $userID=$elUsuario->get(2);
	my $groupID=$elUsuario->get(3);
	print "$userID\n\n";
	print "$groupID\n\n";
	Quota::setqlim("/dev/loop0",$userID,3072,5120,0,0);
	Quota::sync("/dev/loop0");
	my $mode=0750;
	chmod($mode,$home);
	chmod($mode,$publi);
	chown ($userID,$groupNavegador,$home);
	chown($userID,$groupNavegador,$publi);
	#copy("/etc/skel",$home) or die "Copy failed: $!";
	my $oldfile="/etc/skel/index.html";
	my $newfile="/mnt/home/$login/public_html/index.html";
	my $ayudaOld="/etc/skel/ayuda.html";
	my $ayudaNew="/mnt/home/$login/public_html/ayuda.html";
	my $ayudacssOld="/etc/skel/ayuda.css";
	my $ayudacssNew="/mnt/home/$login/public_html/ayuda.css";
	my $indexCssOld="/etc/skel/index.css";
	my $indexCssNew="/mnt/home/$login/public_html/index.css";
	my $tecnicoOld="/etc/skel/tecnico.html";
	my $tecnicoNew="/mnt/home/$login/public_html/tecnico.html";
	my $tecnicocssOld="/etc/skel/tecnico.css";
	my $tecnicocssNew="/mnt/home/$login/public_html/tecnico.css";
	my $webOld="/etc/skel/web.html";
	my $webNew="/mnt/home/$login/public_html/web.html";
	my $webcssOld="/etc/skel/web.css";
	my $webcssNew="/mnt/home/$login/public_html/web.css";
	system("cp $oldfile $newfile");  
	system("cp $ayudaOld $ayudaNew && cp $ayudacssOld $ayudacssNew && cp $indexCssOld $indexCssNew && cp $tecnicoOld $tecnicoNew && cp $tecnicocssOld $tecnicocssNew && cp $webOld $webNew && cp $webcssOld $webcssNew");
	my $contenido;
	open(my $fd,'<',$newfile);
	{
		local $/;
		$contenido=<$fd>;
	}
	close($fd);
	$contenido=~ s/USUARIO/$login/g;
	unlink $newfile;
	my $prefix="/mnt/home/$login/public_html/index.html";
	open (my $fd2,'>',$prefix );
	my $mode2=0750;
	print $fd2 $contenido;
	close ($fd2 );
	
	chmod($mode2,$prefix);
	chown ($userID ,$groupNavegador,$prefix);
	
	chmod($mode2,$ayudaNew);
	chown($userID,$groupNavegador,$ayudaNew);
	
	chmod($mode2,$ayudacssNew);
	chown($userID,$groupNavegador,$ayudacssNew);
	
	chmod($mode2,$indexCssNew);
	chown($userID,$groupNavegador,$indexCssNew);
	
	chmod($mode2,$tecnicoNew);
	chown($userID,$groupNavegador,$tecnicoNew);
	
	chmod($mode2,$tecnicocssNew);
	chown($mode2,$groupNavegador,$webNew);
	
	chmod($mode2,$webNew);
	chown($userID,$groupNavegador,$webNew);
	
	chmod($mode2,$webcssNew);
	chown($userID,$groupNavegador,$webcssNew);
	
	my $htc="/mnt/home/$login/.htpasswd";
	system("htpasswd -bc $htc $login $decoded");
	my $mode3=0440;
	chmod($mode3,$htc);
	chown($userID,$groupNavegador,$htc);
	my $hta="/mnt/home/$login/public_html/.htaccess";
	open(Usuario2,">>$hta");
	my $cabecera="<Files index.html>";
	my $introduce="Introduce tus Datos:";
	my $linea1="\nAuthName \"$introduce\"\n";
	my $linea2="AuthType Basic\n";
	my $linea3="AuthUserFile /mnt/home/$login/.htpasswd\n";
	my $linea4="Require valid-user\n";
	my $endCabecera="</Files>";
	print Usuario2 $cabecera;
	print Usuario2 $linea1;
	print Usuario2 $linea2;
	print Usuario2 $linea3;
	print Usuario2 $linea4;
	print Usuario2 $endCabecera;
	close (Usuario2);
	chmod($mode3,$hta);
	chown($userID,$groupNavegador,$hta);
	
#	my $pathMail="/var/mail/$login";
#	mkdir $pathMail ;
#	my $modeMail = 0660;
#	my $groupMail="8";
#	chmod($modeMail,$pathMail);
#	chown($userID,$groupMail,$pathMail);			
	my $destination="$login\@migalb.com";
	system("echo Bienvenido | mail 	$destination" );
	if($ERROR){
		print "Error";
		last;
	}	
}
$consulta->finish;
$sth->finish;
$pregunta->finish;
$dbh->disconnect;
exit;
}



