provider "aws" {
  region = "eu-west-1"
}

#creating s3 bucket
terraform{
  backend "s3"{
    bucket = "cyber94-zak-calculatorr-bucket"
    key = "tfstate/calculatorr/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "cyber94_full_infra_calculatorr_zak_dynamodb_table_lock"
    encrypt = true
  }
}

#creating vpc
resource "aws_vpc" "cyber94_full_infra_calc_zak_vpc" {
    cidr_block = "10.112.0.0/16"

    tags = {
      Name = "cyber94_full_infra_calc_zak_vpc"
    }
}


#creating internet gateway
resource "aws_internet_gateway" "cyber94_full_infra_calc_zak_IGW" {
    vpc_id =  aws_vpc.cyber94_full_infra_calc_zak_vpc.id
 }



#creating subnets (APP)
 resource "aws_subnet" "cyber94_full_infra_calc_zak_subnet_app" {
  vpc_id = aws_vpc.cyber94_full_infra_calc_zak_vpc.id
  cidr_block = "10.112.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "cyber94_full_infra_calc_subnet_app"
  }
}

#creating subnets (db)
resource "aws_subnet" "cyber94_full_infra_calc_zak_subnet_db" {
 vpc_id = aws_vpc.cyber94_full_infra_calc_zak_vpc.id
 cidr_block = "10.112.2.0/24"
 availability_zone = "eu-west-1a"

 tags = {
   Name = "cyber94_full_infra_calc_subnet_db"
 }
}

#creating subnets (bastion)
resource "aws_subnet" "cyber94_full_infra_calc_zak_subnet_bastion" {
 vpc_id = aws_vpc.cyber94_full_infra_calc_zak_vpc.id
 cidr_block = "10.112.3.0/24"
 availability_zone = "eu-west-1a"

 tags = {
   Name = "cyber94_full_infra_calc_subnet_bastion"
 }
}

#Creating Route table
resource "aws_route_table" "cyber94_full_infra_calc_zak_routing_table" {
   vpc_id = aws_vpc.cyber94_full_infra_calc_zak_vpc.id

   route{
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.cyber94_full_infra_calc_zak_IGW.id
   }

   route {
     ipv6_cidr_block = "::/0"
     gateway_id = aws_internet_gateway.cyber94_full_infra_calc_zak_IGW.id
   }

   tags = {
     Name = "cyber94_full_infra_calc_zak_routing_table"
   }

 }


#routing table associations
 resource "aws_route_table_association" "cyber94_full_infra_calc_zak_rt_assoc_app_tf" {
   subnet_id = aws_subnet.cyber94_full_infra_calc_zak_subnet_app.id
   route_table_id = aws_route_table.cyber94_full_infra_calc_zak_routing_table.id
 }
 resource "aws_route_table_association" "cyber94_full_infra_calc_zak_rt_assoc_bastion_tf" {
   subnet_id =aws_subnet.cyber94_full_infra_calc_zak_subnet_bastion.id
   route_table_id =aws_route_table.cyber94_full_infra_calc_zak_routing_table.id
 }

#NACL APP
 resource "aws_network_acl" "cyber94_full_infra_calc_zak_subnet_app" {      #creating nacl
   vpc_id = aws_vpc.cyber94_full_infra_calc_zak_vpc.id
   subnet_ids = [aws_subnet.cyber94_full_infra_calc_zak_subnet_app.id]

   egress {
          protocol   = "tcp"
          rule_no    = 1000
          action     = "allow"
          cidr_block = "0.0.0.0/0"
          from_port  = 3306
          to_port    = 3306
        }
      egress {
          protocol   = "tcp"
          rule_no    = 2000
          action     = "allow"
          cidr_block = "0.0.0.0/0"
          from_port  = 80
          to_port    = 80
        }
      egress {
          protocol   = "tcp"
          rule_no    = 3000
          action     = "allow"
          cidr_block = "0.0.0.0/0"
          from_port  = 443
          to_port    = 443
        }

      egress {
          protocol   = "tcp"
          rule_no    = 4000
          action     = "allow"
          cidr_block = "0.0.0.0/0"
          from_port  = 1024
          to_port    = 65535
        }

      ingress {
          protocol   = "tcp"
          rule_no    = 100
          action     = "allow"
          cidr_block = "0.0.0.0/0"
          from_port  = 5000
          to_port    = 5000
        }
      ingress {
          protocol   = "tcp"
          rule_no    = 200
          action     = "allow"
          cidr_block = "0.0.0.0/0"
          from_port  = 22
          to_port    = 22
        }
      ingress {
          protocol   = "tcp"
          rule_no    = 300
          action     = "allow"
          cidr_block = "0.0.0.0/0"
          from_port  = 1024
          to_port    = 65535
        }
  tags = {
    Name = "cyber94_full_infra_calc_zak_nacl_app"
  }
 }

 #NACL BASTION
 resource "aws_network_acl" "cyber94_full_infra_calc_zak_nacl_bastion" {      #creating nacl
   vpc_id = aws_vpc.cyber94_full_infra_calc_zak_vpc.id
   subnet_ids = [aws_subnet.cyber94_full_infra_calc_zak_subnet_bastion.id]
   egress {
        protocol   = "tcp"
        rule_no    = 1000
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
      }

    egress {
        protocol   = "tcp"
        rule_no    = 2000
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 1024
        to_port    = 65535
      }

    ingress {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
      }
    ingress {
        protocol   = "tcp"
        rule_no    = 200
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 1024
        to_port    = 65535
      }

      tags = {
        Name = "cyber94_full_infra_calc_zak_nacl_bastion"
      }
     }

