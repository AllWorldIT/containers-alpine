#!/bin/sh

echo "TESTS: Cron running..."
if ! pgrep cron; then
	echo "CHECK FAILED (cron): Not running"
	false
fi

