# ACC Mini Project — Azure Cloud Application Reliability and Recovery

## Goal
Deploy a small Python HTTP service to an Azure Linux VM using Terraform and Docker, then demonstrate health checks and a basic failure/recovery experiment.

## Architecture
- Azure Resource Group, Virtual Network, subnet, and Network Security Group
- Ubuntu 22.04 Linux VM with a static public IP
- Docker image built from `app/app.py` and `app/Dockerfile`
- HTTP on port 80 forwarded to the container on port 8080
- `GET /health` returns JSON with service status and uptime

## Current deployment notes
The Azure infrastructure was successfully created in the **East Asia** region in resource group `rg-tuhin-acc-project`. The VM name is `tuhin-acc-project-vm`.

The first cloud-init attempt failed at the Git clone step because the repository was private at that time. The repository has since been made public and the cloud-init script in this branch has been updated to log its work to `/var/log/acc-cloud-init.log`, build the image, start the container, and check the local health endpoint. **Changing this file in GitHub does not rerun cloud-init on an already-created VM.** The existing VM's app endpoint must be deployed/restarted separately or the VM must be recreated from the updated configuration. Do not report the app as working until `/health` returns HTTP 200.

## Prerequisites
- Azure subscription with permission to create networking, a Linux VM, and a managed disk
- Azure CLI and Terraform 1.5+ installed locally
- SSH key pair; provide only the public key
- A subscription-approved Azure region, available VM size, and sufficient quota

## Deploy
1. Run `az login` and select the intended subscription.
2. Change to `acc-project-azure/terraform`.
3. Copy `terraform.tfvars.example` to `terraform.tfvars`.
4. Set `admin_ssh_public_key` to the public key contents and `allowed_http_cidr` to your current public IPv4 followed by `/32`.
5. Run `terraform init`, `terraform fmt -recursive`, `terraform validate`, and `terraform plan`.
6. Review the plan and costs, then run `terraform apply` if correct.
7. Wait for cloud-init to finish. Open the `application_url` output and test `http://<public-ip>/health`.

Never commit `terraform.tfvars`, private keys, credentials, Terraform state, provider binaries, or local plan files.

## Application checks
- Home endpoint: `GET /` returns a short project message.
- Health endpoint: `GET /health` returns JSON such as `{"status":"ok","uptime_seconds":12}`.
- The Docker image has a container health check. The startup script also probes the endpoint locally before reporting success.

## Failure and recovery experiment
After confirming the endpoint works, record a baseline response and timestamp. Stop the container, observe the health check fail, restart it, and record the time until HTTP 200 returns. Repeat a few times and report the actual observed recovery times. Do not invent an SLA or recovery result.

The current template does not open SSH inbound in the NSG. Use Azure Run Command or a deliberately restricted temporary SSH rule if needed; remove temporary access after the experiment. The repeatable experiment script is `terraform/recovery-experiment.sh`. Run it on the VM only after the app is healthy: `bash recovery-experiment.sh`. It stops and restarts the demo container three times by default and writes measured timestamps and recovery durations to `recovery-results.csv`. It deliberately records observed values rather than assuming a target recovery time.

## Automated code checks
A GitHub Actions workflow (`.github/workflows/azure-project-ci.yml`) runs on project changes and pull requests. It tests the `/` and `/health` endpoints, builds the Docker image, checks Terraform formatting, and runs `terraform validate`. These checks validate code; they do not prove that the live Azure VM is reachable.

## Monitoring and evidence
Azure Monitor / Log Analytics resources are **not** provisioned by this starter. If time permits, configure monitoring separately and capture real VM metrics/logs. Do not claim monitoring is configured unless you have evidence.

Suggested five slides:
1. Problem statement, objective, and architecture.
2. Azure VM, VNet/NSG, Terraform, and Docker design.
3. Terraform plan/apply and VM running evidence.
4. `/health` response and measured failure/recovery experiment.
5. Monitoring evidence (if configured), security/cost considerations, limitations, and conclusion.

## Cleanup
Review the Terraform destroy plan carefully before cleanup. Destroying the dedicated resource group removes its resources. Check the Azure Portal for any leftovers and stop/delete resources promptly after evidence collection to limit charges.

## Security and cost notes
- Public HTTP is unencrypted and intended only for this controlled class demo; inbound HTTP is restricted to the configured source IP.
- VM compute, OS disk, public IP, monitoring ingestion, and data transfer may incur charges.
- The target SLA is not a measured result. Report only observations actually collected.
