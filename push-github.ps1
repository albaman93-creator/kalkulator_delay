# =====================================================
#  push-github.ps1  —  Upload CalcDelay ke GitHub
#  Repo : https://github.com/albaman93-creator/kalkulator_delay
# =====================================================

Set-Location -Path $PSScriptRoot

# ── Warna helper ──────────────────────────────────────
function Write-Step  { param($msg) Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Ok    { param($msg) Write-Host "   OK  $msg" -ForegroundColor Green }
function Write-Fail  { param($msg) Write-Host "   ERR $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "   CalcDelay  —  Push to GitHub" -ForegroundColor White
Write-Host "   Repo: albaman93-creator/kalkulator_delay" -ForegroundColor DarkGray
Write-Host "================================================" -ForegroundColor DarkCyan

# ── 1. Cek git tersedia ───────────────────────────────
Write-Step "Memeriksa git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Fail "Git tidak ditemukan. Install Git dulu: https://git-scm.com"
    pause; exit 1
}
Write-Ok "Git ditemukan: $(git --version)"

# ── 2. Status sekarang ────────────────────────────────
Write-Step "Status perubahan file..."
git status --short
$changed = git status --short
if (-not $changed) {
    Write-Host "`n   Tidak ada perubahan. Semua sudah up-to-date." -ForegroundColor Yellow
    pause; exit 0
}

# ── 3. Input commit message ───────────────────────────
Write-Host ""
$defaultMsg = "update: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
$commitMsg  = Read-Host "Pesan commit (Enter = '$defaultMsg')"
if ([string]::IsNullOrWhiteSpace($commitMsg)) { $commitMsg = $defaultMsg }

# ── 4. git add ───────────────────────────────────────
Write-Step "Menambahkan semua file (git add -A)..."
git add -A
if ($LASTEXITCODE -ne 0) { Write-Fail "git add gagal"; pause; exit 1 }
Write-Ok "File ditambahkan"

# ── 5. git commit ────────────────────────────────────
Write-Step "Membuat commit..."
git commit -m $commitMsg
if ($LASTEXITCODE -ne 0) { Write-Fail "git commit gagal"; pause; exit 1 }
Write-Ok "Commit berhasil: $commitMsg"

# ── 6. git push ──────────────────────────────────────
Write-Step "Mengupload ke GitHub (git push origin main)..."
git push origin main
if ($LASTEXITCODE -ne 0) {
    Write-Fail "Push gagal. Coba cek koneksi internet atau token GitHub."
    pause; exit 1
}

# ── Selesai ───────────────────────────────────────────
Write-Host ""
Write-Host "================================================" -ForegroundColor DarkGreen
Write-Host "   BERHASIL diupload ke GitHub!" -ForegroundColor Green
Write-Host "   https://github.com/albaman93-creator/kalkulator_delay" -ForegroundColor DarkGray
Write-Host "================================================" -ForegroundColor DarkGreen
Write-Host ""
pause
