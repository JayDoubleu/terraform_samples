data "template_file" "html_template" {
  template = "${file("${path.module}/files/form.html.template")}"

  vars = {
    api_deployment_url = "${aws_api_gateway_deployment.stage.invoke_url}/${var.api_resource_name}"
  }
}

resource "local_file" "html_form" {
  content  = "${data.template_file.html_template.rendered}"
  filename = "${path.module}/form.html"
}
