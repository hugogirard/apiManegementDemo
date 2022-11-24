targetScope='subscription'

@description('The location of the Azure resources')
param location string

@description('The name of the Azure resource group for the spoke')
param resourceGroupNameSpoke string

@description('The name of the Azure resource group for the hub')
param resourceGroupNameHub string

@description('The configuration of all virtual networks')
param vnetConfiguration object

@secure()
param publisherEmail string

@secure()
param publisherName string

var spokeSuffix = uniqueString(spokeRg.id)

resource hubRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupNameHub
  location: location
}

resource spokeRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupNameSpoke
  location: location
}

module vnetHub 'modules/networking/vnet.hub.bicep' = {
  scope: resourceGroup(hubRg.name)
  name: 'vnetHub'
  params: {
    location: location
    vnetConfiguration: vnetConfiguration    
  }
}

module vnetSpoke 'modules/networking/vnet.spoke.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'vnetSpoke'
  params: {
    location: location
    vnetConfiguration: vnetConfiguration    
  }
}

module apim 'modules/apim/apim.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'apim'
  params: {
    location: location 
    suffix: spokeSuffix
    apimSubnetId: vnetSpoke.outputs.subnetId
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

module kv 'modules/vault/keyvault.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'kv'
  params: {
    location: location
    suffix: spokeSuffix
  }
}

output apimName string = apim.outputs.apimName
output spokeRgName string = spokeRg.name
