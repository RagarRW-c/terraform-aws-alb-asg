# Terraform AWS ALB + ASG + Docker (Portfolio Project)

## Overview
This project provisions a production-style AWS infrastructure using Terraform.
It deploys a containerized application behind an Application Load Balancer,
running on EC2 Auto Scaling Group, with monitoring, security, and CI/CD.

## Architecture
- VPC with public and private subnets
- Application Load Balancer
- Auto Scaling Group with EC2 instances
- Dockerized application pulled from ECR
- AWS WAF attached to ALB
- CloudWatch monitoring and alarms
- Terraform remote backend (S3 + DynamoDB)
- GitHub Actions CI/CD pipeline

## Tech Stack
- Terraform
- AWS (EC2, ALB, ASG, VPC, ECR, WAF, CloudWatch, SNS)
- Docker
- GitHub Actions

## Key Features
- High availability with ALB + ASG
- Immutable infrastructure with Terraform
- Container-based deployment using ECR
- Security hardening (WAF, Security Groups, IMDSv2)
- Observability with CloudWatch alarms
- Remote Terraform state with locking
- CI/CD pipeline for automated deploys

## Monitoring
- ALB 5xx error alarm
- Auto Scaling Group capacity alarm
- EC2 CPU utilization alarm
- SNS-based alerting

## CI/CD
- GitHub Actions pipeline
- Terraform fmt / validate / plan / apply
- Secure credentials via GitHub Secrets

## How to Deploy
1. Configure AWS credentials
2. Initialize Terraform backend
3. Run terraform apply
4. Access application via ALB DNS name

## Cleanup
Run `terraform destroy` to remove all resources.
