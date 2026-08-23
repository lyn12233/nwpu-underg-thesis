<#
.SYNOPSIS
    Regenerate the README comparison images (绪论 and 目录 pages).
.DESCRIPTION
    Renders PDF pages to PNG using poppler's pdftoppm.  Paths are relative to
    this script's directory.  By default regenerates all four README images:
      refpg1.png <- docx_template.pdf p16 (绪论)
      refpg2.png <- test_sty.pdf      p4  (绪论)
      refpg3.png <- docx_template.pdf p15 (目录)
      refpg4.png <- test_sty.pdf      p3  (目录)
    Pass PdfPath/Page/OutPath together to render a single page instead.
.PARAMETER PdfPath
    PDF to render (relative to this script's directory), for single-page mode.
.PARAMETER Page
    1-based page number to render, for single-page mode.
.PARAMETER OutPath
    Output PNG (relative to this script's directory), for single-page mode.
.PARAMETER Dpi
    Render resolution. Default: 150.
.EXAMPLE
    ./test/gen_refimg.ps1
.EXAMPLE
    ./test/gen_refimg.ps1 -PdfPath ../docx_template.pdf -Page 16 -OutPath ../ref/refpg1.png
#>
[CmdletBinding()]
param(
    [string]$PdfPath = "",
    [int]$Page = 0,
    [string]$OutPath = "",
    [int]$Dpi = 150
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

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

function Render-PdfPage {
    param(
        [Parameter(Mandatory)][string]$PdfRel,
        [Parameter(Mandatory)][int]$PageNum,
        [Parameter(Mandatory)][string]$OutRel,
        [Parameter(Mandatory)][int]$DpiNum
    )

    $pdf = [IO.Path]::GetFullPath((Join-Path $scriptDir $PdfRel))
    $out = [IO.Path]::GetFullPath((Join-Path $scriptDir $OutRel))
    $outDir = Split-Path -Parent $out

    if (-not (Test-Path -LiteralPath $pdf)) {
        throw "PDF not found: $pdf"
    }
    if (-not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir | Out-Null
    }

    # pdftoppm usage: pdftoppm [options] <PDF-file> [prefix].  Build the prefix
    # as a relative forward-slash path from the current directory.
    $cwd = [IO.Path]::GetFullPath((Get-Location).Path)
    $relDir = [IO.Path]::GetRelativePath($cwd, $outDir).Replace('\', '/')
    if ([string]::IsNullOrEmpty($relDir)) { $relDir = "." }
    $prefix = "$relDir/__refimg_tmp"
    $pdfArg = $pdf.Replace('\', '/')

    Write-Host "Rendering page $PageNum of $pdf -> $out (${DpiNum} dpi)"

    # Preferred: single-file output (no page-number suffix).
    & $exe -f $PageNum -l $PageNum -r $DpiNum -png -singlefile $pdfArg $prefix 2>$null
    if ($LASTEXITCODE -eq 0) {
        $tmpFile = Join-Path $outDir "__refimg_tmp.png"
    } else {
        # Fallback: page-numbered output, then rename.
        & $exe -f $PageNum -l $PageNum -r $DpiNum -png $pdfArg $prefix 2>$null
        $tmpFile = Join-Path $outDir "__refimg_tmp-$PageNum.png"
    }

    if (-not (Test-Path -LiteralPath $tmpFile)) {
        throw "pdftoppm failed to render the page."
    }
    Move-Item -LiteralPath $tmpFile -Destination $out -Force
    Write-Host "Done: $out ($((Get-Item -LiteralPath $out).Length) bytes)"
}

if ($PdfPath -and $Page -gt 0 -and $OutPath) {
    Render-PdfPage -PdfRel $PdfPath -PageNum $Page -OutRel $OutPath -DpiNum $Dpi
} else {
    $jobs = @(
        @{ Pdf = "..\docx_template.pdf"; Page = 16; Out = "..\ref\refpg1.png" },
        @{ Pdf = "..\test_sty.pdf";      Page = 4;  Out = "..\ref\refpg2.png" },
        @{ Pdf = "..\docx_template.pdf"; Page = 15; Out = "..\ref\refpg3.png" },
        @{ Pdf = "..\test_sty.pdf";      Page = 3;  Out = "..\ref\refpg4.png" }
    )
    foreach ($j in $jobs) {
        Render-PdfPage -PdfRel $j.Pdf -PageNum $j.Page -OutRel $j.Out -DpiNum $Dpi
    }
}