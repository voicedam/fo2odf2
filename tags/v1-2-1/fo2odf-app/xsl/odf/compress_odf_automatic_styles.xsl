<?xml version="1.0"?>

<!--
Templates for "compressing" ODF automatic styles (see below).
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:set="http://exslt.org/sets"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
	exclude-result-prefixes="exsl set log"
    extension-element-prefixes="exsl set">

<xsl:import href="../common/xslt_logging.xsl" />
<xsl:import href="../common/strings.xsl" />

<!-- Generates "nice" style names and makes one style:style element from style:style elements containing the same properties. -->
<xsl:template name="compress-odf-automatic-styles">
    <xsl:param name="nodes" select="." />
    
    <!-- === Find out style names to be replaced === -->
    
    <xsl:variable name="orig-styles" select="$nodes//style:style" />
    <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Concatenating style elements content for finding out equal styles... (<xsl:value-of select="count($orig-styles)" /> found)</xsl:with-param></xsl:call-template>
    
    <xsl:variable name="concat-styles">
        <xsl:for-each select="$orig-styles">
            <xsl:variable name="concat-style-text">
                <xsl:value-of select="my:nodes-to-string(@*[not(name(.) = 'style:name')])" /><!-- concat attributes (except style name) -->
                <xsl:value-of select="my:nodes-to-string(*)" /><!-- concat style properties elements -->
            </xsl:variable>
            <concat-style family="{@style:family}" name="{@style:name}"><xsl:value-of select="normalize-space($concat-style-text)" /></concat-style>
            <xsl:call-template name="log:log-trace"><xsl:with-param name="msg">- concat. content of style '<xsl:value-of select="@style:name" />': <xsl:value-of select="normalize-space($concat-style-text)" /></xsl:with-param></xsl:call-template> -->
        </xsl:for-each>
    </xsl:variable>
    
    <!-- === Prepare replacements of equal styles... === -->
    
    <xsl:variable name="distinct-concat-styles" select="set:distinct(exsl:node-set($concat-styles)/*)" />
    <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Preparing replacements of equal styles... (<xsl:value-of select="count($distinct-concat-styles)" /> found)</xsl:with-param></xsl:call-template>
    
    <xsl:variable name="nodes-with-replace-styles">
        <xsl:for-each select="set:distinct($distinct-concat-styles/@family)">
            <xsl:variable name="family" select="." />
            <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">- for family: <xsl:value-of select="$family" /></xsl:with-param></xsl:call-template>
            <xsl:call-template name="generate-replace-styles-and-go-next">
                <xsl:with-param name="distinct-concat-styles" select="$distinct-concat-styles[@family = $family]" />
            </xsl:call-template>
        </xsl:for-each>
        
        <xsl:copy-of select="$nodes" />
    </xsl:variable>
    
    <!-- === Make the replacement of equal styles and of style names -->
    
    <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Making the replacements of equals styles and style names...</xsl:with-param></xsl:call-template>
    
    <xsl:apply-templates select="exsl:node-set($nodes-with-replace-styles)" mode="compress-odf-automatic-styles" />
    
</xsl:template>

<!-- Generates <replace-style> elements for a given concat style and same styles. -->
<xsl:template name="generate-replace-styles-and-go-next">
    <xsl:param name="style-number" select="'1'" />
    <xsl:param name="distinct-concat-styles" />
    
    <xsl:variable name="concat-style" select="$distinct-concat-styles[1]" />
    <xsl:variable name="style-prefix" select="substring-before($concat-style/@name, '_')" /><!-- style name must contain '_'! -->
    <xsl:variable name="new-name" select="concat($style-prefix, '_', $style-number)" />
    
    <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">the same:</xsl:with-param></xsl:call-template>
    
    <xsl:for-each select="$concat-style/../*[. = $concat-style]">
        <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">style name '<xsl:value-of select="@name" />' -&gt; '<xsl:value-of select="$new-name" />'</xsl:with-param></xsl:call-template>
        <replace-style orig-name="{@name}" new-name="{$new-name}" />
    </xsl:for-each>
    
    <xsl:if test="$distinct-concat-styles[2]">
        <xsl:call-template name="generate-replace-styles-and-go-next">
            <xsl:with-param name="style-number" select="$style-number + 1" />
            <xsl:with-param name="distinct-concat-styles" select="$distinct-concat-styles[position() > 1]" />
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- By using this key the transformation is a little bit faster (cca -8 % on a sample document). It should be tested on larger documents... -->
<xsl:key name="replace-style" match="replace-style" use="@orig-name" />

<xsl:template match="replace-style" mode="compress-odf-automatic-styles" />

<xsl:template match="style:style" mode="compress-odf-automatic-styles">
    <xsl:variable name="orig-name" select="@style:name" />
    <xsl:variable name="this" select="." />
    
    <xsl:for-each select="/">
        <xsl:variable name="replace-style" select="key('replace-style', $orig-name)" />
        <xsl:variable name="new-name" select="$replace-style/@new-name" />
        <xsl:choose>
            <xsl:when test="$replace-style/preceding-sibling::*[@new-name = $new-name]">
                <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Omitting duplicate style: '<xsl:value-of select="$orig-name" />' -&gt; '<xsl:value-of select="$new-name" />'</xsl:with-param></xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Changing style name: '<xsl:value-of select="$orig-name" />' -&gt; '<xsl:value-of select="$new-name" />'</xsl:with-param></xsl:call-template>
                <xsl:for-each select="$this">
                    <xsl:copy>
                        <xsl:copy-of select="@*" />
                        <xsl:attribute name="style:name"><xsl:value-of select="$new-name" /></xsl:attribute>
                        <xsl:copy-of select="*" />
                    </xsl:copy>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<!-- Changes the 'style-name' attribute value with a newly generated name if the attribute is present. -->
<xsl:template match="*" mode="compress-odf-automatic-styles">
    <xsl:copy>
        <xsl:copy-of select="@*" />
        <xsl:variable name="style-name-attrib" select="@*[local-name(.) = 'style-name'][1]" />
        <xsl:if test="$style-name-attrib">
            <xsl:variable name="orig-name" select="$style-name-attrib" />
            <xsl:for-each select="/">
                <xsl:variable name="replace-style" select="key('replace-style', $orig-name)" />
                <xsl:variable name="new-name" select="$replace-style/@new-name" />
                <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Changing element's style-name: '<xsl:value-of select="$orig-name" />' -&gt; '<xsl:value-of select="$new-name" />'</xsl:with-param></xsl:call-template>
                <xsl:attribute name="{name($style-name-attrib)}">
                    <xsl:value-of select="$new-name" />
                </xsl:attribute>
            </xsl:for-each>
        </xsl:if>
        <xsl:apply-templates mode="compress-odf-automatic-styles" />
    </xsl:copy>
</xsl:template>


</xsl:stylesheet>