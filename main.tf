# Create ElastiCache Redis security group

resource "aws_security_group" "redis_sg" {
  vpc_id = "${var.vpc_id}"

  ingress {
      cidr_blocks = ["${split(",", var.private_subnet_cidrs)}"]
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name          = "${var.tag_name}"
    contact-email = "${var.tag_contact-email}"
  }
}

# Create ElastiCache Redis subnet group

resource "aws_elasticache_subnet_group" "default" {
  name        = "subnet-group-${var.tag_name}"
  description = "Private subnets for the ElastiCache instances: ${var.tag_name}"
  subnet_ids  = ["${split(",", var.private_subnet_ids)}"]
}

# Create ElastiCache Redis cluster

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.cluster_id}"
  engine               = "redis"
  engine_version       = "${var.engine_version}"
  maintenance_window   = "${var.maintenance_window}"
  node_type            = "${var.instance_type}"
  num_cache_nodes      = "1"
  parameter_group_name = "${var.parameter_group_name}"
  port                 = "6379"
  subnet_group_name    = "${aws_elasticache_subnet_group.default.name}"
  security_group_ids   = ["${aws_security_group.redis_sg.id}"]

  tags {
    Name          = "${var.tag_name}"
    contact-email = "${var.tag_contact-email}"
  }
}

# Create IAM role for Lambda function

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-vpc-role" {
  name               = "${var.function_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

# Attach an additional policy to Lambda function IAM role required for the VPC config

data "aws_iam_policy_document" "network" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "network" {
  count = "${var.attach_vpc_config ? 1 : 0}"

  name   = "${var.function_name}-network"
  policy = "${data.aws_iam_policy_document.network.json}"
}

resource "aws_iam_policy_attachment" "network" {
  count = "${var.attach_vpc_config ? 1 : 0}"

  name       = "${var.function_name}-network"
  roles      = ["${aws_iam_role.lambda-vpc-role.name}"]
  policy_arn = "${aws_iam_policy.network.arn}"
}

# Create Lambda function

resource "null_resource" "lambda_function" {
    provisioner "local-exec" {
        command = "pwd"
    }
}

resource "aws_lambda_function" "demo_lambda_redis" {
  depends_on = [ "null_resource.lambda_function" ]
	function_name    = "${var.function_name}"
	handler          = "index.handler"
	runtime          = "nodejs8.10"
	filename         = "${var.file_name}"
	source_code_hash = "${base64sha256(file("${var.file_name}"))}"
	role             = "${aws_iam_role.lambda-vpc-role.arn}"
  vpc_config {
    subnet_ids          = ["${split(",", var.private_subnet_ids)}"]
    security_group_ids  = ["${aws_security_group.redis_sg.id}"]
  }
  environment = {
    variables = { REDIS_URL = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:${aws_elasticache_cluster.redis.cache_nodes.0.port}" }
  }
}
