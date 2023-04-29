<#
    .Synopsis
    This script will hunt after user objects with disabled security Inheritance (adminSDholder).

    .Notes
    Version 1.0.0
    Author  Loic VEIRMAN (MSSEC)
#>

Param()

#.Script Data
$Version    = "01.00.000"
$Author     = "loic.veirman@mssec.fr"
$GithubLink = "https://github.com/LoicVeirman/MSSecLab"

#.startup
Write-Host
Write-Host "*******************************************" -ForegroundColor Yellow
Write-Host "*** " -NoNewline -ForegroundColor Yellow ; Write-Host "Users Security Inheritance Cleaner " -NoNewline -ForegroundColor Cyan ; Write-Host "****" -ForegroundColor Yellow
Write-Host "*******************************************" -ForegroundColor Yellow
write-host
Write-Host "Vesion: " -NoNewline -ForegroundColor DarkGray
Write-host $Version -ForegroundColor Gray
Write-Host "Author: " -NoNewline -ForegroundColor DarkGray
Write-Host $Author -ForegroundColor Gray
Write-Host 
Write-Host $GithubLink -ForegroundColor Gray
Write-Host

#.Collect all users with an adminCount not equal to 1, which indicate "not protected by adminSDholder"
$Users = Get-ADuser -Filter * -Properties NTSecurityDescriptor,adminCount | Where-Object { $_.AdminCount -ne 1 }

Write-Host "Found " -NoNewline ; Write-Host $Users.Count -ForegroundColor Yellow -NoNewline ; Write-Host " users not protected by adminSDholder"

#.analyse each objects
Write-Host "`nAnalyzing:`n" -ForegroundColor Cyan

$FixCounter = 0
$displayIdx = 0
$FixedUsers = @()

foreach ($user in $Users)
{
    $displayIdx++

    if ($displayIdx -eq 80) 
    {
        $sameLine   = $false
        $displayIdx = 0
    } 
    else 
    {
        $sameLine = $true
    }

    $tobeFixed = $user.ntSecurityDescriptor.areAccessRulesProtected

    if ($tobeFixed)
    {
	$fixedUsers += $user
        try 
	{
        	$dn   = $user.DistinguishedName
        	$null = dsacls $dn -resetDefaultDACL
        	
		Write-Host "+" -NoNewline:$sameLine -ForegroundColor Green
        	$FixCounter++
	}
	Catch
	{
		Write-Host "!" -NoNewline:$sameLine -ForegroundColor Red
	}
    } 
    Else 
    {
    	Write-Host "." -NoNewline:$sameLine -ForegroundColor white
    }
}
Write-Host "Done`n" -ForegroundColor Cyan

$fileName   = "ModifiedUSers_" + (Get-Date -Format "yyyyMMdd_hhmmss") + ".csv"
$fixedUsers | export-csv $fileName -delimiter ';' -noTypeInformation

write-host "Fixed" $fixedUsers.count "users"
Write-Host "Exported modified objects to $fileName`n"
Write-Host "Script's done." -foregroundColor yellow
