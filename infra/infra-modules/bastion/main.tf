# resource "aws_security_group" "bastion" {
#   name        = "${var.project}-bastion-sg-${var.environment}"
#   description = "Security group for bastion host"
#   vpc_id      = var.vpc_id

#   # Only allowing outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project}-bastion-sg-${var.environment}"
#   }
# }

# IAM Role for Bastion with Enhanced SSM Permissions
resource "aws_iam_role" "bastion" {
  name = "${var.project}-bastion-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# SSM Policies
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_directory" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AWSDirectoryServiceFullAccess"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project}-bastion-profile-${var.environment}"
  role = aws_iam_role.bastion.name
}

# Bastion Host
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.bastion_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2 required
  }

  tags = {
    Name = "${var.project}-bastion-${var.environment}"
  }
}