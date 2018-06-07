param(
      [string]$server,
      [string]$path,
      [string]$dest
     )

#call api endpoint to return catalogitems from folder.
$uri = "https://$server/reports/api/v2.0/Folders(Path='$path')/CatalogItems"
$result = Invoke-webrequest -Uri $uri -Method Get -UseDefaultCredentials | ConvertFrom-Json

ForEach ($i in $result.value) 
{
    if($i.Type -eq "DataSet")
    {
        #call api endpoint to return dataset content.
        $dsUri = 'https://'+$server+'/reports/api/v2.0/DataSets('+$i.Id+')/Content/$value'
        $rsd = Invoke-webrequest -Uri $dsUri -Method Get -UseDefaultCredentials

        #test if dest folder exists
        if (!(Test-Path $dest -PathType Container)) 
        {
            write-host "Creating output folder..."
            New-Item -ItemType Directory -Force -Path $dest
        }
        
        #write dataset content to local filesystem.
        [System.IO.File]::WriteAllBytes("$dest\$($i.Name).rsd", $rsd.Content)
        write-host "Saved Dataset: $($i.Name).rsd"

        #cast as xml and write commandtext to sql file.
        $xml = [xml](Get-Content "$dest\$($i.Name).rsd")
        Set-Content -Path "$dest\$($i.Name).sql" -Value $xml.SharedDataSet.DataSet.Query.CommandText
        write-host "Saved CommandText: $($i.Name).sql`n"
    }
}
