@echo off
setlocal

REM Get the current folder's name
for %%I in ("%~dp0.") do set "folderName=%%~nxI"

REM Create a zip file with the folder's name
set "zipName=%folderName%.op"
if exist "%zipName%" del "%zipName%"

REM Copy .as, .toml, and .md files into the zip
for /r %%F in (*.as *.toml *.md) do (
    "C:\Program Files\7-Zip\7z.exe" a -tzip "%zipName%" "%%F"
)

echo Files copied to "%zipName%"

endlocal