#NACL DB

resource "aws_network_acl" "cyber94_full_infra_calc_zak_nacl_db" {      #creating nacl
  vpc_id = aws_vpc.cyber94_full_infra_calc_zak_vpc.id
  subnet_ids = [aws_subnet.cyber94_full_infra_calc_zak_subnet_db.id]
  egress {
        protocol   = "tcp"
        rule_no    = 1000
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 1024
        to_port    = 65535
      }

    ingress {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
      }
    ingress {
        protocol   = "tcp"
        rule_no    = 200
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 3306
        to_port    = 3306
      }

      tags = {
        Name = "cyber94_full_infra_calc_zak_nacl_db"
      }
      }

      #creating sg app
  resource "aws_security_group" "cyber94_full_infra_calc_zak_sg_app" {     #security group
  name = "cyber94_full_infra_calc_zak_sg_app"
  vpc_id = aws_vpc.cyber94_full_infra_calc_zak_vpc.id

  ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "5000"
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      description = "MySQL"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "cyber94_full_infra_calc_zak_sg_app"
  }
 }


#creating sg bastion
 resource "aws_security_group" "cyber94_full_infra_calc_zak_sg_bastion" {     #security group
 name = "cyber94_full_infra_calc_zak_sg_bastion"
 vpc_id = aws_vpc.cyber94_full_infra_calc_zak_vpc.id

 ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

 tags = {
   Name = "cyber94_full_infra_calc_zak_sg_bastion"
 }
}

# creating sg db
resource "aws_security_group" "cyber94_full_infra_calc_zak_sg_db" {     #security group
name = "cyber94_full_infra_calc_zak_sg_db"
vpc_id = aws_vpc.cyber94_full_infra_calc_zak_vpc.id

ingress {
     description = "MySQL"
     from_port   = 3306
     to_port     = 3306
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     from_port   = 0
     to_port     = 0
     protocol    = -1
     cidr_blocks = ["0.0.0.0/0"]
   }

tags = {
  Name = "cyber94_full_infra_calc_zak_sg_db"
}
}

#creating instance app
resource "aws_instance" "cyber94_full_infra_calc_zak_server_app_tf"{
   ami = "ami-0943382e114f188e8"
   instance_type = "t2.micro"
   key_name = "cyber94-zkhatri"
   vpc_security_group_ids = [aws_security_group.cyber94_full_infra_calc_zak_sg_app.id]
   subnet_id = aws_subnet.cyber94_full_infra_calc_zak_subnet_app.id
   associate_public_ip_address = true
   tags = {
     Name = "cyber94_full_infra_calc_zak_server_app"
     }

#     lifecyle {
#       create_before_destory = true
#     }

#running the ansible commands
#just to make sure that terraform will not continue to local-exec before the server is up
 connection {
   type = "ssh"
   user = "ubuntu"
   host = self.public_ip
   private_key = file("/home/kali/.ssh/cyber94-zkhatri.pem")
 }
 provisioner "remote-exec" {
     inline = [
       "pwd"
     ]
   }

provisioner "local-exec" {
  working_dir ="../ansible"
  command = "ansible-playbook -i ${self.public_ip}, -u ubuntu provisioner.yml"

  }
   }


   #creating instance bastion
   resource "aws_instance" "cyber94_full_infra_calc_zak_server_bastion_tf"{
      ami = "ami-0943382e114f188e8"
      instance_type = "t2.micro"
      key_name = "cyber94-zkhatri"
      vpc_security_group_ids = [aws_security_group.cyber94_full_infra_calc_zak_sg_bastion.id]
      subnet_id = aws_subnet.cyber94_full_infra_calc_zak_subnet_bastion.id
      associate_public_ip_address = true
      tags = {
        Name = "cyber94_full_infra_calc_zak_server_bastion"
        }
#        lifecyle {
#          create_before_destory = true
#        }
      }



      #creating instance db
      resource "aws_instance" "cyber94_full_infra_calc_zak_server_db_tf"{
         ami = "ami-0d1c7c4de1f4cdc9a"
         instance_type = "t2.micro"
         key_name = "cyber94-zkhatri"
         vpc_security_group_ids = [aws_security_group.cyber94_full_infra_calc_zak_sg_db.id]
         subnet_id = aws_subnet.cyber94_full_infra_calc_zak_subnet_db.id
         tags = {
           Name = "cyber94_full_infra_calc_zak_server_db"
           }
  #         lifecyle {
  #           create_before_destory = true
  #         }
         }
