# Build script for the NFAdvanciaLab2026 module
# This script contains various build tasks

param(
    [ValidateSet('Clean', 'Build', 'Test', 'All')]
    [string]$Task = 'All'
)

$ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TestsPath = Join-Path $ModuleRoot 'Tests'
$TestFile = Join-Path $TestsPath 'MyModule.Tests.ps1'

function Invoke-Clean {
    Write-Host "Cleaning build artifacts..." -ForegroundColor Cyan
    # Add any cleanup tasks here
    Write-Host "Clean completed." -ForegroundColor Green
}

function Invoke-Build {
    Write-Host "Building module..." -ForegroundColor Cyan
    # Add any build tasks here (e.g., copying files, compiling, etc.)
    Write-Host "Build completed." -ForegroundColor Green
}

function Invoke-Tests {
    Write-Host "Running Pester tests..." -ForegroundColor Cyan
    
    if (-not (Get-Module -Name Pester -ListAvailable)) {
        Write-Host "Pester module not found. Installing..." -ForegroundColor Yellow
        Install-Module -Name Pester -Force -SkipPublisherCheck
    }
    
    if (-not (Test-Path $TestFile)) {
        Write-Error "Test file not found at: $TestFile"
        return
    }
    
    # Run Pester tests
    $PesterConfig = New-PesterConfiguration
    $PesterConfig.Run.Path = $TestFile
    $PesterConfig.Run.PassThru = $true
    $PesterConfig.Output.Verbosity = 'Detailed'
    
    $TestResults = Invoke-Pester -Configuration $PesterConfig
    
    if ($TestResults.FailedCount -gt 0) {
        Write-Host "Tests completed with failures!" -ForegroundColor Red
        return $false
    }
    else {
        Write-Host "All tests passed!" -ForegroundColor Green
        return $true
    }
}

# Execute tasks based on parameter
switch ($Task) {
    'Clean' {
        Invoke-Clean
    }
    'Build' {
        Invoke-Build
    }
    'Test' {
        Invoke-Tests
    }
    'All' {
        Invoke-Clean
        Invoke-Build
        Invoke-Tests
    }
}
