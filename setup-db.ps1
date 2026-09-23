$ErrorActionPreference = 'Stop'

Write-Host '=== data-career-journey database setup ==='

$psql = Get-Command psql -ErrorAction SilentlyContinue

if (-not $psql) {
    Write-Error 'psql was not found. Run setup.ps1 first and make sure PostgreSQL 18 is installed.'
    exit 1
}

$sqlFile = Join-Path $PSScriptRoot 'sql\setup.sql'

if (-not (Test-Path $sqlFile)) {
    Write-Error "Database setup file was not found: $sqlFile"
    exit 1
}

Write-Host 'Creating/updating local database data_career_journey...'
Write-Host 'Using local PostgreSQL credentials. If pgpass.conf is not configured, psql will ask for the password.'

& $psql.Source `
    -U postgres `
    -h localhost `
    -p 5432 `
    -d postgres `
    -f $sqlFile

if ($LASTEXITCODE -ne 0) {
    Write-Error 'Database setup failed.'
    exit 1
}

Write-Host ''
Write-Host 'Database setup complete.'
