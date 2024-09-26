# Disponibilità di una API Restful

## Focus

Data la URL ad una API Rest, voglio verificare se è raggiungibile e dato un payload di verifica in quanto tempo ottengo la risposta aspettata.

## Script PowerShell

Ecco uno script PowerShell che prende come parametri la URL dell'API da verificare e il nome di un file JSON contenente il payload restituito in risposta alla richiesta dall'API:

```powershell
param (
    [string]$apiUrl,
    [string]$jsonFile
)

try {
    $expectedResponse = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json
    $startTime = Get-Date
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get
    $endTime = Get-Date

    $response | ConvertTo-Json | Out-File "actual_$jsonFile"

    $elapsedTime = $endTime - $startTime
    Write-Output "API response time: $($elapsedTime.TotalMilliseconds) ms"

    if ($response -eq $expectedResponse) {
        Write-Output "The response matches the expected output."
    } else {
        Write-Output "The response does not match the expected output."
    }
} catch {
    Write-Error "Failed to reach API: $_"
}
```

## Esempio di utilizzo

```powershell
.\CheckApi.ps1 -apiUrl "https://api.restful-api.dev/objects/7" -jsonFile "expected_response.json"
# or this sites for testing: 
# [Free Public APIs for Developers](https://rapidapi.com/collection/list-of-free-apis)
# [JSONPlaceholder - Free Fake REST API](https://jsonplaceholder.typicode.com/)
# [Free API - 90+ Public APIs For Testing [No Key] - Apipheny](https://apipheny.io/free-api/)
```

File expected_response.json:

```json
{
  "id": "7",
  "name": "Apple MacBook Pro 16",
  "data": {
    "year": 2019,
    "price": 1849.99,
    "CPU model": "Intel Core i9",
    "Hard disk size": "1 TB"
  }
}
```
