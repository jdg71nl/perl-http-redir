#!/bin/bash
#
echo "# running: start.sh ... "
#
PID_FILENAME="/var/run/lock/perl-http-redir.pid"
#
if [ -f $PID_FILENAME ]; then
  echo "# PROG already started -- file exist: $PID_FILENAME "
  exit 1
fi
#
. ./settings.env.sh
#
if [ $LISTEN_PORT -ge 1024 ]; then
  echo "# found \$LISTEN_PORT > 1024 so no need for 'sudo' ..."
  echo "# cmd> ./perl-http-redir.pl --rport $REDIR_PORT --ruri $REDIR_URI --lport $LISTEN_PORT "
  ./perl-http-redir.pl --rport $REDIR_PORT --ruri $REDIR_URI --lport $LISTEN_PORT
else
  echo "# found \$LISTEN_PORT < 1024 so using 'sudo' ..."
  echo "# cmd> sudo ./perl-http-redir.pl --rport $REDIR_PORT --ruri $REDIR_URI --lport $LISTEN_PORT "
  sudo ./perl-http-redir.pl --rport $REDIR_PORT --ruri $REDIR_URI --lport $LISTEN_PORT
fi

#
#-eof
