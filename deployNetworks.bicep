param location string
param name string
param addressPrefixes array
param deployBastion bool = false
param deployGateway bool = false
param tagsByResource object = {}
param deployVM bool = false
param vmSize string
param osType string
param bastionSku string = 'Standard'
param timeStamp string

@secure()
param adminUsername string

@secure()
param adminPassword string

module nsg 'modules/nsg.bicep' = {
  name: 'Deploy-NSG-${name}-${location}-${timeStamp}'
  params: {
    location: location
    name: '${name}-nsg-${location}'
    tagsByResource: tagsByResource
  }
}

module vnet 'modules/vnet.bicep' = {
  name: 'Deploy-VNET-${name}-${location}-${timeStamp}'
  params: {
    addressPrefixes: addressPrefixes
    location: location
    name: '${name}-vnet-${location}'
    deployBastion: deployBastion
    deployGateway: deployGateway
    tagsByResource: tagsByResource
    nsgID: nsg.outputs.id
  }
}

module vm 'modules/vm.bicep' = if (deployVM) {
  name: 'Deploy-VM-${name}-${location}-${timeStamp}'
  params: {
    location: location
    name: '${name}-vm-${location}'
    tagsByResource: tagsByResource
    subnetID: vnet.outputs.defaultSubnetID
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
    osType: osType
  }
}

module bastion 'modules/bastion.bicep' = if (deployBastion) {
  name: 'Deploy-Bastion-${name}-${location}-${timeStamp}'
  params: {
    location: location
    name: '${name}-bastion-${location}'
    tagsByResource: tagsByResource
    subnetID: deployBastion ? vnet.outputs.bastionSubnetID : ''
    bastionSku: bastionSku
  }
}

module gateway 'modules/gateway.bicep' = if (deployGateway) {
  name: 'Deploy-Gateway-${name}-${location}-${timeStamp}'
  params: {
    location: location
    name: '${name}-gateway-${location}'
    tagsByResource: tagsByResource
    subnetID: deployGateway ? vnet.outputs.gatewaySubnetID : ''
  }
}
