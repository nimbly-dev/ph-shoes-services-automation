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

output "service_discovery_details" {
  description = "Detailed service discovery information for debugging"
  value = {
    for key, data in data.external.service_instance : key => {
      service_name           = var.services[key].service_name
      domain                = var.services[key].domain
      discovered_ip         = data.result.ip
      task_arn             = data.result.task_arn
      container_instance_arn = data.result.container_instance_arn
      ec2_instance_id      = data.result.ec2_instance_id
      service_status       = data.result.service_status
      dns_hostname         = cloudflare_record.service[key].hostname
    }
  }
}

output "service_to_ip_mapping" {
  description = "Simple service-to-IP mapping for quick reference"
  value = {
    for key, data in data.external.service_instance : var.services[key].domain => {
      ip = data.result.ip
      status = data.result.service_status
      instance_id = data.result.ec2_instance_id
    }
  }
}
