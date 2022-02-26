#!/bin/bash
#NK: We need bash for the redirects below


set -e

if [ -e /.VERSION_INFO ]; then
	echo ">>>> Docker Image Version <<<<"
	cat /.VERSION_INFO
	echo "------------------------------"
fi

if [ "$CI" == "true" ]; then
	# Execute any pre-init-tests scripts
	while read i
	do
		if [ -e "${i}" ]; then
			echo "INFO: pre-init-tests.d - Processing [$i]"
			. "${i}"
		fi
	done < <(find /docker-entrypoint-pre-init-tests.d -type f -name '*.sh' | sort)
fi


# Execute any pre-init scripts
while read i
do
	if [ -e "${i}" ]; then
		echo "INFO: pre-init.d - Processing [$i]"
		. "${i}"
	fi
done < <(find /docker-entrypoint-pre-init.d -type f -name '*.sh' | sort)


# Execute any init scripts
while read i
do
	if [ -e "${i}" ]; then
		echo "INFO: init.d - Processing [$i]"
		. "${i}"
	fi
done < <(find /docker-entrypoint-init.d -type f -name '*.sh' | sort)


# Execute any pre-exec scripts
while read i
do
	if [ -e "${i}" ]; then
		echo "INFO: pre-exec.d - Processing [$i]"
		. "${i}"
	fi
done < <(find /docker-entrypoint-pre-exec.d -type f -name '*.sh' | sort)


if [ "$CI" == "true" ]; then
	echo "INFO: Running in TEST mode"
	/usr/bin/env -i /usr/bin/supervisord --nodaemon --config /etc/supervisor/supervisord.conf &
	SUPERVISORD_PID=$!
	trap "
		echo 'Exit Code: $?';
		echo 'Cleanup: supervisord';
		kill $SUPERVISORD_PID;
	" EXIT
	sleep 5
	# Execute any pre-exec scripts
	echo "INFO: Running tests..."
	while read test
	do
		echo "INFO: Running tests... $test"
		if [ -e "${test}" ]; then
			echo "INFO: tests.d - Processing [$test]"
			set -x
			. "${test}"
			set +x
		fi
	done < <(find /docker-entrypoint-tests.d -type f -name '*.sh' | sort)

	exit 0
fi


if [ $# -gt 0 ]; then
	echo "INFO: Ready for start up with manual command"
	echo "INFO: Logging enabled"
	/usr/bin/env -i /usr/bin/supervisord --config /etc/supervisor/supervisord.conf \
			--logfile /var/log/supervisord.log \
			--logfile_maxbytes=1000000 \
			--logfile_backups=8
	"$@"
else
	echo "INFO: Ready for start up"
	exec /usr/bin/env -i /usr/bin/supervisord --nodaemon --config /etc/supervisor/supervisord.conf
fi

