def lambda_handler(event, context):
    """
    Simple Lambda function for event-driven pipeline demo.

    Trigger:
    - S3 ObjectCreated event

    Function:
    - Logs incoming event
    - Confirms processing
    """

    print("Event received from S3:")
    print(event)

    return {
        "statusCode": 200,
        "body": "File received and processed successfully"
    }

