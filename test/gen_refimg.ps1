<#
.SYNOPSIS
    Regenerate ref/refpg2.png (the typst 绪论 page) from test_sty.pdf.
.DESCRIPTION
    Renders one page of a PDF to PNG using poppler's pdftoppm.  Paths are
    relative to this script's directory.  Defaults to ../test_sty.pdf page 4 at
    150 DPI, matching the README comparison image.
.PARAMETER PdfPath
    PDF to render (relative to this script's directory). Default: ..\test_sty.pdf.
.PARAMETER Page
    1-based page number to render. Default: 4 (the 绪论 page in test_sty.pdf).
.PARAMETER OutPath
    Output PNG (relative to this script's directory). Default: ..\ref\refpg2.png.
.PARAMETER Dpi
    Render resolution. Default: 150.
.EXAMPLE
    ./test/gen_refimg.ps1
.EXAMPLE
    ./test/gen_refimg.ps1 -PdfPath ../docx_template.pdf -Page 16 -OutPath ../ref/refpg1.png
#>
[CmdletBinding()]
param(
    [string]$PdfPath = "..\test_sty.pdf",
    [int]$Page = 4,
    [string]$OutPath = "..\ref\refpg2.png",
    [int]$Dpi = 150
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pdf = [IO.Path]::GetFullPath((Join-Path $scriptDir $PdfPath))
$out = [IO.Path]::GetFullPath((Join-Path $scriptDir $OutPath))
$outDir = Split-Path -Parent $out

if (-not (Test-Path -LiteralPath $pdf)) {
    throw "PDF not found: $pdf"
}
if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

# Locate pdftoppm (poppler): PATH first, then common MiKTeX install paths.
$pdftoppm = Get-Command pdftoppm -ErrorAction SilentlyContinue
$exe = if ($pdftoppm) { $pdftoppm.Source } else {
    @(
        "D:\program\miktex\miktex\bin\x64\pdftoppm.exe",
        "C:\Program Files\MiKTeX\miktex\bin\x64\pdftoppm.exe"
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
if (-not $exe) {
    throw "pdftoppm not found on PATH or in common MiKTeX locations."
}

# pdftoppm usage: pdftoppm [options] <PDF-file> [prefix].  Build the prefix as a
# relative forward-slash path from the current directory for portability.
$cwd = [IO.Path]::GetFullPath((Get-Location).Path)
$relDir = [IO.Path]::GetRelativePath($cwd, $outDir).Replace('\', '/')
if ([string]::IsNullOrEmpty($relDir)) { $relDir = "." }
$prefix = "$relDir/__refimg_tmp"
$pdfArg = $pdf.Replace('\', '/')

Write-Host "Rendering page $Page of $pdf -> $out (${Dpi} dpi)"

# Preferred: single-file output (no page-number suffix).
& $exe -f $Page -l $Page -r $Dpi -png -singlefile $pdfArg $prefix 2>$null
if ($LASTEXITCODE -eq 0) {
    $tmpFile = Join-Path $outDir "__refimg_tmp.png"
} else {
    # Fallback: page-numbered output, then rename.
    & $exe -f $Page -l $Page -r $Dpi -png $pdfArg $prefix 2>$null
    $tmpFile = Join-Path $outDir "__refimg_tmp-$Page.png"
}

if (-not (Test-Path -LiteralPath $tmpFile)) {
    throw "pdftoppm failed to render the page."
}
Move-Item -LiteralPath $tmpFile -Destination $out -Force
Write-Host "Done: $out ($((Get-Item -LiteralPath $out).Length) bytes)"