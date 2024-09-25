# Event Viewer

## Focus

Consultare da PowerShell i registri di log in Event Viewer per estrarre in modo filtrato event_id, quando è avvenuto nel sistema e il messaggio associato per riversarlo in InfluxDB e gestirlo come sequenz temporale.

## Script steps

1. **Get-WinEvent** - Get-WinEvent é un cmdlet di PowerShell che permette di accedere ai log di Windows Event Viewer.
2. **Filtering** - Filtrare i log in base a parametri come logname, id, time, ecc.
3. **Select-Object** - Selezionare le proprietà da visualizzare.
4. **Export-Csv** - Esportare i dati in un file CSV.
5. **ConvertTo-Json** - Convertire gli oggetti PowerShell in formato JSON.
6. **Invoke-RestMethod** - Inviare i dati a InfluxDB.

```powershell
# Windows Logs list
Get-WinEvent -ListLog *

# List property of a specific log
Get-WinEvent -ListLog Setup | Format-List -Property *

# Configure the maximum size of a log
$log = Get-WinEvent -ListLog Security
$log.MaximumSizeInBytes = 1gb
try{
   $log.SaveChanges()
   Get-WinEvent -ListLog Security | Format-List -Property *
}catch [System.UnauthorizedAccessException]{
   $ErrMsg  = 'You do not have permission to configure this log!'
   $ErrMsg += ' Try running this script with administrator privileges. '
   $ErrMsg += $_.Exception.Message
   Write-Error $ErrMsg
}

# Get the number of records in each log of localhost
Get-WinEvent -ListLog * -ComputerName localhost | Where-Object { $_.RecordCount }

# List Id and Description of all events generate of GroupPolicy
(Get-WinEvent -ListProvider Microsoft-Windows-GroupPolicy).Events | Format-Table Id, Description

# Get all events from a archived event log
Get-WinEvent -Path 'C:\Test\Windows PowerShell.evtx'

# List all application errors' events from the last 7 days from Internet Explorer 
$StartTime = (Get-Date).AddDays(-7)
Get-WinEvent -FilterHashtable @{
  Logname='Application'
  ProviderName='Application Error'
  Data='iexplore.exe'
  StartTime=$StartTime
}

# List all events from the last 2 days from the Application log except those that have level a level 4 (Info)
$Date = (Get-Date).AddDays(-2)
$filter = @{
  LogName='Application'
  StartTime=$Date
  SuppressHashFilter=@{Level=4}
}
Get-WinEvent -FilterHashtable $filter

# Define the start time for filtering events (e.g., last 30 days)
$StartTime = (Get-Date).AddDays(-30)

# Filter events related to unexpected shutdown of Microsoft Edge
$events = Get-WinEvent -FilterHashtable @{
    LogName='Application'
    ProviderName='Application Error'
    Data='msedge.exe'
    StartTime=$StartTime
}

# Select relevant properties and convert to JSON
$events | Select-Object TimeCreated, Id, Message | ConvertTo-Json | Out-File -FilePath 'C:\Path\To\Export\EdgeUnexpectedShutdowns.json'


```powershell
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
    $data = "disk_errors,host=$hostname event_id=$($_.Id) $([System.DateTimeOffset]::new($_.TimeCreated).ToUnixTimeMilliseconds())"
    Invoke-RestMethod -Uri "http://192.168.178.95:8086/api/v2/write?org=pve&bucket=pve&precision=ms" -Method Post -Body $data -ContentType "text/plain; charset=utf-8" -Headers $headers
}
```

## Considerazioni finali

Get-WinEvent è un cmdlet di PowerShell che permette di accedere ai log di Windows Event Viewer. Questo cmdlet può essere utilizzato per filtrare i log in base a parametri come logname, id, time, ecc. e selezionare le proprietà da visualizzare. I dati possono essere esportati in un file CSV, convertiti in formato JSON e inviati a InfluxDB per la gestione come sequenza temporale.

Get-WinEvent è uno strumento prezioso per monitorare e analizzare i log di Windows Event Viewer in modo efficiente e automatizzato. Può essere utilizzato per identificare e risolvere problemi di sistema, monitorare le prestazioni del sistema e rilevare eventuali violazioni della sicurezza. Inoltre, può essere utilizzato per generare alert, report dettagliati sui log di Windows Event Viewer e per integrare i dati dei log con altri strumenti di monitoraggio e analisi.

In conclusione, Get-WinEvent è uno strumento potente e flessibile che può essere utilizzato per gestire i log di Windows Event Viewer in modo efficace e automatizzato. È uno strumento essenziale per gli amministratori di sistema e gli operatori IT che desiderano monitorare e analizzare i log di Windows Event Viewer in modo efficiente e automatizzato.

## Riferimenti

- [Get-WinEvent (Microsoft.PowerShell.Diagnostics) - PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-7.4)
- [Event Viewer](https://docs.microsoft.com/en-us/windows/win32/eventlog/event-viewer)
- [How to check Windows event logs with PowerShell (Get-EventLog)](https://www.codetwo.com/admins-blog/how-to-check-event-logs-with-powershell-get-eventlog/)
- [How to store and read user credentials from Windows Credentials manager](https://morgantechspace.com/2019/05/how-to-store-and-read-user-credentials-from-windows-credentials-manager.html)
- [Line protocol@Influxdata documentation](https://docs.influxdata.com/influxdb/cloud/reference/syntax/line-protocol/)
- [Write data with the InfluxDB API@Influxdata documentation](https://docs.influxdata.com/influxdb/cloud/write-data/developer-tools/api/)
- [GitHub - markwragg/PowerShell-Influx: A PowerShell module for interacting with the time-series database platform Influx: https://www.influxdata.com/](https://github.com/markwragg/PowerShell-Influx)