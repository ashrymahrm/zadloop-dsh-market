# ZadLoop — install the dsh-market plugin (pinned working build) with one command.
# Run in PowerShell:
#   powershell -ExecutionPolicy Bypass -File install.ps1
# or one-line from the repo README.
# NOTE: paths follow the standard Electron desktop layout for the Windows build
# of ZadLoop; if detection fails, pass the runtime directory explicitly:
#   $env:ZL_RUNTIME = "C:\Program Files\ZadLoop\resources\app.asar.unpacked\runtime"
$ErrorActionPreference = 'Stop'

$Repo = "github:ashrymahrm/zadloop-dsh-market"
$Profile = if ($env:ZL_PROFILE) { $env:ZL_PROFILE } else { "web" }

# --- locate the ZadLoop runtime ----------------------------------------------
function Find-Runtime {
    if ($env:ZL_RUNTIME) { return $env:ZL_RUNTIME }
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\ZadLoop\resources\app.asar.unpacked\runtime",
        "$env:ProgramFiles\ZadLoop\resources\app.asar.unpacked\runtime",
        "${env:ProgramFiles(x86)}\ZadLoop\resources\app.asar.unpacked\runtime"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    throw "ZadLoop runtime not found. Set `$env:ZL_RUNTIME to ...\ZadLoop\resources\app.asar.unpacked\runtime and re-run."
}

# --- locate DSH_HOME (harness directory) --------------------------------------
$DshHome = if ($env:ZL_DSH_HOME) { $env:ZL_DSH_HOME } else { "$env:APPDATA\ZadLoop\harness" }
if (-not (Test-Path $DshHome)) {
    throw "DSH_HOME not found at: $DshHome — pass `$env:ZL_DSH_HOME and re-run."
}
$env:DSH_HOME = $DshHome

$Runtime = Find-Runtime
$ResDir = (Split-Path (Split-Path $Runtime -Parent) -Parent)   # ...\ZadLoop\resources
Write-Host "runtime : $Runtime"
Write-Host "dsh_home: $DshHome"
Write-Host "profile : $Profile"

# --- locate node ---------------------------------------------------------------
$NodeBin = $null
if ($env:ZL_NODE) { $NodeBin = $env:ZL_NODE }
else {
    $candidates = @(
        "$ResDir\primary-runtime\dependencies\node\node.exe",
        "$ResDir\primary-runtime\dependencies\node\bin\node.exe"
    )
    foreach ($c in $candidates) { if (Test-Path $c) { $NodeBin = $c; break } }
    if (-not $NodeBin) {
        $cmd = Get-Command node -ErrorAction SilentlyContinue
        if ($cmd) { $NodeBin = $cmd.Source }
    }
}
if (-not $NodeBin) { throw "node not found inside ZadLoop and no system node on PATH." }
Write-Host "node    : $NodeBin"

# --- align pnpm: the dsh CLI spawns `pnpm` from PATH; it must be the same
# major version the ZadLoop app itself uses, or the store path mismatches.
$PnpmCjs = Join-Path $ResDir "primary-runtime\dependencies\pnpm\bin\pnpm.cjs"
if (Test-Path $PnpmCjs) {
    $TmpBin = Join-Path ([System.IO.Path]::GetTempPath()) ("zl-pnpm-" + [guid]::NewGuid().ToString('N').Substring(0,8))
    New-Item -ItemType Directory -Path $TmpBin | Out-Null
    $shimPath = Join-Path $TmpBin "pnpm.cmd"
    "@echo off`r`n`"$NodeBin`" `"$PnpmCjs`" %*" | Set-Content -Path $shimPath -Encoding ASCII
    $env:PATH = "$TmpBin;$env:PATH"
}

# --- install -------------------------------------------------------------------
$RuntimeUri = ([System.Uri] (Join-Path $Runtime "lib\runtime.js")).AbsoluteUri
$BinJs = Join-Path $Runtime "node_modules\@deepseek-ai\dsh\lib\bin.js"

& $NodeBin --expose-internals --use-system-ca `
    --import $RuntimeUri `
    $BinJs plugin --profile $Profile add $Repo
if ($LASTEXITCODE -ne 0) { throw "dsh plugin add failed with exit code $LASTEXITCODE" }
