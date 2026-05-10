import boto3
import urllib.parse
import os

s3 = boto3.client('s3')
sns = boto3.client('sns')

SOURCE_BUCKETS = ['batteries-data-2026', 'panels-data-2026']

SINK_BUCKET = os.environ['MONITORING_BUCKET']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):

    for record in event['Records']:

        src_bucket = record['s3']['bucket']['name']

        key = urllib.parse.unquote_plus(
            record['s3']['object']['key']
        )

        if src_bucket not in SOURCE_BUCKETS:
            continue

        copy_source = {
            'Bucket': src_bucket,
            'Key': key
        }

        s3.copy_object(
            Bucket=SINK_BUCKET,
            Key=key,
            CopySource=copy_source
        )

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,

            Subject="New S3 Upload",

            Message=f"""
Hello AbdelRahman,

A new file has been uploaded successfully.

File Name: {key}
Source Bucket: {src_bucket}
Monitoring Bucket: {SINK_BUCKET}

The file has been automatically copied to the monitoring bucket.

Best regards,
Cloud Monitoring System
"""
        )