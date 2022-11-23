param location string
param suffix string
// param apimSubnetId string
// @secure()
// param publisherEmail string
// @secure()
// param publisherName string

resource pip 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: 'pip-apim-${suffix}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'    
  }
}

// resource apimName_resource 'Microsoft.ApiManagement/service@2020-12-01' = {
//   name: 'apim-${suffix}'
//   location: location
//   sku:{
//     capacity: 1
//     name: 'Developer'
//   }
//   properties:{    
//     virtualNetworkType: 'Internal'
//     publisherEmail: publisherEmail
//     publisherName: publisherName
//     virtualNetworkConfiguration: {
//       subnetResourceId: apimSubnetId
//     }
//   }
// }
