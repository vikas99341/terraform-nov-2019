provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "in.javahome.930am-oct.tf"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "javahome-db"
  }
}
// Create VPC using terraform

resource "aws_vpc" "myapp" {

  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name     = "JavaHomeVPC-${terraform.workspace}"
    Batch    = "930AM"
    Year     = 2019
    Location = "Banglore"
  }

}
resource "aws_subnet" "private" {
  count             = length(local.pri_sub_names)
  vpc_id            = aws_vpc.myapp.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = local.pri_sub_names[count.index]
  tags = {
    Name = "PrivateSubnet-${substr(local.pri_sub_names[count.index], 9, 2)}"
  }
}

resource "aws_subnet" "public" {
  count             = length(local.pri_sub_names)
  vpc_id            = aws_vpc.myapp.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, local.public_netnum + count.index)
  availability_zone = local.pri_sub_names[count.index]
  tags = {
    Name = "PublicSubnet-${substr(local.pri_sub_names[count.index], 9, 2)}"
  }
}