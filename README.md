# terraform-aws-redis-lambda

A Terraform module that represents an AWS ElastiCache Redis cluster and a Lambda function that connects to it.  See example usage below.

### Usage

1. Download `demo-lambda-redis.zip` into the folder you are terraforming from.

2. Run terraform, here is a sample plan


 ```terraform
provider "aws" {
  version = "~> 1.8.0"
  region = "us-east-1"
}

module "elasticache_redis" {
  source = "github.com/udaysharma/terraform-aws-redis-lambda?ref=v1.0"

  cluster_id            = "Sandbox-redis"
  engine_version        = "2.8.24"
  instance_type         = "cache.t2.micro"
  maintenance_window    = "sun:05:00-sun:06:00"
  vpc_id                = "vpc-xxxxxxxx"
  private_subnet_ids    = "subnet-xxxxxxxx,subnet-yyyyyyyy"
  private_subnet_cidrs  = "x.x.x.x/x,y.y.y.y/y"
  parameter_group_name  = "default.redis2.8"
  tag_name              = "Sandbox-redis"
  tag_contact-email     = "example@domain.com"
  attach_vpc_config     = true
}
```

### Variables

- `cluster_id`          - ID of the cluster
- `vpc_id`              - ID of VPC meant to house the cache
- `private_subnet_ids`  - Comma delimited list of private subnet IDs
- `engine_version`      - Cache engine version (default: `2.8.24`)
- `instance_type`       - Instance type for cache instance (default: `cache.t2.micro`)
- `maintenance_window`  - 60 minute time window to reserve for maintenance
  (default: `sun:05:00-sun:06:00`)
- `parameter_group_name`- Name of the parameter group to associate with this cache cluster
  (default: `default.redis2.8`)
- `tag_name`            - Name tag for the Elasticache Redis cluster
- `tag_contact-email`   - Email tag for the Elasticache Redis cluster


### Outputs

- `hostname`                - Public DNS name of cache node
- `port`                    - Port of cache instance
- `endpoint`                - Public DNS name and port separated by a `:`
- `cache_security_group_id` - Security group ID of the cache cluster
- `iam-role-arn`            - ARN for IAM role created for Lambda function


### License

[MIT](./LICENSE) © Uday Sharma
