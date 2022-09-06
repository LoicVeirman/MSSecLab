## This module contains functions related to NEtworking.

## Module Test-SystemIP
Function Test-SystemIP
{
    <# 
        .Synopsis
        Return true or false, following choosen parameter.

        .Description
        Analyse the IP configuration and look after a static or dynamic address.
        
        .Parameter isStatic
        Ask the script to search for at least one static IP.

        .Parameter isDynamic
        Ask the script to search for at least one static dynamic address.

        .Notes
        Version 01.00: 24/08/2019. 
            History: Function creation.
    #>

    ## Parameters 
    Param (
        # Ask to search for a static ip
        [Parameter(Mandatory=$False)]
        [Switch]
        $isStatic,
        # Ask to search for a DHCP assignement
        [Parameter(Mandatory=$False)]
        [Switch]
        $isDynamic
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
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter isStaic........: $isStatic"
    
    ## Case 1: Return true if a static IP is found
    if ($isStatic)
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---| INIT STATIC IP CHECK"
        $srvAddr  = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.DHCPEnabled -eq $False -and $null -ne $_.IPAddress }    
        if ($srvAddr)
        {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Found at least one static IP. Return TRUE."
            $result = $true
        } else {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> No static IP found. Return FALSE."
            $result = $false
        }
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---| STOP STATIC IP CHECK"
    }
   
    ## Case 2: Return true if a dynamic IP is found
    if ($isDynamic)
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---| INIT DHCP IP CHECK"
        $srvAddr  = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.DHCPEnabled -eq $True -and $null -ne $_.IPAddress }    
        if ($srvAddr)
        {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Found at least one dynamic IP. Return TRUE."
            $result = $true
        } else {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> No dynamic IP found. Return FALSE."
            $result = $false
        }
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---| STOP DHCP IP CHECK"
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
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ****")
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T **** FUNCTION ENDS")
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ****")
    $DbgMess | Out-File .\Debugs\$DbgFile -Append

    ## Return function result
    return $result
}

## Export module members
Export-ModuleMember -Function *
