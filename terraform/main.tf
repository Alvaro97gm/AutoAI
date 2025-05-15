# Estructura base para AutoAI (Frontend + Backend Serverless en AWS)

# === providers.tf ===
provider "aws" {
    region = "eu-west-1"
}

# === s3.tf ===
resource "aws_s3_bucket" "frontend_bucket" {
    bucket = "autoai-frontend-bucket"
    acl    = "public-read"

    website {
        index_document = "index.html"
        error_document = "index.html"
    }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
    bucket = aws_s3_bucket.frontend_bucket.id
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect    = "Allow",
                Principal = "*",
                Action    = "s3:GetObject",
                Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
            }
        ]
    })
}

# === apigateway.tf ===
resource "aws_apigatewayv2_api" "http_api" {
    name          = "autoai-api"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
    api_id           = aws_apigatewayv2_api.http_api.id
    integration_type = "AWS_PROXY"
    integration_uri  = aws_lambda_function.generate_prompt.invoke_arn
    integration_method = "POST"
    payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "generate_route" {
    api_id    = aws_apigatewayv2_api.http_api.id
    route_key = "POST /generate"
    target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigw_lambda" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.generate_prompt.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# === outputs.tf ===
output "api_endpoint" {
    value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "s3_frontend_url" {
    value = aws_s3_bucket.frontend_bucket.website_endpoint
}
