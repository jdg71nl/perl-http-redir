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
MYUID=$( id -u )
if [ $MYUID != 0 ]; then
  # https://unix.stackexchange.com/questions/129072/whats-the-difference-between-and
  # $* is a single string, whereas $@ is an actual array.
  echo "# provide your password for 'sudo':" ; sudo "$0" "$@" ; exit 0 ;
fi
# - - - - - - = = = - - - - - - . - - - - - - = = = - - - - - - .
#
. ./settings.env.sh
#
DAEMON_HOME=/opt/$DAEMON_NAME
DAEMON_RUN=$DAEMON_HOME/$DAEMON_NAME.run.sh
DAEMON_INIT="/etc/init.d/$DAEMON_NAME"
#
mkdir -pv $DAEMON_HOME/ 
#
cp -v perl_http_redir.pl $DAEMON_HOME/
cp -v settings.env.sh $DAEMON_HOME/
cp -v my_daemon.run.sh $DAEMON_RUN
#
chown -v -R 0:0 $DAEMON_HOME/
chmod -v -R 700 $DAEMON_HOME/
#
touch $DAEMON_INIT
chown -v 0:0 $DAEMON_INIT
chmod -v 755 $DAEMON_INIT
cat my_daemon.init.sh | sed "s/my_daemon/$DAEMON_NAME/g" > $DAEMON_INIT
update-rc.d $DAEMON_NAME defaults
#
#-eof

