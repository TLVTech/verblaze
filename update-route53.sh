#!/bin/bash

# Set variables
HOSTED_ZONE_ID="Z04320311ASMBEOMPIIN6"  # Replace with your Hosted Zone ID
RECORD_NAME="verblaze.tlvtech.io"  # Replace with your DNS record name
TTL=300                               # Time to live for DNS record
TYPE="CNAME"                              # Record type (A, CNAME, etc.)

# Command to get the desired output (example: getting your public IP address)
OUTPUT=$(./run-gradio.sh | grep -Eo 'https?://.*(gradio\.live)')

# Validate the output
if [[ -z "$OUTPUT" ]]; then
    echo "Error: No output from command"
    exit 1
fi

# Create JSON payload for updating the DNS record
cat << EOF > /tmp/route53-record-update.json
{
  "Comment": "Auto update DNS record via script",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$RECORD_NAME",
        "Type": "$TYPE",
        "TTL": $TTL,
        "ResourceRecords": [
          {
            "Value": "$OUTPUT"
          }
        ]
      }
    }
  ]
}
EOF

# Update the Route 53 record
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file:///tmp/route53-record-update.json

# Check if the update was successful
if [[ $? -eq 0 ]]; then
    echo "DNS record updated successfully with value: $OUTPUT"
else
    echo "Failed to update DNS record"
    exit 1
fi

# Clean up the temporary file
rm /tmp/route53-record-update.json

