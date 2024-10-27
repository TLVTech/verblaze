# test_start_ec2.py
import json
from lambda_functions import start_ec2

# Simulate Lambda event and context
event = {}
context = {}

# Call the Lambda function
response = start_ec2(event, context)
print("Lambda response:", json.dumps(response, indent=2))
