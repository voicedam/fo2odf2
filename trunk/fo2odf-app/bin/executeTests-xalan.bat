@ECHO OFF

REM Executes JUnit-like tests of the FO2ODF XSLT stylesheets.

CALL settings.inc.bat

ECHO Executing tests in the '%ODF_STYLESHEETS_DIR%\test' directory

CALL _xalan -OUT "%ODF_STYLESHEETS_DIR%\test\results.xml" -XSL "%ODF_STYLESHEETS_DIR%\test\tests.xsl" -IN "%ODF_STYLESHEETS_DIR%\test\tests.xml" %*