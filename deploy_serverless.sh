#!/bin/bash

# Load environment variables from .env file
set -o allexport
source .env
set +o allexport

# Variables
ZIP_FILE="lambda_functions.zip"
PACKAGE_DIR="package"
START_RULE_NAME="StartEC2ScheduleRule"
STOP_RULE_NAME="StopEC2ScheduleRule"

# Step 1: Create IAM Role if it doesn't exist
ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query "Role.Arn" --output text --region $REGION 2>/dev/null)

if [ -z "$ROLE_ARN" ]; then
    echo "Creating IAM role for Lambda..."
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document file://trust-policy.json \
        --region $REGION
    ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query "Role.Arn" --output text --region $REGION)

    # Attach basic Lambda execution policy
    aws iam attach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
        --region $REGION
fi

# Step 2: Install dependencies and package the Lambda
echo "Installing dependencies and packaging Lambda functions..."
mkdir -p $PACKAGE_DIR
pip install -r requirements.txt --target ./$PACKAGE_DIR
cp lambdas/lambda_functions.py $PACKAGE_DIR/

# Create the ZIP file
cd $PACKAGE_DIR
zip -r ../$ZIP_FILE .
cd ..

# Step 3: Deploy or update Lambda functions
for FUNCTION_NAME in "$START_FUNCTION_NAME" "$STOP_FUNCTION_NAME"; do
    HANDLER_NAME="start_ec2"  # Default to start function handler
    if [ "$FUNCTION_NAME" == "$STOP_FUNCTION_NAME" ]; then
        HANDLER_NAME="stop_ec2"
    fi

    # Check if function already exists
    FUNCTION_EXISTS=$(aws lambda get-function --function-name $FUNCTION_NAME --region $REGION 2>/dev/null)

    if [ -z "$FUNCTION_EXISTS" ]; then
        echo "Creating Lambda function: $FUNCTION_NAME"
        aws lambda create-function \
            --function-name $FUNCTION_NAME \
            --zip-file fileb://$ZIP_FILE \
            --handler lambda_functions.$HANDLER_NAME \
            --runtime python3.9 \
            --role $ROLE_ARN \
            --region $REGION \
            --timeout 30
    else
        echo "Updating existing Lambda function: $FUNCTION_NAME"
        aws lambda update-function-code \
            --function-name $FUNCTION_NAME \
            --zip-file fileb://$ZIP_FILE \
            --region $REGION
    fi
done

# Step 4: Add CloudWatch event rules for scheduling Lambda triggers
echo "Setting up CloudWatch event rules for scheduled Lambda triggers..."

# Create start EC2 CloudWatch rule (runs at 8 AM UTC)
aws events put-rule \
    --name $START_RULE_NAME \
    --schedule-expression "cron(0 8 * * ? *)" \
    --region $REGION

# Create stop EC2 CloudWatch rule (runs at 5 PM UTC)
aws events put-rule \
    --name $STOP_RULE_NAME \
    --schedule-expression "cron(0 17 * * ? *)" \
    --region $REGION

# Add permissions for CloudWatch to invoke each Lambda function
for FUNCTION_NAME in "$START_FUNCTION_NAME" "$STOP_FUNCTION_NAME"; do
    aws lambda add-permission \
        --function-name $FUNCTION_NAME \
        --statement-id "AllowCloudWatchToInvoke" \
        --action "lambda:InvokeFunction" \
        --principal events.amazonaws.com \
        --source-arn "arn:aws:events:$REGION:$ACCOUNT_ID:rule/$START_RULE_NAME" \
        --region $REGION
done

# Link start and stop rules to their respective Lambda functions
aws events put-targets --rule $START_RULE_NAME --targets "Id"="1","Arn"="arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$START_FUNCTION_NAME" --region $REGION
aws events put-targets --rule $STOP_RULE_NAME --targets "Id"="1","Arn"="arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$STOP_FUNCTION_NAME" --region $REGION

# Cleanup
rm -rf $PACKAGE_DIR $ZIP_FILE

echo "Lambda functions deployed and updated successfully with CloudWatch event triggers."
