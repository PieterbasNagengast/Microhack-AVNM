param location string
param name string
param tagsByResource object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: name
  location: location
  tags: contains(tagsByResource, 'Microsoft.Network/networkSecurityGroups') ? tagsByResource['Microsoft.Network/networkSecurityGroups'] : {}
}

output id string = nsg.id
