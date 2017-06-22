# This will generate and export a certificate on behalf of a user, with pre-defined pin
# This was used with a Microsoft PKI.
# This is pieced together from various scripts on the internet plus my own additions and modifications.

Function New-CertificateRequest {
    param (
        [Parameter(Mandatory=$true)][string]$sAMAccountName,
        [Parameter(Mandatory=$true)][string]$UserPrincipalName,
        [Parameter(Mandatory=$true)][string]$IssuingCA,
        [Parameter(Mandatory=$true)][string]$CATemplate,
        [Parameter(Mandatory=$false)][string]$ExportPath
    )
 
    ### Define Variables
    $CertificateINI = "$sAMAccountName.ini"
    $CertificateREQ = "$sAMAccountName.req"
    $CertificateRSP = "$sAMAccountName.rsp"
    $CertificateCER = "$sAMAccountName.cer"
 
    ### Define Export Location
    if ((Test-Path $ExportLocation) -eq $false){New-Item -Path $ExportLocation -ItemType Directory -Force}
 
    ### INI file generation
    Set-Location $ExportLocation
    New-Item -type file $CertificateINI -force
    Add-Content $CertificateINI '[Version]'
    Add-Content $CertificateINI 'Signature="$Windows NT$"'
    Add-Content $CertificateINI ''
    Add-Content $CertificateINI '[NewRequest]'
    $temp = 'Subject="' + $SubjectName + ',OU=Users,DC=test,DC=com"'
    Add-Content $CertificateINI $temp
    Add-Content $CertificateINI 'FriendlyName="test"'
    Add-Content $CertificateINI 'Exportable=TRUE'
    Add-Content $CertificateINI 'KeyLength=2048'
    Add-Content $CertificateINI 'KeySpec=1'
    Add-Content $CertificateINI 'KeyUsage=0xA0'
    Add-Content $CertificateINI 'MachineKeySet=True'
    Add-Content $CertificateINI 'ProviderName="Microsoft RSA SChannel Cryptographic Provider"'
    Add-Content $CertificateINI 'ProviderType=1'
    Add-Content $CertificateINI 'SMIME=FALSE'
    Add-Content $CertificateINI 'RequestType=PKCS10'
    Add-Content $CertificateINI '[Extensions]'
    Add-Content $CertificateINI '2.5.29.17 = "{text}"'
    $temp = '_continue_ = "UPN=' + $UserPrincipalName + '&"'
    Add-Content $CertificateINI $temp
 
    ### Certificate request generation
    if (Test-Path $CertificateREQ) {Remove-Item $CertificateREQ}
    certreq.exe -new $CertificateINI $CertificateREQ
 
    ### Online certificate request and import
    if ($IssuingCA){
        if (Test-Path $CertificateCER) {Remove-Item $CertificateCER}
        if (Test-Path $CertificateRSP) {Remove-Item $CertificateRSP}
        certreq.exe -submit -attrib "CertificateTemplate:$CATemplate" -config $IssuingCA $CertificateREQ $CertificateCER
 
        certreq.exe -accept $CertificateCER
    }
}

Function Export-CertificateRequest {
    param (
        [Parameter(Mandatory=$true)][string]$sAMAccountName,
        [Parameter(Mandatory=$true)][string]$ExportLocation
    )
 
    $Certificate = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -like "$SubjectName*"}
    $CertificateExport = $ExportLocation + '\' + $sAMAccountName + '.pfx'
    Export-PfxCertificate -Cert $Certificate.PSPath -FilePath $CertificateExport -Password $secure_Password
}
 
$users = Import-Csv -Path C:\Working\cert-new-user.csv
$DomainSuffix = 'test.com'
 
foreach ($user in $users){

    $password = $user.pin
	$secure_password = convertto-securestring "$password" -asplaintext -force
    $sAMAccountName = $user.sAMAccountName
    $SubjectName = 'CN=' + $sAMAccountName
    $UserPrincipalName = $sAMAccountName + '@' + $DomainSuffix
    $ExportPath = 'C:\Working\CertExport'
    $ExportLocation = $ExportPath + '\' + $sAMAccountName
 
    New-CertificateRequest `
        -sAMAccountName $sAMAccountName `
        -UserPrincipalName $UserPrincipalName `
        -IssuingCA 'ca.test.com\CA' `
        -CATemplate 'UserCertificate2Years' 
 
    Export-CertificateRequest `
        -sAMAccountName $sAMAccountName `
        -ExportLocation $ExportLocation
 
    Clean-CertificateRequest
}