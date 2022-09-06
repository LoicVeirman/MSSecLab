Function Install-ADDS
{
    <# 
        .Synopsis
         Configure a new forest on the server.

        .Description
         Perform a new forest installation on the server.

        .Parameter Config
         All settings to configure the new forest.

        .Notes
         Version 01.00: 30/08/2019. 
               History: Function creation.
    #>
    Param(
        # Collect the Bundle to be checked for
        [Parameter(Mandatory=$true)]
        [object]
        $Config
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
   $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter CONFIG.........: $Config"

    ## 1.Initialize verbose output for follow-up
    write-logInfo -LogMessage '`(*`) `[.START.`]`(:`)`[ New AD Forest installation`]' -ToScreen
    
    ## 2.Check if the server is not already a domain member (it is a new forest)
    write-logInfo -LogMessage '`(* .......: `)server''s domain membership (checking)' -ToScreen
    $Flag = $false
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter FLAG...........: $Flag"

    Try   { $InstalledForest = Get-ADForest $Config["FOREST"]["ForestName"] }
    Catch { $InstalledForest = $null }
    
	if ($InstalledForest)
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> a forest has been detected"
        
        $check = $InstalledForest.Name -eq $Config["DOMAIN"]["DomainName"]
        
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter CHECK..........: $Check"
        
        if (!($check))
        {
            write-logInfo -LogMessage '`(* .......: `)server''s domain membership (`{test''s ko`})' -ToScreen
            $Flag = $true    
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter FLAG...........: $Flag"
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> The forest is not the one expected: error."
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> debug value: INSTALLEDFOREST.NAME......=" + $InstalledForest.Name
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> debug value: CONFIG[DOMAIN][DOMAINNAME]=" + $Config["DOMAIN"]["DomainName"]
        }
        else
        {
            write-logInfo -LogMessage '`(* .......: `)server''s domain membership (test ok)' -ToScreen
            $test = 0
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter TEST...........: $Test"
        }
    }
    else 
    {
        write-logInfo -LogMessage '`(* .......: `)server''s domain membership (test ok)' -ToScreen    
        $test = 1
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter TEST...........: $Test"
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> The forest will be installed."
}

    if (!($Flag))
    {
        write-logInfo -LogMessage '`(* .......: `)run installation command (start)' -ToScreen
        if ($test -gt 0)
        {
            #.Debug Message with ini content to ensure a proper reading was done.
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Start installation."
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] [INSTALL]"
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] CreateDnsDelegation..........:" + $Config["INSTALL"]["CreateDnsDelegation"] 
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] NoRebootOnCompletion.........:" + $Config["INSTALL"]["NoRebootOnCompletion"] 
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] SafeModeAdministratorPassword:" + $Config["INSTALL"]["AdminPassword"]
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] InstallDns...................:" + $Config["INSTALL"]["InstallDNS"] 
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] [FOREST]"
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] ForestMode...................: " + $Config["FOREST"]["ForestMode"]
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] ForestName...................: " + $Config["FOREST"]["ForestName"]
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] [DOMAIN]"
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] DomainMode...................: " + $Config["DOMAIN"]["DomainMode"]
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] DomainName...................: " + $Config["DOMAIN"]["DomainName"]
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] DomainNetbiosName............: " + $Config["DOMAIN"]["NtBiosName"]

            Try     
            {
                
                #PrepareOption
				if ( $Config["INSTALL"]["CreateDnsDelegation"]  -eq "true") { $CDD = $True } else { $CDD = $FALSE }
				if ( $Config["INSTALL"]["InstallDNS"]           -eq "true") { $IDS = $True } else { $IDS = $FALSE }
				if ( $Config["INSTALL"]["NoRebootOnCompletion"] -eq "true") { $NRC = $True } else { $NRC = $FALSE }
								
				$dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> [DEBUG] CMD=install-addsForest -CreateDnsDelegation:$" + $CDD `
                                                               + " -DomainMode " + $Config["DOMAIN"]["DomainMode"] `
                                                               + " -DomainName " + $Config["DOMAIN"]["DomainName"] `
                                                               + " -DomainNetbiosName " + $Config["DOMAIN"]["NtBiosName"] `
                                                               + " -ForestMode " + $Config["FOREST"]["ForestMode"] `
                                                               + " -InstallDns:$" + $IDS `
                                                               + " -NoRebootOnCompletion:$" + $NRC `
                                                               + ' -Force:$True' `
                                                               + " -SafeModeAdministratorPassword (ConvertTo-SecureString -string " + $Config["INSTALL"]["AdminPassword"] + " -AsPlainText -Force)" `
                                                               + " -SkipPreChecks"

                
				$NoEcho = install-addsForest -CreateDnsDelegation:$CDD `
                                             -DomainMode $Config["DOMAIN"]["DomainMode"] `
                                             -DomainName $Config["DOMAIN"]["DomainName"] `
                                             -DomainNetbiosName $Config["DOMAIN"]["NtBiosName"] `
                                             -ForestMode $Config["FOREST"]["ForestMode"] `
                                             -InstallDns:$IDS `
                                             -NoRebootOnCompletion:$NRC `
                                             -Force:$True `
                                             -SafeModeAdministratorPassword (ConvertTo-SecureString -String $Config["INSTALL"]["AdminPassword"] -AsPlainText -Force) `
                                             -SkipPreChecks `
											 -WarningAction SilentlyContinue
											 
                write-logInfo -LogMessage '`(* .......: `)command executed with success' -ToScreen
            }#.End Try

            Catch  
            {
				$dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> installation has failed."
                write-logInfo -LogMessage '`(* .......: `)command failed to execute' -ToScreen
                $flag = $true
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter FLAG...........: $flag"
            }#.End Catch
        }
        else 
        {
            write-logInfo -LogMessage '`(* .......: `)the requested forest is already installed' -ToScreen
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> The forest is the one expected : no installation to perform."
        }
        write-logInfo -LogMessage '`(* .......: `)run installation command (finish)' -ToScreen
        write-logInfo -LogMessage '`(*`) `[..END..`]`(:`)`[ New AD Forest installation`]' -ToScreen
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> installation done."
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

    if ($Flag) { $result = $false } else { $result = $true }

    return $result
}

