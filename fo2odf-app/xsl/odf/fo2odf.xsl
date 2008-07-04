<?xml version="1.0"?>

<!--
Converts a FO document to an ODF document. This stylesheet doesn't output anything by itself, it rather
imports/includes all stylesheets necessary for the conversion. Plus it defines functions and templates
commonly used in the transformation. 

So don't use this stylesheet directly, use some of the 'fo2odf-*.xsl' stylesheets instead.
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:str="http://exslt.org/strings"
    xmlns:my="http://example.com/muj"
    xmlns:php="http://php.net/xsl"
    xmlns:myjavautils="MyJavaUtils"
    xmlns:fo2odf="http//example.com/fo2odf"
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
	exclude-result-prefixes="doc my php myjavautils fo2odf"
    extension-element-prefixes="exsl func str">

<xsl:import href="../common/strings.xsl" />

<xsl:import href="expand_fo_shorthands.xsl" />
<xsl:import href="compute_fo_properties.xsl" />
<xsl:import href="fo_info_functions.xsl" />

<xsl:import href="fo2odf_params.xsl" />
<xsl:import href="manifest.xsl" />
<xsl:import href="meta.xsl" />
<xsl:import href="settings.xsl" />
<xsl:import href="content.xsl" />

<!-- Check whether the source document is a FO document. If not, then the transformation is terminated. -->
<xsl:template name="check-source-document">
    <xsl:if test="not(/foIn:root)">
        <xsl:message terminate="yes">FATAL: Input file is not a FO document (root element "fo:root" not found)! Terminating transformation...</xsl:message>
    </xsl:if>
    <xsl:if test="/foIn:root/@xml:base and function-available('myjavautils:saveBaseURI')">
        <xsl:variable name="foo" select="myjavautils:saveBaseURI(string(/foIn:root/@xml:base))" />
    </xsl:if>
</xsl:template>

<!-- ===== COMMON FUNCTIONS ===== -->

<!-- Returns a unique value for the "style:name"/"text:style-name" ODF attribute of the passed element and its type ('block', 'inline', ...). -->
<func:function name="my:get-unique-style-name">
    <xsl:param name="node" select="." /><!-- element or its text -->
    <xsl:param name="elem-type" select="''" />
    <xsl:variable name="type-prefix">
        <xsl:choose>
            <xsl:when test="$elem-type = 'page-sequence'">MP_</xsl:when><!-- 'Master Page' -->
            <xsl:when test="$elem-type = 'simple-page-master'">PL_</xsl:when><!-- 'Page Layout' -->
            <xsl:when test="$elem-type = 'block'">P_</xsl:when>
            <xsl:when test="$elem-type = 'inline'">T_</xsl:when>
            <xsl:when test="$elem-type = 'table'">TB_</xsl:when>
            <xsl:when test="$elem-type = 'table-column'">TC_</xsl:when>
            <xsl:when test="$elem-type = 'table-row'">TR_</xsl:when>
            <xsl:when test="$elem-type = 'table-cell'">TD_</xsl:when>
            <xsl:when test="$elem-type = 'frame'">FR_</xsl:when>
            <xsl:when test="$elem-type = 'graphic'">GR_</xsl:when>
            <xsl:otherwise>U_</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="static-prefix">
        <xsl:if test="ancestor::foIn:static-content">STATIC-</xsl:if>
    </xsl:variable>
    <func:result select="concat($static-prefix, $type-prefix, generate-id($node))" /> 
</func:function>

<!-- Returns whether a given attribute is an FO property which will become an ODF text property after transformation. -->
<func:function name="my:is-text-property">
    <xsl:param name="n" select="." />
    <xsl:variable name="name" select="local-name($n)" />
    <!-- <func:result select="true()" /> -->
    <func:result select="$name = $global-fo-odf-text-properties" />
</func:function>
<!-- TODO Not complete list yet -->
<xsl:variable name="global-fo-odf-text-properties" select="str:tokenize('font-weight,font-style,font-variant,text-transform,font-size,font-family,baseline-shift,text-decoration,color,background-color,letter-spacing,language,country,hyphenate,hyphenation-push-character-count,hyphenation-remain-character-count', ',')" />

<!-- Returns whether a given attribute is an FO property which will become an ODF paragraph property after transformation. -->
<func:function name="my:is-paragraph-property">
    <xsl:param name="n" select="." />
    <xsl:variable name="name" select="local-name($n)" />
    <func:result select="$name = $global-fo-odf-paragraph-properties" />
</func:function>
<!-- TODO Not complete list yet -->
<xsl:variable name="global-fo-odf-paragraph-properties" select="str:tokenize('background-color,space-before,space-after,start-indent,end-indent,margin-left,margin-right,margin-top,margin-bottom,padding-left,padding-right,padding-top,padding-bottom,border-left-style,border-left-width,border-left-color,border-right-style,border-right-width,border-right-color,border-top-style,border-top-width,border-top-color,border-bottom-style,border-bottom-width,border-bottom-color,text-align,text-align-last,text-indent,keep-together,keep-with-next,keep-with-previous,orphans,widows,break-before,break-after,line-height,hyphenation-ladder-count,hyphenation-keep', ',')" />

<!-- Returns whether a given attribute is an FO property which will become an ODF table cell property after transformation. -->
<func:function name="my:is-table-cell-property">
    <xsl:param name="n" select="." />
    <xsl:variable name="name" select="local-name($n)" />
    <func:result select="$name = $global-fo-odf-table-cell-properties" />
</func:function>
<!-- TODO Not complete list yet (some properties probably are yet to be removed...) -->
<xsl:variable name="global-fo-odf-table-cell-properties" select="str:tokenize('display-align,background-color,space-before,space-after,start-indent,end-indent,margin-left,margin-right,margin-top,margin-bottom,padding-left,padding-right,padding-top,padding-bottom,border-left-style,border-left-width,border-left-color,border-right-style,border-right-width,border-right-color,border-top-style,border-top-width,border-top-color,border-bottom-style,border-bottom-width,border-bottom-color', ',')" />

<!-- Returns whether a given attribute is a FO "inherited" property, i.e. whether it is necessary to copy it to child elements. 
The property doesn't have to be necessarily mentioned as "inherited" in the XSL-FO specification, important is whether it behaves
like an inherited property during the conversion to ODF (like f.e. the 'background-color' property). -->
<func:function name="my:is-inherited-property">
    <xsl:param name="n" select="." />
    <xsl:variable name="name" select="local-name($n)" />
    <func:result select="my:is-inherited-fo-property($name) or ($name = $global-odf-copied-properties)" />
</func:function>
<!-- TODO Not complete list yet -->
<xsl:variable name="global-odf-copied-properties" select="str:tokenize('background-color', ',')" />

<xsl:key name="element-with-id" match="*" use="@id" />

<!-- ===== /COMMON FUNCTIONS ===== -->

</xsl:stylesheet>