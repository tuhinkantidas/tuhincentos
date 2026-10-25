# ACC Mini Project — Azure Cloud Application Reliability and Recovery

## Scope
A small cloud reliability demo using Azure Virtual Machines, Terraform, Docker, and an HTTP health-check endpoint. It is intended as a starting implementation for the ACC presentation, not evidence of a completed test until you deploy and record results.

## Architecture
- Azure Resource Group: lifecycle boundary for demo resources
- Azure Virtual Network and subnet: private network placement
- Network Security Group: inbound HTTP only from your specified public IP (/32)
- Azure Linux VM (Ubuntu 22.04): virtualized compute
- Docker: packages and runs the Python HTTP health-check application
- Azure Monitor / Log Analytics: add and configure during the monitoring stage; not yet provisioned by this starter

## Prerequisites
- Azure subscription with permission to create resource groups, VMs, networking, and managed disks
- Terraform 1.5+ and Azure CLI installed locally
- SSH key pair; supply the public key only
- Check current Azure VM quota, regional availability, and pricing

## Deploy
1. Log in: `az login`
2. Choose the correct subscription: `az account set --subscription "<subscription-id>"`
3. Change to this directory: `cd acc-project-azure/terraform`
4. Copy `terraform.tfvars.example` to `terraform.tfvars`.
5. Replace `admin_ssh_public_key` with your public SSH key and `allowed_http_cidr` with your current public IPv4 address followed by `/32`. Never use `0.0.0.0/0` for inbound access.
6. Run `terraform init`, `terraform fmt -recursive`, `terraform validate`, and `terraform plan`.
7. Review the plan. If correct and you accept the cost, run `terraform apply`.
8. After cloud-init finishes, open the Terraform output `application_url`. The page should show the ACC demo message. Check `http://<public-ip>/health` for JSON health output.

## Failure and recovery experiment
After confirming deployment and collecting a baseline, connect by SSH from an allowed network and run `sudo docker stop acc-healthcheck`. Observe the health endpoint failing. Then run `sudo docker start acc-healthcheck` and measure elapsed time from failure detection to successful HTTP 200 verification. Record timestamps and repeat a few times. Do not claim an SLA or TTR result until measured.

## Monitoring work still required
Create a Log Analytics workspace and enable Azure Monitor Agent / VM insights (or another approved Azure Monitor configuration). Capture real CPU/network metrics and logs, then document alert conditions and evidence. The current starter does not configure those resources automatically.

## Cleanup
From this directory run `terraform destroy` and review the plan before confirming. Then check Azure Portal for remaining resources. Deleting the resource group also deletes all resources inside it. Stop/delete resources promptly after evidence collection to limit charges.

## Security and cost
- Public HTTP is unencrypted and only intended for this controlled class demo. The NSG restricts it to your current IP.
- SSH access is not opened in the NSG by this template; use Azure Bastion or add a carefully restricted SSH rule from your IP if needed for the failure test, then remove it afterward.
- Do not commit `terraform.tfvars`, private SSH keys, credentials, or secrets.
- VM compute, disks, public IP, monitoring ingestion, and data transfer can incur charges.
- A target SLA is not the same as a measured result. Report actual observations and limitations.

## Five-slide evidence
1. Industry problem, objective, and architecture.
2. Azure services and Docker/VM virtualization design.
3. Terraform plan/apply and Azure VM running state.
4. App health endpoint, failure/recovery timestamps, and measured TTR.
5. Azure Monitor evidence, small performance test, security/cost notes, and conclusion.

## Status
Starter files added; not yet deployed or validated in the user's subscription. Monitoring, performance testing, and measured recovery evidence must be completed before submission.
