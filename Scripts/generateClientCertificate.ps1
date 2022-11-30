param(
    [Parameter(Mandatory = $true)]
    [string]$certificatePassword = $true,
    [string]$friendlyName = "CAlocalhost"
)

# Generate a CA (Certificate Authority) -- this can be installed on the server where the
# client reside, in our case in KeyVault and read by APIM

$thumbprint = New-SelfSignedCertificate -DnsName "localhost", `
                                                 "localhost" -CertStoreLocation "cert:\LocalMachine\My" `
                                                 -NotAfter (Get-Date).AddYears(10) -FriendlyName $friendlyName `
                                                 -KeyUsageProperty All -KeyUsage CertSign, CRLSign, DigitalSignature `
                                                 | Select-Object Thumbprint `
                                                 | ForEach-Object {$_.Thumbprint}

$workingDirectory = Join-Path -Path "." -ChildPath "selfSignedCertificate"

New-Item -Path $workingDirectory -ItemType Directory | Out-Null

$mypwd = ConvertTo-SecureString -String $certificatePassword -Force -AsPlainText

Get-ChildItem -Path cert:\localMachine\my\$thumbprint | Export-PfxCertificate -FilePath $workingDirectory\"ca$friendlyName".pfx -Password $mypwd

# Now we can generate a client certificate

$rootcert = ( Get-ChildItem -Path cert:\LocalMachine\My\$thumbprint )

New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname "localhost" -Signer $rootcert -NotAfter (Get-Date).AddYears(10) -FriendlyName $friendlyName

Get-ChildItem -Path cert:\localMachine\my\$thumbprint | Export-PfxCertificate -FilePath $workingDirectory\"$($friendlyName)cert.pfx" -Password $mypwd
