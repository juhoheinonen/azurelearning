param servers_juhohesql_name string = 'juhohesql'
param location string = 'northeurope'

@secure()
param password string

resource servers_juhohesql_name_resource 'Microsoft.Sql/servers@2021-11-01-preview' = {
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
  parent: servers_juhohesql_name_resource
  properties: {
    autoPauseDelay: 60
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
    longTermRetentionBackupResourceId: 'string'
    maxSizeBytes: 34359738368
    minCapacity: json('0.5')
    readScale: 'Disabled'
    sampleName: 'AdventureWorksLT'
    zoneRedundant: false
  }
}
