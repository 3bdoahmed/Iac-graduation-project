import json
import boto3
import os

from decimal import Decimal

dynamodb = boto3.resource(
    'dynamodb',
    region_name='eu-west-3'
)

table = dynamodb.Table(
    os.environ['TABLE_NAME']
)

def convert_decimal(obj):

    if isinstance(obj, Decimal):
        return float(obj)

    raise TypeError


def lambda_handler(event, context):

    try:

        response = table.scan()

        items = response.get('Items', [])

        return {

            'statusCode': 200,

            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },

            'body': json.dumps(
                items,
                default=convert_decimal
            )
        }

    except Exception as e:

        return {

            'statusCode': 500,

            'body': json.dumps({
                "error": str(e)
            })
        }