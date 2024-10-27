# lambdas/lambda_functions.py
import boto3

# Load environment variables from .env

# Initialize the EC2 client
REGION='us-east-1'
ec2 = boto3.client('ec2', region_name=REGION)

def start_ec2(event, context):
    """Starts the specified EC2 instance."""
    #instance_id = os.getenv('INSTANCE_ID')
    instance_id = 'i-0bbec564bcca79694'
    try:
        response = ec2.start_instances(InstanceIds=[instance_id])
        return {
            'statusCode': 200,
            'body': response
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'error': str(e)
        }

def stop_ec2(event, context):
    """Stops the specified EC2 instance."""
    #instance_id = os.getenv('INSTANCE_ID')
    instance_id = 'i-0bbec564bcca79694'
    try:
        response = ec2.stop_instances(InstanceIds=[instance_id])
        return {
            'statusCode': 200,
            'body': response
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'error': str(e)
        }
