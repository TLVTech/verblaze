#!/bin/bash
cd /home/ubuntu/verblaze || { echo "Failed to change directory"; exit 1; }
source .env

./run-gradio.sh
sleep 30
OUTPUT=$(cat $LOG_FILE | grep -Eo 'https?://.*(gradio\.live)')
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

git add $HTML_FILE
git commit -m "Update redirect to $OUTPUT"
git push https://$GITHUB_TOKEN@github.com/$GITHUB_REPO.git main

