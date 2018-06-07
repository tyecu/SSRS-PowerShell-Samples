# Deletes a subscription by ID
param([string]$server,
      [string]$id)
$uri = "https://$server/reports/api/v2.0/subscriptions($($id))"

Invoke-webrequest -Uri $uri -Method Delete -UseDefaultCredentials
