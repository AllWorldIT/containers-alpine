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


function fdc_color() {
	local color=${1:-reset}
	local bgcolor=$2

	case "$color" in
		black)
			color=30
			;;
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
		purple)
			color=35
			;;
		cyan)
			color=36
			;;
		white)
			color=37
			;;
		reset)
			color=0
			;;
		*)
			echo "INTERNAL ERROR: Invalid color '$color'" >&2
			;;
	esac

	if [ -n "$bgcolor" ]; then
		case "$bgcolor" in
			black)
				bgcolor=40
				;;
			red)
				bgcolor=41
				;;
			green)
				bgcolor=42
				;;
			yellow)
				bgcolor=43
				;;
			blue)
				bgcolor=44
				;;
			purple)
				bgcolor=45
				;;
			cyan)
				bgcolor=46
				;;
			white)
				bgcolor=47
				;;
			reset)
				bgcolor=0
				;;
			*)
				echo "INTERNAL ERROR: Invalid bgcolor '$bgcolor'" >&2
				;;
		esac
		bgcolor=";$bgcolor"
	fi
	printf "\033[1;%s%sm" "$color" "$bgcolor"
}


#
# Helper functions
#

function fdc_error() {
	local color reset
	color=$(fdc_color red)
	reset=$(fdc_color reset)
	echo -e "$color>>> ERROR  > $1$reset" >&2
}

function fdc_warn() {
	local color reset
	color=$(fdc_color yellow)
	reset=$(fdc_color reset)
	echo -e "$color>>> WARNING > $1$reset" >&2
}

function fdc_notice() {
	local color reset
	color=$(fdc_color blue)
	reset=$(fdc_color reset)
	echo -e "$color>>> NOTICE  > $1$reset" >&2
}

function fdc_info() {
	local color reset
	color=$(fdc_color white)
	reset=$(fdc_color reset)
	echo -e "$color>>> INFO    > $1$reset" >&2
}


function fdc_test_start() {
	local color color2 reset
	color=$(fdc_color blue)
	color2=$(fdc_color purple)
	reset=$(fdc_color reset)
	echo -e "$color### TEST START    ($color2$1$color): $2$reset" >&2
}

function fdc_test_progress() {
	local color color2 reset
	color=$(fdc_color blue)
	color2=$(fdc_color purple)
	reset=$(fdc_color reset)
	echo -e "$color### TEST PROGRESS ($color2$1$color): $2$reset" >&2
}

function fdc_test_pass() {
	local color color2 reset
	color=$(fdc_color green)
	color2=$(fdc_color purple)
	reset=$(fdc_color reset)
	echo -e "$color### TEST PASSED   ($color2$1$color): $2$reset" >&2
}

function fdc_test_info() {
	local color color2 reset
	color=$(fdc_color blue)
	color2=$(fdc_color purple)
	reset=$(fdc_color reset)
	echo -e "$color### TEST INFO     ($color2$1$color): $2$reset" >&2
}

function fdc_test_fail() {
	local color color2 reset
	color=$(fdc_color red)
	color2=$(fdc_color purple)
	reset=$(fdc_color reset)
	echo -e "$color### TEST FAILED   ($color2$1$color): $2$reset" >&2
}
