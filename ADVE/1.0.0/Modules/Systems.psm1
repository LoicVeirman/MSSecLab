## This module contains functions related to Computer's System.

## Module Test-FeaturesBinaries
Function Test-FeaturesBinaries
{
    <# 
        .Synopsis
        Check if a role or feature has its binaries already installed on the system or not.

        .Description
        Check if a role or feature has its binaries already installed on the system or not.

        .Parameter Role
        Name of the binaries set to be checked.

        .Notes
        Version 01.00: 24/08/2019. 
            History: Function creation.
    #>
    Param(
        # Collect the Bundle to be checked for
        [Parameter(Mandatory=$true)]
        [ValidateSet('ADDS and DNS','ADDS and DNS Tools')]
        [String]
        $Role
    )

    ## Function Log Debug File
    $DbgFile = 'Debug_{0}.log' -f $MyInvocation.MyCommand
    $dbgMess = @()

    ## Start Debug Trace
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "****"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "**** FUNCTION STARTS"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "****"

    ## Indicates caller and options used
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Function caller..........: " + (Get-PSCallStack)[1].Command
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter ROLE...........: $Role"

    ## BinaryRoles Library
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Building binaries library"
    $LibBinaries = @{
        'ADDS and DNS'=@('DNS','AD-Domain-Services')
        'ADDS and DNS Tools'=@('RSAT-ADDS','RSAT-AD-AdminCenter','RSAT-ADDS-Tools','RSAT-DNS-Server')
    }

    ## Check if roles are present
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Testing if " + ($LibBinaries[$Role] -split ",").count + " role(s) is/are found(s) installed"
    $RoleFound = Get-WindowsFeature -Name $LibBinaries[$Role] | Where-Object { $true -eq $_.installed }
    if (($LibBinaries[$Role] -split ",").count -eq $RoleFound.count)    
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> All role(s) was/were found(s)"
        $result = $true
    } else {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> One or more role(s) were missing. Failed."
        $result = $false
    }

    ## Finally append debug log execution to a rotative one. We'll keep only last 1000 lines as history.
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "===| INIT  ROTATIVE  LOG "
    if (Test-Path .\Debugs\$DbgFile)
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Rotate log file......: 1000 last entries kept" 
        $Backup = Get-Content .\Debugs\$DbgFile -Tail 1000 
        $Backup | Out-File .\Debugs\$DbgFile -Force
    }
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "===| STOP  ROTATIVE  LOG "
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "#### FUNCTION RETURN: $result #####"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ****")
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T **** FUNCTION ENDS")
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ****")
    $DbgMess | Out-File .\Debugs\$DbgFile -Append
    
    ## Return result
    return $result
}

