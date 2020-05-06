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
	/usr/bin/env -i /usr/bin/supervisord --config /etc/supervisor/supervisord.conf &
	SUPERVISORD_PID=$!
	trap "
		echo 'Exit Code: $?';
		echo 'Cleanup: supervisord';
		kill $SUPERVISORD_PID;
	" EXIT
	sleep 5
	# Execute any pre-exec scripts
	echo "INFO: Running tests..."
	while read i
	do
		echo "INFO: Running tests... $i"
		if [ -e "${i}" ]; then
			echo "INFO: tests.d - Processing [$i]"
			. "${i}"
		fi
	done < <(find /docker-entrypoint-tests.d -type f -name '*.sh' | sort)
else
	echo "INFO: Ready for start up"
	exec /usr/bin/env -i /usr/bin/supervisord --config /etc/supervisor/supervisord.conf
fi

