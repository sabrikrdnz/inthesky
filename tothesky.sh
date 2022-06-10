#!/bin/bash
# Checking Terraform is installed or not
echo "---- TERRAFORM CHECK ----"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    TF_CHECK="terraform"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $TF_CHECK|grep "install ok installed")
    echo Checking for $TF_CHECK: $PKG_OK
    if [ "" = "$PKG_OK" ]; then
    
    echo "No $TF_CHECK. Setting up $TF_CHECK."
    echo "//////////"

    # ensure that system is up to date and we have required packages on system
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
    # add hashicorp gpg key
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    # add official hashicorp linux repository
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    # update to add the repository and install terraform cli
    sudo apt-get update && sudo apt-get install terraform
    fi

elif [[ "$OSTYPE" == "darwin"* ]]; then
    # install the HashiCorp tap, repository of Hashicorp homebrew packages
    brew tap hashicorp/tap
    # install terraform with hashicorp/tap/terraform
    brew install hashicorp/tap/terraform

    # update latest of terraform but first update homebrew
    brew update
    # now update terraform
    brew upgrade hashicorp/tap/terraform

else
        echo "You should use Linux or MacOSx!"
fi

echo "---- ANSIBLE CHECK ----"

# Checking Ansible is installed or not
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ANS_CHECK="ansible"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $ANS_CHECK|grep "install ok installed")
    echo Checking for $ANS_CHECK: $PKG_OK
    if [ "" = "$PKG_OK" ]; then
    
    echo "No $ANS_CHECK. Setting up $ANS_CHECK."
    echo "//////////"

    # installing ansible
    sudo apt install ansible
    fi

elif [[ "$OSTYPE" == "darwin"* ]]; then
    # now install ansible
    brew install ansible

else
        echo "You should use Linux or MacOSx!"
fi

# executing terraform plan
echo Executing Terraform Plan!
echo Initializing Terraform
#terraform init

# Running Terraform plan to check main.tf and creating tfplan file
terraform plan -out main.tfplan

# Now applying the tfplan file
terraform apply main.tfplan

# tooking the key from output to connect our vm
terraform output -raw tls_private_key > id_rsa

# changing permissions of key
chmod 400 id_rsa

# checking public adress of our vm
terraform output public_ip_address

export PUB_IP=$(terraform output public_ip_address | tr -d '"')
echo $PUB_IP | tr -d '"' > ansible/inventory
echo Public IP of VM: $PUB_IP

echo "waiting to vm up"
sleep 10

# Disable host key checking for ansible
export ANSIBLE_HOST_KEY_CHECKING=False

# running ansible playbook
echo "Running Ansible Playbook! TO THE SKYYYY!"
ansible-playbook -i ansible/inventory ansible/playbook.yml

echo "You can access your service from the following ip address:"
echo "http://$PUB_IP"

echo "DONE!"