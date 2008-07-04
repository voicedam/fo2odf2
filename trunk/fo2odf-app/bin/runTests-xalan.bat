@ECHO OFF

REM Runs JUnit-like tests of the FO2ODF XSLT stylesheets.

CALL settings.inc.bat

CALL prepareTests-xalan.bat

IF ERRORLEVEL 1 GOTO :end

CALL executeTests-xalan.bat %*

IF ERRORLEVEL 1 GOTO :end

START "Test results" "%ODF_STYLESHEETS_DIR%\test\results.xml"

:end