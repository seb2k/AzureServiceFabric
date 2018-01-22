Select-AzureRmSubscription -SubscriptionId ""
#New-AzureRmResourceGroup -Name RGServiceFabric -Location northcentralus

$clusterName = "asfgraefdev"
$clusterLocation = "westeurope"
$sourceVaultValue = ""
$certificateThumbprint = ""
$certificateUrlValue = ""
$reverseProxyCertificateThumbprint = ""
$reverseProxyCertificateUrlValue = ""
$aadTenantId = ""
$aadClusterApplication = ""
$aadClientApplication = ""

$password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("Q2FsYW11Y2hpdGEyMDE3"))
$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$additionalParameters = New-Object -TypeName Hashtable
$additionalParameters['clusterName'] = $clusterName
$additionalParameters['clusterLocation'] = $clusterLocation

$additionalParameters['adminPassword'] = $securePassword

$additionalParameters['sourceVaultValue'] = $sourceVaultValue
$additionalParameters['certificateThumbprint'] = $certificateThumbprint
$additionalParameters['certificateUrlValue'] = $certificateUrlValue
$additionalParameters['reverseProxyCertificateThumbprint'] = $reverseProxyCertificateThumbprint
$additionalParameters['reverseProxyCertificateUrlValue'] = $reverseProxyCertificateUrlValue

$additionalParameters['aadTenantId'] = $aadTenantId
$additionalParameters['aadClusterApplication'] = $aadClusterApplication
$additionalParameters['aadClientApplication'] = $aadClientApplication

New-AzureRmResourceGroupDeployment -Name "$clusterName-deployment" -ResourceGroupName RGServiceFabric -TemplateFile .\azuredeploy.json @additionalParameters -Verbose -Force