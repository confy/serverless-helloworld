resource "aws_api_gateway_rest_api" "hello-gw" {
  name        = "hello-gw"
  description = "hello"
}

resource "aws_api_gateway_resource" "hello" {
  parent_id   = aws_api_gateway_rest_api.hello-gw.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.hello-gw.id
  path_part   = "{${var.resource_name}+}"
}

resource "aws_api_gateway_method" "hello" {
   rest_api_id   = aws_api_gateway_rest_api.hello-gw.id
   resource_id   = aws_api_gateway_resource.hello.id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_method" "hello_root" {
   rest_api_id   = aws_api_gateway_rest_api.hello-gw.id
   resource_id   = aws_api_gateway_rest_api.hello-gw.root_resource_id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
   rest_api_id = aws_api_gateway_rest_api.hello-gw.id
   resource_id = aws_api_gateway_method.hello_root.resource_id
   http_method = aws_api_gateway_method.hello_root.http_method

   integration_http_method = "POST"
   type                    = "AWS"
   uri                     = aws_lambda_function.hello_func.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200" {
 rest_api_id = aws_api_gateway_rest_api.hello-gw.id
 resource_id = aws_api_gateway_resource.hello.id
 http_method = aws_api_gateway_method.hello.http_method
 status_code = "200"
 
 response_models = { "application/json" = "Empty"}
}

resource "aws_api_gateway_integration_response" "IntegrationResponse" {
  depends_on = [
     aws_api_gateway_integration.lambdapy,
     aws_api_gateway_integration.lambda_root,
  ]
  rest_api_id = aws_api_gateway_rest_api.hello-gw.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  # Transforms the backend JSON response to json. The space is "A must have"
 response_templates = {
 "application/json" = <<EOF
 
 EOF
 }
}

resource "aws_api_gateway_deployment" "hello-gw" {
   depends_on = [
     aws_api_gateway_integration.lambdapy,
     aws_api_gateway_integration_response.IntegrationResponse,
   ]

   rest_api_id = aws_api_gateway_rest_api.hello-gw.id
   stage_name  = var.stage
}

output "base_url" {
  value = "${aws_api_gateway_deployment.hello-gw.invoke_url}/${var.resource_name}"
}