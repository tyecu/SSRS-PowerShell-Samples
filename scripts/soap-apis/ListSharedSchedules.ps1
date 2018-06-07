#How to list shared schedules in PowerShell
param([string]$server)
$ReportServerUri = "https://$server:443/ReportServer/ReportService2010.asmx";
$rs = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential -Namespace "SSRS"
$rs.Url = "https://ecubic.ecu.edu/reportserver/reportservice2010.asmx"

$rs.ListSchedules([System.Management.Automation.Language.NullString]::Value)
