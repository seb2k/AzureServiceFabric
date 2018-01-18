Select-AzureRmSubscription -SubscriptionId ""
New-AzureRmResourceGroup -Name RGServiceFabric -Location westeurope

$password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("asdQ2sdsYW11asdY2hpdGEyMasdDE3"))
$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$additionalParameters = New-Object -TypeName Hashtable
$additionalParameters['adminPassword'] = $securePassword

New-AzureRmResourceGroupDeployment -Name deployment `
-ResourceGroupName RGServiceFabric `
-TemplateFile .\template.json `
-TemplateParameterFile .\parameters.json @additionalParameters `
-Verbose -Force