Function Switch-ADRecycleBin
{
    <#
        .Synopsis
         Enable the Recycle Bin, or ensure it is so.
        
        .Description
         Will perform a query to ensure that the AD Recycle Bin is enable. If not, it will do so if requested.
         Return TRUE if the states is as expected, else return FALSE.
        
        .Parameter DesiredState
         choose one of the two values (enable,disable).

        .Notes
         Version: 01.00 -- Loic.veirman@mssec.fr
         history: 19.08.31 Script creation
    #>
    param(
        # State of AD Recycle Bin
        [Parameter(Mandatory=$true)]
        [ValidateSet("ENABLE","DISABLE")]
        [String]
        $DesiredState
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
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter DESIREDSTATE...: $DesiredState"

    ## Test Options current settings
    if ((Get-ADOptionalFeature -Filter 'name -like "Recycle Bin Feature"').EnabledScopes) 
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Active Directory Recycle Bin is already enabled"
        $result = $true
    }
    else
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Active Directory Recycle Bin is not enabled yet"
        
        if ($DesiredState -eq "ENABLE")
        {
            Try 
            {
                $NoEchoe = Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target (Get-ADForest).Name -WarningAction SilentlyContinue -Confirm:$false
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target " + (Get-ADForest).Name + ' -WarningAction SilentlyContinue -Confirm:$false'
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Active Directory Recycle Bin is enabled"
                $result = $true
            }
            catch 
            {
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---! Error while configuring the active directory Recycle Bin"
                $result = $false
            }
        }
    }

    ##Ensure result is as expected
    if ($result -ne $DesiredState)
    {
        switch ($result)
        {
            $true  {$compl = "is enabled" }
            $false {$compl = "is disabled"}
        }
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---! Error: the active directory Recycle Bin $compl but the expected status was $DesiredState"
        $result = $false
    }    
    
    ## Exit
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> function return RESULT: $Result"
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

    return $result
}

