param location string
param suffix string
param apimSubnetId string
@secure()
param publisherEmail string
@secure()
param publisherName string

resource pip 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: 'pip-apim-${suffix}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'    
  }
}

resource apimName_resource 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
  name: 'apim-${suffix}'
  location: location
  sku:{
    capacity: 1
    name: 'Developer'
  }
  properties:{    
    virtualNetworkType: 'External'
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
    publicIpAddressId: pip.id
  }
}
