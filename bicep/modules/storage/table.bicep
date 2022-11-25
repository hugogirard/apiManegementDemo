param location string
param suffix string

resource storageAccountDocument 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'str${suffix}'
  location: location
  sku: {
    name: 'Standard_LRS'    
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true    
    accessTier: 'Hot'
  }
}

resource lookupService 'Microsoft.Storage/storageAccounts/tableServices@2022-05-01' = {
  name: 'default'
  parent: storageAccountDocument
  properties: {
  }
}

resource lookupTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2022-05-01' = {
  name: 'lookup'
  parent: lookup
  properties: {
  }
}
