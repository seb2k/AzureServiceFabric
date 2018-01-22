Select-AzureRmSubscription -SubscriptionId ""
#New-AzureRmResourceGroup -Name RGServiceFabric -Location northcentralus

$clusterName = "asfgraefdev"
$clusterLocation = "westeurope"
$existingVNetRGName = "Existing-VNetRG"
$existingVNetName = "Existing-VNet"
$subnet0Name = "Subnet-0"
$subnet0Prefix = "10.43.116.46/27"
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

$additionalParameters['existingVNetRGName'] = $existingVNetRGName
$additionalParameters['existingVNetName'] = $existingVNetName
$additionalParameters['subnet0Name'] = $subnet0Name
$additionalParameters['subnet0Prefix'] = $subnet0Prefix

$additionalParameters['sourceVaultValue'] = $sourceVaultValue
$additionalParameters['certificateThumbprint'] = $certificateThumbprint
$additionalParameters['certificateUrlValue'] = $certificateUrlValue
$additionalParameters['reverseProxyCertificateThumbprint'] = $reverseProxyCertificateThumbprint
$additionalParameters['reverseProxyCertificateUrlValue'] = $reverseProxyCertificateUrlValue

$additionalParameters['aadTenantId'] = $aadTenantId
$additionalParameters['aadClusterApplication'] = $aadClusterApplication
$additionalParameters['aadClientApplication'] = $aadClientApplication

New-AzureRmResourceGroupDeployment -Name "$clusterName-deployment" -ResourceGroupName RGServiceFabric -TemplateFile .\azuredeploy.json @additionalParameters -Verbose -Force