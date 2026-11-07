
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main-sb-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main-sb-1"
  }
}

resource "aws_subnet" "main-sb-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main-sb-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "main-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "main-rt"
  }
}

resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.main-sb-1.id
  route_table_id = aws_route_table.main-rt.id
}

resource "aws_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.main-sb-2.id
  route_table_id = aws_route_table.main-rt.id
}

resource "aws_security_group" "Talha-Web-SG" {
  name        = "web_sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Talha-Web-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.Talha-Web-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.Talha-Web-SG.id
  cidr_ipv4         = "139.135.46.209/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.Talha-Web-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_key_pair" "SMS-key" {
  key_name   = "SMS-key"
  public_key = file("C:/Users/HP/.ssh/SMS-key.pub")
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "sms_bucket" {
  bucket = "sms-school-html-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "sms_bucket_security" {
  bucket                  = aws_s3_bucket.sms_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "school_html" {
  bucket = aws_s3_bucket.sms_bucket.id
  key    = "School.html"
  source = "${path.module}/School.html"
  etag   = filemd5("${path.module}/School.html")
}

resource "aws_iam_role" "SMS_role" {
  name = "SMS-EC2-S3-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "SMS_s3_policy" {
  name = "SMS-S3-Read-Policy"
  role = aws_iam_role.SMS_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "${aws_s3_bucket.sms_bucket.arn}/School.html"
    }]
  })
}

resource "aws_iam_instance_profile" "SMS_profile" {
  name = "SMS_profile"
  role = aws_iam_role.SMS_role.name
}

resource "aws_instance" "SMS" {
  ami                         = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.SMS-key.key_name
  subnet_id                   = aws_subnet.main-sb-1.id
  vpc_security_group_ids      = [aws_security_group.Talha-Web-SG.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.SMS_profile.name

  user_data = <<-EOF
    #!/bin/bash
    set -e
    dnf install -y nginx awscli-2
    systemctl enable --now nginx
    aws s3 cp s3://${aws_s3_bucket.sms_bucket.bucket}/School.html /usr/share/nginx/html/index.html --region us-east-1
  EOF

  user_data_replace_on_change = true

  depends_on = [
    aws_s3_object.school_html,
    aws_iam_role_policy.SMS_s3_policy
  ]

  tags = {
    Name = "SMS"
  }
}