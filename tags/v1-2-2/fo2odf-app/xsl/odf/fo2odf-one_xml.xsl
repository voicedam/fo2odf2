<?xml version="1.0"?>

<!--
Converts a FO document to an ODF document. The result is one XML file containing
the whole ODF text document.
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
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
	exclude-result-prefixes="doc"
    extension-element-prefixes="exsl">

<xsl:import href="fo2odf.xsl" />

<xsl:output indent="no" />

<!-- The main template. Calls imported templates for creating various parts of an ODF document.
1. Checks whether the input file is an XSL FO document.
2. Outputs result of conversion to one XML file in the ODF format. -->
<xsl:template match="/">    
    
    <xsl:call-template name="check-source-document" />
    
    <office:document mimetype="application/vnd.oasis.opendocument.text" version="1.0">
        <xsl:call-template name="document-meta-part" /><!-- optional -->
        <xsl:call-template name="document-settings-part" /><!-- optional -->
        <xsl:call-template name="document-content-part-with-styles" />
    </office:document>
</xsl:template>

</xsl:stylesheet>