# Variables
tf_image_name = terraform-aws

.PHONY: create_tf #destroy_tf

# Build and run the Terraform Docker container
create_tf:
    docker build -t $(tf_image_name) .
    docker run --rm -it --env-file ./env.list $(tf_image_name)

# Stop and remove the Terraform Docker container, then remove the image
# destroy_tf:
#     docker ps -a | grep $(tf_image_name) | awk '{print $$1}' | xargs -r docker stop | xargs -r docker rm || true
#     docker rmi $(tf_image_name) || true

# destroy_tf:
# 	docker ps -a | Select-String terra | ForEach-Object { docker stop $_.Line.Split(' ')[0] } | \
#     docker ps -a | Select-String terra | ForEach-Object { docker rm $_.Line.Split(' ')[0] } | \
#     docker image ls | Select-String terra | ForEach-Object { docker rmi $_.Line.Split(' ')[0] }
