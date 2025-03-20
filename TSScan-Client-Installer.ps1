<#
.SYNOPSIS
    TSScan-Client-Installer

.DESCRIPTION
    PowerShell-Skript, welches den TSScan Client installiert (RMM kompatibel).

.LINK
    GitHub: https://github.com/MichaelSchoenburg/TSScan-Client-Installer

.INPUTS
    Beispiel für die Verwendung in einem RMM (z. B. Riverbird):
    Folgende Variablen müssen im Kontext des Skripts während der Laufzeit des Skripts gesetzt werden:

    Wenn $Interactive nicht definiert wurde, geht das Skript davon aus, dass es interaktiv ausgeführt wird. 
    Wenn irgendetwas beliebiges gesetzt wird, wird das Skript davon ausgehen, dass es nicht interaktiv ausgeführt wird.
    $Interactive = "irgendetwas"

    Wenn $ResultPushOver auf 0 gesetzt wird, wird eine PushOver-Benachrichtigung versendet, wenn das Skript erfolgreich durchgelaufen ist.
    Wenn $ResultPushOver auf 1 gesetzt wird, wird keine PushOver-Benachrichtigung versendet.
    $ResultPushOver = 0

    $ApiToken ist der API-Token von PushOver.
    $ApiToken = "API-Token"

    $UserKey ist der User Key aka. User Token von PushOver.
    $UserKey = "User-Key"

.OUTPUTS
    Exit Code 0 = Erfolgreich
    Exit Code 1 = Fehler
    Exit Code 2 = Warnung

.NOTES
    Author: Michael Schönburg
    Version: v1.0
    Last Edit: 20.03.2025
    
    This projects code loosely follows the PowerShell Practice and Style guide, as well as Microsofts PowerShell scripting performance considerations.
    Style guide: https://poshcode.gitbook.io/powershell-practice-and-style/
    Performance Considerations: https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.1
#>

#region INITIALIZATION
<# 
    Libraries, Modules, ...
#>



#endregion INITIALIZATION
#region DECLARATIONS
<#
    Declare local variables and global variables
#>

# Statische Deklarationen
$DownloadUrl = "https://www.terminalworks.com/downloads/tsscan/TSScan_client.exe"
$Path = "C:\TSD.CenterVision\Software\TSScan Client"
$ExeName = "TSScan_client.exe"
$LogName = "TSScan_Client_Install.log"
$PathExeSetup = Join-Path -Path $Path -ChildPath $ExeName
$PathLog = Join-Path -Path $Path -ChildPath $LogName

# Falls das Skript interaktiv ausgeführt wird (ist der Fall, wenn $Interactive nicht definiert wurde), wird $Interactive auf $true gesetzt.
if ($null -eq $Interactive) {
    $Interactive = $true
} else {
    $Interactive = $false
}

#endregion DECLARATIONS
#region FUNCTIONS
<# 
    Declare Functions
#>

function Write-ConsoleLog {
    <#
    .SYNOPSIS
    Protokolliert ein Ereignis in der Konsole.
    
    .DESCRIPTION
    Schreibt Text in die Konsole mit dem aktuellen Datum (US-Format) davor.
    
    .PARAMETER Text
    Ereignis/Text, der in die Konsole ausgegeben werden soll.
    
    .EXAMPLE
    Write-ConsoleLog -Text 'Subscript XYZ aufgerufen.'
    
    Lange Form
    .EXAMPLE
    Log 'Subscript XYZ aufgerufen.'
    
    Kurze Form
    #>
    [alias('Log')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        Position = 0)]
        [string]
        $Text
    )

    if ($Interactive) {
        # Aktuelle VerbosePreference speichern
        $VerbosePreferenceBefore = $VerbosePreference

        # Verbose-Ausgabe aktivieren
        $VerbosePreference = 'Continue'

        # Verbose-Ausgabe schreiben
        Write-Verbose "$( Get-Date -Format 'MM/dd/yyyy HH:mm:ss' ) - $( $Text )"

        # Aktuelle VerbosePreference wiederherstellen
        $VerbosePreference = $VerbosePreferenceBefore
    } else {
        Write-Output "$( Get-Date -Format 'MM/dd/yyyy HH:mm:ss' ) - $( $Text )"
    }
}

function Get-TSScanClientInstalled {
    if (Get-Package -Name "TSScan Client" -ErrorAction SilentlyContinue) {
        return $true
    } else {
        return $false
    }
}

#endregion FUNCTIONS
#region EXECUTION
<# 
    Script entry point
#>

