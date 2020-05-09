#!/bin/bash

echo "TESTS: Postfix connectivity..."
OUT_V4_25=$(socat -T2 - "TCP:127.0.0.1:25,end-close" < /dev/null)
if ! grep 'ESMTP' <<< "$OUT_V4_25"; then
	echo "CHECK FAILED (postfix): Check IPv4 port 25 works"
	false
fi

