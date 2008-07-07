@ECHO OFF

REM Defines settings for the FO2ODF Converter scripts.

REM Path to the directory where the Converted was installed (unpacked).
SET BASE_DIR=%~dp0..

SET SAMPLES_DIR=%BASE_DIR%\samples

SET ODF_STYLESHEETS_DIR=%BASE_DIR%\xsl\odf

SET LIB_DIR=%BASE_DIR%\lib