Function Switch-GpoCentralStore
{
    <#
        .Synopsis
         Enable the Centralized GPO repository (aka Central Store), or ensure it is so.
        
        .Description
         Will perform a query to ensure that the GPO Central Store is enable. If not, it will do so if requested.
         Return TRUE if the states is as expected, else return FALSE.
        
        .Parameter DesiredState
         choose one of the two values (enable,disable).

        .Notes
         Version: 01.00 -- Loic.veirman@mssec.fr
         history: 19.08.31 Script creation
    #>
    param(
        # State of AD Recycle Bin
        [Parameter(Mandatory=$true)]
        [ValidateSet("ENABLE","DISABLE")]
        [String]
        $DesiredState
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
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter DESIREDSTATE...: $DesiredState"
    
    ## Test if already enabled
    if (Test-Path "C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions") 
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Central Store path is present"
        ## compare with current state
        if ($DesiredState -eq "ENABLE")
        {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Central Store path is enabled as requested"
            $result = $true
        }
        else 
        {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---! Warning: Central Store path is enabled but this shouldn't be!"
            $result = $false    
        }
    }
    else 
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Central Store path is not enable yet"
        ## Check if installation is needed
        if ($DesiredState -eq "ENABLE")
        {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Robocopy C:\Windows\PolicyDefinitions C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions /MIR (start)"
            $NoEchoe = Robocopy "C:\Windows\PolicyDefinitions" "C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions" /MIR
            
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Robocopy C:\Windows\PolicyDefinitions C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions /MIR (finish)"
            if ((Get-ChildItem "C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions" -Recurse).count -gt 10)
            {
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Seems copying has worked."
                $result = $true
            }
            else 
            {
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---! Error while copying file."
                $result = $false    
            }
        }

        $result = $true

    }

    ## Exit
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> function return RESULT: $Result"
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

    return $result
}

Function Switch-InstantReplication
{
    <#
        .Synopsis
         Enable the Immediate Replication, or ensure it is so.
        
        .Description
         Enable the Immediate Replication, or ensure it is so.
         Return TRUE if the states is as expected, else return FALSE.
        
        .Parameter DesiredState
         choose one of the two values (enable,disable).

        .Notes
         Version: 01.00 -- Loic.veirman@mssec.fr
         history: 19.08.31 Script creation
    #>
    param(
        # State of AD Recycle Bin
        [Parameter(Mandatory=$true)]
        [ValidateSet("ENABLE","DISABLE")]
        [String]
        $DesiredState
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
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter DESIREDSTATE...: $DesiredState"
    
    ## Test if already enabled
    if ($DesiredState -eq "ENABLE")
    {
        #.Check if already enabled.
        if ((Get-ADReplicationSiteLink DEFAULTIPSITELINK -Properties *).options) 
        {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Urgent Replication Options are already enabled with value " + (Get-ADReplicationSiteLink DEFAULTIPSITELINK -Properties *).options 
            $Result = $true
        } 
        Else 
        {
            try
            {
                $NoEchoe = Set-ADReplicationSiteLink DEFAULTIPSITELINK -Replace @{'Options'=1} -WarningAction SilentlyContinue
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Urgent Replication Options is now enabled with value " + (Get-ADReplicationSiteLink DEFAULTIPSITELINK -Properties *).options 
                $Result = $true
            }
            Catch
            {
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---! Urgent Replication failed to be enabled with value 1"
                $Result = $False
            }
        }
    } 
    Else 
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Urgent Replication will not be modified"
        $Result = $true
    }

    ## Exit
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> function return RESULT: $Result"
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

    return $result
}

