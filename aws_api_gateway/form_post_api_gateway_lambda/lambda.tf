data "archive_file" "zip_lambda" {
  type        = "zip"
  source_file = "${path.module}/files/lambda_function.py"
  output_path = "${path.module}/files/lambda.zip"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

resource "aws_lambda_function" "lambda" {
  filename         = "${path.module}/files/lambda.zip"
  function_name    = "${var.lambda_name}"
  role             = "${aws_iam_role.role.arn}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${base64sha256(file("${path.module}/files/lambda.zip"))}"
}

resource "aws_iam_role" "role" {
  name = "api_lambda_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}
