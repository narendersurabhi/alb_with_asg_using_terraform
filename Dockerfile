FROM hashicorp/terraform:latest

# Optional: Install additional tools you may need
# RUN apk add --no-cache curl git

WORKDIR /workspace/dev

# Copy Terraform configuration files
# COPY . .

# Copy specific directories to the workspace
COPY ./dev /workspace/dev
COPY ./qa /workspace/qa
COPY ./modules/blog /workspace/modules/blog

# Start an interactive shell instead of running a command directly
ENTRYPOINT ["/bin/sh"]
