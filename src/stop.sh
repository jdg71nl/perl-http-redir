#!/bin/bash
#
echo "# running: stop.sh ... "
#
PID_FILENAME="/var/run/lock/perl-http-redir.pid"
#
if ! [ -f $PID_FILENAME ]; then
  echo "# file does not exist: $PID_FILENAME "
  exit 1
else
  echo "# contents of file $PID_FILENAME = " `cat $PID_FILENAME`
fi
#
echo "# cmd> sudo pkill -F $PID_FILENAME "
sudo pkill -F $PID_FILENAME
#
echo "# cmd> sudo rm $PID_FILENAME "
sudo rm $PID_FILENAME
#
#-eof
