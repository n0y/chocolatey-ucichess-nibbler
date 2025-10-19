$Props = convertfrom-stringdata (get-content versions.properties | Select-String -pattern "^#" -NotMatch)
$UpstreamVersion = $Props.UPSTREAM_VERSION

$FileUrl = "https://github.com/rooklift/nibbler/releases/download/v$UpstreamVersion/nibbler-$UpstreamVersion-windows.zip"

"Building Upstream Version: $UpstreamVersion from url $FileUrl"
""

try {
    # Erstellt eine HTTP-Anfrage
    $request = [System.Net.WebRequest]::Create($FileUrl)
    $request.Method = "GET"

    # Sendet die Anfrage und erhält den Antwort-Stream
    $response = $request.GetResponse()
    $stream = $response.GetResponseStream()

    # Erstellt ein SHA256-Objekt
    $sha256 = [System.Security.Cryptography.SHA256]::Create()

    # Berechnet den Hash direkt aus dem Stream
    # Die Daten werden in Blöcken gelesen und verarbeitet, nicht auf einmal
    $hashBytes = $sha256.ComputeHash($stream)

    # Konvertiert das Hash-Byte-Array in einen hexadezimalen String
    $UpstreamChecksum = [System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()
} finally {
    # Schließt den Stream und die Antwort, um Ressourcen freizugeben
    if ($stream) { $stream.Close() }
    if ($response) { $response.Close() }
}

if (Test-Path -LiteralPath .\target) {
    Remove-Item -LiteralPath .\target -Recurse
}
New-Item -ItemType Directory -Force -Path .\target\tools | Out-Null
#
(Get-Content .\src\tools\chocolateyinstall.template.ps1) `
    -replace '%%VERSION%%', $UpstreamVersion `
    -replace '%%CHECKSUM%%', $UpstreamChecksum  |
        Out-File -Encoding utf8 ".\target\tools\chocolateyinstall.ps1"
(Get-Content .\src\tools\chocolateyUninstall.template.ps1) `
    -replace '%%VERSION%%', $UpstreamVersion `
    -replace '%%CHECKSUM%%', $UpstreamChecksum  |
        Out-File -Encoding utf8 ".\target\tools\chocolateyUninstall.ps1"
Copy-Item .\src\tools\sync-engines.ps1 -Destination ".\target\tools"
(Get-Content .\src\ucichess-nibbler.template.nuspec.xml) -replace '%%VERSION%%', $UpstreamVersion | Out-File -Encoding utf8 ".\target\ucichess-nibbler.nuspec"

