# AzureServiceFabric

Here are the steps for everybody who wants to kick up an Azure Service Fabric Cluster.

1.Invoke-AddCertToKeyVault.ps1 - It creates a KeyVault in a separate resource group, generates one or more certificates (Cluster Authentication and ReverseProxy) and outputs the needed CertificateThumbprint, SourceVault and CertificateURL for the template. It also enables the KeyVault for deployment which the vm instances need.

2.	Optional for AAD Integration: SetupApplications.ps1 from AAD Helper - It registers your Cluster Application in your AAD and outputs the needed tenantId, clusterApplicationId and clientApplicationId. The tenantId needed for SetupApplications.ps1 can be retrieved with the help of Get-AzureRmSubscription. You can use my Register-ClusterApplication.ps1 if you want.

3.	Deploy cluster using Azure Portal or an ARM template with the help of PowerShell. You can use psDeploy.ps1 for that.

The New-AzureRmServiceFabricCluster.ps1 makes it more easier, you don't need a template for it, just execute and lean beack.
