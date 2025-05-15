resource "aws_lambda_function" "generate_prompt" {
    function_name = "generatePrompt"
    role          = aws_iam_role.lambda_role.arn
    handler       = "index.handler"
    runtime       = "nodejs18.x"
    filename      = "../backend/generate-prompt.zip"
    source_code_hash = filebase64sha256("../backend/generate-prompt.zip")
    environment {
        variables = {
            OPENAI_API_KEY = var.openai_api_key
        }
    }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
    role       = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_role" {
    name = "autoai_lambda_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }]
    })
}
