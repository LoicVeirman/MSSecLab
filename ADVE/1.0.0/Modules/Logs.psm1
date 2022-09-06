## This module contains functions related to log write and/or display.

## Module write-logInfo
Function write-logInfo
{
    <# 
        .Synopsis
        Write log to the log file.

        .Description
        This script will add to a the log file the message (adding a timestamp). When displaying on a screen, use the following commands:
        - `[ and `]: indicate to use the toggle color 
        - `{ and `}: indicate to use the reverse color
        - `( and `): indicate to use the secondary color
        - `n: will perform a line return to the log or a multiple line display on screen
        - `t: will perform a tab indentation on screen

        .Parameter LogMessage
        Message to be added to the log. Special character are removed when written to the log file.

        .Parameter ToScreen
        Used to perform a display on screen too. Will perform analysis on special char to handle a proper display.

        .Parameter Scheme
        Color Scheme to be used when a display is set on screen. If not specified, will use the default one.

        .Parameter LogFile
        Path to the log file itself. If not specified, then will use the $[GLOBAL]LogFile variable instead.

        .Notes
        Version 01.00: 24/08/2019. 
            History: Function creation.
    #>

    ## Parameters 
    Param (
        # LogMessage to display or write
        [Parameter(Mandatory=$true)]
        [string]
        $LogMessage,

        # Indicates to display on screen
        [Parameter(Mandatory=$false)]
        [switch]
        $ToScreen,

        # Allow to specify the color scheme to use
        [Parameter(mandatory=$false)]
        [ValidateSet('OK and KO','START and STOP','WARNING')]
        [string]
        $Scheme,

        # Logfile to output to
        [Parameter(Mandatory=$false)]
        [String]
        $LogFile
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
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter LOGMESSAGE.....: $LogMessage"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter TOSCREEN.......: $ToScreen"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter SCHEME.........: $Scheme"
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> parameter LogFile........: $LogFile"

    ## Generate log file message
    $FileMsg  = $LogMessage -replace '`[\[{()}\]]',''
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Variable FILEMSG.........: $FileMsg"

    ## Output to file by parsing input through `n special char
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "===| INIT PARSING FILEMSG"

    if (!($LogFile)) 
    { 
        if (!($Global:LogFile))
        {
            $LogFile  = '_ModuleError_{0}.log' -f $MyInvocation.MyCommand
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---! Error: variable LOGFILE is null. Replaced by '$LogFile'."    
        }
        else 
        {
            $LogFile  = $Global:LogFile
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---! Warning: variable LOGFILE is null. Using global variable content '$Global:LogFile'."    
        }
    }

    foreach ($line in ($FileMsg -split '`n'))
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Adding variable LINE.....: $LINE"
        ## Get timestamp then add to file
        $LogTime = Get-Date -Format "yyyy/MM/dd`tHH:mm:ss`t"
        ($LogTime + $line) | Out-File .\Logs\$LogFile -Encoding utf8 -Append -Force
    }
    
    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "===| STOP PARSING FILEMSG"

    ## If needed, verbosely display to screen
    if ($ToScreen)   
    {
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "===| INIT  SCREEN  OUTPUT"
        
        ## Prepare color scheme. Color Scheme is a set of attributes from write-host.
        Switch ($Scheme)
        {
            ## this colorset will write to white, gray or cyan. Use for common display.
            Default     { $Normal    = @{ foregroundColor = "white"     ; backgroundColor = "black" } 
                          $toggle    = @{ foregroundColor = "cyan"      ; backgroundColor = "black" }
                          $reverse   = @{ foregroundColor = "black"     ; backgroundColor = "white" }
                          $Secondary = @{ foregroundColor = "DarkGray"  ; backgroundColor = "black" }
                        }
            ## this colorset will highlight as green or red. Use for 'good/bad' display
            'OK and KO' { $Normal    = @{ foregroundColor = "white" ; backgroundColor = "black" } 
                          $toggle    = @{ foregroundColor = "green" ; backgroundColor = "black" }
                          $reverse   = @{ foregroundColor = "black" ; backgroundColor = "white" }
                          $Secondary = @{ foregroundColor = "red"   ; backgroundColor = "black" }
                        }
            ## this colorset will highlight as yellow or magenta. Use for alerting display
            'WARNING' { $Normal    = @{ foregroundColor = "white"  ; backgroundColor = "black"  } 
                        $toggle    = @{ foregroundColor = "yellow" ; backgroundColor = "black"  }
                        $reverse   = @{ foregroundColor = "black"  ; backgroundColor = "yellow" }
                        $Secondary = @{ foregroundColor = "magenta"; backgroundColor = "black"  }
                      }
            ## this colorset will highlight as Yellow or Green. Use for start program, stop or highlight a special value display
            'START and STOP' { $Normal    = @{ foregroundColor = "Green"  ; backgroundColor = "black" } 
                               $toggle    = @{ foregroundColor = "Yellow" ; backgroundColor = "black" }
                               $reverse   = @{ foregroundColor = "black"  ; backgroundColor = "green" }
                               $Secondary = @{ foregroundColor = "Magenta"; backgroundColor = "black" }
                             }
        }
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Color Scheme Values...: NORMAL    = " + $Normal.foregroundColor    + " on " + $Normal.backgroundColor
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Color Scheme Values...: TOGGLE    = " + $toggle.foregroundColor    + " on " + $toggle.backgroundColor
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Color Scheme Values...: REVERSE   = " + $reverse.foregroundColor   + " on " + $reverse.backgroundColor
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Color Scheme Values...: SECONDARY = " + $Secondary.foregroundColor + " on " + $Secondary.backgroundColor

        ## Analyzing text message... Will split on ` character. The first parameter is then analyzed for each acting.
        $LogMsgArr = $LogMessage -split '`n'
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Message splitted in...: " + $LogMsgArr.count + " line(s)"
        foreach ($line in $LogMsgArr)
        {
            ## Add a white space at begining for ease of reading
            write-host " " @Normal -NoNewline            
            
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> New LINE content......: " + $Line
            
            $LineData = $line -split '`'
            $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "---> Message split on `....: " + $LineData.count + " part(s)"
            for ($i = 0 ; $i -lt $LineData.count ; $i++)
            {
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "-------> Part number...: $i" 
                $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "-------> Part content..: " + $LineData[$i] 
                ## Check by RegEx if this is a highlight section that begin
                if ($LineData[$i][0] -match '[{\[(]')
                {
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> found regex...: ' + $LineData[$i][0]
                    ## If nothing, then move next iteration
                    if ($LineData[$i].Length -eq 0) 
                    { 
                        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> String Length.: ' + $LineData[$i].Length
                        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> Move to next line.'
                        continue 
                    }

                    ## Else check which color settings to use
                    Switch ($LineData[$i][0])
                    {
                        '[' { Write-Host $LineData[$i].Substring(1) @toggle    -NoNewline ; $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> Output Color..: toggle'    }
                        '{' { Write-Host $LineData[$i].Substring(1) @reverse   -NoNewline ; $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> Output Color..: reverse'   }
                        '(' { Write-Host $LineData[$i].Substring(1) @secondary -NoNewline ; $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> Output Color..: secondary' }
                    }
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> Output text...: ' + $LineData[$i].Substring(1)
                }

                ElseIf ($LineData[$i][0] -match '[]})]')
                {
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> found regex..: ' + $LineData[$i][0]
                    Write-Host $LineData[$i].Substring(1) @normal -NoNewline
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> Output Color..: normal'
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> Output Text...: ' + $LineData[$i].Substring(1)
                }
                
                Else 
                { 
                    Write-Host $LineData[$i] @normal -NoNewline
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> Output Color..: normal'
                    $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + '-------> Output Text...: ' + $LineData[$i]
                }
            }
            ## Final write-host to end the line
            Write-Host "" @Normal
        }
        $dbgMess += (Get-Date -UFormat "%Y-%m-%d %T ") + "===| STOP  SCREEN  OUTPUT"        
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
}

## Export module members
Export-ModuleMember -Function *