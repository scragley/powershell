# This will enable any AD Computer accounts in the csv AD-Computer-EnableAccount.csv located in the same folder

$Description = "Disabled $(Get-Date)- user - job reference"

$script_parent     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csv_path          = $script_parent + "\AD-Computer-EnableAccount.csv"

Import-Csv $csv_path | ForEach-object {
    $computer = $_.ComputerName
    Set-ADComputer -identity $Computer -Description $Description -Enabled $true
}