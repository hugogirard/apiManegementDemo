param(
    [Parameter(Mandatory = $true)]
    [string]$certificatePassword = $true
)

# Generate a CA (Certificate Authority) -- this can be installed on the server where the
# client reside, in our case in KeyVault and read by APIM

$thumbprint = New-SelfSignedCertificate -DnsName "localhost", `
                                                 "localhost" -CertStoreLocation "cert:\LocalMachine\My" `
                                                 -NotAfter (Get-Date).AddYears(10) -FriendlyName "CAlocalhost" `
                                                 -KeyUsageProperty All -KeyUsage CertSign, CRLSign, DigitalSignature `
                                                 | Select-Object Thumbprint `
                                                 | ForEach-Object {$_.Thumbprint}

$workingDirectory = Join-Path -Path "." -ChildPath "selfSignedCertificate"

New-Item -Path $workingDirectory -ItemType Directory | Out-Null

$mypwd = ConvertTo-SecureString -String $certificatePassword -Force -AsPlainText

Get-ChildItem -Path cert:\localMachine\my\$thumbprint | Export-PfxCertificate -FilePath $workingDirectory\cacert.pfx -Password $mypwd

# Now we can generate a client certificate

$rootcert = ( Get-ChildItem -Path cert:\LocalMachine\My\$thumbprint )

New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname "localhost" -Signer $rootcert -NotAfter (Get-Date).AddYears(10) -FriendlyName "Clientlocalhost"

Get-ChildItem -Path cert:\localMachine\my\$thumbprint | Export-PfxCertificate -FilePath $workingDirectory\clientcert.pfx -Password $mypwd
