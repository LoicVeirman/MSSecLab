<#
    .SYNOPSIS
    This script is intended to massively import new users to an AD. 
    Designed to be used in production with interactive query.

    .NOTES
    Version 01.00.000 by loic.veirman@mssec.fr
#>
Param(
    [Parameter(mandatory=$true)]
    [String]
    $ImportCsvFile
)

$csvData = import-csv .\$ImportCsvFile

$msg = "Please provide DN path to store object (if needed): "
$DfltDN = read-host -prompt $msg

if ($DfltDN -eq "")
{
    $DfltDN = (Get-AdDomain).UsersContainer
}

foreach ($data in $csvData)
{
    $Name           = $data.Prenom
    $Surname        = $data.Nom
    $samAccountName = $data."Login TSE ad"
    $UPN            = $data.Email
    $Service        = $data.Service
    $Company        = $data.Entreprise
    $DisplayName    = $Surname + " " + $Name
    $DefaultPwd     = "34sy-L1f3=" + (Get-Random -minimum 1000 -maximum 9999)

    ($DisplayName + "`t`t" + $DefaultPwd) | out-file .\PwdList.txt -append 

    try {
        new-aduser -name $DisplayName -AccountPAssword (convertto-secureString -asplaintext $DefaultPwd -force) `
                   -GivenName $Name -DisplayName $DisplayName -enabled $true -samAccountName $samAccountName `
                   -Surname $Surname -userprincipalname $UPN -path $DfltDN 
        
        write-host "SUCCESS`t" -foregroundcolor green -nonewline
        write-host $DisplayName 
    }
    Catch {
        write-host "FAILED!`t" -foregroundcolor red -nonewline
        write-host $DisplayName 
    }
}
write-host
write-host "job's done"
write-host