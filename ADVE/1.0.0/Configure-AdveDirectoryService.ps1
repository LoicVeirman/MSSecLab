<#
    .Synopsis
    Configure Active Directory on a target server using an input file.

    .Description
    This script will perform all steps to configure a Directory Service on a windows server.

    .Parameter ConfigFile
    This parameter will teach the script to use a specific configuration file for Domain/Forest information. 
    By default, it will use ActiveDirectory-Configuration.ini in .\Inputs.

    .Notes
    Version 01.00:  2019/09/05 - Github@mssec.fr
                    Script creation.
#>

Param( 
    # Input File for configuration
    [Parameter(Mandatory=$False)]
    [string]
    $ConfigFile='ActiveDirectory-configuration.ini' 
     )

## Generate Global variables
$Global:LogFile  = ($MyInvocation.MyCommand.Name -replace '.ps1','') + "_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".log"

## Check for old log files to cleanup: only keep the last 10.
$Loglist = Get-ChildItem .\Logs -Filter (($MyInvocation.MyCommand.Name -replace '.ps1','') + "_*") -Recurse | Sort-Object -Descending
For ($j = 9 ; $j -lt $Loglist.count ; $j++) {
    Remove-Item $Loglist[$j].FullName
}

## Import modules for this script
$Modules = Get-ChildItem .\Modules -Filter '*.psm1' -Recurse
ForEach ($module in $modules) { 
    Import-Module $module.FullName -ErrorAction Stop 
}

## Initialize Configuration File for the script
$ScriptConfig = Import-Ini -FilePath .\Configs\ADVE-Configuration.ini

## Initialize log
write-logInfo -LogMessage ('| `[' + $MyInvocation.MyCommand.Name + '`]')                -ToScreen -Scheme 'START and STOP'
write-logInfo -LogMessage ('| Version: `(' + $ScriptConfig["Global"]["Version"] + '`)') -ToScreen -Scheme 'START and STOP'
write-logInfo -LogMessage ('| Author.: `(' + $ScriptConfig["Global"]["Author"] + '`)')  -ToScreen -Scheme 'START and STOP'
write-logInfo -LogMessage ('| Date...: `(' + $ScriptConfig["Global"]["Date"] + '`)`n')  -ToScreen -Scheme 'START and STOP'

## 1.Import configuration file(s)
$ADconfig = Import-Ini -FilePath .\Inputs\$ConfigFile
if ($ADconfig) {
    write-logInfo -LogMessage ($ScriptConfig["SUCCESS"]["1"] -replace 'ConfigFile',$ConfigFile) -ToScreen -Scheme 'OK and KO'
} else {
    write-logInfo -LogMessage ($ScriptConfig["FAILURE"]["1"] -replace 'ConfigFile',$ConfigFile) -ToScreen -Scheme 'OK and KO'
    Exit 1
}

## 7.Enable (or not) recycle bin
if (Switch-ADRecycleBin -DesiredState $ADconfig["OPTIONS"]["ADRecycleBin"]) {
    write-logInfo -LogMessage ($ScriptConfig["SUCCESS"]["7"] -replace "VALUE",$ADconfig["OPTIONS"]["ADRecycleBin"]) -ToScreen -Scheme 'OK and KO'
} else {
    write-logInfo -LogMessage ($ScriptConfig["WARNING"]["7"] -replace "VALUE",$ADconfig["OPTIONS"]["ADRecycleBin"]) -ToScreen -Scheme 'WARNING'
}

## 8.Enable (or not) Centralized Gpo Repository
if (Switch-GpoCentralStore -DesiredState $ADconfig["OPTIONS"]["GpoCentralStore"]) {
    write-logInfo -LogMessage ($ScriptConfig["SUCCESS"]["8"] -replace "VALUE",$ADconfig["OPTIONS"]["GpoCentralStore"]) -ToScreen -Scheme 'OK and KO'
} else {
    write-logInfo -LogMessage ($ScriptConfig["WARNING"]["8"] -replace "VALUE",$ADconfig["OPTIONS"]["GpoCentralStore"]) -ToScreen -Scheme 'WARNING'
}

## 9.Enable (or not) instant replication
if (Switch-InstantReplication -DesiredState $ADconfig["OPTIONS"]["EnforceImmediateReplication"]) {
    write-logInfo -LogMessage ($ScriptConfig["SUCCESS"]["9"] -replace "VALUE",$ADconfig["OPTIONS"]["EnforceImmediateReplication"]) -ToScreen -Scheme 'OK and KO'
} else {
    write-logInfo -LogMessage ($ScriptConfig["WARNING"]["9"] -replace "VALUE",$ADconfig["OPTIONS"]["EnforceImmediateReplication"]) -ToScreen -Scheme 'WARNING'
}

## 10.Install (or not) adds tools
if ($ADconfig["MANAGEMENT"]["RsatTools"] -eq "enable") {
    if (Add-FeaturesBinaries -Role 'ADDS and DNS Tools') {
        write-logInfo -LogMessage $ScriptConfig["SUCCESS"]["10"] -ToScreen -Scheme 'OK and KO'
    } else {
        write-logInfo -LogMessage $ScriptConfig["WARNING"]["10"] -ToScreen -Scheme 'WARNING'
    }
} else {
    write-logInfo -LogMessage $ScriptConfig["SKIPPED"]["10"] -ToScreen
}

## 11.Provisionning OU: this step is mandatory but will not break the script.
if (New-ProvisioningOU -RootOU $ADconfig['PROVISIONING']['ROOTNAME'] -CptrOU $ADconfig['PROVISIONING']['COMPUTERNAME'] -UserOU $ADconfig['PROVISIONING']['USERNAME']  `
                       -RootDS $ADconfig['PROVISIONING']['ROOTDESC'] -CptrDS $ADconfig['PROVISIONING']['COMPUTERDESC'] -USerDS $ADconfig['PROVISIONING']['USERDESC']) {
    write-logInfo -LogMessage $ScriptConfig["SUCCESS"]["11"] -ToScreen -Scheme 'OK and KO'
} else {
    write-logInfo -LogMessage $ScriptConfig["WARNING"]["11"] -ToScreen -Scheme 'OK and KO'
}

## 12.Create OUs TREE
if (New-AdvceOUtree -OUData $ADconfig['OU'] -BasePath (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)) {
    write-logInfo -LogMessage $ScriptConfig["SUCCESS"]["12"] -ToScreen -Scheme 'OK and KO'
}else {
    write-logInfo -LogMessage $ScriptConfig["FAILURE"]["12"] -ToScreen -Scheme 'OK and KO'
    exit 12
}

## 13.Import GPO : Flush Backup Operators on PC and Servers


## Script ends
write-logInfo -LogMessage '`n| `{Script''s done!`}`n' -ToScreen -Scheme 'START and STOP'
ForEach ($module in $modules) { Remove-Module ($module.Name -replace '.psm1','') -ErrorAction SilentlyContinue }