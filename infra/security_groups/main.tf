resource "aws_security_group" "emr_network_sg" {
  name        = "emr-network-sg"
  description = "Security group for EMR access"
  vpc_id      = var.vpc_id

  # Inbound rules - Allow SSH from anywhere
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules - Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
