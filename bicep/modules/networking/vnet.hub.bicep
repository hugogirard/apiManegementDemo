param vnetConfiguration object
param location string


resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetConfiguration.hub.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetConfiguration.hub.addressPrefix
      ]
    }
    subnets: [
      {
        name: vnetConfiguration.subnets[0].name
        properties: {
          addressPrefix: vnetConfiguration.subnets[0].addressPrefix
        }
      }                  
    ]
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
