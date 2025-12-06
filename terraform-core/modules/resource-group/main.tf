resource "aws_resourcegroups_group" "this" {
  name        = var.name
  description = var.description

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        for key, value in var.tag_query : {
          Key    = key
          Values = [value]
        }
      ]
    })
  }

  tags = var.tags
}
