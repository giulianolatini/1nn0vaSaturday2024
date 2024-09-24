# Event Viewer

## Focus

Consultare da PowerShell i registri di log in Event Viewer per estrarre in modo filtrato event_id, quando è avvenuto nel sistema e il messaggio associato per riversarlo in InfluxDB e gestirlo come sequenz temporale.

## Script steps

1. **Get-WinEvent** - Get-WinEvent é un cmdlet di PowerShell che permette di accedere ai log di Windows Event Viewer.
2. **Filtering** - Filtrare i log in base a parametri come logname, id, time, ecc.
3. **Select-Object** - Selezionare le proprietà da visualizzare.
4. **Export-Csv** - Esportare i dati in un file CSV.
5. **Import-Csv** - Importare i dati da un file CSV.
6. **ConvertFrom-Csv** - Convertire i dati da CSV a oggetti PowerShell.
7. **ConvertTo-Json** - Convertire gli oggetti PowerShell in formato JSON.
8. **Invoke-RestMethod** - Inviare i dati a InfluxDB.
9. **Invoke-WebRequest** - Inviare i dati a InfluxDB.




## Riferimenti

- [Get-WinEvent](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-7.1)
- [Event Viewer](https://docs.microsoft.com/en-us/windows/win32/eventlog/event-viewer)
- [How to check Windows event logs with PowerShell (Get-EventLog)](https://www.codetwo.com/admins-blog/how-to-check-event-logs-with-powershell-get-eventlog/)
- 