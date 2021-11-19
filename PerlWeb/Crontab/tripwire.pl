#!/usr/bin/perl

use strict;
use warnings;
use CGI qw();
use DBI;
use Email::Valid;
use CGI::Session;
use Email::Send::SMTP::Gmail;
use MIME::Base64;





my $file='/root/tripwire.txt';

 if (-e $file){

my $cuerpo='Su informe Tripwire diario';

my $email='miguelcabezaspuerto@gmail.com';
my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com',-login=>'miguelcabezaspuerto@gmail.com',
                                        -pass=>'soyelputoamoyelmejor',-layer=>'ssl');
 
$mail->send(-from=>'admin@admin.com', -to=>$email, -subject=>'Informe tripwire',
            -body=>$cuerpo, -attachments=>$file);
$mail->bye;
unlink $file;
exit;
}