Function Test-OSVersion
{
    <# 
        .Synopsis
        Check if the OS is as expected.

        .Description
        Based on input entries, the script will check if the OS version and type is as expected.

        .Parameter OSType
        Array of Regex to match the OS Type as returned by (Get-WindowsEdition -Online).Edition.

        .Parameter OSVersion
        Array of Regex to match the OS Version as returned by (Get-WmiObject Win32_OperatingSystem).Version.

        .Notes
        Version 01.00: 28/08/2019. 
            History: Function creation.
    #>

    Param(
        # OSType Regex
        [Parameter(mandatory=$true,ParameterSetName='OS')]
        [String]
        $OSType,
        # OSVersion Regex
        [Parameter(mandatory=$true,ParameterSetName='Version')]
        [String]
        $OSVersion
    )

    ## Function Log Debug File
    $DbgFile = 'Debug_{0}.log' -f $MyInvocation.MyCommand
    $dbgMess = @()

    ## Start Debug Trace
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "****"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "**** FUNCTION STARTS"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "****"

    ## Indicates caller and options used
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Function caller..........: " + (Get-PSCallStack)[1].Command
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter OSTYPE.........: $OSType"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter OSVERSION......: $OSVersion"

    ## Check OS Type
    if ($OSType) 
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> OS Type analysis detected"
        $result = $false
        foreach ($Type in ($OSType -split ","))
        {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Testing OS type against $Type"
            if ((Get-WindowsEdition -Online).Edition -match $Type)
            {
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> OS Type is compatible with $Type"
                $result = $true
            }
        }
        if (!($result)) { $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> OS Type is not compatible" }
    }

    ## Check OS Version
    if ($OSVersion) 
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> OS Version analysis detected"
        $result = $false
        foreach ($Vr in ($OSVersion -split ","))
        {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Testing OS type against $Vr"
            if ((Get-WmiObject Win32_OperatingSystem).Version -match $Vr)
            {
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> OS Version is compatible wtih $Vr"
                $result = $true
            } 
        }
        if (!($result)) { $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> OS Version is not compatible" }
    }

    if ($null -eq $result) 
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---! No analysis detected! That's a miss!"
        $result = $false
    }

    ## Finally append debug log execution to a rotative one. We'll keep only last 1000 lines as history.
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "===| INIT  ROTATIVE  LOG "
    if (Test-Path .\Debugs\$DbgFile)
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Rotate log file......: 1000 last entries kept" 
        $Backup = Get-Content .\Debugs\$DbgFile -Tail 1000 
        $Backup | Out-File .\Debugs\$DbgFile -Force
    }
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "===| STOP  ROTATIVE  LOG "
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "#### FUNCTION RETURN: $result #####"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ****")
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T **** FUNCTION ENDS")
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ****")
    $DbgMess | Out-File .\Debugs\$DbgFile -Append
    
    ## Return result
    return $result
}

Function Add-FeaturesBinaries
{
    <# 
        .Synopsis
        Add a role or feature binaries to the system.

        .Description
        Add a role or feature to the system.

        .Parameter Role
        Name of the binaries set to be checked.

        .Notes
        Version 01.00: 29/08/2019. 
            History: Function creation.
    #>
    Param(
        # Collect the Bundle to be checked for
        [Parameter(Mandatory=$true)]
        [ValidateSet('ADDS and DNS','ADDS and DNS Tools')]
        [String]
        $Role
    )

    ## Function Log Debug File
    $DbgFile = 'Debug_{0}.log' -f $MyInvocation.MyCommand
    $dbgMess = @()

    ## Start Debug Trace
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "****"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "**** FUNCTION STARTS"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "****"

    ## Indicates caller and options used
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Function caller..........: " + (Get-PSCallStack)[1].Command
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter ROLE...........: $Role"

    ## BinaryRoles Library
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Building binaries library"
    $LibBinaries = @{
        'ADDS and DNS'=@('DNS','AD-Domain-Services')
        'ADDS and DNS Tools'=@('RSAT-ADDS','RSAT-AD-AdminCenter','RSAT-ADDS-Tools','RSAT-DNS-Server')
    }

    ## Try to install roles
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Begin: role(s) installation"
    $NoEcho   = install-WindowsFeature -Name $LibBinaries[$Role] -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> End..: role(s) installation"

    ## Check installation status
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Begin: role(s) installation"
    $result   = Test-FeaturesBinaries -Role $Role
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "--->        installation result is $result"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> End..: role(s) installation"

    ## Finally append debug log execution to a rotative one. We'll keep only last 1000 lines as history.
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "===| INIT  ROTATIVE  LOG "
    if (Test-Path .\Debugs\$DbgFile)
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Rotate log file......: 1000 last entries kept" 
        $Backup = Get-Content .\Debugs\$DbgFile -Tail 1000 
        $Backup | Out-File .\Debugs\$DbgFile -Force
    }
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "===| STOP  ROTATIVE  LOG "
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "#### FUNCTION RETURN: $result #####"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ****")
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T **** FUNCTION ENDS")
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ****")
    $DbgMess | Out-File .\Debugs\$DbgFile -Append
    
    ## Return result
    return $result
}

## Export modules
Export-ModuleMember -Function *