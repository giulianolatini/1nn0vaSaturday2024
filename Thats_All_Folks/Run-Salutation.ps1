# Definisci i colori dell'arcobaleno
$colors = @(
    "Red", "Orange", "Yellow", "Green", "Blue", "Indigo", "Violet"
)

# Frase da visualizzare
$message = "Grazie a Tutti per aver seguito l'evento"

# Funzione per stampare il messaggio con i colori dell'arcobaleno
function Show-RainbowMessage {
    param (
        [string]$message,
        [array]$colors
    )

    $length = $message.Length
    $colorIndex = 0

    while ($true) {
        $output = ""
        for ($i = 0; $i -lt $length; $i++) {
            $color = $colors[($colorIndex + $i) % $colors.Length]
            $output += "`e[38;5;${color}m$($message[$i])`e[0m"
        }
        Write-Host $output
        Start-Sleep -Seconds 1
        $colorIndex = ($colorIndex + 1) % $colors.Length
        Clear-Host
    }
}

# Mappa i colori ai codici ANSI
$colorMap = @{
    "Red" = 1
    "Orange" = 208
    "Yellow" = 11
    "Green" = 10
    "Blue" = 12
    "Indigo" = 13
    "Violet" = 5
}

# Converti i nomi dei colori in codici ANSI
$ansiColors = $colors | ForEach-Object { $colorMap[$_] }

# Esegui la funzione per mostrare il messaggio
Show-RainbowMessage -message $message -colors $ansiColors