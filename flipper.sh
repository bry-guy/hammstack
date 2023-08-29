#!/bin/bash

# set -e

if [ -z "$API_KEY" ]; then
		echo "ERROR: Missing API_KEY env var."
		exit 1
fi

echo "Finding services..."

SERVICE_LIST=$(curl --request GET --url https://api.render.com/v1/services --header "authorization: Bearer $API_KEY" | jq '.[].service | select(.id | startswith("srv"))')

SUSPEND_STR=$(echo "$SERVICE_LIST" | jq '.suspended' | uniq | tr -d '"')

SUSPEND_TYPE_COUNT=$(echo "$SERVICE_STR" | wc -l) 

if [ $SUSPEND_TYPE_COUNT = "1" ]; then
		echo "Found one suspend type."
else
		echo "ERROR: Too many suspend types."
		exit 1
fi

echo "Checking suspend string..."
echo "Suspend String: $SUSPEND_STR"

if [ "$SUSPEND_STR" = "suspended" ]; then
		echo "Resuming..."
		VERB="resume"
else
		echo "Suspending..."
		VERB="suspend"
fi

SERVICE_IDS=$(echo "$SERVICE_LIST" | jq '.id' | tr -d '"')

IFS=$'\n' read -d '' -a lines <<< "$SERVICE_IDS"
for line in "${lines[@]}"; do
		echo "$VERB: $line"
		curl --request POST \
				--url https://api.render.com/v1/services/$line/$VERB \
				--header "accept: application/json" \
				--header "authorization: Bearer $API_KEY"
done 
