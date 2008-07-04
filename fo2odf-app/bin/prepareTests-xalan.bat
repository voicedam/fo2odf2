@ECHO OFF

REM Prepares JUnit-like tests of the FO2ODF XSLT stylesheets for execution.

CALL settings.inc.bat

ECHO Preparing tests in the '%ODF_STYLESHEETS_DIR%\test' directory

CALL _xalan -OUT "%ODF_STYLESHEETS_DIR%\test\tests.xsl" -XSL "%ODF_STYLESHEETS_DIR%\test\gentest.xsl" -IN "%ODF_STYLESHEETS_DIR%\test\tests.xml" %*