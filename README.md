# AnsibleTerraform
Repo for testing Ansible and Terraform with Azure deployments.

# Ansible Tower Configuration
## Add vars to Ansible Tower template
Add the below vars to the Ansible Tower template:
* subscription_id: "xxxxxxxx-xxxxxxxx-xxxxxxxx"
* client_id: "xxxxxxxx-xxxxxxxx-xxxxxxxx"
* tenant_id: "xxxxxxxx-xxxxxxxx-xxxxxxxx"
* client_secret: "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
* managementIP: "123.123.123.123/32"

## Create inventory 
Create inventory with hosts, groups and variables as per 
production.yml or development.yml.

## Configure template with inventory
Configure the Ansible Tower template to use the correct 
inventory (production or development).