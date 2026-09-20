$ErrorActionPreference = 'Stop'

Write-Host '=== data-career-journey setup ==='

# Check Python 3.14
py -3.14 --version

if ($LASTEXITCODE -ne 0) {
    Write-Error 'Python 3.14 was not found. Install Python 3.14 and run setup again.'
    exit 1
}

# Create virtual environment if needed
$venv = Join-Path $PSScriptRoot '.venv'
$python = Join-Path $venv 'Scripts\python.exe'

if (-not (Test-Path $python)) {
    Write-Host 'Creating .venv...'
    py -3.14 -m venv $venv

    if ($LASTEXITCODE -ne 0) {
        Write-Error 'Failed to create virtual environment.'
        exit 1
    }
}
else {
    Write-Host '.venv already exists.'
}

# Install project + development dependencies
Write-Host 'Installing dependencies...'
& $python -m pip install -r (Join-Path $PSScriptRoot 'requirements-dev.txt')

if ($LASTEXITCODE -ne 0) {
    Write-Error 'Failed to install dependencies.'
    exit 1
}

# Smoke checks
Write-Host ''
Write-Host 'Checking environment...'
& $python --version
& $python -m pip --version
& $python -c "import pandas; print('pandas', pandas.__version__)"

if ($LASTEXITCODE -ne 0) {
    Write-Error 'Pandas import check failed.'
    exit 1
}

& $python -m pytest --version

if ($LASTEXITCODE -ne 0) {
    Write-Error 'Pytest check failed.'
    exit 1
}

Write-Host ''
Write-Host 'Setup complete.'
Write-Host 'Open the repository in VS Code and use the .venv interpreter.'
