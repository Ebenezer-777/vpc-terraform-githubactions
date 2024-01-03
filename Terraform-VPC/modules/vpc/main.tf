# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "my_vpc"
  }
}

# Two Subnets
resource "aws_subnet" "my_subnet" {
  count                   = length(var.subnet_cidr)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidr[count.index]
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_names[count.index]
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# Route Table
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0" #Public
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Route Table"
  }
}
# Route Table Association
resource "aws_route_table_association" "rta" {
  count          = length(var.subnet_cidr)
  subnet_id      = aws_subnet.my_subnet[count.index].id
  route_table_id = aws_route_table.my_rt.id
}