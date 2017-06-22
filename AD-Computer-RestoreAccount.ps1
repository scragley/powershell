# This will restore any AD Computer accounts in the csv AD-Computer-RestoreAccount.csv located in the same folder

$script_parent     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csv_path          = $script_parent + "\AD-Computer-RestoreAccount.csv"

Import-Csv $csv_path | ForEach-object {
$computer = $_.ComputerName
Get-ADObject -Filter {displayName -eq $computer} -IncludeDeletedObjects | Restore-ADObject
}