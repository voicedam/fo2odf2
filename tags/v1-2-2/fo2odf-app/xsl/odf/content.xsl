<?xml version="1.0"?>

<!--
Generates the "content" part of a document. This stylesheet can be considered as the "main"
stylesheet of the "FO2ODF transformation".
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:set="http://exslt.org/sets"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
    xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
    xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
    xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
    xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
    xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
    xmlns:math="http://www.w3.org/1998/Math/MathML"
    xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
    xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
    xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer"
    xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events"
    xmlns:xforms="http://www.w3.org/2002/xforms"
    exclude-result-prefixes="exsl set my log"
    extension-element-prefixes="exsl set"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format">

<xsl:import href="../common/xslt_logging.xsl" />

<xsl:include href="page_layout.xsl" />
<xsl:include href="blocks.xsl" />
<xsl:include href="inlines.xsl" />
<xsl:include href="attributes.xsl" />

<xsl:include href="preprocess-fo-for-odf.xsl" />
<xsl:include href="fix-odf-structure.xsl" />
<xsl:include href="compress_odf_automatic_styles.xsl" />
<xsl:include href="preserve_white_space.xsl" />

<!-- Ignore any text nodes when generating styles. -->
<xsl:template match="text()" mode="styles">
</xsl:template>

<!-- ===== "phase1" templates ===== -->

<!-- See "preserve_white_space.xsl" if you wonder how white space is treated in the "phase1". -->

<!-- Simply ignore any unknown elements. -->
<xsl:template match="*" mode="phase1">
    <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Element not recognized: '<xsl:value-of select="name(.)" />'</xsl:with-param></xsl:call-template>
</xsl:template>

<!-- Simply ignore any unknown attributes. -->
<xsl:template match="@*" mode="phase1" />

<xsl:template match="foIn:root" mode="phase1">
    <xsl:apply-templates mode="phase1" />
</xsl:template>

<xsl:template match="foIn:flow" mode="phase1">
    <xsl:apply-templates mode="phase1" />
</xsl:template>

<xsl:template match="foIn:retrieve-marker" mode="phase1">
    <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Element 'fo:retrieve-marker' not supported - ignored.</xsl:with-param></xsl:call-template> 
</xsl:template>

<!-- ===== /"phase1" templates ===== -->

<xsl:template name="prepare-nodes-for-transformation">
    <xsl:param name="nodes" />
    <!-- Expand FO shorthand properties. -->
    <xsl:call-template name="log:log-info"><xsl:with-param name="msg">=== Expanding FO shorthand properties... ===</xsl:with-param></xsl:call-template>
    <xsl:variable name="nodes-with-expanded-shorthands">
        <xsl:call-template name="expand-fo-shorthands">
            <xsl:with-param name="nodes" select="$nodes" />
        </xsl:call-template>
    </xsl:variable>
    
    <!-- Compute values of FO properties. -->
    <xsl:call-template name="log:log-info"><xsl:with-param name="msg">=== Computing FO properties values... ===</xsl:with-param></xsl:call-template>
    <xsl:variable name="nodes-with-computed-fo-properties">
        <xsl:call-template name="compute-fo-properties">
            <xsl:with-param name="nodes" select="exsl:node-set($nodes-with-expanded-shorthands)" />
        </xsl:call-template>
    </xsl:variable>
    
    <!-- Copy all inherited properties. -->
    <xsl:call-template name="log:log-info"><xsl:with-param name="msg">=== Copying inherited properties... ===</xsl:with-param></xsl:call-template>
    <xsl:variable name="nodes-with-computed-and-inherited-fo-properties">
        <xsl:call-template name="copy-inherited-properties">
            <xsl:with-param name="nodes" select="exsl:node-set($nodes-with-computed-fo-properties)" />
        </xsl:call-template>
    </xsl:variable>
    
    <!-- Preprocess FOs for easier transformation to ODF. -->
    <xsl:call-template name="log:log-info"><xsl:with-param name="msg">=== Preprocessing FOs for easier transformation to ODF... ===</xsl:with-param></xsl:call-template>
    <xsl:apply-templates select="exsl:node-set($nodes-with-computed-and-inherited-fo-properties)" mode="preprocess-fo-for-odf" />
</xsl:template>

