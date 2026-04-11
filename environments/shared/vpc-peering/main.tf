data "terraform_remote_state" "prod_network" {
  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "prod/network/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "stage_network" {
  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "stage/network/terraform.tfstate"
    region = "ap-south-1"
  }
}


resource "aws_vpc_peering_connection" "prod_stage" {
  vpc_id      = data.terraform_remote_state.prod_network.outputs.vpc_id
  peer_vpc_id = data.terraform_remote_state.stage_network.outputs.vpc_id
  auto_accept = true

  tags = {
    Name = "prod-stage-peering"
  }
}


resource "aws_route" "prod_to_stage" {
  route_table_id            = data.terraform_remote_state.prod_network.outputs.route_table_id
  destination_cidr_block    = data.terraform_remote_state.stage_network.outputs.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_stage.id
}

resource "aws_route" "stage_to_prod" {
  route_table_id            = data.terraform_remote_state.stage_network.outputs.route_table_id
  destination_cidr_block    = data.terraform_remote_state.prod_network.outputs.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_stage.id
}