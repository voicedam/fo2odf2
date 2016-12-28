@ECHO OFF

REM Converts FO document (%1) to ODF document (%1.oft). The result document can be open in
REM OpenOffice if the XML filter for opening "flat" ODF files was successfully installed.

REM Note: 'Xalan-J' is used as the XSLT processor for this transformation.

CALL settings.inc.bat

CALL _xalan -IN %1 -XSL "%ODF_STYLESHEETS_DIR%\fo2odf-one_xml.xsl" -OUT %1.oft %2 %3 %4 %5 %6 %7 %8 %9