Function New-ProvisioningOU
{
    <#
        .Synopsis
         Create the an OU to provision new objects.
        
        .Description
         Create the requiered OU to provision new objects and apply them minimal security settings per GPO.
        
        .Parameter RootOU
         Name of the OU to be created at the domain root level.
        
        .Parameter CptrOU
         Name of the child OU under the root provisioning OU that will host new computer objects.
         If empty: the OU will not be created and the default provisioning OU will be the RootOU.
         
        .Parameter UserOU
         Name of the child OU under the root provisioning OU that will host new user objects.
         If empty: the OU will not be created and the default provisioning OU will be the RootOU.

        .Parameter RootDS
         Description to add to the provisioning OU ROOT.        

         .Parameter CptrDS
         Description to add to the provisioning OU COMPUTER.        
         
        .Parameter UserDS
         Description to add to the provisioning OU USER.        

         .Notes
         Version: 01.00 -- Loic.veirman@mssec.fr
         history: 19.09.06 Script creation
    #>
    param(
        [String]$RootOU,
        [String]$CptrOU,
        [String]$UserOU,
        [String]$RootDS,
        [String]$CptrDS,
        [String]$UserDS
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
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter ROOTOU.........: $RootOU"    
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter ROOTDS.........: $RootDS"    
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter CPTROU.........: $CptrOU"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter CPTRDS.........: $CptrDS"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter USEROU.........: $UserOU"    
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter USERDS.........: $UserDS"    

    ## Variable to increment at each OU creation
    $Success = 0
    
    ## Begin with Root OU generation
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---[ Begin Root Provisioning OU creation ]"
    if (!($rootOU)) { 
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------! ERROR: the RootOU parameter has no value!"
        $Result = $false 
    } else {
        Try {
            $test = Get-ADOrganizationalUnit ('OU=' + $RootOU + ',' + (Get-ADDomain).DistinguishedName)
        } Catch {
            $test = $null
        }
        if ($test) {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Success...............: the root OU for provisioning already exists"

            $Success++
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter SUCCESS.....: $Success"

            $RootOUDN = 'OU=' + $RootOU + ',' + (Get-ADDomain).DistinguishedName
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter ROOTOUDN....: $RootOUDN"

        } Else {
            
            try {
                $NoEcho = New-ADOrganizationalUnit -Name $RootOU `
                                                   -Description $RootDS `
                                                   -Path (Get-ADDomain).DistinguishedName `
                                                   -ErrorAction SilentlyContinue `
                                                   -WarningAction SilentlyContinue

                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Success...............: the root OU for provisioning has been created"
                
                $Success++
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter SUCCESS.....: $Success"

                $RootOUDN = 'OU=' + $RootOU + ',' + (Get-ADDomain).DistinguishedName
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter ROOTOUDN....: $RootOUDN"

            } Catch {
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Failure...............: the root OU for provisioning has not been created"
                $Result = $false 
            }
        }
    }
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---[  End Root Provisioning OU creation  ]"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---[  Begin Child Provisioning creation  ]"

    if ($Success -eq 1) {
        ## Create Computer OU as child.
        if ($CptrOU) {
            Try {
                $test = Get-ADOrganizationalUnit ('OU=' + $CptrOU + ',' + $RootOUDN)
            } Catch {
                $test = $null
            }
            if ($test) {
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Success...............: the child OU for provisioning computers already exists"
    
                $Success++
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter SUCCESS.....: $Success"
    
                $NewCptrOU = Get-ADOrganizationalUnit ('OU=' + $CptrOU + ',' + $RootOUDN)
                $NoEcho = redircmp $NewCptrOU
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Default Computer OU...: $NewCptrOU"
    
            } Else {
                
                try {
                    $NoEcho = New-ADOrganizationalUnit -Name $CptrOU `
                                                       -Description $CptrDS `
                                                       -Path $RootOUDN `
                                                       -ErrorAction SilentlyContinue `
                                                       -WarningAction SilentlyContinue
    
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Success...............: the child OU for provisioning computers has been created"
                    
                    $Success++
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter SUCCESS.....: $Success"

                    $NewCptrOU = Get-ADOrganizationalUnit ('OU=' + $CptrOU + ',' + $RootOUDN)
                    $NoEcho = redircmp $NewCptrOU
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Default Computer OU...: $NewCptrOU"
    
                } Catch {
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Failure...............: the child OU for provisioning computers has not been created"
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter SUCCESS.....: $Success"
                }
            }
        } else {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Success...............: no child OU for provisioning computers to be created"
            $Success++
        }

        ## Create User OU as child.
        if ($UserOU) {
            Try {
                $test = Get-ADOrganizationalUnit ('OU=' + $UserOU + ',' + $RootOUDN)
            } Catch {
                $test = $null
            }
            if ($test)  {
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Success...............: the child OU for provisioning users already exists"
    
                $Success++
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter SUCCESS.....: $Success"

                $NewUserOU = Get-ADOrganizationalUnit ('OU=' + $UserOU + ',' + $RootOUDN)
                $NoEcho = redirusr $NewUserOU
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Default User OU.......: $NewUserOU"
    
            } Else {
                
                try {
                    $NoEcho = New-ADOrganizationalUnit -Name $UserOU `
                                                       -Description $UserDS `
                                                       -Path $RootOUDN `
                                                       -ErrorAction SilentlyContinue `
                                                       -WarningAction SilentlyContinue
    
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Success...............: the child OU for provisioning users has been created"
                    
                    $Success++
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter SUCCESS.....: $Success"

                    $NewUserOU = Get-ADOrganizationalUnit ('OU=' + $UserOU + ',' + $RootOUDN)
                    $NoEcho = redirusr $NewUserOU
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Default User OU.......: $NewUserOU"
    
                } Catch {
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Failure...............: the child OU for provisioning users has not been created"
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter SUCCESS.....: $Success"
                }
            }
        } else {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Success...............: no child OU for provisioning users to be created"
            $Success++
        }
    } else {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------! ERROR: the function could not continue and will break."
        $Success++
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> Parameter SUCCESS.....: $Success"
    }

    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---[   End Child Provisioning creation   ]"

    if ($Success -eq 3) { $Result = $true } else {$Result = $false }

    ## Exit
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Function return RESULT: $Result"
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

    return $result
}

Function New-AdvceOUtree
{
    <#
        .Synopsis
            Create OU tree as specified in the reference inputs.
        
        .Description
            Create OU tree as specified in the reference inputs.
        
        .Parameter OUData
            Array contening the OU list. THe input include an index and a list of OU (name,class and version)

            .Notes
            Version: 01.00 -- Loic.veirman@mssec.fr
            history: 19.09.21 Script creation
    #>
    param(
        $OUData,
        $BasePath
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
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter OUData.........: $OUData"    
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter BasePath.......: $BasePath"    

    ## Get index to follow OU creation
    [int]$LastIndex = $OUData['Index']
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Parameter LastIndex......: $LastIndex"

    ## Import xml file with OU build requierment
    Try { 
        [xml]$xmlSkeleton = Get-Content ("$BasePath\Configs\" + $OUData['xml'])
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> xml skeleton file........: " + $OUData['xml']
        $Result = $true

    } Catch {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---! FAILED loading xml skeleton file " + $OUData['xml']
        $Result = $false
    }

    if ($Result) {
        ## The xml file was loaded sucessfully, starting the OU creation loop
        $NoError = $True
        $DomainRootDN = (Get-ADDomain).DistinguishedName
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Parameter DomainRootDN...: $DomainRootDN"
        
        for ($index = 1 ; $index -le $LastIndex ; $index++) {
            
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "------> NEW INDEX.............: $index"
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------> OU DATA............: " + $OUData["$index"]
            
            $OUName = ($OUData["$index"] -split ",")[0]
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------> OU Name............: $OUName"
            
            $OUClas = ($OUData["$index"] -split ",")[1]
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------> OU Class...........: $OUClas"
            
            $OUDesc = ($OUData["$index"] -split ",")[2]
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------> OU Description.....: $OUDesc"

            ## on retrouve le modele demandé dans le fichier xml
            $xmlData = $xmlSkeleton.ouTree.OU | Where-Object { $_.class -eq $OUClas }

            ## Si le modele est trouvé, on vérifie que l'OU parente n'existe pas, sinon on la créée.
            if ($xmlData) {
                ## Test de présence de l'OU
                Try {
                    $NoEchoe = Get-ADOrganizationalUnit "OU=$OUName,$DomainRootDN"
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------> OU Creation........: Already Exists (skipped)"
                    $NoEchoe = Set-ADOrganizationalUnit "OU=$OUName,$DomainRootDN" -Description $OUDesc
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------> OU Description.....: Updated to $OUDesc"
                ## Test échoue : création de l'OU
                } Catch {
                    $NoEchoe = New-ADOrganizationalUnit $OUName -Path $DomainRootDN -Description $OUDesc
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------> OU Creation........: Success"
                }
                ## Une fois l'OU créée, on appelle la fonction récursive qui va créer les OU filles.
                ## Cette fonction est particulière car elle renvoie le log de fonction en retour.
                $MyOUs   = $xmlData.ChildOU

                foreach ($myOU in $myOUs) {
                    Try {
                        $NoEchoe = Get-ADOrganizationalUnit ("OU=" + $myOU.Name + ",OU=$OUName,$DomainRootDN")
                        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------> OU Creation........: " + $myOU.Name + ": Already Exists (skipped)"
                        $NoEchoe = Set-ADOrganizationalUnit ("OU=" + $myOU.Name + ",OU=$OUName,$DomainRootDN") -Description $myOU.Description
                        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------> OU Description.....: " + $myOU.Name + ": Updated to " + $myOU.Description
                    ## Test échoue : création de l'OU
                    } Catch {
                        $NoEchoe = New-ADOrganizationalUnit $myOU.Name -Path "OU=$OUName,$DomainRootDN" -Description $myOU.Description
                        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------> OU Creation........: " + $myOU.Name + ": Success"
                    }

                    ## Hop, here goes the infinite loop!
                    $myChildOUs = $myOU.childOU
                    if ($myChildOUs) {  
                        foreach ($ChildOU in $myChildOUs) {
                            $dbgMess += New-ChildOU -ChildOU $ChildOU -ParentOU ("OU=" + $MyOU.Name + ",OU=$OUName,$DomainRootDN")
                        }
                    }
                }

                #$dbgMess += New-ChildOUTree -OUData $xmlData -PArentOU "OU=$OUName,$DomainRootDN"

            } else {
                ## pas de données ! On quitte et on l'indique dans le log de debug.
                $NoError = $False
                $index = $LastIndex + 10
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---------! Error! the requested Class/version isn't present in the xml file."
            }
        }
    } 
    
    ## Exit
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Function return RESULT: $Result"
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

    return $NoError
}

Function New-ChildOU
{
    <#
        .Synopsis
         Create OU tree as specified in the reference inputs.
            
        .Description
         Create OU tree as specified in the reference inputs.
            
        .Parameter OUData
            Array contening the OU list. THe input include an index and a list of OU (name,class and version)

            .Notes
            Version: 01.00 -- Loic.veirman@mssec.fr
            history: 19.09.21 Script creation
    #>
    param(
        $ChildOU,
        [string]$ParentOU 
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
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter ChildOU........: $ChildOU"    
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter ParentOU.......: $ParentOU"   

    Try {
        ## on test si l'ou existe deja
        $NoEchoe = Get-ADOrganizationalUnit ("OU=" + $ChildOU.Name + ",$ParentOU")
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> OU Creation........: " + $ChildOU.Name + ": Already Exists (skipped)"

        $NoEchoe = Set-ADOrganizationalUnit ("OU=" + $ChildOU.Name + ",$ParentOU") -Description $ChildOU.Description
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> OU Description.....: " + $ChildOU.Name + ": Updated to " + $ChildOU.Description

    } Catch {
        ## Test échoue : création de l'OU
        $NoEchoe = New-ADOrganizationalUnit $ChildOU.Name -Path "$ParentOU" -Description $ChildOU.Description
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "----> OU Creation........: " + $ChildOU.Name + ": Success"
    }                
            
    ## On verifie si des sous-ou existent
    $myChildOUs = $ChildOU.childOU
    if ($myChildOUs) {  
        foreach ($myChildOU in $myChildOUs) {
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> OU Child Tree......: Child Tree detected"
            $DbgMess += New-ChildOU -ChildOU $myChildOU -ParentOU $("OU=" + $ChildOU.Name + ",$ParentOU")
        }
    } else {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> OU Child Tree......: No Child Tree detected"
    }

    ## Exit
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Function return RESULT: $Result"
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
    
    return ((Get-Date -UFormat "%Y-%m-%d %T ") + "---------> Tree Creation.......: " + $myOU.Name + ": Success")
}
Export-ModuleMember -Function *