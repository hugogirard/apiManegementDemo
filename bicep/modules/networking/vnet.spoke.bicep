param location string
param vnetConfiguration object

resource nsgApim 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: 'nsg-apim'
  location: location
  properties: {
      securityRules: [
        {
          name: 'apim-mgmt-endpoint-for-portal'
          properties: {
            priority: 2000
            sourceAddressPrefix: 'ApiManagement'
            protocol: 'Tcp'
            destinationPortRange: '3443'
            access: 'Allow'
            direction: 'Inbound'
            sourcePortRange: '*'
            destinationAddressPrefix: 'VirtualNetwork'
          }
        }
        {
          name: 'apim-azure-infra-lb'
          properties: {
            priority: 2010
            sourceAddressPrefix: 'AzureLoadBalancer'
            protocol: 'Tcp'
            destinationPortRange: '6390'
            access: 'Allow'
            direction: 'Inbound'
            sourcePortRange: '*'
            destinationAddressPrefix: 'VirtualNetwork'
          }
        }
        {
          name: 'apim-azure-storage'
          properties: {
            priority: 2000
            sourceAddressPrefix: 'VirtualNetwork'
            protocol: 'Tcp'
            destinationPortRange: '443'
            access: 'Allow'
            direction: 'Outbound'
            sourcePortRange: '*'
            destinationAddressPrefix: 'Storage'
          }
        }
        {
          name: 'apim-azure-sql'
          properties: {
            priority: 2010
            sourceAddressPrefix: 'VirtualNetwork'
            protocol: 'Tcp'
            destinationPortRange: '1433'
            access: 'Allow'
            direction: 'Outbound'
            sourcePortRange: '*'
            destinationAddressPrefix: 'SQL'
          }
        }
        {
          name: 'apim-azure-kv'
          properties: {
            priority: 2020
            sourceAddressPrefix: 'VirtualNetwork'
            protocol: 'Tcp'
            destinationPortRange: '443'
            access: 'Allow'
            direction: 'Outbound'
            sourcePortRange: '*'
            destinationAddressPrefix: 'AzureKeyVault'
          }
        }        
      ]
  }
}

resource appGatewayNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'appgw-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'HealthProbes'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_TLS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 111
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_AzureLoadBalancer'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetConfiguration.spoke.name
  location: location
  properties: {
      addressSpace: {
          addressPrefixes: [
              vnetConfiguration.spoke.addressPrefixes
          ]
      }
      subnets: [
          {
              name: 'snet-appgw'
              properties: {
                  addressPrefix: vnetConfiguration.subnets[1].addressPrefix
                  networkSecurityGroup: {
                     id: appGatewayNSG.id
                  }
              }
          }
          {
              name: 'snet-apim'
              properties: {
                  addressPrefix: vnetConfiguration.subnets[2].addressPrefix
                  networkSecurityGroup: {
                    id: nsgApim.id
                 }                  
              }
          }       
      ]
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
