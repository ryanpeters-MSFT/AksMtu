$group = "rg-aks-mtu"
$vnet = "vnet"
$aksSubnet = "aks"
$clusterName = "mtucluster"

# create the resource group
az group create -n $group -l eastus2 --query id -o tsv

# create a vnet
az network vnet create -n $vnet -g $group --address-prefixes 10.0.0.0/16

# create subnets for AKS and ALB
$aksSubnetId = az network vnet subnet create `
    -n $aksSubnet -g $group `
    --vnet-name $vnet `
    --address-prefixes 10.0.0.0/24 `
    -o tsv --query id

# create the AKS cluster
az aks create -n $clusterName -g $group `
    --vnet-subnet-id $aksSubnetId `
    --network-plugin azure `
    --network-plugin-mode overlay `
    --node-vm-size Standard_D8s_v6 `
    --service-cidr 10.1.0.0/24 `
    --dns-service-ip 10.1.0.3 `
    --os-sku Ubuntu2404 `
    -c 2

# get AKS credentials
az aks get-credentials --resource-group $group --name $clusterName --overwrite-existing