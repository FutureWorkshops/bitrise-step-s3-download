#!/bin/bash

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e

#=======================================
# Functions
#=======================================

RESTORE='\033[0m'
RED='\033[00;31m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
GREEN='\033[00;32m'

function color_echo {
	color=$1
	msg=$2
	echo -e "${color}${msg}${RESTORE}"
}

function echo_fail {
	msg=$1
	echo
	color_echo "${RED}" "${msg}"
	exit 1
}

function echo_warn {
	msg=$1
	color_echo "${YELLOW}" "${msg}"
}

function echo_info {
	msg=$1
	echo
	color_echo "${BLUE}" "${msg}"
}

function echo_details {
	msg=$1
	echo "  ${msg}"
}

function echo_done {
	msg=$1
	color_echo "${GREEN}" "  ${msg}"
}

function validate_required_input {
	key=$1
	value=$2
	if [ -z "${value}" ] ; then
		echo_fail "[!] Missing required input: ${key}"
	fi
}

function validate_required_input_with_options {
	key=$1
	value=$2
	options=$3

	validate_required_input "${key}" "${value}"

	found="0"
	for option in "${options[@]}" ; do
		if [ "${option}" == "${value}" ] ; then
			found="1"
		fi
	done

	if [ "${found}" == "0" ] ; then
		echo_fail "Invalid input: (${key}) value: (${value}), valid options: ($( IFS=$", "; echo "${options[*]}" ))"
	fi
}

#=======================================
# Main
#=======================================

#
# Validate parameters
echo_info "Configs:"
if [[ -n "$aws_access_key" ]] ; then
	echo_details "* aws_access_key: ***"
else
	echo_details "* aws_access_key: [EMPTY]"
fi
if [[ -n "$aws_secret_access_key" ]] ; then
	echo_details "* aws_secret_access_key: ***"
else
	echo_details "* aws_secret_access_key: [EMPTY]"
fi
echo_details "* s3_bucket: $s3_bucket"
echo_details "* s3_filepath: $s3_filepath"
echo_details "* s3_filepath: $s3_filepath"
echo_details "* output_location: $output_location"
echo

validate_required_input "access_key_id" $aws_access_key
validate_required_input "secret_access_key" $aws_secret_access_key
validate_required_input "upload_bucket" $s3_bucket
validate_required_input "remote_path" $s3_filepath
validate_required_input "output_location" $output_location

# this expansion is required for paths with ~
#  more information: http://stackoverflow.com/questions/3963716/how-to-manually-expand-a-special-variable-ex-tilde-in-bash
eval expanded_local_path="${output_location}"

if [ ! -e "${expanded_local_path}" ]; then
  echo_fail "The specified local path doesn't exist at: ${expanded_local_path}"
  exit 1
fi


# if [[ "$aws_region" != "" ]] ; then
# 	echo_details "AWS region (${aws_region}) specified!"
# 	export AWS_DEFAULT_REGION="${aws_region}"
# fi

S3_PATH="s3://$s3_bucket/$s3_filepath"
export AWS_ACCESS_KEY_ID="${access_key_id}"
export AWS_SECRET_ACCESS_KEY="${secret_access_key}"

AWS_ACCESS_KEY_ID=$aws_access_key
AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"

echo_info "Downloading file from path: $S3_PATH to $output_location"

if command -v brew >/dev/null 2>&1; then
  brew install awscli
else 
  apt-get -y install awscli
fi

aws s3 cp $S3_PATH $output_location

# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
#  envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
