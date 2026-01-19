using './vnet.bicep'

// TODO(mloskot): Move to https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/patterns-shared-variable-file
param nsgName = 'nsg-minikube-ci'
param vnetName = 'vnet-minikube-ci'
