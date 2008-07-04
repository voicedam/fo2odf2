<?xml version="1.0"?>

<!-- Defines common functions / templates for testing stylesheets. -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://xsltsl.org/xsl/documentation/1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:str="http://exslt.org/strings"
    xmlns:my="http://example.com/muj"
    extension-element-prefixes="str"
    exclude-result-prefixes="doc my exsl str" version="1.0">

<!-- Returns sorted attributes of an element as a string.
Example:
- for <fo:block margin-top="20pt" font-size="10pt" /> returns 'font-size="10pt" margin-top="20pt"'
-->
<xsl:template name="_get-element-sorted-attributes">
    <xsl:param name="element" select="." /><!-- element -->
    <xsl:for-each select="$element/@*">
        <xsl:sort select="local-name(.)" />
        <xsl:value-of select="concat(local-name(.), '=&quot;', ., '&quot;')" />
        <xsl:if test="position() &lt; last()"><xsl:text> </xsl:text></xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- Returns sorted attributes of an element as a string.
Example:
- for <fo:block margin-top="20pt" font-size="10pt" /> returns 'font-size="10pt" margin-top="20pt"'
-->
<xsl:template name="_get-result-tree-element-sorted-attributes">
    <xsl:param name="element" select="." /><!-- element -->
    <xsl:call-template name="_get-element-sorted-attributes">
        <xsl:with-param name="element" select="exsl:node-set($element)/*" />
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>