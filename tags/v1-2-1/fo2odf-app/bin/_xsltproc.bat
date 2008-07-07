@ECHO OFF

REM Calls the 'xsltproc' XSLT processor located in the libraries directory.

CALL settings.inc.bat

"%LIB_DIR%\xsltproc.exe" %*