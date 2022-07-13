param servers_juhohesql_name string = 'juhohesql'
param location string = 'northeurope'

@secure()
param password string

resource juhohesql 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: servers_juhohesql_name
  location: location
  properties: {
    administratorLogin: 'juhohe'
    administratorLoginPassword: password
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource juhohedb 'Microsoft.Sql/servers/databases@2017-10-01-preview' = {
  name: 'juhohedb'
  location: location
  sku: {
    capacity: 1
    family: 'Gen5'
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
  }
  parent: juhohesql
  properties: {
    autoPauseDelay: 60
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
    maxSizeBytes: 34359738368
    minCapacity: json('0.5')
    readScale: 'Disabled'
    sampleName: 'AdventureWorksLT'
    zoneRedundant: false
  }
}

resource juhoheWebAppPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'juhohewebappplan'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
  kind: 'linux'
}

resource juhoheWebApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'juhohewebapp'
  location: location
  properties: {
    serverFarmId: juhoheWebAppPlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|6.0'
    }
  }
}

resource juhoheFuncAppStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: 'juhohefuncappsa'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

resource juhoheFuncAppPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'juhohefuncappplan'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
  kind: 'linux'
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: 'juhohefuncapp'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: juhoheFuncAppPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${juhoheFuncAppStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${juhoheFuncAppStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${juhoheFuncAppStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${juhoheFuncAppStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower('juhohefuncapp')
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~10'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource juhohe1VirtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'juhohe1vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'webappsubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'pe1subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}
