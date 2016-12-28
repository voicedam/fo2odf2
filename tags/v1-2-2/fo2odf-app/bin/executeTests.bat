@ECHO OFF

REM Executes JUnit-like tests of the FO2ODF XSLT stylesheets.

CALL settings.inc.bat

ECHO Executing tests in the '%ODF_STYLESHEETS_DIR%\test' directory

CALL _xsltproc %* -o "%ODF_STYLESHEETS_DIR%\test\results.xml" "%ODF_STYLESHEETS_DIR%\test\tests.xsl" "%ODF_STYLESHEETS_DIR%\test\tests.xml"