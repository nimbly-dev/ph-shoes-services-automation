output "repositories" {
  description = "Map of repository names to attributes"
  value = {
    for name, repo in aws_ecrpublic_repository.this :
    name => {
      repository_uri = repo.repository_uri
      arn            = repo.arn
    }
  }
}
