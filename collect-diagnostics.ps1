$ErrorActionPreference = "SilentlyContinue"
$ReportPath = Join-Path (Get-Location) "codex-safe-report.txt"
$Lines = [System.Collections.Generic.List[string]]::new()

function Add-Line([string]$Text = "") {
    $Lines.Add($Text)
}

function Redact-Text([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return "unknown" }
    $Text = $Text -replace '(?i)[A-Z]:\\Users\\[^\\\s]+', '<USER_HOME>'
    $Text = $Text -replace '(?i)[A-Z]:\\[^\s"]+', '<PATH>'
    $Text = $Text -replace '(^|[\s"])/[A-Za-z0-9._~!$&()*+,;=:@%/?-]+', '$1<PATH>'
    $Text = $Text -replace '(?i)sk-[A-Za-z0-9_-]+', '<REDACTED>'
    $Text = $Text -replace '[A-Za-z0-9_-]{48,}', '<LONG_VALUE_REDACTED>'
    return $Text.Trim()
}

function Add-Version([string]$Label, [string]$Command, [string[]]$Arguments) {
    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        $Output = & $Command @Arguments 2>&1
        if ($Command -eq "codex") {
            $Value = $Output | Where-Object { [string]$_ -match '^codex-cli\s+[0-9]+(?:\.[0-9]+)*' } | Select-Object -Last 1
            if ([string]::IsNullOrWhiteSpace([string]$Value)) { $Value = "version unreadable" }
        } else {
            $Value = $Output | Select-Object -First 1
        }
        Add-Line ("{0}: installed | {1}" -f $Label, (Redact-Text ([string]$Value)))
    } else {
        Add-Line ("{0}: not found" -f $Label)
    }
}

function Test-Presence([string]$Label, [string[]]$Names) {
    $Found = $false
    foreach ($Name in $Names) {
        if (-not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($Name))) {
            $Found = $true
            break
        }
    }
    Add-Line ("{0}: {1}" -f $Label, $(if ($Found) { "yes" } else { "no" }))
}

function Test-Endpoint([string]$Label, [string]$Url) {
    try {
        $Response = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 10 -UseBasicParsing
        Add-Line ("{0}: reachable (HTTP {1})" -f $Label, [int]$Response.StatusCode)
    } catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            Add-Line ("{0}: reachable (HTTP {1})" -f $Label, [int]$_.Exception.Response.StatusCode)
        } else {
            Add-Line ("{0}: unreachable or timed out" -f $Label)
        }
    }
}

Add-Line "Codex Safe Diagnostic Report v1.0"
Add-Line ("Generated: {0}" -f (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
Add-Line "Collector: read-only; no secret values or file contents collected"
Add-Line
Add-Line "[System]"
Add-Line "OS family: Windows"
Add-Line ("OS version: {0}" -f [Environment]::OSVersion.Version.ToString())
Add-Line ("Architecture: {0}" -f [Runtime.InteropServices.RuntimeInformation]::OSArchitecture)
Add-Line ("PowerShell: {0}" -f $PSVersionTable.PSVersion.ToString())
Add-Line
Add-Line "[Tools]"
Add-Version "Codex CLI" "codex" @("--version")
Add-Version "Node.js" "node" @("--version")
Add-Version "npm" "npm" @("--version")
Add-Version "Git" "git" @("--version")
Add-Version "curl" "curl.exe" @("--version")
Add-Version "Python" "python" @("--version")
Add-Line
Add-Line "[Configuration presence]"
Test-Presence "Proxy configured" @("HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "http_proxy", "https_proxy", "all_proxy")
Test-Presence "Custom CA configured" @("CODEX_CA_CERTIFICATE", "SSL_CERT_FILE", "NODE_EXTRA_CA_CERTS")
Test-Presence "Codex home override configured" @("CODEX_HOME")
Add-Line
Add-Line "[Official endpoint reachability]"
Test-Endpoint "Codex installer host" "https://chatgpt.com/codex/install.ps1"
Test-Endpoint "OpenAI API host" "https://api.openai.com/"
Add-Line
Add-Line "[Codex self-check availability]"
if (Get-Command "codex" -ErrorAction SilentlyContinue) {
    & codex doctor --help *> $null
    if ($LASTEXITCODE -eq 0) {
        Add-Line "codex doctor: available"
    } else {
        Add-Line "codex doctor: unavailable in this Codex version"
    }
} else {
    Add-Line "codex doctor: not tested (Codex CLI not found)"
}
Add-Line
Add-Line "[Customer symptom]"
Add-Line "Please add one redacted error line here before sending:"

$Lines | Set-Content -Path $ReportPath -Encoding UTF8
Write-Host "Report created: codex-safe-report.txt"
Write-Host "Open it and complete the manual privacy check before sending."
