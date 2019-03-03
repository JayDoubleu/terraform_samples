resource "aws_api_gateway_rest_api" "api" {
  name = "${var.api_name}"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "${var.api_resource_name}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "${var.api_method_type}"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "${var.api_method_type}"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = ["aws_api_gateway_integration.integration"]
}

resource "aws_api_gateway_integration_response" "response" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = ["aws_api_gateway_integration.integration"]
}

###cors stuff

resource "aws_api_gateway_method" "ResourceOptions" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ResourceOptionsIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.ResourceOptions.http_method}"
  type        = "MOCK"

  request_templates = {
    "application/json" = <<PARAMS
{ "statusCode": 200 }
PARAMS
  }
}

resource "aws_api_gateway_integration_response" "ResourceOptionsIntegrationResponse" {
  depends_on  = ["aws_api_gateway_integration.ResourceOptionsIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.ResourceOptions.http_method}"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_method_response" "ResourceOptions200" {
  depends_on  = ["aws_api_gateway_method.ResourceOptions"]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "OPTIONS"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_deployment" "stage" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "prod"
  description = "Deployed at ${timestamp()}"

  depends_on = [
    "aws_api_gateway_integration.ResourceOptionsIntegration",
    "aws_api_gateway_integration.integration",
    "aws_api_gateway_integration_response.ResourceOptionsIntegrationResponse",
    "aws_api_gateway_integration_response.response",
    "aws_api_gateway_method.ResourceOptions",
    "aws_api_gateway_method.method",
    "aws_api_gateway_method_response.200",
    "aws_api_gateway_method_response.ResourceOptions200",
    "aws_api_gateway_resource.resource",
    "aws_api_gateway_rest_api.api",
  ]
}

output "api_endpoint_url" {
  value = "${aws_api_gateway_deployment.stage.invoke_url}/${var.api_resource_name}"
}
