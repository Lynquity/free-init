Install-Module -Name PowerShell-Yaml -Scope CurrentUser -Force

Import-Module PowerShell-Yaml

# Überprüfen, ob das Skript mit Administratorrechten ausgeführt wird
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Administratorrechte erforderlich. Starte das Skript mit Administratorrechten neu..."
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Überprüfen, ob die Datei 'init.bat' existiert
$initFile = Join-Path -Path $PSScriptRoot -ChildPath "init.bat"

If (-Not (Test-Path $initFile)) {
    Write-Host "Fehler: Die Datei 'init.bat' wurde im Verzeichnis '...' nicht gefunden."
    Pause
    Exit
}

# Überprüfen, ob das Zielverzeichnis existiert
$system32 = "C:\Windows\System32"
If (-Not (Test-Path $system32)) {
    Write-Host "Fehler: Zielverzeichnis '$system32' existiert nicht."
    Pause
    Exit
}

# Verschiebe 'init.bat' nach System32
Write-Host "Verschiebe 'init.bat' nach '$system32'..."
Move-Item -Path $initFile -Destination $system32 -Force

# Prüfen ob Verschiebung erfolgreich war
If (Test-Path (Join-Path $system32 "init.bat")) {
    Write-Host "Die Datei 'init.bat' wurde erfolgreich nach '$system32' verschoben!"
}
Else {
    Write-Host "Fehler beim Verschieben der Datei 'init.bat'."
}

# Dateien aus 'program' nach 'C:\Windows\System32\ELW\init' verschieben
$sourceProgram = Join-Path -Path $PSScriptRoot -ChildPath "program"
$destinationProgram = "C:\Windows\System32\ELW\init"

If (-Not (Test-Path $sourceProgram)) {
    Write-Host "Fehler: Quellverzeichnis '$sourceProgram' existiert nicht."
    Pause
    Exit
}

If (-Not (Test-Path $destinationProgram)) {
    Write-Host "Erstelle den Ordner '$destinationProgram'..."
    New-Item -Path $destinationProgram -ItemType Directory -Force | Out-Null
}

Write-Host "Verschiebe alle Dateien von '$sourceProgram' nach '$destinationProgram'..."
Move-Item -Path (Join-Path $sourceProgram "*") -Destination $destinationProgram -Force -ErrorAction Stop

Write-Host "Alle Dateien wurden erfolgreich verschoben!"

# Dateien aus 'templates' nach '%APPDATA%\init' verschieben
$destinationTemplates = Join-Path $env:APPDATA "init"
$sourceTemplates = Join-Path -Path $PSScriptRoot -ChildPath "templates"

If (-Not (Test-Path $sourceTemplates)) {
    Write-Host "Fehler: Quellverzeichnis '$sourceTemplates' existiert nicht."
    Pause
    Exit
}

If (-Not (Test-Path $destinationTemplates)) {
    Write-Host "Erstelle den Ordner '$destinationTemplates'..."
    New-Item -Path $destinationTemplates -ItemType Directory -Force | Out-Null
}

Write-Host "Verschiebe alle Dateien von '$sourceTemplates' nach '$destinationTemplates'..."
Move-Item -Path (Join-Path $sourceTemplates "*") -Destination $destinationTemplates -Force -ErrorAction Stop

Write-Host "Alle Dateien wurden erfolgreich verschoben!"

Start-Sleep -Seconds 20
# Löscht das Verzeichnis, in dem das Skript liegt, rekursiv und beendet sich
Remove-Item -Path $PSScriptRoot -Recurse -Force
Exit
