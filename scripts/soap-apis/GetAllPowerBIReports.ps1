param([String]$serverName
)

$ReportServerUri = "https://"+$serverName+":443/ReportServer/ReportService2010.asmx";

$rs = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential

$rs.Url = "https://$serverName/reportserver/reportservice2010.asmx"

$rs.ListChildren("/",$true) | where-object {$_.TypeName -eq "PowerBIReport"} | select Path
