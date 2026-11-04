
$ErrorActionPreference = "Stop"

# Always run relative to this script's directory
Set-Location $PSScriptRoot

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
# Absolute path: the Supabase CLI resolves relative -f paths from the project root, not from here.
$backupDir = Join-Path $PSScriptRoot "backups\$timestamp"

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "Backing up Supabase database..." -ForegroundColor Cyan

# Backup schema
supabase db dump --remote -f "$backupDir/schema.sql"
if ($LASTEXITCODE -ne 0) { throw "Schema backup failed" }

# Backup data
supabase db dump --remote --use-copy --data-only `
    -x "storage.buckets_vectors" `
    -x "storage.vector_indexes" `
    -f "$backupDir/data.sql"
if ($LASTEXITCODE -ne 0) { throw "Data backup failed" }

# Backup roles
supabase db dump --remote --role-only -f "$backupDir/roles.sql"
if ($LASTEXITCODE -ne 0) { throw "Roles backup failed" }

Write-Host "`nBackup completed successfully!" -ForegroundColor Green
Write-Host "Location: $backupDir" -ForegroundColor Yellow
