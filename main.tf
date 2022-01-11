terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

data "template_file" "user_data_training" {
  template = file("bootstrap-training.yml")
}

data "template_file" "user_data_monitoring" {
  template = file("bootstrap-monitoring.yml")
}

resource "aws_instance" "training_server" {
  ami             = "ami-0e5989519d28fb3cc"
  instance_type   = "p3.2xlarge"
  key_name        = "training-server-key"
  security_groups = ["${aws_security_group.allow_ssh.name}", "${aws_security_group.allow_out.name}"]
  user_data       = data.template_file.user_data_training.rendered

  tags = {
    Name    = "GanTrainingInstance"
    Purpose = "GanTrainingJob"
  }
}

resource "aws_instance" "monitoring_server" {
  ami             = "ami-00f7e5c52c0f43726"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.allow_http_dev.name}", "${aws_security_group.allow_out.name}"]
  user_data       = data.template_file.user_data_monitoring.rendered

  tags = {
    Name    = "GanMonitoringInstance"
    Purpose = "GanTrainingJob"
  }
}

output "monitoring_server_ip" {
  value = "${aws_instance.monitoring_server.public_ip}"
}
