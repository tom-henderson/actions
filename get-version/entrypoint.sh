#!/bin/bash
set -e
set -o pipefail

ARGS="$1"

if [[ -z "$GITHUB_REPOSITORY" ]]; then
	echo "ERROR: GITHUB_REPOSITORY env variable is not set."
	exit 1
fi

function slack_notification() {
	MESSAGE=$1

	PAYLOAD="'text':'${MESSAGE}'"

	if [[ -z "$SLACK_WEBHOOK_URL" ]]; then
		echo "INFO: SLACK_WEBHOOK_URL env variable is not set, notifications will not be sent."
		return
	fi

	if [[ -n "$SLACK_CHANNEL" ]]; then
		PAYLOAD="${PAYLOAD},'channel':'${SLACK_CHANNEL}'"
	fi

	echo "INFO: Sending slack message ${MESSAGE}."
	curl --silent --output /dev/null --show-error --request POST --header 'Content-type: application/json' --data "{${PAYLOAD}}" "${SLACK_WEBHOOK_URL}"
}

echo "INFO: Getting latest tag"
cd "${GITHUB_WORKSPACE}"
echo "Searching for tags matching '${ARGS}-*'"
CURRENT=$(git describe --tags --abbrev=0 --match "${ARGS}-*" 2>/dev/null | sed -e "s/${ARGS}-//" || :)
echo "Found: '${CURRENT}'"

if [[ -z "${CURRENT}" ]]; then
	echo "INFO: No tag matching ${ARGS}, starting from 0.0.1"
	CURRENT="0.0.0"
	NEXT="0.0.1"
else
	echo "INFO: Current version is ${CURRENT}"
	NEXT=$(echo "${CURRENT}" | awk -F . '{print $1"."$2"."$3+1}')
fi

cat <<EOF > "${GITHUB_WORKSPACE}/${ARGS}-version.json"
{
	"current": "${CURRENT}",
	"next": "${NEXT}"
}
EOF

cat "${GITHUB_WORKSPACE}/${ARGS}-version.json"
echo "::set-output name=latest::${CURRENT}"
echo "::set-output name=next::${NEXT}"
