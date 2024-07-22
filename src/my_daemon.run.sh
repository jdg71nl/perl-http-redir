#!/bin/bash
#
# - - - - - - = = = - - - - - - . - - - - - - = = = - - - - - - .
# display every line executed in this bash script:
#set -o xtrace
#
BASENAME=`basename $0`
echo "# running: $BASENAME ... "
SCRIPT=`realpath -s $0`  # man says: "-s, --strip, --no-symlinks : don't expand symlinks"
SCRIPT_PATH=`dirname $SCRIPT`
cd $SCRIPT_PATH
#
#f_echo_exit1() { echo $1 ; exit 1 ; }
#if [ ! -e /etc/debian_version ]; then f_echo_exit1 "# Error: found non-Debain OS .." ; fi
#if ! which sudo >/dev/null ; then f_echo_exit1 "# please install first (as root) ==> apt install sudo " ; fi
#if ! which dpkg-query >/dev/null ; then f_echo_exit1 "# please install first: using ==> sudo apt install dpkg-query " ; fi
#
#usage() {
#  #echo "# usage: $BASENAME { -req_flag | [ -opt_flag string ] } " 1>&2 
#  echo "# usage: $BASENAME " 1>&2 
#  exit 1
#}
#
#MYUID=$( id -u )
#if [ $MYUID != 0 ]; then
#  # https://unix.stackexchange.com/questions/129072/whats-the-difference-between-and
#  # $* is a single string, whereas $@ is an actual array.
#  echo "# provide your password for 'sudo':" ; sudo "$0" "$@" ; exit 0 ;
#fi
# - - - - - - = = = - - - - - - . - - - - - - = = = - - - - - - .
#
. ./settings.env.sh
#
# PID_FILENAME="/var/run/lock/$DAEMON_NAME.pid"
# #
# if [ -f $PID_FILENAME ]; then
#   echo "# PROG already started -- file exist: $PID_FILENAME "
#   exit 1
# fi
#
# if [ $LISTEN_PORT -ge 1024 ]; then
#   echo "# found \$LISTEN_PORT > 1024 so no need for 'sudo' ..."
#   echo "# cmd> ./perl-http-redir.pl --rport $REDIR_PORT --ruri $REDIR_URI --lport $LISTEN_PORT "
#   ./perl-http-redir.pl --rport $REDIR_PORT --ruri $REDIR_URI --lport $LISTEN_PORT
# else
#   echo "# found \$LISTEN_PORT < 1024 so using 'sudo' ..."
#   echo "# cmd> sudo ./perl-http-redir.pl --rport $REDIR_PORT --ruri $REDIR_URI --lport $LISTEN_PORT "
#   sudo ./perl-http-redir.pl --rport $REDIR_PORT --ruri $REDIR_URI --lport $LISTEN_PORT
# fi
#
./perl_http_redir.pl --rport $REDIR_PORT --ruri $REDIR_URI --lport $LISTEN_PORT
#
#-eof

