#!/usr/bin/perl

use strict;
use warnings;
use CGI qw();
use DBI;
use CGI::Session;
use MIME::Base64;
use Linux::usermod;
#use Unix::PasswdFile;
use Quota;
use File::Path;

my $base_datos="usuarios"; #Nombre de las base de datos
my $usuario="useradmin"; #Usuario de la BD
my $clave="rootadmin"; #Password de la BD
my $driver="mysql"; #Utilizamos el driver de mysql
my $tabla="modificados";
my $ERROR;

my $dbh = DBI->connect("dbi:$driver:database=$base_datos",$usuario,$clave) || die "\nError al abrir la base datos: $base_datos::errstr\n";

#my $pw  = new Unix::PasswdFile "/etc/passwd";

my $consulta= $dbh->prepare("SELECT * FROM $tabla;");
$consulta->execute();
while(my $ref = $consulta->fetchrow_hashref()){
	my $login=$ref->{login};
	my $pass=$ref->{password};
	my $sth=$dbh->prepare("DELETE FROM $tabla where login='$login';");
	$sth->execute();
	$sth->finish;
	Linux::usermod->del($login);
	my $decoded = decode_base64($pass);
	print "$decoded\n";
	my $home="/mnt/home/$login";
	my $grupito="1001";
	my $groupNavegador="33";
	Linux::usermod->add($login,$decoded,'',$grupito,'',$home,'/bin/bash');
	my $elUsuario=Linux::usermod->new($login);
	my $userID=$elUsuario->get(2);
	my $groupID=$elUsuario->get(3);
	Quota::setqlim("/dev/loop0",$userID,3072,5120,0,0);
	Quota::sync("/dev/loop0");
	my $mode=0750;
	my $pathGeneral= "/mnt/home/$login/*";
	chmod($mode,$home);
	chown ($userID,$groupNavegador, $home);
	chmod($mode,$pathGeneral);
	chown($userID,$groupNavegador, $pathGeneral);
	my $mode2=0440;
	my $hta="/mnt/home/$login/public_html/.htaccess";
	chmod($mode2,$hta);
	chown($userID,$groupNavegador,$hta);
	my $htp="/mnt/home/$login/.htpasswd";
	chmod($mode2,$htp);
	chown($userID,$groupNavegador,$htp);
	my $pathMail="/var/mail/$login";
	rmtree($pathMail) or die "Cannot rmtree '$pathMail: $!";
#	mkdir $pathMail;
#	my $groupMail="8";
#	my $modeMail=0660;
#	chmod($modeMail,$pathMail);
#	chown($userID,$groupMail,$pathMail);
	my $correito="$login\@migalb.com";
	system("echo Cambios realizados, si desea recuperar sus anteriores correos contacte con el webmaster | mail $correito");
	if($ERROR){
		print "Error";
		last;
	}	
}
$consulta->finish;
$dbh->disconnect();
