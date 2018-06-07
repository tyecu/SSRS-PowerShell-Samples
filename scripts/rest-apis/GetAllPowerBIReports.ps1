#Gets all PowerBI Reports on SSRS
param([string]$server)
$uri = "https://$server/reports/api/v2.0/powerbireports"

Write-Host "`nGetting PowerBI reports..."

Write-Host "`nPowerBI Reports on SSRS`n---------------------------------"

Invoke-webrequest -Uri $uri -Method Get -UseDefaultCredentials | ConvertFrom-Json | foreach { $_.value.Path }
