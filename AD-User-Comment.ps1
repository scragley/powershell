# This will modify the comment field of any AD user accounts in the csv AD-User-Comment.csv located in the same folder

$Comment = "Happy User"

$script_parent     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csv_path          = $script_parent + "\AD-User-Comment.csv"

Import-Csv $csv_path | ForEach-object {
	$user = $_.Name
	Set-ADUser $user -replace @{comment=$Comment}
}