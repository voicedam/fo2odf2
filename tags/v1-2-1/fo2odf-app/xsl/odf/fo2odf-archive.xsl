<?xml version="1.0"?>

<!--
Converts a FO document to an ODF document. The result is several files which form
the whole ODF document after zipping them to one archive file (by some external tool).
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:str2="http://exslt.org/strings2"
    xmlns:my="http://example.com/muj"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
	xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
	xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
	xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
	xmlns:foIn="http://www.w3.org/1999/XSL/Format"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
	xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
	xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
	xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
	xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
	xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
	xmlns:ooo="http://openoffice.org/2004/office"
	xmlns:ooow="http://openoffice.org/2004/writer"
	xmlns:oooc="http://openoffice.org/2004/calc"
	xmlns:dom="http://www.w3.org/2001/xml-events"
	xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:doc="http://xsltsl.org/xsl/documentation/1.0"
	exclude-result-prefixes="doc exsl func my str2"
    extension-element-prefixes="exsl func">

<xsl:import href="../common/strings.xsl" />

<xsl:import href="fo2odf.xsl" />

<!-- Directory to which output files should be written. It must end with "/". -->
<xsl:param name="output-dir">transformed/</xsl:param>

<!--
Whether this stylesheet is called from PHP and the paranoid PHP's 'safe_mode' directive is on.
If this is 'yes', then all files are output to the actual directory. Original
paths to these files become start of the filenames, "/" in each path is replaced by "<hyphen><hyphen>" (<hyphen> = '-').

An example will hopefully make this clear:

- $output-dir is 'transformed/' and $php-safe_mode is 'yes',
  then f.e. the 'manifest.xml' file is saved as 'transformed<hyphen><hyphen>META<hyphen><hyphen>INF<hyphen><hyphen>manifest.xml'.
-->
<xsl:param name="php-safe_mode">no</xsl:param><!-- yes/no -->

<!-- The main template. Calls imported templates for creating various parts of an ODF document.
1. Checks whether the input file is an XSL FO document.
2. Outputs result of conversion to files needed for creating the ODF document. -->
<xsl:template match="/">
	
    <xsl:call-template name="check-source-document" />
	
	<exsl:document method="text" href="{my:get-safe_mode-aware-filename(concat($output-dir, 'mimetype'))}">application/vnd.oasis.opendocument.text</exsl:document>
	
	<exsl:document method="xml" href="{my:get-safe_mode-aware-filename(concat($output-dir, 'META-INF/manifest.xml'))}" indent="yes">
		<xsl:call-template name="document-manifest" />
	</exsl:document>

	<exsl:document method="xml" href="{my:get-safe_mode-aware-filename(concat($output-dir, 'meta.xml'))}" indent="yes">
		<office:document-meta version="1.0">
            <xsl:call-template name="document-meta-part" />
        </office:document-meta>
	</exsl:document>

	<exsl:document method="xml" href="{my:get-safe_mode-aware-filename(concat($output-dir, 'settings.xml'))}" indent="yes">
		<office:document-settings version="1.0">
            <xsl:call-template name="document-settings-part" />
        </office:document-settings>
	</exsl:document>

	<xsl:variable name="rtf-content-and-styles">
        <xsl:call-template name="document-content-part-with-styles" />
    </xsl:variable>
    <xsl:variable name="content-and-styles" select="exsl:node-set($rtf-content-and-styles)" />
    
    <exsl:document method="xml" href="{my:get-safe_mode-aware-filename(concat($output-dir, 'styles.xml'))}" indent="yes">
		<office:document-styles version="1.0"
                xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
                xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
                xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
                xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
                xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
                xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
                xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
                xmlns:foIn="http://www.w3.org/1999/XSL/Format"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
                xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
                xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
                xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
                xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
                xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
                xmlns:ooo="http://openoffice.org/2004/office"
                xmlns:ooow="http://openoffice.org/2004/writer"
                xmlns:oooc="http://openoffice.org/2004/calc"
                xmlns:dom="http://www.w3.org/2001/xml-events"
                xmlns:xforms="http://www.w3.org/2002/xforms">
            <office:automatic-styles>
                <xsl:copy-of select="$content-and-styles
                    /office:automatic-styles/*[self::style:style[starts-with(@style:name, 'STATIC-')] or self::style:page-layout]" />
            </office:automatic-styles>
            <xsl:copy-of select="$content-and-styles
                    /*[self::office:styles or self::office:master-styles]" />
        </office:document-styles>
	</exsl:document>

	<exsl:document method="xml" href="{my:get-safe_mode-aware-filename(concat($output-dir, 'content.xml'))}" indent="yes">
		<office:document-content version="1.0"
                xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
                xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
                xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
                xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
                xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
                xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
                xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
                xmlns:foIn="http://www.w3.org/1999/XSL/Format"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
                xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
                xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
                xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
                xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
                xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
                xmlns:ooo="http://openoffice.org/2004/office"
                xmlns:ooow="http://openoffice.org/2004/writer"
                xmlns:oooc="http://openoffice.org/2004/calc"
                xmlns:dom="http://www.w3.org/2001/xml-events"
                xmlns:xforms="http://www.w3.org/2002/xforms">
            <office:automatic-styles>
                <xsl:copy-of select="$content-and-styles
                    /office:automatic-styles/style:style[not(starts-with(@style:name, 'STATIC-'))]" />
            </office:automatic-styles>
            <xsl:copy-of select="$content-and-styles
                    /*[not(self::office:automatic-styles or self::office:styles or self::office:master-styles)]" />
        </office:document-content>
	</exsl:document>

</xsl:template>

<func:function name="my:get-safe_mode-aware-filename">
    <xsl:param name="filename" />
    <xsl:choose>
        <xsl:when test="$php-safe_mode = 'yes'"><func:result select="str2:replace($filename, '/', '--')" /></xsl:when>
        <xsl:otherwise><func:result select="$filename" /></xsl:otherwise>
    </xsl:choose>
</func:function>

</xsl:stylesheet>