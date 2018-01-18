$subscriptionId = ""
$certpwd ="ksdf3kYlKIvJiw7sfdsfxWuS9eP" | ConvertTo-SecureString -AsPlainText -Force
$certfolder = "."
$adminuser = "seb2k"
$adminpwd = "ksdf3kYlKIvJiw7sfdsfxWuS9eP" | ConvertTo-SecureString -AsPlainText -Force 
$clusterloc = "westeurope"
$clustername = "asfgraefdev"
$groupname = "RGServiceFabric"       
$vaultname = "asfgraefdevkv"
$vaultgroupname = "RGKeyVaultServiceFabric"
$subname = "$clustername.$clusterloc.cloudapp.azure.com"
$clustersize = 5
$vmsku = "Standard_D2"

Select-AzureRmSubscription -SubscriptionId $subscriptionId

New-AzureRmServiceFabricCluster -Name $clustername -ResourceGroupName $groupname -Location $clusterloc `
-ClusterSize $clustersize -VmUserName $adminuser -VmPassword $adminpwd -CertificateSubjectName $subname `
-CertificatePassword $certpwd -CertificateOutputFolder $certfolder `
-OS WindowsServer2016Datacenter -VmSku $vmsku -KeyVaultName $vaultname -KeyVaultResouceGroupName $vaultgroupname
