#This was an attempt to collect details form WWAN cards and store in WMI for SCCM to collect during inventory.
#It almost works but I havn't had the time to go back and finish it.
#This is pieced together from various scripts on the internet plus my own additions and modifications.

# Creates a new class in WMI to store our data
function Create-Wmi() {
$newClass = New-Object System.Management.ManagementClass("root\cimv2", [String]::Empty, $null); 

$newClass["__CLASS"] = "CUSTOM_WWAN_Details"; 
$newClass.Qualifiers.Add("Static", $true)

$newClass.Properties.Add("IMEI", [System.Management.CimType]::String, $false)
$newClass.Properties["IMEI"].Qualifiers.Add("read", $true)
$newClass.Properties["IMEI"].Qualifiers.Add("key", $true)

$newClass.Properties.Add("Manufacturer", [System.Management.CimType]::String, $false)
$newClass.Properties["Manufacturer"].Qualifiers.Add("read", $true)

$newClass.Properties.Add("Model", [System.Management.CimType]::String, $false)
$newClass.Properties["Model"].Qualifiers.Add("read", $true)

$newClass.Properties.Add("FirmwareVersion", [System.Management.CimType]::String, $false)
$newClass.Properties["FirmwareVersion"].Qualifiers.Add("read", $true)

$newClass.Properties.Add("SIMICCId", [System.Management.CimType]::String, $false)
$newClass.Properties["SIMICCID"].Qualifiers.Add("read", $true)
$newClass.Put()
}


function Check-Wmi() {
# Check whether we already created our custom WMI class on this PC, if not, create it
[void](Get-WmiObject CUSTOM_WWAN_Details -ErrorAction SilentlyContinue -ErrorVariable wmiclasserror)
# If the wmiClassError is returned then assume that the WMI class does not exist yeat and try to create a WMI class to hold the Monitor info
# If creating the WMI class fails, exit with error code 1
if ($wmiclasserror) {
    try { Create-Wmi-Class }
    catch {
        "Could not create WMI class"
        Exit 1
        }
    }
}


function Get-WWAN-Details() {
$wwan1 = @{}
# Any cmd commend can go in here. In this case we are after MBN interface details
$NetshMEIDResult = Invoke-Command {netsh mbn sh interface}
$MEIDresult = @{}
$NetshMEIDResult = $NetshMEIDResult | Select-String : #break into chunks if colon  only
$i = 0
while($i -lt $NetshMEIDResult.Length){
    $line = $NetshMEIDResult[$i]
    $line = $line -split(":")
    $line[0] = $line[0].trim()
    $line[1] = $line[1].trim()
    $MEIDresult.$($line[0]) = $($line[1])
    $i++
    }


# And repeat to get SIM details
$NetshICCIDResult = Invoke-Command {netsh mbn sh read i=*}
$ICCIDresult = @{}
$NetshICCIDResult = $NetshICCIDResult | Select-String : #break into chunks if colon  only
$i = 0
while($i -lt $NetshICCIDResult.Length){
    $line = $NetshICCIDResult[$i]
    $line = $line -split(":")
    $line[0] = $line[0].trim()
    $line[1] = $line[1].trim()
    $ICCIDresult.$($line[0]) = $($line[1])
    $i++
    }

$wwan1.IMEI = $MEIDResult.'Device Id'
$wwan1.Manufacturer = $MEIDResult.Manufacturer
$wwan1.Model = $MEIDResult.Description
$wwan1.Firmware = $MEIDResult.'Firmware Version'
$wwan1.SIMICCID = $ICCIDResult.'SIM ICC Id'
}


function Clear-Wmi() {
# Clear WMI
Get-WmiObject CUSTOM_WWAN_Details | Remove-WmiObject
}


function Write-Wmi() {
# Write data to WMI
$wwan1 | % { $i=0 } {
    [void](Set-WmiInstance -Path \\.\root\cimv2:CUSTOM_WWAN_Details -Arguments @{IMEI=$_.IMEI; `
    Manufacturer=$_.Manufacturer; `
    Model=$_.Model; `
    FirmwareVersion=$_.Firmware; `
    SIMICCId=$_.SIMICCID})
    $i++
    }
}


Create-Wmi
Check-Wmi
Get-WWAN-Details
Clear-Wmi
Write-Wmi