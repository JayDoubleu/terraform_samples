data "external" "sample_output_json" {
  program = ["python", "${path.module}/sample_output_json.py"]
}

output "names" {
  value = "${data.external.sample_output_json.result.names}"
}
