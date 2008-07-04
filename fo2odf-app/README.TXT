##################################
# FO2ODF Converter - readme file #
##################################

About FO2ODF Converter
======================
- version: 1.2.1 (2008-06-28)
- author: Petr Bodnár <p.bodnar@centrum.cz>
- purpose: Converts a document from XSL FO format to ODF format. The result document can be opened in OpenOffice Writer, further processed in here and then f.e. exported to PDF.
- implementation: Nearly the whole conversion is done by calling an XSLT 1.0 processor with the FO2ODF Converter's stylesheets.
- interface: the converter offers the following ways of invoking the conversion:
	- run the conversion from command line using 'xsltproc' (this enables probably the fastest conversion times)
	- run the conversion from command line using 'Xalan-J' (for now this is the best choice if you want to convert FO documents containing images addressed by relative paths)
	- use web interface written in PHP 5
	- open FO document directly in OpenOffice

Description of the Converter files
==================================
- README.TXT ... This file.
- doc/ ... Documentation of the project.
	- history.txt ... Description of changes made in each version of the Converter.
	- implementation_notes.txt ... Implementation notes.
	- fo2odf_model.uml ... UML model of the Converter. It can be opened in the 'StarUML' open source application.
	- fo2odf_model.png ... Diagram exported from the UML model giving the basic idea about the Converter implementation as well as about its usage.
- bin/ ... Executable files of the Converter (batch files for Windows; hopefully soon for UNIX too)
- etc/ ... Other files that don't belong to any special directory.
- java/ ... Source files of the 'fo2odf-javautils.jar' package.
- lib/ ... XSLT processors and other necessary files used by the Converter.
- php/ ... Files of the Converter's web interface (written in the PHP language).
- samples/ ... Sample FO documents.
- xsl/ ... Converter's XSLT stylesheets.

General installation notes
==========================
- Unpack the Converter's archive content to any directory on your PC.

Installation of the 'command line' version
==========================================
Note: Only batch files for MS Windows are available now. The UNIX scripts are yet to be created (even though it shouldn't be too difficult to prepare them).

Follow these steps:
- Add the 'bin' directory of the unpacked Converter to the PATH system variable. Then you can run the Converter batch files (which are located in the 'bin' directory) from any directory. The batch files contain comments which should give you enough information to run the conversion easily.

Installation of the 'PHP' version
=================================
Follow these steps:
- Install a web server (f.e. the well known Apache) and PHP (see 'php/fo2odf.php' for requirements) on the computer where you want to install the Converter.
- Copy the 'php' and 'xsl' directories to directory of your choice on your web server. Alternatively you can directly use the folder where you unpacked the Converter.
- Alter the 'php/serverSettings.inc.php' if you need some customization.
- In your favorite browser enter the address which is bound to the 'php' directory. The Converter web interface should appear.

Installation of the 'OpenOffice' version
========================================
In order to open FO documents directly in OpenOffice, you must install a so called 'XML Filter' in your OpenOffice instance.

Follow these steps:
- Open the OpenOffice Writer.
- In the main menu select 'Tools' -> 'XML Filter Settings...' (If no document is opened in the editor, the menu item won't be visible.)
- In the appeared dialog click on the 'New...' button.
- In the 'Filter name' field write f.e. 'XSL FO filter'.
- In the 'Application' combobox select 'OpenOffice.org Writer (.odt)'.
- In the 'Filter extension' field write 'fo'.
- Now switch to the 'Transformation' tab.
- In the 'DocType' field write 'fo:root'. This should be sufficient for OpenOffice to recognize an FO file and use the created filter automatically.
- In the 'XSLT for import' field enter the full path to the 'fo2odf-one_xml.xsl' file which should reside in the 'xsl/odf' directory of the unpacked Converter.
- Click on the 'OK' button to create the filter. Close the dialog.
- Now you should be able to open FO documents (files with the 'fo' extension) directly in OpenOffice Writer.

In order to the Converter's stylesheets could load images addressed by relative paths, follow these additional steps:
- Start any OpenOffice application.
- In the main menu select 'Tools' -> 'Options...'. Then select 'OpenOffice.org' -> 'Java'.
- Check that the 'Use a Java runtime environment' option is checked and an existing JRE is selected. Then click on the 'Class Path...' button.
- In the appeared dialog click on the 'Add Archive...' button.
- In the appeared 'Select Archives' dialog select the 'lib/fo2odf-javautils.jar' file from the Converter directory.
- Confirm all the opened dialogs. OpenOffice informs you that they need to be restarted.
- Close all windows of OpenOffice. Close the 'OpenOffice Quick Launch' as well if it is on.
- Now you should be able to open FO documents which contain images addressed by relative paths. Unfortunately because of the limitations of technologies used for the conversion, one more thing is needed: you must put an attribute called 'baseURI' to the <fo:root> element in the document to be opened in OpenOffice. The value of this attribute must contain the absolute path of the directory where the document is located. Namespace of the attribute must be 'http//example.com/fo2odf'.

Installation of the XML Filter for "flat" ODF files
===================================================
To be able to open "flat" ODF files (files which are simple XML documents and not ODF archives) in OpenOffice, you must install a simple XML Filter which is part of the Converter package.

Follow these steps:
- Open the OpenOffice Writer.
- In the main menu select 'Tools' -> 'XML Filter Settings...' (If no document is opened in the editor, the menu item won't be visible.)
- In the appeared dialog click on the 'Open Package...' button.
- In the appeared 'Open' dialog select the 'etc/OpenOffice/flatOdfOOXmlFilter.jar' file from the Converter directory.
- Click on the 'Open' button. A message dialog should inform you about successful installation of the filter. Close all the opened dialogs.
- Now you should be able to open "flat" ODF files (files with the 'oft' extension) in OpenOffice Writer.

Custom level of logging from XSLT
=================================
You can choose level of messages which will be send from the XSLT transformation by specifying the 'global-log-level' XSLT parameter. See the 'xsl/common/xslt_logging.xsl' file for details.

Customizing the conversion
==========================
Some aspects of the conversion can be easily changed by modifying the XSLT parameters which are described in the 'xsl/odf/fo2odf_params.xsl'.