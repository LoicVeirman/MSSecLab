<#
    .SYNOPSIS
    This script is intended to massively import new groups to an AD. 
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

$msg = "Please provide DN path to store objects (if needed)"
$DfltDN = read-host -prompt $msg

if ($DfltDN -eq "")
{
    $DfltDN = (Get-AdDomain).UsersContainer
}

#.Create main groups
$csvHeaders = $csv[0].psObject.Properties.Name
$GroupsList = @()

for ($ptr = 7 ; $ptr -le 27 ; $ptr)
{
    $GrpName  = ""
    $Splitted = $csvHeaders[$ptr] -Split ' '
    foreach ($split in $Splitted)
    {
        $GrpName += $split
    }
    
    $GroupsList += $GrpName

    $checkIfExists   = Get-AdGroup $GrpName -ErrorAction SilentlyContinue
    $FuckItHasFailed = $False

    if ($checkIfExists)
    {
        write-host "$GrpName " -foregroundcolor Cyan -NoNewLine
        Write-host "Already exists" -foregroundcolor white 
    }
    Else 
    {
        write-host "$GrpName " -foregroundcolor Cyan -NoNewLine
        Try
        {
            New-AdGroup -name $GrpName -samAccountName $GrpName -DisplayName $GrpName
            Write-host "Successfully created" -foregroundcolor green
        }
        Catch
        {
            Write-host "Creation failed!" -foregroundcolor red
            $FuckItHasFailed = $true
        }
    }
}

#.Adding Members...
if (-not($FuckItHasFailed))
{
    foreach ($Group in $GroupsList)
    {
        $filteredCsv = $csv | Where-object { $_.$Group -ne "" }
        Write-host "{$Group}`t" $filteredCsv.count

        #new-ADgroupMember -identity $Group -member $FilteredCsv."Login TSE ad"
    }
}
