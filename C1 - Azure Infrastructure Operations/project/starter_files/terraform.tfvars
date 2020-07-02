# Azure subscription vars
subscription_id = "" 
client_id = ""
client_secret = ""
tenant_id = ""

# Resource Group/Location
location = "EAST US"
resource_group = "UdaResourceGrouptf"
application_type = "webApp"

# Network
virtual_network_name = "udacity"
address_space = ["10.5.0.0/16"]
address_prefix_test = ["10.5.1.0/24"]

#VirtualMachineCount
vm_count=2

#image_id
packer_image_id = "/subscriptions/<id>/resourceGroups/UdaResourceGroup/providers/Microsoft.Compute/images/UdaPackerImage"