#!/bin/bash

### BEGIN INIT INFO
# Provides:          my_daemon
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: TokenMe Microntroller Manager (python-deamon)
# Description:       TokenMe Microntroller Manager (python-deamon)
### END INIT INFO

# this script example from:
# http://blog.scphillips.com/posts/2013/07/getting-a-python-script-to-run-in-the-background-as-a-service-on-boot/

# INSTALL:
# sudo cp -av /path_to/my_daemon.init.sh /etc/init.d/
# sudo update-rc.d my_daemon defaults
# USAGE:
# sudo /etc/init.d/my_daemon start
# sudo /etc/init.d/my_daemon stop

ID=`/usr/bin/id -u`
[[ $ID -ne 0 ]] && echo "Run this command as root" && exit 1

DAEMON_NAME="my_daemon"
#
# Change the next 3 lines to suit where you install your script and what you want to call it
HOME=/opt/$DAEMON_NAME
#
DAEMON=$HOME/$DAEMON_NAME.run.sh
#
# Add any command line options for your daemon here
# DAEMON_OPTS="--daemon"
DAEMON_OPTS=""

# This next line determines what user the script runs as.
# Root generally not recommended but necessary if you are using the Raspberry Pi GPIO from Python.
DAEMON_USER=root

# The process ID of the script when it runs is stored here:
PIDFILE=/var/run/$DAEMON_NAME.pid

. /lib/lsb/init-functions

do_start () {
    log_daemon_msg "Starting system $DAEMON_NAME daemon"
    /sbin/start-stop-daemon --start --background --pidfile $PIDFILE --make-pidfile --user $DAEMON_USER --chuid $DAEMON_USER --startas $DAEMON -- $DAEMON_OPTS
    log_end_msg $?
}
do_stop () {
    log_daemon_msg "Stopping system $DAEMON_NAME daemon"
    /sbin/start-stop-daemon --stop --pidfile $PIDFILE --retry 10
    log_end_msg $?
}

case "$1" in

    start|stop)
        do_${1}
        ;;

    restart|reload|force-reload)
        do_stop
        do_start
        ;;

    status)
        status_of_proc "$DAEMON_NAME" "$DAEMON" && exit 0 || exit $?
        ;;

    *)
        echo "Usage: /etc/init.d/$DAEMON_NAME {start|stop|restart|status}"
        exit 1
        ;;

esac
exit 0

