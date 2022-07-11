param location string = 'northeurope'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'learning-juho-heinonen'
  scope: subscription('')
}

resource juhohesql 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: 'juhohesql'
  location: location
}
