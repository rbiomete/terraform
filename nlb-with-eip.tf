##create nlb attach eip with 2 zones

data "aws_subnets" "subnet_mappings" {

   filter {
    name   = "tag:name"
    values = ["test"]
  }
}
 
resource "aws_lb" "public-lb" {
  name                              = "test-lb"
  internal                          = false
  load_balancer_type                = "network"

  enable_cross_zone_load_balancing  = false

  #enable_deletion_protection        = true

  dynamic "subnet_mapping" {
    for_each = range(length(data.aws_subnets.subnet_mappings.ids))

    content {
      subnet_id                         = data.aws_subnets.subnet_mappings.ids[subnet_mapping.key]
      allocation_id                     = lookup(aws_eip.public-nlb[subnet_mapping.key], "id")
    }
  }
}

resource "aws_eip" "public-nlb" {
  count = length(data.aws_subnets.subnet_mappings.ids)
  vpc   = true
}
