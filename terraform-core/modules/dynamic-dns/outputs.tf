output "dns_records" {
  description = "Map of created DNS records with their hostnames and IPs"
  value = {
    for key, record in cloudflare_record.service : key => {
      hostname = record.hostname
      ip       = record.content
      domain   = record.name
    }
  }
}

output "service_ips" {
  description = "Map of service names to their discovered IP addresses"
  value = {
    for key, data in data.external.service_instance : key => data.result.ip
  }
}
