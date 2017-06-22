# This will query AD for computer acounts that have not logged in within the last x days.
# It will write the results to AD-Computer-DisableAccount.csv in the same folder the script was run from.

$DaysSinceLogon = "-90"

$date = (Get-Date).AddDays($DaysSinceLogon)
$script_parent     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csv_path          = $script_parent + "\AD-Computer-GetAccount.csv"

Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $date} | Sort-Object Name | Select-Object Name, ObjectClass, Enabled, LastLogonDate, distinguishedName | Export-Csv -NoTypeInformation -path $csv_path