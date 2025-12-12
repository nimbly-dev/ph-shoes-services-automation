frontend_enable          = true
frontend_container_image = "public.ecr.aws/n4j5x4n7/ph-shoes-data-spa-frontend:9a22d82cc62118824234a5b7d2ee55bdb6217b27"
frontend_container_port  = 80
frontend_desired_count   = 1

ecs_instance_ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
