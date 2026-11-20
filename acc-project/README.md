# ACC Mini Project: Cloud Application Reliability and Recovery

## Purpose
A small industry-style IT service demo for the Advanced Cloud Computing assignment. It demonstrates cloud VM provisioning, Docker packaging, health checks, restricted network access, and a basis for measuring service recovery time (TTR).

> The instructor's template explicitly mentions AWS, Docker, virtualization, SLA/TTR, monitoring, performance testing, failure/recovery, security and cost. This starter is a foundation, not yet the complete rubric implementation.

## Components
- AWS EC2: virtualized compute host
- Default VPC/subnet: network placement
- EC2 security group: HTTP ingress restricted to your supplied public IP CIDR
- Amazon Linux 2023: guest OS
- Docker: container runtime on the instance
- CloudWatch: recommended next step for instance/system monitoring and logs
- `app/`: small Python health-check HTTP service with a Dockerfile
- `terraform/`: Terraform infrastructure configuration

## Important implementation note
The EC2 bootstrap currently serves a simple static page using an Nginx container so that the first cloud deployment is easy to verify. The separate Python health-check app in `app/` is for the next stage of the demo. Before claiming Docker health-check recovery or measured TTR, build/run that app and perform an actual failure/recovery test.

## Prerequisites
- AWS account and permission to create EC2 and security groups
- Terraform 1.5+
- AWS CLI configured with a profile/role (do not commit credentials)
- Docker installed locally if building the app locally

## Deploy
1. Review current AWS pricing, regional availability, and your account's EC2 quota.
2. Change to `terraform/`.
3. Copy `terraform.tfvars.example` to `terraform.tfvars`.
4. Set `my_ip_cidr` to your current public IPv4 address with `/32`. Do not use `0.0.0.0/0`.
5. Run:
   ```bash
   terraform init
   terraform fmt -check
   terraform validate
   terraform plan
   ```
6. Review the plan carefully, then run `terraform apply` and confirm only if you intend to create billable resources.
7. Open the output application URL from the same public IP configured in the security group.

## Cleanup
From the same `terraform/` directory:
```bash
terraform destroy
```
Review the plan and confirm only when you are certain the resources belong to this demo. Check the AWS console afterward for any remaining resources.

## Security and cost
- Never commit AWS access keys, passwords, private keys, or real `terraform.tfvars` values.
- HTTP is not encrypted; this is a limited classroom demo, not production hosting.
- The security group limits inbound HTTP to one source IP. If your IP changes, update the CIDR.
- EC2, EBS, public IPv4, data transfer, and monitoring can incur charges. Destroy resources after collecting evidence.
- The first deployment uses a small EC2 type, but availability and cost depend on account and region.

## Evidence to collect (only after actual execution)
1. Terraform plan/validation output.
2. EC2 instance in running state and its security group.
3. Browser showing the deployed demo page.
4. Docker container and health-check output for the Python app once deployed.
5. A real failure/recovery test with timestamps; calculate TTR from observed times, not estimates.

## Remaining work for the full professor checklist
- Complete deployment of the Python app image (for example through Amazon ECR or a controlled build on EC2).
- Add CloudWatch logs/metrics/alarms and explain the selected AWS services.
- Execute a container-failure test, record detection/diagnosis/recovery/verification timestamps, and calculate measured TTR.
- Run a small performance test and report observed latency/throughput.
- Fill in SLA targets as project targets and clearly distinguish them from measured results.
