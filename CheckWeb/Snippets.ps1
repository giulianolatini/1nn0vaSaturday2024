param (
    [string]$url,
    [string]$regexp
)

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
    $data = "$measurement,host=$hostname " `
    + "accessible=$($fields.Accessible)," `
    + "load_time=$($fields.LoadTime)" `
    + ",matches=$($fields.Matches)"
    Invoke-RestMethod `
    -Uri "$InfluxDBUrl/api/v2/write?org=pve&bucket=pve&precision=ms" `
    -Method Post `
    -Body $data `
    -ContentType "text/plain; charset=utf-8" `
    -Headers $headers
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
    $response = Invoke-RestMethod `
        -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
        -ContentType "application/x-www-form-urlencoded" `
        -Body $body
    $accessToken = $response.access_token
    
    # Define the message to send
    $chatText = @{
        body = @{
            content = "$message"
        }
    }
    
    Invoke-RestMethod `
        -Method Post `
        -Uri "https://graph.microsoft.com/v1.0/teams/$teamId/channels/$channelId/messages" `
        -Headers @{ Authorization = "Bearer $accessToken" } `
        -Body ($chatText | ConvertTo-Json -Depth 4) `
        -ContentType "application/json"

    # Placeholder for notification logic (e.g., email, SMS)
    Write-Output $message
}

# Main script execution
$logFilePath = "web_check_log.txt"
$result = Test-WebPage -url $url -regexp $regexp
Save-Log -result $result -filePath $logFilePath
Write-InfluxDB `
    -measurement "web_check" `
    -fields $result `
    -token "mytoken" `
    -InfluxDBUrl "http://‹InfluxDB›:8086"

if ($result.Accessible -and $result.Matches) {
    Send-Notification `
        -message "Success: The web page is accessible and matches the criteria."
} else {
    Send-Notification `
        -message "Error: The web page check failed."
}