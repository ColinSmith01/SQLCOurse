### Configure Self Signed Certificate for SQL Server
### $IPAddress = (Get-NetIPAddress -AddressState Preferred -AddressFamily IPv4 | Where-Object IPAddress -ne "127.0.0.1" | Select-Object IPAddress -First 1 -ExpandProperty IPAddress)
### MSXEncryptChannelOptions registry setting must be set to allow Multiserver configuration.
reg import C:\Classfiles\Tools\MSXEncryptChannelOptions.reg

### Variables
$IPAddress = "192.168.10.101"
$ComputerName = $env:COMPUTERNAME
$FQDN = [System.Net.DNS]::GetHostByName($Null).HostName
$CertName = "SQLServerSSL"
$Password = "Password1"
$SecurePassword = ConvertTo-SecureString -String $Password -Force -AsPlainTex
$ExportPath = "C:\Classfiles\"
$CertificatePath = $ExportPath + $certname + ".cer"
$PrivateKeyPath = $ExportPath + $certname + ".pfx"

### Create Self-signed certificate
$Cert = New-SelfSignedCertificate -Type SSLServerAuthentication `
-Subject $FQDN `
-FriendlyName $CertName `
-DnsName $FQDN, $ComputerName, $IPAddress `
-KeyAlgorithm ‘RSA’ `
-KeyLength '2048' `
-Hash ‘SHA256’ `
-TextExtension ‘2.5.29.37={text}1.3.6.1.5.5.7.3.1’ `
-NotAfter (Get-Date).AddMonths(120) `
-KeySpec KeyExchange `
-Provider "Microsoft RSA SChannel Cryptographic Provider" `
-KeyLocation $ExportPath `
-KeyFriendlyName $CertName `
-CertStoreLocation Cert:\LocalMachine\My

### Export Certificate and Private Key
$CertExport = Export-Certificate -FilePath $CertificatePath -Cert $Cert 
$PrivateKeyExport = Export-PfxCertificate -Cert $Cert -FilePath $PrivateKeyPath -Password $SecurePassword 

### Restart SQL Server services
# Restart-Service -Name MSSQLSERVER -Force
# Restart-Service -Name SQLSERVERAGENT -Force
# Restart-Service -Name "SQL Server (SQL2)" -Force
# Restart-Service -Name "SQL Server Agent (SQL2)" -Force


<# WIP Import Certificate
$CertificateObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$ThumbPrint = $certificateObject.Import($PrivateKeyPath, $SecurePassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet)
Set-ItemProperty -Path $(get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\*\MSSQLServer\SuperSocketNetLib").PsPath -Name "Certificate" -Type String -Value "$($CertificateObject.Thumbprint)"
#>