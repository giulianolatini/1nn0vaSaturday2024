# Application Insights

## Focus

Application Insights come sistema di logging esterno all'infrastruttura verso cui inviare eventi custom per success o exceptions di attività scriptate in PowerShell

## Script steps

1. caricare il modulo di Application Insights con i meccanismi di reflection in PowerShell
2. creare un nuovo oggetto TelemetryClient
3. assegnare la InstrumentationKey, endpoint con token per l'invio degli eventi
4. a seconda del risultato dell'attività scriptata, generare un evento di successo o di errore
5. inviare l'evento risultato al servizio di Application Insights

## Esempio

```powershell
$aiAssembly = [Reflection.Assembly]::LoadFile("C:\Program Files\Microsoft Application Insights\Microsoft.ApplicationInsights.dll")
$telemetryClient = New-Object Microsoft.ApplicationInsights.TelemetryClient
$telemetryClient.InstrumentationKey = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$telemetryClient.TrackEvent("EventName")
$telemetryClient.TrackException((New-Object System.Exception("Exception message")))
$telemetryClient.Flush()
```

## Considerazioni finali

Application Insights è un servizio di logging esterno integrato con un motore di analisi di eventi e metriche che permette l'ingestion di eventi custom indirizzati ad un endpoint specifico a cui possiamo inviare eventi di successo o di errore di attività scriptate in PowerShell. Il motore di analisi integrato permette facilmente di generare notifiche multicanali scatenate dai risultati di query su gli eventi inviati.

Application Insights è un servizio a pagamento, ma offre un piano gratuito con limitazioni di volume di eventi inviati e di retention degli stessi. I vantaggi maggiori si hanno quando é giá utilizzato come servizio dalla propria organizzazione, in quanto si possono sfruttare le stesse risorse di logging per inviare eventi custom di attività scriptate in PowerShell.

Application Insights é un sistema sicuro e facilmente gestibile dalla security perimetrale dell'organizzazione. L'endpoint é protetto da token di autenticazione e autorizzazione, e i dati inviati sono crittografati in trasmissione. Microsoft Azure pubblica il pool d'IP pubblici per l'accesso organizzato per servizi.

## Riferimenti

- [Documentazione ufficiale di Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [Automate Application Insights with PowerShell - Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/app/powershell)
- [Application Insights for ASP.NET Core applications - Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core?tabs=netcorenew)
- [https://ryland.dev/posts/app-insights-powershell/](https://ryland.dev/posts/app-insights-powershell/)
- [Logging Azure Application Insights telemetry data from PowerShell](https://keithbabinec.com/2019/07/07/logging-azure-application-insights-telemetry-data-from-powershell/)