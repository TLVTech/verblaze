#!/bin/bash

# Set variables
BUCKET_NAME="verblaze.tlvtech.io"
CLOUDFRONT_DISTRIBUTION_ID="E3LNQZFD1JJLAI"
HTML_FILE="index.html"

./run-gradio.sh
sleep 10
OUTPUT=$(cat /tmp/script_output.log | grep -Eo 'https?://.*(gradio\.live)')
echo Deploying $OUTPUT
cat <<EOF > $HTML_FILE
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Redirecting...</title>
    <script type="text/javascript">
        // Redirect to the target URL
        window.location.href = "$OUTPUT";
    </script>
</head>
<body>
    <p>If you are not redirected automatically, <a href="$OUTPUT">click here</a>.</p>
</body>
</html>
EOF
if [[ -f "$HTML_FILE" ]]; then
    echo "HTML redirect file created successfully."
else
    echo "Failed to create HTML file."
    exit 1
fi

aws s3 cp "$HTML_FILE" "s3://$BUCKET_NAME/index.html"

# Check if the upload was successful
if [[ $? -eq 0 ]]; then
    echo "HTML file uploaded successfully to S3."
else
    echo "Failed to upload HTML file to S3."
    exit 1
fi
INVALIDATION_ID=$(aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" --paths "/index.html" --query 'Invalidation.Id' --output text)
if [[ $? -eq 0 ]]; then
    echo "Cache invalidation initiated successfully. Invalidation ID: $INVALIDATION_ID"
else
    echo "Failed to initiate cache invalidation."
    exit 1
fi

git add $HTML_FILE
git commit -m "Update redirect to $OUTPUT"
git push origin main