<xsl:template name="transform-nodes-to-odf">
    <xsl:param name="nodes" />
    
    <xsl:variable name="rtf-nodes-prepared-for-transformation">
        <xsl:call-template name="prepare-nodes-for-transformation">
            <xsl:with-param name="nodes" select="$nodes" />
        </xsl:call-template>
    </xsl:variable>
    
    <!-- Make the transformation from FO to ODF format. -->
    <xsl:call-template name="log:log-info"><xsl:with-param name="msg">=== Transforming preprocessed FOs to ODF elements... ===</xsl:with-param></xsl:call-template>
    
    <xsl:if test="exsl:node-set($rtf-nodes-prepared-for-transformation)//foIn:leader">
        <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">'leader-length' property not supported - a default length will be used for all leaders (unless 'xfc:tab-position' extension attribute is specified on the leader)</xsl:with-param></xsl:call-template>
    </xsl:if>
    
    <xsl:variable name="rtf-nodes-in-nearly-odf-format">
        <xsl:apply-templates select="exsl:node-set($rtf-nodes-prepared-for-transformation)" mode="phase1" />
    </xsl:variable>
    
    <xsl:call-template name="log:log-info"><xsl:with-param name="msg">=== Fixing structure of the ODF elements... ===</xsl:with-param></xsl:call-template>
    <xsl:variable name="rtf-nodes-in-nearly-odf-format2">
        <xsl:apply-templates select="exsl:node-set($rtf-nodes-in-nearly-odf-format)" mode="fix-odf-structure" />
    </xsl:variable>
    
    <xsl:choose>
        <xsl:when test="$compress-odf-automatic-styles = 'yes'">
            <xsl:call-template name="log:log-info"><xsl:with-param name="msg">=== Compressing ODF automatic styles... ===</xsl:with-param></xsl:call-template>
            <xsl:call-template name="compress-odf-automatic-styles">
                <xsl:with-param name="nodes" select="exsl:node-set($rtf-nodes-in-nearly-odf-format2)" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:copy-of select="$rtf-nodes-in-nearly-odf-format2" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="document-content-part-with-styles">
    
    <xsl:variable name="rtf-nodes-in-nearly-odf-format">
        <xsl:call-template name="transform-nodes-to-odf">
            <xsl:with-param name="nodes" select="/" />
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="nodes-in-nearly-odf-format" select="exsl:node-set($rtf-nodes-in-nearly-odf-format)" />
    
    <!-- Allowed content: scripts, font-face-decls, automatic-styles, body -->
    <!-- office:document-content office:version="1.0" -->

        <office:scripts />

        <office:font-face-decls>
            <style:font-face style:name="F1" svg:font-family="Tahoma" />
            <style:font-face style:name="F2" svg:font-family="&apos;Times New Roman&apos;"
                style:font-family-generic="roman" style:font-pitch="variable" />
        </office:font-face-decls>

        <office:automatic-styles>
            <style:style style:family="paragraph" style:name="P1">
                <style:paragraph-properties fo:text-align="start" style:font-name="F1">
                </style:paragraph-properties>
            </style:style>
            
            <xsl:call-template name="log:log-info"><xsl:with-param name="msg">=== Generating ODF automatic styles... ===</xsl:with-param></xsl:call-template>
            <xsl:for-each select="$nodes-in-nearly-odf-format//style:style | $nodes-in-nearly-odf-format//style:page-layout">
                <xsl:sort select="substring-before(@style:name, '_')" />
                <xsl:sort select="substring-after(@style:name, '_')" data-type="number" />
                <xsl:copy-of select="." />
            </xsl:for-each>
        </office:automatic-styles>

        <!-- This is not allowed in <office:document-content> - must be put to <office:document-styles> for "archive version" of ODF document -->
        <office:styles>
            <style:style style:family="graphics" style:name="Frame">
                <style:graphic-properties />
            </style:style>
            <style:style style:family="graphics" style:name="Graphics">
                <style:graphic-properties />
            </style:style>
        </office:styles>
        <office:master-styles>
            <xsl:for-each select="$nodes-in-nearly-odf-format//style:master-page">
                <xsl:sort select="substring-before(@style:name, '_')" />
                <xsl:sort select="substring-after(@style:name, '_')" data-type="number" />
                <xsl:copy>
                    <xsl:copy-of select="./@*" />
                    <xsl:apply-templates mode="odf-office-text" /><!-- omits style elements -->
                </xsl:copy>
            </xsl:for-each>
        </office:master-styles>
        <!-- /end -->
        
        <office:body>
            <office:text>
                <xsl:call-template name="log:log-info"><xsl:with-param name="msg">=== Generating ODF text content... ===</xsl:with-param></xsl:call-template>
                <xsl:apply-templates select="$nodes-in-nearly-odf-format" mode="odf-office-text" />
                <!-- <xsl:copy-of select="$nodes-in-nearly-odf-format" />-->
            </office:text>
        </office:body>

    <!-- /office:document-content -->
</xsl:template>

<!-- ===== Post-processing for content of the "office:text" element ===== -->

<!-- By default take (copy) all elements. -->
<xsl:template match="*" mode="odf-office-text">
    <xsl:copy>
        <xsl:copy-of select="@*" />
        <xsl:apply-templates mode="odf-office-text" />
    </xsl:copy>
</xsl:template>

<!-- Omit all elements which don't belong to "office:text". -->
<xsl:template match="style:style | style:page-layout | style:master-page" mode="odf-office-text">
</xsl:template>

<!-- ===== Copying inherited properties ===== -->

<!-- Copies inherited FO properties on the given nodes. -->
<xsl:template name="copy-inherited-properties">
    <xsl:param name="nodes" select="." /><!-- node set -->
    <xsl:apply-templates select="$nodes" mode="copy-inherited-properties" />
</xsl:template>

<xsl:template match="*" mode="copy-inherited-properties">
    <xsl:copy>
        <xsl:if test="not(@color)">
            <!-- Put default color everywhere. Otherwise OO would expect automatic color when opening a flat ODF document... -->
            <xsl:attribute name="color"><xsl:value-of select="$default-color" /></xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="ancestor::*/@*[my:is-inherited-property(.)]" />
        <xsl:copy-of select="@*" />
        <xsl:apply-templates mode="copy-inherited-properties" />
    </xsl:copy>
</xsl:template>

<!-- ===== /Copying inherited properties ===== -->

<!-- Called by templates in the "phase1" mode before outputing FO element's ODF style and ODF element. -->
<xsl:template name="process-fo-id">
    <xsl:if test="@id">
        <text:bookmark text:name="{@id}" />
    </xsl:if>
</xsl:template>

</xsl:stylesheet>