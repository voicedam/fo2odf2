@ECHO OFF

REM Converts FO document (%1) to ODF document (%1.odt).  The result document can be open in
REM OpenOffice if the XML filter for opening "flat" ODF files was successfully installed.

REM Note: 'xsltproc' is used as the XSLT processor for this transformation. Images from the FO
REM document won't be loaded. Use 'fo2odf-flat-xalan.bat' or FO2ODF Converter web interface
REM ('fo2odf.php') if you want the support for images.

CALL settings.inc.bat

CALL _xsltproc -o %1.oft %2 %3 %4 %5 %6 %7 %8 %9 "%ODF_STYLESHEETS_DIR%\fo2odf-one_xml.xsl" %1