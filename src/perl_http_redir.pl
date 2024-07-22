#!/usr/bin/perl

# - - - - - - = = = - - - - - - . 
### GOAL: to respond with the same HTTP-Redirect (Location:) as 
#         this Apache2-config (without actually requiring apache2 installed):
#
# > a2enmod rewrite
# RewriteEngine on
# RewriteRule ^/?$ http://%{HTTP_HOST}:1080/web/display [L,R,NE]
#
# so: we want to 'read' the hostname from the HTTP-Request header (Host:), 
#     and then write the HTTP-Response 'Location:' 
#     using :PORT/REDIR_URI like: ':1080/web/display'
#
# http://HOST:LISTEN_PORT/  ==[redir]==>  http://HOST:REDIR_PORT/REDIR_URI
#
# - - - - - - = = = - - - - - - . 

use strict;
use warnings;
# use Data::Dumper;

# https://perldoc.perl.org/Getopt::Long
# use Getopt::Long;
#
# https://metacpan.org/pod/Getopt::ArgParse
# > sudo apt install libgetopt-argparse-perl
use Getopt::ArgParse;

my $gap = Getopt::ArgParse->new_parser(
  prog        => 'perl-http-redir',
  description => 'A Perl-based simple HTTP Redirect daemon.',
);
 
# Parse an option: '--foo value' or '-f value'
$gap->add_arg('--rport', required => 1);
$gap->add_arg('--ruri', required => 1);
$gap->add_arg('--lport', required => 1);

# do the parsing-magic (using @ARGV):
my $gap_ns = $gap->parse_args();

my $def_REDIR_PORT = "1234";
my $def_REDIR_URI = "/some";
my $def_LISTEN_PORT = "8012";

my $REDIR_PORT = $def_REDIR_PORT;
my $REDIR_URI = $def_REDIR_URI;
my $LISTEN_PORT = $def_LISTEN_PORT;

my $PROG_NAME = "perl-http-redir";
# my $PID_FILENAME = "/var/run/$PROG_NAME.pid";
# my $PID_FILENAME = "/var/run/user/$PROG_NAME.pid";
my $PID_FILENAME = "/var/run/lock/$PROG_NAME.pid";

$REDIR_PORT = $gap_ns->rport || $def_REDIR_PORT;
$REDIR_URI = $gap_ns->ruri || $def_REDIR_URI;
$LISTEN_PORT = $gap_ns->lport || $def_LISTEN_PORT;
#
print STDERR "[stderr] REDIR_PORT = $REDIR_PORT\n";
print STDERR "[stderr] REDIR_URI = $REDIR_URI\n";
print STDERR "[stderr] LISTEN_PORT = $LISTEN_PORT\n";

{
package PerlWebServer;
  
# https://metacpan.org/pod/HTTP::Server::Simple
# https://metacpan.org/dist/CGI/view/lib/CGI.pod
# > sudo apt install libhttp-server-simple-perl
use HTTP::Server::Simple::CGI;
use base qw(HTTP::Server::Simple::CGI);
  
sub handle_request {
  my $self = shift;
  my $cgi  = shift;

  #
  my $virtual_host = $cgi->virtual_host();
  my $redir_url = "http://$virtual_host:$REDIR_PORT$REDIR_URI";

  # print "HTTP/1.0 200 OK\r\n";
  # print $cgi->header,
  #       # $cgi->header("Location: $redir_url"),
  #       $cgi->start_html("Redirecting"),
  #       $cgi->h3("Redirecting to $redir_url"),
  #       $cgi->end_html;

  print $cgi->redirect(
      -uri    => $redir_url,
      -nph    => 1,
      -status => '301 Moved Permanently'
  );

  #

}  
  
} 
  
# start the server on port 
my $pid = PerlWebServer->new($LISTEN_PORT + 0)->background();

# open(FH, '>', $PID_FILENAME) or die $!;
# print FH "$pid\n";
# close(FH);
# #
# print "# wrote PID ($pid) to file: $PID_FILENAME \n";
# print "# test using: \n";
# print "# > curl -v -s -o - http://127.0.0.1:$LISTEN_PORT/ \n";
# print "# kill using: \n";
# print "# > kill $pid \n";
# print "# > pkill -F $PID_FILENAME \n";


# print STDOUT "$pid\n";
# print STDERR "[stderr] Use 'kill $pid' to stop server.\n";

#-eof
