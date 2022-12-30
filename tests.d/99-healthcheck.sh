#!/bin/sh

echo "TESTS: Healthcheck running..."
if ! docker-healthcheck; then
	echo "CHECK FAILED (healthcheck): Failed"
	false
fi
