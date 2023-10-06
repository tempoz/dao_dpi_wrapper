SETLOCAL EnableDelayedExpansion
:: Wrapper script for running Dragon Age Origins with dgVoodoo to get higher
:: resolution 3D-rendering without making the GUI elements so small as to be
:: unusable.

:: It is recommended (but not necessary) to disable the Windows Compatibility
:: Assistant when using this wrapper, as it will prevent an annoying pop-up
:: dialog. To do this, run `services.msc` and go to "Services (Local)" >
:: "Program Compatibility Assistant Service". Double-click that entry and set
:: the "Startup type:" drop-down to "Disabled" and click the "Stop" button
:: under "Service Status". Click "Apply" and then "OK".
:: Then run `gpedit.msc` and go to "User Configuration" > "Administrative
:: Settings" > "Windows Components" > "Application Compatibility" and
:: double-click the entry "Turn off Program Compatibility Assistant" under
:: "Setting". Select "Enabled" from the radio-buttons on the top-left of the
:: dialog. Click "Apply" and then "OK".

:: Set directory_path to the directory the batch file is located in.
SET directory_path=%~dp0

:: Change to the directory the batch file is located in.
CHDIR "%directory_path%"

:: The name (but not path) of the Dragon Age Origins executable we want to run.
SET "dao_executable_name=DAOrigins.exe"

:: The path of the DragonAge.ini file.
SET "dao_ini=%userprofile%\Documents\BioWare\Dragon Age\Settings\DragonAge.ini"

:: The path of the dgVoodoo.conf file.
SET "voodoo_conf=.\dgVoodoo.conf"

:: The path of the SetDPI executable.
SET "set_dpi=.\SetDPI.exe"

:: Add a registry entry that tells Windows to use "System (enhanced)" Custom DPI
:: Scaling for the DAOrigins executable. This cannot be accomplished with a
:: Side-by-Side manifest, unfortunately. We have to do this on every launch
:: because Windows will "helpfully" append " HIGHDPIAWARE" to the value when we
:: close the program because it thinks something went wrong with the
:: compatibility settings. In fact, until you disable the Windows Compatibility
:: Assistant, it will spawn a dialog on program close telling you something went
:: wrong and it has changed tha compatibilty settings. Disabling the assistant
:: stops this dialog from appearing, but does not prevent this infuriating
:: behavior.
REG ADD ^
  "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" ^
  /v "%directory_path%%dao_executable_name%" ^
  /t "REG_SZ" ^
  /d "~ GDIDPISCALING DPIUNAWARE" ^
  /f

:: Get the resolution from the voodoo.conf file.
CALL :get-ini "%voodoo_conf%" DirectX Resolution voodoo_resolution

:: Split the resolution on ", v:". Wow, batch is weird.
SET "voodoo_h=%voodoo_resolution:, v:=" & SET "voodoo_v=%"

:: Trim "h:" from the string
SET "voodoo_h=%voodoo_h:h:=%"

:: Transform the strings into numerical values
SET /a "voodoo_h=%voodoo_h%"
SET /a "voodoo_v=%voodoo_v%"

:: Get both resolution components from the DragonAge.ini file.
CALL :get-ini "%dao_ini%" VideoOptions ResolutionWidth dao_h
CALL :get-ini "%dao_ini%" VideoOptions ResolutionHeight dao_v

:: Check to ensure the horizontal scaling percentage is a whole number.
SET /a "rem_h=(100 * %voodoo_h%) %% %dao_h%"
IF %rem_h% NEQ 0 (
SET "error_message=Resolution scaling requires whole percentages. DAO resolution was %dao_h%x%dao_v%, while voodoo resolution was %voodoo_h%x%voodoo_v%. The remainder when obtaining the horizontal scaling percent was %rem_h%." & call :error
)

