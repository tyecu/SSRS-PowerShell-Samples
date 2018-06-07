# Mass copy report subscriptions from prod to dev
#
# How to run this script:    
# PS> .\CopyProdSubsToDev.ps1 -FromServer myserver1 -ToServer myserver2 -Folder "/Users Folders/INTRA USERNAME/My Reports"

param([String]$FromServer,
      [String]$ToServer,
      [string]$Folder
)

write-host "Copying subscriptions from $FromServer to $ToServer..."

$FromReportServerUri = "https://"+$FromServer+":443/ReportServer/ReportService2010.asmx";
$FromRS = New-WebServiceProxy -Uri $FromReportServerUri -UseDefaultCredential
$FromRS.Url = "https://$FromServer/reportserver/reportservice2010.asmx"

$ToReportServerUri = "https://"+$ToServer+":443/ReportServer/ReportService2010.asmx";
$ToRS = New-WebServiceProxy -Uri $ToReportServerUri -UseDefaultCredential
$ToRS.Url = "https://$ToServer/reportserver/reportservice2010.asmx"

$reportItems = $FromRS.ListChildren($Folder, $true) | where {$_.TypeName -eq "Report" -OR $_.TypeName -eq "PowerBIReport" -OR $_.TypeName -eq "MobileReport"}
$totalSubs = 0

ForEach($i in $reportItems)
{
    write-host "Getting subscriptions for report: $($i.Name)"
    $subs = $FromRS.ListSubscriptions($i.Path)
    ForEach($sub in $subs)
    {
        write-host "Processing: $($sub.SubscriptionId)"

        $extSettings,$desc,$active,$status,$eventType,$matchData,$parameters = $null
        $FromRS.GetSubscriptionProperties($sub.SubscriptionId, [ref]$extSettings, [ref]$desc, [ref]$active, [ref]$status, [ref]$eventType, [ref]$matchData, [ref]$parameters)
        
        $type = $ToRS.GetType().Namespace
        $extSettingsType = ($type + '.ExtensionSettings')
        $paramValueType = ($type + '.ParameterValue')
        $extSettings2 = New-Object ($extSettingsType)
        $extSettings2.Extension = $extSettings.Extension

        ForEach($pv in $extSettings.ParameterValues)
        {
            $paramValue = New-Object ($paramValueType)
            $paramValue.Name = $pv.Name
            $paramValue.Value = $pv.Value
            $extSettings2.ParameterValues += $paramValue
        }

        $parameters2 = @()

        ForEach($pv in $parameters)
        {
            $paramValue = New-Object ($paramValueType)
            $paramValue.Name = $pv.Name
            $paramValue.Value = $pv.Value
            $parameters2 += $paramValue
        }

        $ToRS.CreateSubscription($sub.Path,$extSettings2,$($sub.Description),$eventType,$matchData,$parameters2)
        $totalSubs += $subs.length
    }
    write-host "---------------------------------------------------------"
}

write-host "Total Subs: $($totalSubs)"
