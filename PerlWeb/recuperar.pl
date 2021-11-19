#!/usr/bin/perl

use strict;
use warnings;
use CGI qw();
use DBI;
use MIME::Base64;
use Email::Send::SMTP::Gmail;

print "Content-type: text/html\n\n";

my $peticion=CGI->new;

my $login=$peticion->param('login');

my $base_datos="usuarios"; #Nombre de las base de datos
my $usuario="useradmin"; #Usuario de la BD
my $clave="rootadmin"; #Password de la BD
my $driver="mysql"; #Utilizamos el driver de mysql
my $tabla="definitivos"; #Nombre de la tabla de ejemplo
my $ERROR;
my $IP="172.20.1.73";
my $dbh = DBI->connect("dbi:$driver:database=$base_datos",$usuario,$clave,{'RaiseError'=>1}); 

my $sth=$dbh->prepare("SELECT * from $tabla");
$sth->execute();


while(my $ref = $sth->fetchrow_hashref()){
	if($login eq $ref->{login}){
		my $passwd=$ref->{password};
		my $email=$ref->{email};
		my $decoded=decode_base64($passwd);
		my ($remitente, $destinatario, $asunto, $mensaje) = @_;
    		#open(MAIL, "|/usr/lib/sendmail -oi -t");
    		#print MAIL "From: admin\n";
    		#print MAIL "To: $email\n";
    		#print MAIL "Subject: Codigo de verificacion\n\n";
    		#print MAIL "$decoded\n";
    		#close(MAIL);
		my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com',-login=>'miguelcabezaspuerto@gmail.com',
                                        -pass=>'soyelputoamoyelmejor',-layer=>'ssl');
 
		$mail->send(-from=>'admin@admin.com', -to=>$email, -subject=>'Recuperacion password',
            -body=>$decoded);
		$mail->bye;
		
		$sth->finish;
		$dbh->disconnect;
		print "<h3 style='color:blue'>Enviado correo de recuperacion al email indicado en el registro</h3>";
		print "<a href='http://$IP/login.html'>Login</a>";
		exit;
	}
	if($ERROR){
		last;
		print "<h3 style='color:red'>Error de conexion</h3>";
		print "<a href='http://$IP/recuperar.html'>Intentar de nuevo</a>";
		exit;
	}
}

$sth->finish;
$dbh->disconnect;
print "<h3 style='color:red'>Login incorrecto</h3>";
print "<a href='http://$IP/recuperar.html'>Intentar de nuevo</a>";
exit;

