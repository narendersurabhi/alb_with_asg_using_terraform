# tf_image_name = terraform-aws
.PHONY: plan

AWS_ACCESS_KEY_ID ?= $(shell echo $$AWS_ACCESS_KEY_ID)
AWS_SECRET_ACCESS_KEY ?= $(shell echo $$AWS_SECRET_ACCESS_KEY)
AWS_DEFAULT_REGION ?= $(shell echo $$AWS_DEFAULT_REGION)

CURRENT_DIR := $(shell pwd)

create_tf:
	docker build -t terraform-aws .
	docker run -it -v ./ :/workspace -w /workspace -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) -e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) terraform-aws

destroy_tf:
	docker ps -a | grep terraform-aws | awk '{print $$1}' | xargs docker stop | xargs docker rm || true
	 docker rmi terraform-aws || true

