@ECHO OFF

REM Calls the 'Xalan-J' XSLT processor located in the libraries directory. All libraries necessary
REM for the FO2ODF Converter are added to the classpath.

CALL settings.inc.bat

java -cp ".;%LIB_DIR%\xalan.jar;%LIB_DIR%\fo2odf-javautils.jar" org.apache.xalan.xslt.Process %*