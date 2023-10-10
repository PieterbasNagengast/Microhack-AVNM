// example bicep parameters file 
using './main.bicep'

param ipAddressSpace = '10.0.0.0/8'
param resourceGroupName = 'rg-microhack'
param tagsByResource = {}
param vmsize = 'Standard_b2s'
param adminUsername = ''
param adminPassword = ''
param HubNetworks = [
  {
    region: 'WestEurope'
    name: 'Hub1'
    deployBastion: false
    deployGateway: false
    deployVM: true
    osType: 'Windows'
  }
  {
    region: 'NorthEurope'
    name: 'Hub2'
    deployBastion: false
    deployGateway: false
    deployVM: false
    osType: 'none'
  }
]
param SpokeNetworks = [
  {
    region: 'WestEurope'
    deployVM: false
    prefix: 'SpokeWE'
    amount: 2
    osType: 'none'
  }
  {
    region: 'NorthEurope'
    deployVM: true
    prefix: 'SpokeNE'
    amount: 4
    osType: 'Linux'
  }
]
