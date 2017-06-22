# This will disable any AD Computer accounts in the csv AD-Computer-DisableAccount.csv located in the same folder

$Description = "Disabled $(Get-Date)- user - job reference"

$script_parent     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csv_path          = $script_parent + "\AD-Computer-DisableAccount.csv"

Import-Csv $csv_path | ForEach-object {
	$computer = $_.ComputerName
	Set-ADComputer -identity $Computer -Description $Description -Enabled $false
}