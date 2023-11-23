"""Simple hello-world lambda."""


def lambda_handler(event, context):
    """Simple hello-world lambda handler"""
    print('Lambda invoked')
    return {
        'statusCode': 200,
        'body': 'Hello world!'
    }
