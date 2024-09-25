# Disponibilità di una web application

## Focus

Data una URL che punta ad una web application, voglio verificare se la pagina è accessibile, in quanto tempo viene caricata e se è presente nell'HTML content restituito dalla chiamata uno o più elementi caratterizzanti.

# Script steps

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
} else {
    Send-Notification -message "Error: The web page check failed."
}
```
