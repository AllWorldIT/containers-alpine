#!/bin/bash
# Copyright (c) 2022-2023, AllWorldIT.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


fdc_test_start crond "Checking crond is running..."
for i in {30..0}; do
	if ! pgrep crond > /dev/null; then
		break
	fi
	fdc_test_progress crond "Waiting for crond to start... ${i}s"
	sleep 1
done
if [ "$i" = 0 ]; then
	fdc_test_fail crond "Did not start!"
	false
fi
fdc_test_fail crond "Crond is running"


fdc_test_start crond "Check for @reboot being run"
for i in {60..0}; do
	if [ -f /PASSED_CROND ]; then
		break
	fi
	fdc_test_progress crond "Waiting for run of @reboot script... ${i}s"
	sleep 1
done
if [ "$i" = 0 ]; then
	fdc_test_fail crond "Did not run @reboot script!"
	false
fi
fdc_test_pass crond "Ran @reboot script"
