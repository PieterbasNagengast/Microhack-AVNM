targetScope = 'subscription'

param ipAddressSpace string
param location string = deployment().location
param resourceGroupName string
param tagsByResource object = {}

// define the vm size
param vmsize string = 'Standard_b2s'

@secure()
param adminUsername string = ''

@secure()
param adminPassword string = ''

// // define the os type
// type _osType = 'Windows' | 'Linux' | 'none'

// // define the hub networks type
// type _Hubs = {
//   region: string
//   name: string
//   deployBastion: bool
//   deployGateway: bool
//   deployVM: bool
//   osType: _osType
// }[]

// // define the spoke networks type
// type _Spokes = {
//   region: string
//   prefix: string
//   amount: int
//   deployVM: bool
//   osType: _osType
// }[]

// define the hub networks
param HubNetworks array

// define the spoke networks
param SpokeNetworks array

// amount of the counts of all spoke networks
var amountOfNetworks = length(HubNetworks) + length(varSpokeNetworks)

// create the ip spaces for all networks
var ipSpaces = [for i in range(1, amountOfNetworks): cidrSubnet(ipAddressSpace, 24, i)]

// create array and flatten the spoke networks
var varSpokeNetworks = flatten(map(SpokeNetworks, spoke => map(range(0, int(spoke.amount)), i => {
        name: '${spoke.prefix}-${spoke.region}-${i}'
        region: spoke.region
        deployVM: spoke.deployVM
        osType: spoke.osType
      })
  )
)

// create the resource group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: contains(tagsByResource, 'Microsoft.Resources/subscriptions/resourceGroups') ? tagsByResource['Microsoft.Resources/subscriptions/resourceGroups'] : {}
}

// deploy the hub networks
module deployHubNetworks 'deployNetworks.bicep' = [for (hubNetwork, i) in HubNetworks: {
  scope: rg
  name: 'Deploy-Hub-${i}-${hubNetwork.region}'
  params: {
    name: hubNetwork.name
    location: hubNetwork.region
    addressPrefixes: array(ipSpaces[i])
    deployBastion: bool(hubNetwork.deployBastion)
    deployGateway: bool(hubNetwork.deployGateway)
    deployVM: bool(hubNetwork.deployVM)
    adminUsername: adminUsername
    adminPassword: adminPassword
    osType: string(hubNetwork.osType)
    vmSize: vmsize
    tagsByResource: tagsByResource
  }
}]

// deploy the spoke networks
module deploySpokeNetworks 'deployNetworks.bicep' = [for (spokeNetwork, i) in varSpokeNetworks: {
  scope: rg
  name: 'Deploy-Spoke-${i}-${spokeNetwork.region}'
  params: {
    name: spokeNetwork.name
    location: spokeNetwork.region
    addressPrefixes: array(ipSpaces[i + length(HubNetworks)])
    deployVM: bool(spokeNetwork.deployVM)
    adminUsername: adminUsername
    adminPassword: adminPassword
    osType: string(spokeNetwork.osType)
    vmSize: vmsize
    tagsByResource: tagsByResource
  }
}]

output ipSpaces array = ipSpaces
output HubNetworks array = HubNetworks
output SpokeNetworks array = varSpokeNetworks