if ($Interactive) {
    Write-Host "
  ______ _____ _____                        ______ __ _               __     ____              __          __ __           
 /_  __// ___// ___/ _____ ____ _ ____     / ____// /(_)___   ____   / /_   /  _/____   _____ / /_ ____ _ / // /___   _____
  / /   \__ \ \__ \ / ___// __ `// __ \   / /    / // // _ \ / __ \ / __/   / / / __ \ / ___// __// __ `// // // _ \ / ___/
 / /   ___/ /___/ // /__ / /_/ // / / /  / /___ / // //  __// / / // /_   _/ / / / / /(__  )/ /_ / /_/ // // //  __// /    
/_/   /____//____/ \___/ \__,_//_/ /_/   \____//_//_/ \___//_/ /_/ \__/  /___//_/ /_//____/ \__/ \__,_//_//_/ \___//_/     
                                                                                                                           
                                                                                                       by Michael Schönburg" -ForegroundColor Yellow
}
# Font from https://patorjk.com/software/taag

#  TSScan benötigt mindestens ein .NET 2.0-Framework, damit es richtig funktioniert.

# Überprüfen, ob der TSScan Client bereits installiert ist
if (Get-TSScanClientInstalled) {
    Log "Der TSScan Client ist bereits installiert. Das Skript wird erfolgreich abgebrochen."
    Exit 0
} else {
    Log "Der TSScan Client ist noch nicht installiert. Das Skript wird fortgesetzt."
    try {
        <# 
            Installationsordner
        #>

        try {
            # Überprüfen, ob der Installationsordner existiert
            Log "Überprüfen, ob der Installationsordner existiert..."

            if (Test-Path -Path $Path) {
                Log "Installationsordner existiert bereits."
            } else {
                Log "Lege Installationsordner an..."
                $null = New-Item -Path $Path -ItemType Directory -ErrorAction Stop # Terminierender Error, falls der Ordner nicht erstellt werden kann.
            }
        } catch {
            throw "Der Installationsordner konnte nicht erstellt werden. Fehler: $( $_.Exception.Message )"
        }

        <# 
            Download
        #>

        # Überprüfen, ob der TSScan Client bereits heruntergeladen wurde, falls nicht, herunterladen
        Log 'Teste, ob der TSScan Client Installer bereits heruntergeladen wurde...'

        if (-not (Test-Path $PathExeSetup)) {
            Log 'Lade den TSScan Client Installer herunter...'

            # Setze TLS-Version auf 1.1 und 1.2 zwecks Download
            $AllProtocols = [System.Net.SecurityProtocolType]'Tls11,Tls12'
            [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
            
            try {
                # Download des TSScan Client Installers
                $response = Invoke-WebRequest -Uri $DownloadUrl -OutFile $PathExeSetup -PassThru -UseBasicParsing
                Log 'TSScan Client Installer erfolgreich heruntergeladen...'
            } catch {
                if( $_.Exception.Response.StatusCode.Value__ -eq 404 ) {
                    throw "TSScan Client Installer kann nicht heruntergeladen werden. 404 Nicht gefunden. Vielleicht ist die URL nicht mehr aktuell oder es liegt eine Störung bei terminalworks vor, sodass der Download nicht zur Verfügung steht?"
                } else {
                    throw "Unbekannter Fehler beim Herunterladen des TSScan Client Installers. Response Code: $( $_.Exception.Response.StatusCode.Value__ ) Error: $( $_.Exception.Message )"
                }
            }
        } else {
            Log "TSScan Client Installer bereits heruntergeladen."
        }

        <# 
            Installation
        #>

        try {
            Log "Starte Installer..."

            $arguments = "/VerySilent /SuppressMsgBoxes /Log /Log=`"$PathLog`" /NoRestart /NoCloseApplications"
            Start-Process $PathExeSetup -ArgumentList $arguments -Wait

            # Setup Command Line Parameters
            # The Setup program accepts optional command line parameters. These can be useful to system administrators, and to other programs calling the Setup program.
            
            # For more detailed information, please visit
            # https://jrsoftware.org/ishelp/index.php?topic=setupcmdline

            # Also see Uninstaller Command Line Parameters.

            # /HELP, /?
            # Shows a summary of this information. Ignored if the UseSetupLdr [Setup] section directive was set to no.

            # /SP-
            # Disables the This will install... Do you wish to continue? prompt at the beginning of Setup. Of course, this will have no effect if the DisableStartupPrompt [Setup] section directive was set to yes.

            # /SILENT, /VERYSILENT
            # Instructs Setup to be silent or very silent. When Setup is silent the wizard and the background window are not displayed but the installation progress window is. When a setup is very silent this installation progress window is not displayed. Everything else is normal so for example error messages during installation are displayed and the startup prompt is (if you haven't disabled it with DisableStartupPrompt or the '/SP-' command line option explained above).

            # If a restart is necessary and the '/NORESTART' command isn't used (see below) and Setup is silent, it will display a Reboot now? message box. If it's very silent it will reboot without asking.

            # /SUPPRESSMSGBOXES
            # Instructs Setup to suppress message boxes. Only has an effect when combined with '/SILENT' or '/VERYSILENT'.

            # The default response in situations where there's a choice is:

            # Yes in a 'Keep newer file?' situation.
            # No in a 'File exists, confirm overwrite.' situation.
            # Abort in Abort/Retry situations.
            # Cancel in Retry/Cancel situations.
            # Yes (=continue) in a DiskSpaceWarning/DirExists/DirDoesntExist/NoUninstallWarning/ExitSetupMessage/ConfirmUninstall situation.
            # Yes (=restart) in a FinishedRestartMessage/UninstalledAndNeedsRestart situation.
            # The recommended choice in a PrivilegesRequiredOverridesAllowed=dialog situation.
            # 5 message boxes are not suppressible:

            # The About Setup message box.
            # The Exit Setup? message box.
            # The FileNotInDir2 message box displayed when Setup requires a new disk to be inserted and the disk was not found.
            # Any (error) message box displayed before Setup (or Uninstall) could read the command line parameters.
            # Any task dialog or message box displayed by [Code] support functions TaskDialogMsgBox and MsgBox.
            # /ALLUSERS
            # Instructs Setup to install in administrative install mode. Only has an effect when the [Setup] section directive PrivilegesRequiredOverridesAllowed allows the commandline override.

            # /CURRENTUSER
            # Instructs Setup to install in non administrative install mode. Only has an effect when the [Setup] section directive PrivilegesRequiredOverridesAllowed allows the commandline override.

            # /LOG
            # Causes Setup to create a log file in the user's TEMP directory detailing file installation and [Run] actions taken during the installation process. This can be a helpful debugging aid. For example, if you suspect a file isn't being replaced when you believe it should be (or vice versa), the log file will tell you if the file was really skipped, and why.

            # The log file is created with a unique name based on the current date. (It will not overwrite or append to existing files.)

            # The information contained in the log file is technical in nature and therefore not intended to be understandable by end users. Nor is it designed to be machine-parsable; the format of the file is subject to change without notice.

            # /LOG="filename"
            # Same as /LOG, except it allows you to specify a fixed path/filename to use for the log file. If a file with the specified name already exists it will be overwritten. If the file cannot be created, Setup will abort with an error message.

            # /NOCANCEL
            # Prevents the user from cancelling during the installation process, by disabling the Cancel button and ignoring clicks on the close button. Useful along with '/SILENT' or '/VERYSILENT'.

            # /NORESTART
            # Prevents Setup from restarting the system following a successful installation, or after a Preparing to Install failure that requests a restart. Typically used along with /SILENT or /VERYSILENT.

            # /RESTARTEXITCODE=exit code
            # Specifies a custom exit code that Setup is to return when the system needs to be restarted following a successful installation. (By default, 0 is returned in this case.) Typically used along with /NORESTART. See also: Setup Exit Codes

            # /CLOSEAPPLICATIONS
            # Instructs Setup to close applications using files that need to be updated by Setup if possible.

            # /NOCLOSEAPPLICATIONS
            # Prevents Setup from closing applications using files that need to be updated by Setup. If /CLOSEAPPLICATIONS was also used, this command line parameter is ignored.

            # /FORCECLOSEAPPLICATIONS
            # Instructs Setup to force close when closing applications.

            # /NOFORCECLOSEAPPLICATIONS
            # Prevents Setup from force closing when closing applications. If /FORCECLOSEAPPLICATIONS was also used, this command line parameter is ignored.

            # /LOGCLOSEAPPLICATIONS
            # Instructs Setup to create extra logging when closing applications for debugging purposes.

            # /RESTARTAPPLICATIONS
            # Instructs Setup to restart applications if possible.

            # /NORESTARTAPPLICATIONS
            # Prevents Setup from restarting applications. If /RESTARTAPPLICATIONS was also used, this command line parameter is ignored.

            # /LOADINF="filename"
            # Instructs Setup to load the settings from the specified file after having checked the command line. This file can be prepared using the '/SAVEINF=' command as explained below.

            # Don't forget to use quotes if the filename contains spaces.

            # /SAVEINF="filename"
            # Instructs Setup to save installation settings to the specified file.

            # Don't forget to use quotes if the filename contains spaces.

            # /LANG=language
            # Specifies the language to use. language specifies the internal name of the language as specified in a [Languages] section entry.

            # When a valid /LANG parameter is used, the Select Language dialog will be suppressed.

            # /DIR="x:\dirname"
            # Overrides the default directory name displayed on the Select Destination Location wizard page. A fully qualified pathname must be specified. May include an "expand:" prefix which instructs Setup to expand any constants in the name. For example: '/DIR=expand:{autopf}\My Program'.

            # /GROUP="folder name"
            # Overrides the default folder name displayed on the Select Start Menu Folder wizard page. May include an "expand:" prefix, see '/DIR='. If the [Setup] section directive DisableProgramGroupPage was set to yes, this command line parameter is ignored.

            # /NOICONS
            # Instructs Setup to initially check the Don't create a Start Menu folder check box on the Select Start Menu Folder wizard page.

            # /TYPE=type name
            # Overrides the default setup type.

            # If the specified type exists and isn't a custom type, then any /COMPONENTS parameter will be ignored.

            # /COMPONENTS="comma separated list of component names"
            # Overrides the default component settings. Using this command line parameter causes Setup to automatically select a custom type. If no custom type is defined, this parameter is ignored.

            # Only the specified components will be selected; the rest will be deselected.

            # If a component name is prefixed with a "*" character, any child components will be selected as well (except for those that include the dontinheritcheck flag). If a component name is prefixed with a "!" character, the component will be deselected.

            # This parameter does not change the state of components that include the fixed flag.

            # Example:
            # Deselect all components, then select the "help" and "plugins" components:
            # /COMPONENTS="help,plugins"
            # Example:
            # Deselect all components, then select a parent component and all of its children with the exception of one:
            # /COMPONENTS="*parent,!parent\child"
            # /TASKS="comma separated list of task names"
            # Specifies a list of tasks that should be initially selected.

            # Only the specified tasks will be selected; the rest will be deselected. Use the /MERGETASKS parameter instead if you want to keep the default set of tasks and only select/deselect some of them.

            # If a task name is prefixed with a "*" character, any child tasks will be selected as well (except for those that include the dontinheritcheck flag). If a task name is prefixed with a "!" character, the task will be deselected.

            # Example:
            # Deselect all tasks, then select the "desktopicon" and "fileassoc" tasks:
            # /TASKS="desktopicon,fileassoc"
            # Example:
            # Deselect all tasks, then select a parent task and all of its children with the exception of one:
            # /TASKS="*parent,!parent\child"
            # /MERGETASKS="comma separated list of task names"
            # Like the /TASKS parameter, except the specified tasks will be merged with the set of tasks that would have otherwise been selected by default.

            # If UsePreviousTasks is set to yes, the specified tasks will be selected/deselected after any previous tasks are restored.

            # Example:
            # Keep the default set of selected tasks, but additionally select the "desktopicon" and "fileassoc" tasks:
            # /MERGETASKS="desktopicon,fileassoc"
            # Example:
            # Keep the default set of selected tasks, but deselect the "desktopicon" task:
            # /MERGETASKS="!desktopicon"
            # /PASSWORD=password
            # Specifies the password to use. If the [Setup] section directive Password was not set, this command line parameter is ignored.

            # When an invalid password is specified, this command line parameter is also ignored.

            # Überprüfen, ob die Installation erfolgreich war
            if (Get-TSScanClientInstalled) {
                Log "TSScan Client wurde erfolgreich installiert."
            } else {
                throw "TSScan Client-Installation lief ohne Fehler durch. Bei der anschließenden Prüfen konnte jedoch nicht bestätigt werden, dass der TSScan Client installiert ist."
            }

            # Nur wenn alles erfolgreich durchgelaufen ist, wird der ExitCode auf 0 gesetzt
            $ExitCode = 0
        } catch {
            throw "TSScan Client konnte nicht installiert werden. Fehler: $( $_.Exception.Message )"
        }
    } catch {
        Log "Ein Fehler ist aufgetreten. Das Skript wird abgebrochen. Fehler: $( $_.Exception.Message )"
        Log "Hier das Installationsprotokoll:"
        Get-Content -Path $PathLog
        $ExitCode = 1
    } finally {
        # PushOver Notification
        if ($ResultPushOver -eq 0) {
            $apiKeyUrl = "https://api.pushover.net/1/messages.json"
        
            switch ($ExitCode) {
                0 { $message = "Der TSScan Client wurde erfolgreich auf dem Computer $( $env:COMPUTERNAME ) installiert." }
                1 { $message = "Bei der Installation des TSScan Clients auf dem Computer $( $env:COMPUTERNAME ) ist folgender Fehler aufgetreten: $( $_.Exception.Message )" }
            }

            $body = @{
                "token" = $ApiToken
                "user" = $UserKey
                "message" = $message
            } | ConvertTo-Json
            
            $header = @{
                "Content-Type" = "application/json"
            }
            
            Invoke-RestMethod -Uri $apiKeyUrl -Method 'Post' -Body $body -Headers $header
        }

        # ExitCode setzen und Skript beenden
        Exit $ExitCode
    }
}

#endregion EXECUTION