<# 
Spotify Cache Clearing.

The script clears outdated cache from the listened music in Spotify.
It triggers every time you completely close the client (if the client was minimized in the tray, the script will not work).

For the APPDATA\Spotify\Data folder, the rule is that all cache files that have not been used by the client for more than a specified number of days will be deleted.

#>

$day = 7 # Number of days after which the cache is considered outdated

# Clear the \Data folder if outdated cache is found

try {
    $SpotifyData = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Spotify\Data"
    If (!(Test-Path -Path $SpotifyData)) {
        "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss")  Local\Spotify\Data folder not found" | Out-File log.txt -append
        exit	
    }
    $check = Get-ChildItem $SpotifyData -File -Recurse | Where-Object lastaccesstime -lt (get-date).AddDays(-$day)
    if ($check.Length -ge 1) {

        $count = $check
        $sum = $count | Measure-Object -Property Length -sum
        if ($sum.Sum -ge 1044344824) {
            $gb = "{0:N2} Gb" -f (($check | Measure-Object Length -s).sum / 1Gb)
            "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Removed $mb outdated cache" | Out-File log.txt -append
        }
        else {
            $mb = "{0:N2} Mb" -f (($check | Measure-Object Length -s).sum / 1Mb)
            "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Removed $mb outdated cache" | Out-File log.txt -append
        }
        Get-ChildItem $SpotifyData -File -Recurse | Where-Object lastaccesstime -lt (get-date).AddDays(-$day) | Remove-Item
    }
    if ($check.Length -lt 1) {
        "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") No outdated cache found"" | Out-File log.txt -append
    }   
}
catch {
    "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") $error[0].Exception" | Out-File log.txt -append
}
exit
