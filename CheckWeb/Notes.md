# Disponibilità di una web application

## Focus

Data una URL che punta ad una web application, voglio verificare se la pagina è accessibile, in quanto tempo viene caricata e se è presente nell'HTML content restituito dalla chiamata uno o più elementi caratterizzanti.

## Script steps

1. Verificare che la pagina sia accessibile
2. Misurare il tempo di caricamento della pagina
3. Verificare che l'HTML content restituito contenga uno o più elementi caratterizzanti
4. Restituire i risultati
5. Salvare i risultati in un file di log
6. Invio di una notifica in caso di errore
7. Invio di una notifica in caso di successo

```powershell
param (
    [string]$url,
    [string]$regexp
)

function Test-WebPage {
    param (
        [string]$url,
        [string]$regexp
    )

    $result = @{
        Accessible = $false
        LoadTime = 0
        Matches = $false
    }

    try {
        $startTime = Get-Date
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        $endTime = Get-Date

        $result.Accessible = $true
        $result.LoadTime = ($endTime - $startTime).TotalSeconds
        $result.Matches = [regex]::IsMatch($response.Content, $regexp)
    }
    catch {
        $result.Accessible = $false
    }

    return $result
}

function Save-Log {
    param (
        [hashtable]$result,
        [string]$filePath
    )

    $logContent = "Accessible: $($result.Accessible)`n"
    $logContent += "LoadTime: $($result.LoadTime) seconds`n"
    $logContent += "Matches: $($result.Matches)`n"
    $logContent | Out-File -FilePath $filePath -Append
}

function Write-InfluxDB {
    param (
        [string]$measurement,
        [hashtable]$fields,
        [string]$token,
        [string]$InfluxDBUrl
    )

    # Placeholder for InfluxDB logic
    Write-Output "InfluxDB: $measurement - $fields"
    $hostname = $env:COMPUTERNAME
    $headers = @{
        Authorization = "Token $token"
        Accept = "application/json"
    }
    $data = "$measurement,host=$hostname accessible=$($fields.Accessible),load_time=$($fields.LoadTime),matches=$($fields.Matches)"
    Invoke-RestMethod -Uri "$InfluxDBUrl/api/v2/write?org=pve&bucket=pve&precision=ms" -Method Post -Body $data -ContentType "text/plain; charset=utf-8" -Headers $headers
}

function Send-Notification {
    param (
        [string]$message
    )

    # Check the events from the last day in the security log to send a notification on Teams when a login event (4624) for the administrator user is found using Microsoft Graph
    $tenantId = "your_tenant_id"
    $clientId = "your_client_id"
    $clientSecret = "your_client_secret"
    $channelId = "your_channel_id"
    $teamId = "your_team_id"
    
    # Get an access token
    $body = @{
        grant_type    = "client_credentials"
        scope         = "https://graph.microsoft.com/.default"
        client_id     = $clientId
        client_secret = $clientSecret
    }
    $response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
    $accessToken = $response.access_token
    
    # Define the message to send
    $chatText = @{
        body = @{
            content = "$message"
        }
    }
    
    Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/teams/$teamId/channels/$channelId/messages" -Headers @{ Authorization = "Bearer $accessToken" } -Body ($chatText | ConvertTo-Json -Depth 4) -ContentType "application/json"

    # Placeholder for notification logic (e.g., email, SMS)
    Write-Output $message
}

# Main script execution
$logFilePath = "web_check_log.txt"
$result = Test-WebPage -url $url -regexp $regexp
Save-Log -result $result -filePath $logFilePath
Write-InfluxDB -measurement "web_check" -fields $result -token "mytoken" -InfluxDBUrl "http://‹InfluxDB›:8086"

if ($result.Accessible -and $result.Matches) {
    Send-Notification -message "Success: The web page is accessible and matches the criteria."
} else {
    Send-Notification -message "Error: The web page check failed."
}
```

## Esempio di utilizzo

```powershell
.\CheckWeb.ps1 -url "https://www.google.com" -regexp "Google"
```

## Output

```plaintext
Accessible: True
LoadTime: 0.1234567 seconds
Matches: True
```

## Riferimenti

- [Invoke-WebRequest](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest)
- [Invoke-RestMethod](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod)
- [Out-File](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file)
- [influxdb](https://docs.influxdata.com/influxdb/v2.0/write-data/)
- [McrosoftGraph](https://docs.microsoft.com/en-us/graph/api/resources/chatmessage?view=graph-rest-1.0)
