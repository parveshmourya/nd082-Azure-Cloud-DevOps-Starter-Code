# Azure GUIDS
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

# Resource Group/Location
variable "location" {
    description = "The location where resources are created"
    default     = "East US"
}
variable "resource_group" {}
variable "application_type" {}

# Network
variable "virtual_network_name" {}
variable "address_prefix_test" {}
variable "address_space" {}

#
variable "vm_count" {
    description = "The count of the number of VMs to be created"
    default     = "2"
}

variable "packer_image_id" {
    description = "The image id for the packer custom image"
    default = "/subscriptions/<id>/resourceGroups/UdaResourceGroup/providers/Microsoft.Compute/images/UdaPackerImage"
}
