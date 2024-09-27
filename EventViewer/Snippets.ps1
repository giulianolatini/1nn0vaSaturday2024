# Export events from the system log for the last 2 days
$Date = (Get-Date).AddDays(-2)
Get-WinEvent -FilterHashtable @{ LogName='System'; StartTime=$Date } |
    Select-Object TimeCreated, Id, Message |
    Export-Csv -Path C:\Users\user\Documents\eventlog.csv -NoTypeInformation

# Show the first 10 events from the security log for the last 2 days
$Date = (Get-Date).AddDays(-2)
Get-WinEvent -MaxEvents 10 -FilterHashtable @{ LogName='Security'; StartTime=$Date } |
    Select-Object TimeCreated, Id, Message

# Show events with ID 1000 from the application log for the last 2 days
$Date = (Get-Date).AddDays(-2)
Get-WinEvent -FilterHashtable @{ LogName='Application'; StartTime=$Date; Id=1000 } |
    Select-Object TimeCreated, Id, Message

# Show and export events with ID 1000 from the application log for the last 2 days
$Date = (Get-Date).AddDays(-2)
Get-WinEvent -FilterHashtable @{ LogName='Application'; StartTime=$Date; Id=1000 } |
    Select-Object TimeCreated, Id, Message |
    Export-Csv -Path C:\Users\user\Documents\eventlog.csv -NoTypeInformation

# Check the events from the last day in the security log to send an email notification when a login event (4624) for the administrator user is found using a local SMTP server
$sendMailMessageSplat = @{
    From = 'User01 <user01@fabrikam.com>'
    To = 'User02 <user02@fabrikam.com>', 'User03 <user03@fabrikam.com>'
    Subject = 'There is a login event for administrator'
    Body = "There is a login event for administrator."
    Priority = 'High'
    DeliveryNotificationOption = 'OnSuccess', 'OnFailure'
    SmtpServer = 'smtp.fabrikam.com'
}

$Date = (Get-Date).AddDays(-1)
$Events = Get-WinEvent -FilterHashtable @{ LogName='Security'; StartTime=$Date; Id=4624 }
$Events | Select-Object TimeCreated, Id, Message | Where-Object { $_.Message -like '*administrator*' } | ForEach-Object {
    Send-MailMessage @sendMailMessageSplat
}

# Check the events from the last day in the security log 
# to send an email notification when a login event (4624) 
# for the administrator user is found using the Office 365 SMTP server
$username = "user@domain.com"
# If MFA is enabled on $username, use an app password
$password = "user_password"
$sstr = ConvertTo-SecureString -string $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $sstr
$subject = 'There is a login event for administrator'
$body = "There is a login event for administrator."

$Date = (Get-Date).AddDays(-1)
$Events = Get-WinEvent -FilterHashtable @{ LogName='Security'; StartTime=$Date; Id=4624 }
$Events | Select-Object TimeCreated, Id, Message | Where-Object { $_.Message -like '*administrator*' } | ForEach-Object {
    Send-MailMessage -To "admin@domain.com" `
                     -From "user@domain.com" `
                     -Subject $subject `
                     -Body $body `
                     -BodyAsHtml `
                     -SmtpServer smtp.office365.com `
                     -UseSsl `
                     -Credential $cred `
                     -Port 587 
}

# Check the events from the last day in the security log to send a 
# notification on Teams when a login event (4624) for 
# the administrator user is found using Microsoft Graph
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
$response = Invoke-RestMethod -Method Post `
-Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
-ContentType "application/x-www-form-urlencoded" `
-Body $body
$accessToken = $response.access_token

# Define the message to send
$message = @{
    body = @{
        content = "There is a login event for administrator."
    }
}

# Get the events from the security log and Send messages to Teams
$Date = (Get-Date).AddDays(-1)
$Events = Get-WinEvent -FilterHashtable @{ LogName='Security'; StartTime=$Date; Id=4624 }
$Events | Select-Object TimeCreated, Id, Message | Where-Object { $_.Message -like '*administrator*' } | ForEach-Object {
    # Send the message to the Teams channel
    Invoke-RestMethod -Method Post `
    -Uri "https://graph.microsoft.com/v1.0/teams/$teamId/channels/$channelId/messages" `
    -Headers @{ Authorization = "Bearer $accessToken" } `
    -Body ($message | ConvertTo-Json -Depth 4) `
    -ContentType "application/json"
}


# Define the start time for filtering events (e.g., last 30 days)
$StartTime = (Get-Date).AddDays(-30)

# Filter events related to disk errors from the System log
$diskErrorEvents = Get-WinEvent -FilterHashtable @{
    LogName='System'
    Id=7, 11, 15, 25, 51  # Common disk error event IDs
    StartTime=$StartTime
}

# Select relevant properties and prepare data for InfluxDB
$hostname = $env:COMPUTERNAME
$headers = @{
    Authorization = "Token ‹Api_Influx_Token›"
    Accept = "application/json"
}
$diskErrorEvents | ForEach-Object {
    $data = "disk_errors,host=$hostname event_id=$($_.Id)" `
    "$([System.DateTimeOffset]::new($_.TimeCreated).ToUnixTimeMilliseconds())"
    Invoke-RestMethod `
    -Uri "http://‹InfluxDB›:8086/api/v2/write?org=pve&bucket=pve&precision=ms" `
    -Method Post `
    -Body $data `
    -ContentType "text/plain; charset=utf-8" `
    -Headers $headers
}