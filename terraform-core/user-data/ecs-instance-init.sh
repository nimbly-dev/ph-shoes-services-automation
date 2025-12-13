#!/bin/bash
set -e

# Configure ECS cluster
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

# Install nginx
yum install -y nginx

# Deploy nginx config
cat > /etc/nginx/conf.d/services.conf <<'EOF'
${nginx_config}
EOF

# Start nginx
systemctl enable nginx
systemctl start nginx
