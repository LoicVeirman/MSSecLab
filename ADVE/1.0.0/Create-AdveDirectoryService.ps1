<#
    .Synopsis
    Install Active Directory on a target server using an input file.

    .Description
    This script will perform all steps to install a Directory Service on a windows server, then to setup this one with options and data.

    .Parameter ConfigFile
    This parameter will teach the script to use a specific configuration file. By default, it will use ActiveDirectory-Configuration.ini in .\Inputs.

    .Notes
    Version 01.00:  2019/08/25 - github@mssec.fr
                    Script creation.
#>

Param(
    # Input File for configuration
    [Parameter(Mandatory=$False)]
    [string]
    $ConfigFile='ActiveDirectory-configuration.ini'
)

## Generate Global variables
$Global:LogFile = ($MyInvocation.MyCommand.Name -replace '.ps1','') + "_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".log"

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
write-logInfo -LogMessage ('| `[' + $MyInvocation.MyCommand.Name + '`]'               ) -ToScreen -Scheme 'START and STOP'
write-logInfo -LogMessage ('| Version: `(' + $ScriptConfig["Global"]["Version"] + '`)') -ToScreen -Scheme 'START and STOP'
write-logInfo -LogMessage ('| Author.: `(' + $ScriptConfig["Global"]["Author"] + '`)' ) -ToScreen -Scheme 'START and STOP'
write-logInfo -LogMessage ('| Date...: `(' + $ScriptConfig["Global"]["Date"] + '`)`n' ) -ToScreen -Scheme 'START and STOP'

## 1.Import configuration file(s)
$ADconfig = Import-Ini -FilePath .\Inputs\$ConfigFile
if ($ADconfig) {
    write-logInfo -LogMessage ($ScriptConfig["SUCCESS"]["1"] -replace 'ConfigFile',$ConfigFile) -ToScreen -Scheme 'OK and KO'
} else {
    write-logInfo -LogMessage ($ScriptConfig["FAILURE"]["1"] -replace 'ConfigFile',$ConfigFile) -ToScreen -Scheme 'OK and KO'
    Exit 1
}

## Check before installing
## 2.Check if the server is set on a static IP
if (Test-systemIP -isStatic) {
    write-logInfo -LogMessage $ScriptConfig["SUCCESS"]["2"] -ToScreen -Scheme 'OK and KO'
} else {
    write-logInfo -LogMessage $ScriptConfig["FAILURE"]["2"] -ToScreen -Scheme 'OK and KO'
    Exit 2
}

## 3.Ensure the script is running on server OS and is compatible with this script.
$TestOS = Test-OSVersion -OSType     $ScriptConfig["GLOBAL"]["OSTypeMatrix"]
$TestVR = Test-OSVersion -OSVersion $ScriptConfig["GLOBAL"]["OSVersionMatrix"]
if ($TestOS -and $TestVR) {
    write-logInfo -LogMessage $ScriptConfig["SUCCESS"]["3"] -ToScreen -Scheme 'OK and KO'
} else {
    write-logInfo -LogMessage $ScriptConfig["FAILURE"]["3"] -ToScreen -Scheme 'OK and KO'
    Exit 3
}

## 4.Check if the mandatory roles are installed or not. It will return true or false to order 
##   the installation process.
if (Test-FeaturesBinaries -Role "ADDS and DNS") {
    write-logInfo -LogMessage $ScriptConfig["SUCCESS"]["4"] -ToScreen -Scheme 'OK and KO'
} else {
    write-logInfo -LogMessage $ScriptConfig["WARNING"]["4"] -ToScreen -Scheme 'WARNING'
    ## 5.Proceed to installation
    if (Add-FeaturesBinaries -Role "ADDS and DNS")     {
        write-logInfo -LogMessage $ScriptConfig["SUCCESS"]["5"] -ToScreen -Scheme 'OK and KO'
    } else {
        write-logInfo -LogMessage $ScriptConfig["FAILURE"]["5"] -ToScreen -Scheme 'OK and KO'
        exit 5
    }   
}

## 6.Proceed to the role installation processus.
if (Install-ADDS -Config $ADconfig) {
    write-logInfo -LogMessage $ScriptConfig["SUCCESS"]["6"] -ToScreen -Scheme 'OK and KO'
} else {
    write-logInfo -LogMessage $ScriptConfig["FAILURE"]["6"] -ToScreen -Scheme 'OK and KO'
    exit 6
}
 
## Script ends
write-logInfo -LogMessage '`n| `{Script''s done!`}`n' -ToScreen -Scheme 'START and STOP'
ForEach ($module in $modules) { Remove-Module ($module.Name -replace '.psm1','') -ErrorAction SilentlyContinue }
