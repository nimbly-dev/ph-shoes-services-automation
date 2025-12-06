locals {
  repositories = { for repo in var.repositories : repo.name => repo }
}

resource "aws_ecrpublic_repository" "this" {
  for_each        = local.repositories
  repository_name = each.value.name

  dynamic "catalog_data" {
    for_each = try(each.value.description, null) == null ? [] : [each.value.description]
    content {
      description = catalog_data.value
    }
  }

  tags = var.tags
}
