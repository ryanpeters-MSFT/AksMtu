# Adjusting MTU on AKS Nodes

This example will adjust the MTU of nodes in an AKS cluster. This requires that accelerated networking is enabled for the VM SKU (e.g., Standard_D8s_v6). 

The **[mtu.yaml](./mtu.yaml)** will invoke the command `ip link set dev eth0 mtu 9000 && sleep infinity` to set the MTU to 9000 for the `eth0` network adapter.

## View SKUs with Accelerated Networking

If necessary, determine which SKUs support accelerated networking and adjust the **[setup.ps1](./setup.ps1)** script accordingly.

```powershell
az vm list-skus `
  --location eastus2 `
  --all true `
  --resource-type virtualMachines `
  --query "[? capabilities[?name=='AcceleratedNetworkingEnabled'].value | [0] == 'True'].{size:size, name:name, acceleratedNetworkingEnabled: capabilities[?name=='AcceleratedNetworkingEnabled'].value | [0]}" `
  --output table
```

## Quickstart

```powershell
# run setup
.\setup.ps1

#run the MTU daemonset to configure the MTU
kubectl apply -f .\mtu.yaml
```

Create a pod and verify the MTU has changed:

```powershell
# verify the MTU
kubectl run netshoot --image=nicolaka/netshoot -it --rm --restart=Never -- ip link
```

To test using `ping`:

```powershell
# get IP of one of the MTU Daemonset pods
kubectl get pods -l name=mtu-adjuster -n kube-system -o jsonpath='{range .items[0]}{.status.podIP}{"\n"}{end}'

# ping the MTU pod from the netshoot pot
kubectl run netshoot --image=nicolaka/netshoot -it --rm --restart=Never -- ping -M do -s 8900 10.0.0.4
```

Helpful commands if using another container image.

```powershell
# install ping utils
apt update && apt install iputils-ping -y

# install ip from apt
apt update && apt install iproute2 -y

# ping another pod
ping 10.0.0.4 -s 3870 -M do
```

## Links
- [Performance Tuning AKS for Network Intensive Workloads](https://blog.aks.azure.com/2025/07/25/network-perf-aks)