<#
    .SYNOPSIS
    This script will add users to the lab domain.

    .PARAMETER ConfigFile
    This parameter will teach the script to use a specific configuration file for Domain/Forest information. 
    By default, it will use ActiveDirectory-Configuration.ini in .\Inputs.
    
    .PARAMETER FileName
    Name of the csv file put in the .\inputs folder.

#>

Param( 
    # Input File for configuration
    [Parameter(Mandatory=$False)]
    [string]
    $ConfigFile='ActiveDirectory-configuration.ini',
    
    # Input File for users list
    [Parameter(Mandatory=$True)]
    [string]
    $FileName 
    )

## Check if os is 2k8r2 or not. If so, loads ad mods.
if ((Get-WmiObject Win32_OperatingSystem).caption -like "*2008 R2*") 
{
    import-module ServerManager,ActiveDirectory,GroupPolicy
}

## Try to load the csv file
if (test-path .\Inputs\$FileName) 
{
    ## Loading file
    $Users = Import-Csv .\Inputs\$FileName -Delimiter ";"
    
    ## Create users
    foreach ($user in $Users)
    {
        ## Test if user already exists ; if so, no acting.
        $check = try { Get-ADUser $user.samaccountname } Catch { $null }
        if ($check)
        {
            ## User exists
            Write-Host "SKIPPED`t" -ForegroundColor Yellow -NoNewline
                        
            Write-Host "User " -NoNewline
            Write-Host $User.samAccountName -NoNewline -ForegroundColor Yellow
            Write-Host " already exists"
        } else {
            ## User does not exists
            switch ($user.enabled)
			{
				"vrai" { $enbd = $true  }
				"faux" { $enbd = $false }
			}
			Try {
                $tmp = New-ADUser   -Path ($user.BaseOU + "," + (Get-ADDomain).DistinguishedName) `
                                    -USerPrincipalName ($user.samAccountName + "@" + (Get-ADDomain).DNSRoot) `
									-SamAccountName $user.samaccountname `
                                    -Name $user.Name `
                                    -GivenName $user.givenName `
                                    -Surname $user.Surname `
                                    -AccountPassword (ConvertTo-SecureString -AsPlainText $user.AccountPassword -Force) `
                                    -Company $user.company `
                                    -Title $user.title `
                                    -State $user.state `
                                    -City $user.city `
                                    -Description $user.description `
                                    -EmployeeNumber $user.EmployeeNumber `
                                    -Department $user.Departement `
                                    -DisplayName $user.DisplayName `
                                    -Country $user.country `
                                    -PostalCode $user.PostalCode `
                                    -Enabled $enbd
                                    
                $code  = "SUCCESS"
                $color = "Green"

            } Catch {
                $code  = "FAILURE"
                $color = "Red"

            } Finally {
                Write-Host "$code`t" -ForegroundColor $color -NoNewline
                Write-Host "User " -NoNewline
				Write-Host $user.samaccountname -ForegroundColor Yellow -NoNewline
                Write-Host " " -NoNewline
                switch ($code)
                {
                    "SUCCESS" { Write-Host "was created successfully" }
                    "FAILURE" { Write-Host "failed to be created !" -ForegroundColor red }
                }
            }
		}
    } 
} else {
    Write-Error "The specified file was not found in the input folder."
}

Write-Host "Script's done" -ForegroundColor Cyan