param location string
param name string
param addressPrefixes array
param nsgID string
param deployBastion bool = false
param deployGateway bool = false
param tagsByResource object = {}

var defaultSubnet = [ {
    name: 'default'
    properties: {
      addressPrefix: cidrSubnet(addressPrefixes[0], 26, 0)
      networkSecurityGroup: {
        id: nsgID
      }
    }
  } ]

var bastionSubnet = deployBastion ? [ {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefix: cidrSubnet(addressPrefixes[0], 26, 1)
    }
  } ] : []

var gatewaySubnet = deployGateway ? [ {
    name: 'GatewaySubnet'
    properties: {
      addressPrefix: cidrSubnet(addressPrefixes[0], 26, 2)
    }
  } ] : []

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: concat(defaultSubnet, bastionSubnet, gatewaySubnet)
  }
  tags: contains(tagsByResource, 'Microsoft.Network/virtualNetworks') ? tagsByResource['Microsoft.Network/virtualNetworks'] : {}
}

output id string = vnet.id
output defaultSubnetID string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnet.name, 'default')
output bastionSubnetID string = deployBastion ? resourceId('Microsoft.Network/VirtualNetworks/subnets', vnet.name, 'AzureBastionSubnet') : 'Not deployed'
output gatewaySubnetID string = deployGateway ? resourceId('Microsoft.Network/VirtualNetworks/subnets', vnet.name, 'GatewaySubnet') : 'Not deployed'
