import json
import os
from openai_utils import generate_prompt_and_parameters

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        description = body.get("description")

        if not description:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing 'description'"})
            }

        result = generate_prompt_and_parameters(description)

        return {
            "statusCode": 200,
            "body": json.dumps(result)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
