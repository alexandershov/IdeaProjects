## Terraform

Terraform is an infrastructure as code solution.

It allows you to describe the desired state of your infra (e.g. "I want 5 t2.micro instances with the ami=X")
and terraform will bring the actual state of your infra to your desired state.

Terraform works with AWS/GCP/Azure via providers.

Install Terraform
```shell
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

Install [aws cli tool](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Format `*.tf` files
```shell
terraform fmt
```

Export `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

Init Terraform (this will use [tutorial.tf](./tutorial.tf) file)
```shell
terraform init
```

`terraform init` will create `.terraform.lock.hcl` file which pins provider/dependencies versions.

Apply current state
```shell
terraform apply
```

By default, Terraform stores current state in the local file `terraform.tfstate`. 
You can change storage method.
State can contain sensitive information, so don't share it in plain text.

Inspect current state
```shell
terraform show
```

Terminates resources managed by terraform.
This will kill all ec2 instances created after `terraform apply`
```shell
terraform destroy
```

