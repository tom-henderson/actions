#!/bin/bash
set -e
set -o pipefail

if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
	echo "ERROR: AWS_ACCESS_KEY_ID env variable is not set."
	exit 1
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
	echo "ERROR: AWS_SECRET_ACCESS_KEY env variable is not set."
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

echo "INFO: Running serverless deploy in ${GITHUB_WORKSPACE}/${SERVERLESS_WORKDIR}"
cd "${GITHUB_WORKSPACE}"/"${SERVERLESS_WORKDIR}"

if [[ -e "package.json" ]]; then
	echo "Installing npm dependencies"
	npm install
fi

SERVICE=$(serverless print --format json | jq -r '.service')

slack_notification "Deploying serverless service \`${SERVICE}\`"
serverless deploy
slack_notification "Serverless deploy of \`${SERVICE}\` was successful :tada:"
