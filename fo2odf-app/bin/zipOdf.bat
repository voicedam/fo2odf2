@ECHO OFF

REM Zips (copies) files generated by the FO2ODF transformation to a zip called '%1.odt'.

CALL settings.inc.bat

IF EXIST %1.odt DEL %1.odt

SET OUTPUT_DIR=transformed

CD %OUTPUT_DIR%

%LIB_DIR%\7za\7za.exe a -tzip -r ../%1.odt *

CD ..

:end