SETLOCAL EnableDelayedExpansion
:: Script for resetting your registry values after running my Dragon Age Origins
:: wrapper to fix upscaling with dgVoodoo, in case you want to stop using it.

:: Make sure you run this from the directory containing your Dragon Age Origins
:: executable.

:: Set directory_path to the directory the batch file is located in.
SET directory_path=%~dp0

:: Change to the directory the batch file is located in.
CHDIR "%directory_path%"

:: The name (but not path) of the Dragon Age Origins executable we want to run.
SET "dao_executable_name=DAOrigins.exe"

:: Delete the registry entry that tells Windows to use "System (enhanced)"
:: Custom DPI Scaling for the DAOrigins executable.
REG DELETE ^
  "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" ^
  /v "%directory_path%%dao_executable_name%" ^
  /f
