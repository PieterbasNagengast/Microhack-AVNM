param location string
param name string
@secure()
param adminUsername string
@secure()
param adminPassword string
param subnetID string
param vmSize string
param storageType string = 'StandardSSD_LRS'
param osType string = 'Windows'
param tagsByResource object = {}

var Windows = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-datacenter-g2'
  version: 'latest'
}

var Linux = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}

var imagereference = osType == 'Windows' ? Windows : osType == 'Linux' ? Linux : {}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: name
  location: location
  properties: {
    osProfile: {
      computerName: take(name, 15)
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: imagereference
      osDisk: {
        createOption: 'FromImage'
        name: '${name}-osDisk'
        managedDisk: {
          storageAccountType: storageType
        }
        osType: osType
        deleteOption: 'Delete'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  tags: contains(tagsByResource, 'Microsoft.Compute/virtualMachines') ? tagsByResource['Microsoft.Compute/virtualMachines'] : {}
}

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetID
          }
        }
      }
    ]
  }
  tags: contains(tagsByResource, 'Microsoft.Compute/virtualMachines') ? tagsByResource['Microsoft.Compute/virtualMachines'] : {}
}

output id string = vm.id
