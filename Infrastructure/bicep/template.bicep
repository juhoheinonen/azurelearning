param servers_juhohesql_name string = 'juhohesql'
param location string = 'northeurope'
@secure()
param password string

resource servers_juhohesql_resource 'Microsoft.Sql/servers@2021-11-01-preview' = {
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
