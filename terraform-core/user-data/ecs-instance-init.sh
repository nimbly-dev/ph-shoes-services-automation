#!/bin/bash
set -e

# Configure ECS cluster
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

# Install nginx with retry logic
for i in {1..3}; do
    if amazon-linux-extras install -y nginx1; then
        echo "Nginx installed successfully"
        break
    else
        echo "Nginx installation attempt $i failed, retrying..."
        sleep 10
    fi
done

# Ensure nginx directory exists
mkdir -p /etc/nginx/conf.d

# Deploy nginx config
cat > /etc/nginx/conf.d/services.conf <<'EOF'
${nginx_config}
EOF

# Test nginx config
nginx -t

# Start nginx
systemctl enable nginx
systemctl start nginx

# Verify nginx is running
systemctl status nginx

echo "User data script completed successfully"
