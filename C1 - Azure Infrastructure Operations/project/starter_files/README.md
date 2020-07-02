# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started

#### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

#### Instructions
1. You can use the file server.json to create the image. Make sure to add the below mentioned in the server.json file before executing it
    
    Azure subscription vars

    subscription_id 
    client_id 
    client_secret
    tenant_id

    Then run `packer build server.json` to build the image. 
    You can also use `packer validate server.json` to validate the file

2. Change the below mentioed two values in the terraform.tfvars file
    
    VirtualMachineCount: this controls the number of VM machines that will be spawned
    vm_count=2

    This is generated from the `packer build server.json` output.
    packer_image_id = "/subscriptions/<id>/resourceGroups/<resoruce_group>/providers/Microsoft.Compute/images/UdaPackerImage"

3. Then run `terraform init` to initialize the terraform 
4. `terrafrom plan`
5. `terrafrom apply --auto-approve` to spin the infra
6. `terrafrom destory --auto-approve` to destory the infra

#### Output

 11 resoruces will be created apart from the number of VMs you create.

