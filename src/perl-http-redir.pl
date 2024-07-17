#!/usr/bin/perl

### GOAL: to respond with the same HTTP-Redirect (Location:) as this Apache2-config (without actually requiring apache2 installed):
# > a2enmod rewrite
# RewriteEngine on
# RewriteRule ^/?$ http://%{HTTP_HOST}:1080/web/display [L,R,NE]
#
# so: we want to 'read' the hostname from the HTTP-Request header (Host:), and then write the HTTP-Response 'Location:' using :PORT/REDIR_URI like: ':1080/web/display'
my $REDIR_PORT = "1080";
my $REDIR_URI = "/web/display";
#
my $LISTEN_PORT = 8080;
#
my $JSON_FILENAME = "./config.json";
my $PID_FILENAME = "/var/run/perl-http-redir.pid";

# https://metacpan.org/pod/HTTP::Server::Simple

# https://metacpan.org/dist/CGI/view/lib/CGI.pod

# http://linux-srv.i.j71.nl:8080/
# <!DOCTYPE html
# 	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
# 	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
# <html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
# <head>
# <title>Not found</title>
# <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
# </head>
# <body>
# <h1>Not found</h1>
# </body>
# </html>

# http://linux-srv.i.j71.nl:8080/hello
# <!DOCTYPE html
# 	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
# 	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
# <html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
# <head>
# <title>Hello</title>
# <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
# </head>
# <body>
# <h1>Hello !</h1>
# </body>
# </html>

# http://linux-srv.i.j71.nl:8080/hello?name=some

# > curl-show-headers.sh http://linux-srv.i.j71.nl:8080/
# # cmd> curl -v -s -o - http://linux-srv.i.j71.nl:8080/
# * Host linux-srv.i.j71.nl:8080 was resolved.
# * IPv6: (none)
# * IPv4: 10.231.21.121
# *   Trying 10.231.21.121:8080...
# * Connected to linux-srv.i.j71.nl (10.231.21.121) port 8080
# > GET / HTTP/1.1
# > Host: linux-srv.i.j71.nl:8080
# > User-Agent: curl/8.6.0
# > Accept: */*
# > 
# * HTTP 1.0, assume close after body
# < HTTP/1.0 404 Not found
# < Content-Type: text/html; charset=ISO-8859-1
# < 
# <!DOCTYPE html

# https://metacpan.org/dist/JSON-Parse/view/lib/JSON/Parse.pod
# > sudo apt install libjson-parse-perl
# Error: "read_json" is not exported by the JSON::Parse module
# use JSON::Parse 'read_json';
# my $config = read_json ($JSON_FILENAME);
#
# https://stackoverflow.com/questions/64011827/how-can-i-reference-a-local-json-file-in-perl-on-a-linux-box
# > sudo apt install libjson-perl
use strict;
use warnings;
# use Data::Dumper;
use JSON;
my $file_contents = do {
    local $/;
    open my $fh, "<", $JSON_FILENAME or die $!;
    <$fh>;
};
my $config = decode_json($file_contents);
#
$REDIR_PORT = $config->{"REDIR_PORT"} || "1080";
$REDIR_URI = $config->{"REDIR_URI"} || "/web/display";
$LISTEN_PORT = $config->{"LISTEN_PORT"} || 8080;
print STDERR "[stderr] REDIR_PORT = $REDIR_PORT\n";
print STDERR "[stderr] REDIR_URI = $REDIR_URI\n";
print STDERR "[stderr] LISTEN_PORT = $LISTEN_PORT\n";

{
package PerlWebServer;
  
# > sudo apt install libhttp-server-simple-perl
use HTTP::Server::Simple::CGI;
use base qw(HTTP::Server::Simple::CGI);

my %dispatch = (
    '/hello' => \&resp_hello,
    # ...
);
  
sub handle_request {
  my $self = shift;
  my $cgi  = shift;

  my $redir_only = 1; # <== NOTE: the 'other' ($redir_only=0) code is for regular HTTP response testing.
  #
  if ($redir_only) {
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
  } else {
    #

    my $path = $cgi->path_info();
    my $handler = $dispatch{$path};

    # jdg
    # my $remote_host = $cgi->remote_host();
    # my $virtual_host = $cgi->virtual_host();

    if (ref($handler) eq "CODE") {
        print "HTTP/1.0 200 OK\r\n";
        $handler->($cgi);
          
    } else {
        print "HTTP/1.0 404 Not found\r\n";
        print $cgi->header,
              $cgi->start_html('Not found'),
              $cgi->h1('Not found'),
              $cgi->end_html;
    }
  }
}
  
sub resp_hello {
    my $cgi  = shift;   # CGI.pm object
    return if !ref $cgi;

    my $virtual_host = $cgi->virtual_host();

    my $who = $cgi->param('name');
      
    print $cgi->header,
          $cgi->start_html("Hello"),
          # $cgi->h1("Hello $who!"),
          $cgi->h1("Hello $virtual_host !"),
          $cgi->end_html;
}
  
} 
  
# start the server on port 
my $pid = PerlWebServer->new($LISTEN_PORT)->background();
#
# print STDOUT "$pid\n";
print STDERR "[stderr] Use 'kill $pid' to stop server.\n";

#-eof
