variable "Ports_var" {
  description = "This is what we want in our sg to have open"
  type        = list(number)
  default     = [22, 80, 443]
}

resource "aws_security_group" "ec2_web_server" {
  name = "TF_New_TEst_SecGroup"
  dynamic "egress" {
    for_each = toset(var.Ports_var)
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "ingress" {
    for_each = toset(var.Ports_var)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

data "aws_ami" "ami_id" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-*"]
  }
}

output "ami_out" {
  value = data.aws_ami.ami_id.id
}

resource "aws_instance" "my_webs_server" {
  ami           = data.aws_ami.ami_id.id
  instance_type = "t2.nano"
  //key_name = "mykeyfortesting"              --------------->>>>> Need Write Your Own .pem Key Name (Just The Name Without .pem)
  vpc_security_group_ids = [aws_security_group.ec2_web_server.id]
  //user_data              = file("./web.sh")  --------------->>>>> Create Your Own .sh File & Specify The Path
}

output "awbServer_IP" {
  value = aws_instance.my_webs_server.public_ip
}
