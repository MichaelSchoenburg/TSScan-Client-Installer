# TSScan-Client-Installer
PowerShell-Skript, welches den TSScan Client installiert (RMM kompatibel).

# Hilfe

NAME
    .\TSScan-Client-Installer.ps1
    
SYNOPSIS
    TSScan-Client-Installer
    
    
SYNTAX
    .\TSScan-Client-Installer.ps1 [<CommonParameters>]
    
    
DESCRIPTION
    PowerShell-Skript, welches den TSScan Client installiert (RMM kompatibel).
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
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
    
    
OUTPUTS
    Exit Code 0 = Erfolgreich
    Exit Code 1 = Fehler
    Exit Code 2 = Warnung
    
    
NOTES
    
    
        Author: Michael Schönburg
        Version: v1.0
        Last Edit: 20.03.2025
        
        This projects code loosely follows the PowerShell Practice and Style guide, as well as Microsofts PowerShell scripting performance considerations.
        Style guide: https://poshcode.gitbook.io/powershell-practice-and-style/
        Performance Considerations: https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.1
    
    
RELATED LINKS
    GitHub: https://github.com/MichaelSchoenburg/TSScan-Client-Installer


