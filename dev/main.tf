module "dev" {
  source = "../modules/blog"

  environment = {
    name = "dev"
    network_prefix = "10.0"
  }
  asg_min_size = 1
  asg_max_size = 1

}