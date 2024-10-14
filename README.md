# alb_with_asg_using_terraform
Create an autoscaler group and aws application load balancer and configure them to work together


# Terraform AWS Docker

## Build and Run

To build the Docker image and run it with the necessary environment variables, use the following commands:

```sh
docker build -t terraform-aws .
docker run -it -v ${PWD}:/workspace -w /workspace -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION terraform-aws
