#!/bin/bash
add_dir=`pwd`
bind_address="0.0.0.0"
bind_port=11111
pid_file="$app_dir/tmp/pids/passenger.pid"
user="nobody"
env="production"
passenger_exe="/usr/bin/env passenger"
opts=" --user $user --address $bind_address --port $bind_port  -e $env --pid-file $pid_file --max-pool-size 15 -d"


case $1 in
	init)
		if [ -e $socket ] 
		then
			rm -f $socket
		fi
		$0 stop
		$0 start
		;;

	stop)
		$passenger_exe $1 --pid-file $pid_file
		;;

	start)
		$passenger_exe $1 $opts
		;;

	restart)
		$0 stop && $0 start
		;;


	reload)
		touch $app_dir/tmp/restart.txt
		;;

	status)
		$passenger_exe $1 --pid-file $pid_file
		;;

	*)
		echo "$0 [stop|start|status|reload]"
		;;
esac

