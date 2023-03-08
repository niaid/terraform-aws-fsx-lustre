data "aws_subnet" "subnets" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}