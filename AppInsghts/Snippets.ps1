
# This script is used to send telemetry data to Application Insights
$instrumentationKey = "‹Azure InstrumentationKey Endpoint›"
$appInsightSDK = "‹Absolute Path of Microsoft.ApplicationInsights.dll›"
$OperationName = "OperationName"
$OrganizationId = "OrganizationId"

Start-Transcript -Path $($LogPath + "\$OperationName`_$(Get-Date -format 'yyyyMMdd-hhmm').log")

[Reflection.Assembly]::LoadFile($appInsightSDK) | Out-Null

# Instance a new TelemetryClient
$TelemetryClient = [Microsoft.ApplicationInsights.TelemetryClient]::new()
# Set the Application Insights Instrumentation Key
# to access the Application Insights ingestion endpoint
$TelemetryClient.InstrumentationKey = $instrumentationKey

if ($LASTEXITCODE -ne 0) {
    $eventException = New-Object -TypeName Microsoft.ApplicationInsights.DataContracts.ExceptionTelemetry

    $eventException.Properties.TryAdd("ErrorFrom", $OperationName)
    $eventException.Properties.TryAdd("Customer", $OrganizationId)
    $eventException.Properties.TryAdd("MachineName", $($(Resolve-DnsName $(hostname)|Where-Object {$_.Type -eq 'A'}).Name | Select-Object -First 1))
    $eventException.Properties.TryAdd("User", $env:USERNAME)
    $eventException.Properties.TryAdd("PathCommand", $($MyInvocation.MyCommand.Path))

    $eventException.Exception = $_.Exception
    $eventException.Message = $_.Exception.Message
    $eventException.SeverityLevel = "Error"

    # Send eventException object to Application Insight by client
    $TelemetryClient.TrackException($eventException)
    $TelemetryClient.Flush()

    Write-Output "$OperationName is failed! See $LogPath\$OperationName`_$(Get-Date -format 'yyyyMMdd-hhmm').log to know result and ending"

} else {
    $eventTelemetry = New-Object -TypeName Microsoft.ApplicationInsights.DataContracts.EventTelemetry

    $eventTelemetry.Name = $OperationName
    $eventTelemetry.Properties.TryAdd("Customer", $OrganizationId)
    $eventTelemetry.Properties.TryAdd("MachineName", $($(Resolve-DnsName $(hostname)|Where-Object {$_.Type -eq 'A'}).Name | Select-Object -First 1))
    $eventTelemetry.Properties.TryAdd("User", $env:USERNAME)
    $eventTelemetry.Properties.TryAdd("PathCommand", $($MyInvocation.MyCommand.Path))
    $eventTelemetry.Properties.TryAdd("Result", "OK!")

    # Send eventTelemetry object to Application Insight by client
    $TelemetryClient.TrackEvent($eventTelemetry)
    $TelemetryClient.Flush()

    Write-Output "$OperationName is started, and Running! See $LogPath\$OperationName`_$(Get-Date -format 'yyyyMMdd-hhmm').log to know result and ending"
    Write-Output "Dump will be saved into $OutputPath"
}

Stop-Transcript