param location string
param name string
param subnetID string
param SKU string = 'VpnGw1'
param GatewayType string = 'Vpn'
param GatewayVPNtype string = 'RouteBased'
param GatewayGen string = 'Generation1'
param tagsByResource object = {}

var pipName = '${name}-pip'

resource vpngw 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = {
  name: name
  location: location
  properties: {
    gatewayType: GatewayType
    vpnType: GatewayVPNtype
    sku: {
      name: SKU
      tier: SKU
    }
    vpnGatewayGeneration: GatewayGen
    activeActive: false
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetID
          }
          publicIPAddress: {
            id: vpngwpip.id
          }
        }
      }
    ]
  }
  tags: contains(tagsByResource, 'Microsoft.Network/virtualNetworkGateways') ? tagsByResource['Microsoft.Network/virtualNetworkGateways'] : {}
}

resource vpngwpip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: pipName
  location: location
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    tier: 'Regional'
    name: 'Standard'
  }
  tags: contains(tagsByResource, 'Microsoft.Network/publicIPAddresses') ? tagsByResource['Microsoft.Network/publicIPAddresses'] : {}
}

output pip string = vpngwpip.properties.ipAddress
output id string = vpngw.id
output name string = vpngw.name
