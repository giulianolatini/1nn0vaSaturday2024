

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

function Send-Notification {
    param (
        [string]$message
    )

    # Placeholder for notification logic (e.g., email, SMS)
    Write-Output $message
}

# Main script execution
$logFilePath = "web_check_log.txt"
$result = Test-WebPage -url $url -regexp $regexp
Save-Log -result $result -filePath $logFilePath

if ($result.Accessible -and $result.Matches) {
    Send-Notification -message "Success: The web page is accessible and matches the criteria."
    $data = "disk_errors,host=$hostname event_id=$($_.Id) $([System.DateTimeOffset]::new($_.TimeCreated).ToUnixTimeMilliseconds())"
    Invoke-RestMethod -Uri "http://192.168.178.95:8086/api/v2/write?org=pve&bucket=pve&precision=ms" -Method Post -Body $data -ContentType "text/plain; charset=utf-8" -Headers $headers
} else {
    Send-Notification -message "Error: The web page check failed."
}