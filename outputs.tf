output "dn" {
  value       = aci_rest.datetimePol.id
  description = "Distinguished name of `datetimePol` object."
}

output "name" {
  value       = aci_rest.datetimePol.content.name
  description = "Date time policy name."
}
