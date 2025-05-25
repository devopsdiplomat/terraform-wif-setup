# Terraform Workload Identity Provider setup

Run the below commands locally to setup WIF using Terraform
```
# You should have Gcloud CLI and Terraform installed locally already.

gcloud auth login
gcloud config set project YOUR_PROJECT_ID

terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID" -var="project_number=YOUR_PROJECT_NUMBER" -var="github_repo=myorg/myrepo"
```
