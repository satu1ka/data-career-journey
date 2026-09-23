$ErrorActionPreference = 'Stop'

Write-Host '=== data-career-journey setup ==='

# Check Python 3.14
py -3.14 --version

if ($LASTEXITCODE -ne 0) {
    Write-Error 'Python 3.14 was not found. Install Python 3.14 and run setup again.'
    exit 1
}

# Check PostgreSQL 18 / psql
Write-Host ''
Write-Host 'Checking PostgreSQL...'

$psql = Get-Command psql -ErrorAction SilentlyContinue

if (-not $psql) {
    $defaultPgBin = 'C:\Program Files\PostgreSQL\18\bin'
    $defaultPsql = Join-Path $defaultPgBin 'psql.exe'

    if (Test-Path $defaultPsql) {
        Write-Error "PostgreSQL 18 is installed, but psql is not in PATH. Add '$defaultPgBin' to your User PATH and reopen PowerShell."
        exit 1
    }

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host 'PostgreSQL 18 was not found.'
        Write-Host 'Install it with:'
        Write-Host 'winget install --id PostgreSQL.PostgreSQL.18 --exact --source winget --interactive'
        exit 1
    }

    Write-Error 'PostgreSQL 18 / psql was not found. Install PostgreSQL 18 and run setup again.'
    exit 1
}

$psqlVersion = & $psql.Source --version
Write-Host $psqlVersion

if ($LASTEXITCODE -ne 0) {
    Write-Error 'Failed to run psql.'
    exit 1
}

if ($psqlVersion -notmatch '^psql \(PostgreSQL\) 18\.') {
    Write-Error "PostgreSQL 18 is required. Found: $psqlVersion"
    exit 1
}

# Check PostgreSQL Windows service
$pgServiceName = 'postgresql-x64-18'
$pgService = Get-Service -Name $pgServiceName -ErrorAction SilentlyContinue

if (-not $pgService) {
    Write-Error "PostgreSQL service '$pgServiceName' was not found."
    exit 1
}

Write-Host "PostgreSQL service: $($pgService.Status)"

if ($pgService.Status -ne 'Running') {
    Write-Error "PostgreSQL service '$pgServiceName' is not running. Start it with: Start-Service $pgServiceName"
    exit 1
}

# Check PostgreSQL server readiness
$pgIsReady = Get-Command pg_isready -ErrorAction SilentlyContinue

if (-not $pgIsReady) {
    Write-Error 'pg_isready was not found.'
    exit 1
}

& $pgIsReady.Source -h localhost -p 5432

if ($LASTEXITCODE -ne 0) {
    Write-Error 'PostgreSQL is not accepting connections on localhost:5432.'
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