:: Check to ensure the vertical scaling percentage is a whole number.
SET /a "rem_v=(100 * %voodoo_v%) %% %dao_v%"
IF %rem_v% NEQ 0 (
SET "error_message=Resolution scaling requires whole percentages. DAO resolution was %dao_h%x%dao_v%, while voodoo resolution was %voodoo_h%x%voodoo_v%. The remainder when obtaining the vertical scaling percent was %rem_v%." & CALL :error
)

:: Get the scaling percentages for both components of the resolution.
SET /a "scaling_h=(100 * %voodoo_h%) / %dao_h%"
SET /a "scaling_v=(100 * %voodoo_v%) / %dao_v%"

:: Check to ensure the scaling percentages are consistent with each other.
IF %scaling_h% NEQ %scaling_v% (
SET "error_message=Resolution scaling requires two resolutions of equal ratios. DAO resolution was %dao_h%x%dao_v%, while voodoo resolution was %voodoo_h%x%voodoo_v%. The required scaling factor horizontally was %scaling_h% percent, and the required scaling factor vertically was %scaling_v% percent, which were not equal." & CALL :error
)
:: Check to ensure the desired scaling percentage is supported.
IF %scaling_h% EQU 100 (
CALL
) ELSE IF %scaling_h% EQU 125 (
CALL
) ELSE IF %scaling_h% EQU 150 (
CALL
) ELSE IF %scaling_h% EQU 175 (
CALL
) ELSE IF %scaling_h% EQU 200 (
CALL
) ELSE IF %scaling_h% EQU 225 (
CALL
) ELSE IF %scaling_h% EQU 250 (
CALL
) ELSE IF %scaling_h% EQU 300 (
CALL
) ELSE IF %scaling_h% EQU 350 (
CALL
) ELSE (
SET "error_message=Resolution scaling only supports the following scaling percentages: 125, 150, 175, 200, 225, 250, 300, 1nd 350. DAO resolution was %dao_h%x%dao_v%, while voodoo resolution was %voodoo_h%x%voodoo_v%. The required scaling factor was %scaling_h% percent, which is not one of the supported values." & CALL :error
)

:: Set original_scaling to the current Scale percentage value (as seen in
:: System > Display > Scale). 
FOR /f "tokens=* USEBACKQ" ^
%%f IN (`%set_dpi% "value"`) ^
DO (SET /a "original_scaling=%%f")

:: Set the Scale percentage value as seen in System > Display > Scale to our
:: desired scaling percentage.
%set_dpi% "%scaling_h%"

:: Start Dragon Age Origins
.\%dao_executable_name%

:: When Dragon Age Origins closes, reset the Scale percentage value as seen in
:: System > Display > Scale to the value it was before.
%set_dpi% "%original_scaling%"

:: Uncomment in order to debug issues if they appear:
:: PAUSE

:: We're done!
EXIT

:error
  SET "title=Error"
  SET "tmpmsgbox=%temp%\~tmpmsgbox.vbs"
  SET x=msgbox "%error_message%",0,"%title%"
  ECHO %x%>"%tmpmsgbox%"
  WSCRIPT "%tmpmsgbox%"
  EXIT

:trim
  SETLOCAL
  SET params=%*
  FOR /f "tokens=1*" %%a IN ("!params!") DO ENDLOCAL & SET %1=%%b
  EXIT /b

:get-ini <filename> <section> <key> <result>
  SET %~4=
  SETLOCAL
  SET insection=
  FOR /f "usebackq eol=; tokens=*" %%a IN ("%~1") DO (
    SET line=%%a
    IF DEFINED insection (
      FOR /f "tokens=1,* delims==" %%b IN ("!line!") DO (
	    CALL :trim name %%b
        IF /i "!name!"=="%3" (
          ENDLOCAL
		  CALL :trim value %%c
          SET %~4=!value!
          EXIT /b
        )
      )
    )
    IF "!line:~0,1!"=="[" (
      FOR /f "delims=[]" %%b IN ("!line!") DO (
        IF /i "%%b"=="%2" (
          SET insection=1
        ) ELSE (
          ENDLOCAL
          IF DEFINED insection EXIT /b
        )
      )
    )
  )
  ENDLOCAL
  EXIT /b