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


function fdc_color() {
	local color=${1:-grey}
	case "$color" in
		red)
			color=31
			;;
		green)
			color=32
			;;
		yellow)
			color=33
			;;
		blue)
			color=34
			;;
		grey | reset)
			color=0
			;;
		*)
			echo "INTERNAL ERROR: Invalid color '$color'" >&2
			;;
	esac
	printf "\033[1;%sm" "$color"
}


#
# Helper functions
#

function fdc_error() {
	local color
	color=$(fdc_color red)
	reset=$(fdc_color reset)
	echo "$color>>> ERROR  > $1$reset" >&2
}

function fdc_warn() {
	local color
	color=$(fdc_color yellow)
	reset=$(fdc_color reset)
	echo "$color>>> WARNING > $1$reset" >&2
}

function fdc_notice() {
	local color
	color=$(fdc_color blue)
	reset=$(fdc_color reset)
	echo "$color>>> NOTICE  > $1$reset" >&2
}

function fdc_info() {
	local color
	color=$(fdc_color grey)
	reset=$(fdc_color reset)
	echo "$color>>> INFO    > $1$reset" >&2
}


function fdc_test_start() {
	local color
	color=$(fdc_color blue)
	reset=$(fdc_color reset)
	echo "$color### TEST START    ($reset$1$color): $2$reset"
}

function fdc_test_progress() {
	local color
	color=$(fdc_color blue)
	reset=$(fdc_color reset)
	echo "$color### TEST PROGRESS ($reset$1$color): $2$reset"
}

function fdc_test_pass() {
	local color
	color=$(fdc_color green)
	reset=$(fdc_color reset)
	echo "$color### TEST PASSED   ($reset$1$color): $2$reset"
}

function fdc_test_info() {
	local color
	color=$(fdc_color blue)
	reset=$(fdc_color reset)
	echo "$color### TEST INFO     ($reset$1$color): $2$reset"
}

function fdc_test_fail() {
	local color
	color=$(fdc_color red)
	reset=$(fdc_color reset)
	echo "$color### TEST FAILED   ($reset$1$color): $2$reset"
}
