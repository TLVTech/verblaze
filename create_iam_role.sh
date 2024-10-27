#!/bin/bash

# Load environment variables from .env file
set -o allexport
source .env
set +o allexport

# Define role trust policy
TRUST_POLICY=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
)

# Create the IAM role
aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document "$TRUST_POLICY" --region $REGION

# Define custom inline policy for EC2 permissions
INLINE_POLICY=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": "arn:aws:ec2:$REGION:$ACCOUNT_ID:instance/$INSTANCE_ID"
        }
    ]
}
EOF
)

# Attach inline policy to the role
aws iam put-role-policy --role-name $ROLE_NAME --policy-name EC2StartStopPolicy --policy-document "$INLINE_POLICY" --region $REGION

# Attach managed policy for CloudWatch logging permissions
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --region $REGION

# Get the Role ARN to use in Lambda deployment
ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query "Role.Arn" --output text --region $REGION)

echo "Role created with ARN: $ROLE_ARN"
