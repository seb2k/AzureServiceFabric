function Invoke-AddCertToKeyVault
{
    <#
    .SYNOPSIS
    Upload certificate to Azure KeyVault

    .DESCRIPTION
    This command takes an existing pfx or creates a new self-signed certificate and uploads it as a secret to Azure KeyVault. The output of this command should be used during creation of secure cluster
    through portal or for adding new certificates on VMs provisioned by Compute Resource Provider

    .PARAMETER
    .PARAMETER
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>

    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true)]
      [string] $SubscriptionId,

      #[Parameter(Mandatory=$true)]
      [string] $ResourceGroupName,

      [Parameter(Mandatory=$true)]
      [string] $Location,

      [Parameter(Mandatory=$true)]
      [string] $VaultName,

      [Parameter(Mandatory=$true)]
      [string] $CertificateName,
   
      [Parameter(Mandatory=$true)]
      [string] $Password,   

      [Parameter(Mandatory=$true, ParameterSetName="CreateNewCertificate")]
      [switch] $CreateSelfSignedCertificate,

      [Parameter(Mandatory=$true, ParameterSetName="CreateNewCertificate")]
      [string] $DnsName,

      [Parameter(Mandatory=$true, ParameterSetName="CreateNewCertificate")]
      [string] $OutputPath,

      [Parameter(Mandatory=$true, ParameterSetName="UseExistingCertificate")]
      [switch] $UseExistingCertificate,

      [Parameter(Mandatory=$true, ParameterSetName="UseExistingCertificate")] 
      [string] $ExistingPfxFilePath
    )

    $ErrorActionPreference = 'Stop'

    Write-Host "Switching context to SubscriptionId $SubscriptionId"
    Set-AzureRmContext -SubscriptionId $SubscriptionId | Out-Null

    # New-AzureRmResourceGroup is idempotent as long as the location matches
    Write-Host "Ensuring ResourceGroup $ResourceGroupName in $Location"
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Force | Out-Null
    $resourceId = $null

    try
    {
        $existingKeyVault = Get-AzureRmKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroupName
        $resourceId = $existingKeyVault.ResourceId

        Write-Host "Using existing valut $VaultName in $($existingKeyVault.Location)"
    }
    catch
    {
    }

    if(!$existingKeyVault)
    {
        Write-Host "Creating new vault $VaultName in $location"
        $newKeyVault = New-AzureRmKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroupName -Location $Location -EnabledForDeployment
        $resourceId = $newKeyVault.ResourceId
    }

    if($CreateSelfSignedCertificate)
    {
        $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

        $NewPfxFilePath = Join-Path $OutputPath $($CertificateName+".pfx")

        Write-Host "Creating new self signed certificate at $NewPfxFilePath"
    
        ## Changes to PSPKI version 3.2.5 New-SelfSignedCertificate replaced by New-SelfSignedCertificateEx
        $PspkiVersion = (Get-Module PSPKI).Version
        $MinPspkiVersion= New-Object System.Version("3.2.5.0")

        if($PspkiVersion -ge $MinPspkiVersion) {
            New-SelfsignedCertificateEx -Subject "CN=$DnsName" -EKU "Server Authentication", "Client authentication" -KeyUsage "KeyEncipherment, DigitalSignature" -Path $NewPfxFilePath -Password $securePassword -Exportable
        }
        else {
            New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -DnsName $DnsName | Export-PfxCertificate -FilePath $NewPfxFilePath -Password $securePassword | Out-Null
        }

        $ExistingPfxFilePath = $NewPfxFilePath
    }

    Write-Host "Reading pfx file from $ExistingPfxFilePath"
    $cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 $ExistingPfxFilePath, $Password

    $bytes = [System.IO.File]::ReadAllBytes($ExistingPfxFilePath)
    $base64 = [System.Convert]::ToBase64String($bytes)

    $jsonBlob = @{
       data = $base64
       dataType = 'pfx'
       password = $Password
       } | ConvertTo-Json

        $contentbytes = [System.Text.Encoding]::UTF8.GetBytes($jsonBlob)
        $content = [System.Convert]::ToBase64String($contentbytes)

        $secretValue = ConvertTo-SecureString -String $content -AsPlainText -Force

    Write-Host "Writing secret to $CertificateName in vault $VaultName"
    $secret = Set-AzureKeyVaultSecret -VaultName $VaultName -Name $CertificateName -SecretValue $secretValue

    $output = @{};
    $output.SourceVault = $resourceId;
    $output.CertificateURL = $secret.Id;
    $output.CertificateThumbprint = $cert.Thumbprint;

    return $output;
}

$subscriptionId = ""
$resourceGroupName = "RGKeyVaultServiceFabricDev"
$serviceFabricClusterName = "asfkvgraefdev"
$serviceFabricLocation = "westeurope"
$dnsname = "$serviceFabricClusterName.$serviceFabricLocation.cloudapp.azure.com"
$vaultName = "asfgraefdevkv"
$password = "f4fs4fe24qdsfzi67"

$certificateAuthentication = Invoke-AddCertToKeyVault -SubscriptionId $subscriptionId `
-ResourceGroupName $resourceGroupName `
-Location $serviceFabricLocation `
-VaultName $vaultName `
-CertificateName ServiceFabricAuthentication `
-Password $password `
-CreateSelfSignedCertificate `
-DnsName $dnsname `
-OutputPath "." -Verbose

$certificateReverseProxy = Invoke-AddCertToKeyVault -SubscriptionId $subscriptionId `
-ResourceGroupName $resourceGroupName `
-Location $serviceFabricLocation `
-VaultName $vaultName `
-CertificateName ServiceFabricReverseProxy `
-Password $password `
-CreateSelfSignedCertificate `
-DnsName $dnsname `
-OutputPath "." -Verbose
