output "certificate" {
  value = "${acme_certificate.default.issuer_pem}\n${acme_certificate.default.certificate_pem}"
}

output "private_key" {
  value = acme_certificate.default.private_key_pem
}
