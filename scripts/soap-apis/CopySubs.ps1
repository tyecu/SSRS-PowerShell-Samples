# Mass copy report subscription for testing purposes.
#
# How to run this script:    
# PS> .\CopySubs.ps1 -copies 100 -report "/Users Folders/INTRA USERNAME/My Reports/TestReport"
# 
# Note:  This script will return the list of subscriptions that exist for a report and will copy 
#         the first one listed (at index 0).

param([String]$serverName,
      [Int32]$copies,
      [string]$report
)
$ReportServerUri = "https://"+$serverName+":443/ReportServer/ReportService2010.asmx";
$rs = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
$rs.Url = "https://$serverName/reportserver/reportservice2010.asmx"

$sub = $rs.ListSubscriptions($report)[0]

$extSettings,$desc,$active,$status,$eventType,$matchData,$parameters = $null

$rs.GetSubscriptionProperties($sub.SubscriptionId, [ref]$extSettings, [ref]$desc, [ref]$active, [ref]$status, [ref]$eventType, [ref]$matchData, [ref]$parameters)

ForEach($i in 1..$copies) { $rs.CreateSubscription($sub.Path,$extSettings,"Test Subscription $i",$eventType,$matchData,$parameters) }
