# This will move any AD Computer accounts in the csv AD-Computer-MoveAccount.csv located in the same folder

$DestinationOU = "OU=Windows 10,OU=Client Devices,DC=test,DC=com"

$script_parent     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csv_path          = $script_parent + "\AD-Computer-MoveAccount.csv"

Import-Csv $csv_path | ForEach-object {
	$computer = $_.ComputerName
	Get-ADComputer $Computer | Move-ADObject -TargetPath $DestinationOU
}