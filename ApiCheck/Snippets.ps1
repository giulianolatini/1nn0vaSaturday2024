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