#!/bin/bash

# Set variables
HOSTED_ZONE_ID="Z04320311ASMBEOMPIIN6"  # Replace with your Hosted Zone ID
RECORD_NAME="verblaze.tlvtech.io"  # Replace with your DNS record name
TTL=300                               # Time to live for DNS record
TYPE="CNAME"                              # Record type (A, CNAME, etc.)

# Command to get the desired output (example: getting your public IP address)
./run-gradio.sh
sleep 10
OUTPUT=$(cat /tmp/gradio.log | grep -Eo 'https?://.*(gradio\.live)')

echo Deploying $OUTPUT

# Validate the output
if [[ -z "$OUTPUT" ]]; then
    echo "Error: No output from command"
    exit 1
fi


aws s3api put-bucket-website --bucket verblaze.tlvtech.io --website-configuration "{ \"RedirectAllRequestsTo\": { \"HostName\": \"$OUTPUT\", \"Protocol\": \"https\" } }"

# Check if the update was successful
if [[ $? -eq 0 ]]; then
    echo "DNS record updated successfully with value: $OUTPUT"
else
    echo "Failed to update DNS record"
    exit 1
fi

