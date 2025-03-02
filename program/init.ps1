Param(
    [string]$File = "./../templates/express.yaml", # Path to the YAML file (modify or provide via parameter)
    [string]$path = "."
)

$currentPath = Get-Location

if (!(Test-Path $path)) {
    New-Item -ItemType Directory -Path $path | Out-Null
}
Set-Location $path

# Read and parse the YAML file into a PowerShell object
if (!(Test-Path $File)) {
    Write-Host "YAML file '$File' not found." -BackgroundColor Red -ForegroundColor White
    exit 1
}

$yamlData = Get-Content -Path $File -Raw | ConvertFrom-Yaml

# Ensure the YAML has a 'steps' section
if (-not $yamlData.steps) {
    Write-Host "YAML file does not contain a 'steps' section." -BackgroundColor Red -ForegroundColor White
    exit 1
}

$stepIndex = 0
$Succededcount = 0
$failedCount = 0
$count = 0
foreach ($command in $yamlData.steps) {
    $count++
}

foreach ($command in $yamlData.steps) {
    $stepIndex++
    
    try {
        Invoke-Expression $command -ErrorAction Stop *> $null
        Write-Host "Step ($stepIndex/$count) " -ForegroundColor Blue, Green -NoNewline
        Write-Host "SUCCEEDED" -ForegroundColor Green
        $Succededcount++
    }
    catch {
        Write-Host "Step ($stepIndex / $count) " -ForegroundColor Blue, Green -NoNewline
        Write-Host "FAILED ($($_.Exception.Message))" -ForegroundColor Red
        $failedCount++
    }
}

Set-Location $currentPath

Write-Host "[$Succededcount SUCCEEDED, $failedCount FAILED] Setup finished"
