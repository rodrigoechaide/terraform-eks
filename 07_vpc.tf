resource "aws_vpc" "main" {
  cidr_block       = local.vpc.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = local.vpc.environment
  }
}

resource "aws_subnet" "front" {

  for_each   = local.vpc.front_subnets_cidrs

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr
  availability_zone = each.key

  tags = {
    Name = "${local.vpc.environment}-front-${each.key}"
  }
}

resource "aws_subnet" "back" {

  for_each   = local.vpc.back_subnets_cidrs

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr
  availability_zone = each.key

  tags = {
    Name = "${local.vpc.environment}-back-${each.key}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.vpc.environment
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.front["eu-north-1a"].id

  tags = {
    Name = local.vpc.environment
  }

}

resource "aws_eip" "nat_gateway" {
  vpc      = true
}

resource "aws_route_table" "front" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${local.vpc.environment}-front"
  }
}

resource "aws_route_table_association" "front-eu-north-1a" {
  subnet_id      = aws_subnet.front["eu-north-1a"].id
  route_table_id = aws_route_table.front.id
}

resource "aws_route_table_association" "front-eu-north-1b" {
  subnet_id      = aws_subnet.front["eu-north-1b"].id
  route_table_id = aws_route_table.front.id
}

resource "aws_route_table_association" "front-eu-north-1c" {
  subnet_id      = aws_subnet.front["eu-north-1b"].id
  route_table_id = aws_route_table.front.id
}

resource "aws_route_table" "back" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${local.vpc.environment}-back"
  }
}

resource "aws_route_table_association" "back-eu-north-1a" {
  subnet_id      = aws_subnet.back["eu-north-1a"].id
  route_table_id = aws_route_table.back.id
}

resource "aws_route_table_association" "back-eu-north-1b" {
  subnet_id      = aws_subnet.back["eu-north-1b"].id
  route_table_id = aws_route_table.back.id
}

resource "aws_route_table_association" "back-eu-north-1c" {
  subnet_id      = aws_subnet.back["eu-north-1b"].id
  route_table_id = aws_route_table.back.id
}