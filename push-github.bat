@echo off
chcp 65001 >nul
color 0B
title CalcDelay — Push to GitHub

echo.
echo ================================================
echo    CalcDelay  —  Push to GitHub
echo    Repo: albaman93-creator/kalkulator_delay
echo ================================================
echo.

:: Pindah ke folder script ini
cd /d "%~dp0"

:: ── 1. Cek git ────────────────────────────────────────
echo ^>^> Memeriksa git...
git --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo    ERR  Git tidak ditemukan!
    echo         Install Git di: https://git-scm.com
    pause & exit /b 1
)
for /f "delims=" %%v in ('git --version') do echo    OK   %%v

:: ── 2. Status file ────────────────────────────────────
echo.
echo ^>^> Status perubahan file...
git status --short
echo.

:: Cek ada perubahan atau tidak
git status --short | findstr /r "." >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo    Tidak ada perubahan. Semua sudah up-to-date.
    pause & exit /b 0
)

:: ── 3. Input pesan commit ─────────────────────────────
set "TANGGAL="
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "TANGGAL=%%c-%%b-%%a"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "JAM=%%a:%%b"
set "DEFAULT_MSG=update: %TANGGAL% %JAM%"

set /p "COMMIT_MSG=Pesan commit (Enter = '%DEFAULT_MSG%'): "
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=%DEFAULT_MSG%"

:: ── 4. git add ────────────────────────────────────────
echo.
echo ^>^> Menambahkan semua file (git add -A)...
git add -A
if %ERRORLEVEL% neq 0 (
    echo    ERR  git add gagal!
    pause & exit /b 1
)
echo    OK   File ditambahkan

:: ── 5. git commit ─────────────────────────────────────
echo.
echo ^>^> Membuat commit...
git commit -m "%COMMIT_MSG%"
if %ERRORLEVEL% neq 0 (
    echo    ERR  git commit gagal!
    pause & exit /b 1
)
echo    OK   Commit: %COMMIT_MSG%

:: ── 6. git push ───────────────────────────────────────
echo.
echo ^>^> Mengupload ke GitHub (git push origin main)...
git push origin main
if %ERRORLEVEL% neq 0 (
    echo    ERR  Push gagal! Cek koneksi atau token GitHub.
    pause & exit /b 1
)

:: ── Selesai ───────────────────────────────────────────
color 0A
echo.
echo ================================================
echo    BERHASIL diupload ke GitHub!
echo    https://github.com/albaman93-creator/kalkulator_delay
echo ================================================
echo.
pause
