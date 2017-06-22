# This will delete any AD Computer accounts in the csv AD-Computer-DeleteAccount.csv located in the same folder

$script_parent     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csv_path          = $script_parent + "\AD-Computer-DeleteAccount.csv"

Import-Csv $csv_path | ForEach-object {
	$computer = $_.ComputerName
	Get-ADComputer -identity $Computer | Remove-ADObject -Recursive -Confirm:$false
}