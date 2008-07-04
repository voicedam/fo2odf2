<?xml version="1.0"?>

<!--
Templates for converting page layout elements to ODF (including static content).
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:my="http://example.com/muj"
	exclude-result-prefixes="my"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0">

<!-- Simply applies templates on all <fo:simple-page-master> child elements. -->
<xsl:template match="foIn:layout-master-set" mode="phase1">
    <xsl:apply-templates select="foIn:simple-page-master" mode="phase1" />
</xsl:template>

<!-- Outputs <style:master-page> with header and footer elements and applies templates on the child <fo:flow>.
TODO Handling of flow names is inaccurate... -->
<xsl:template match="foIn:page-sequence" mode="phase1">
    <xsl:variable name="simple-page-master" select="my:get-simple-page-master(.)" />
    <style:master-page
            style:name="{my:get-unique-style-name(., 'page-sequence')}"
            style:page-layout-name="{my:get-unique-style-name($simple-page-master, 'simple-page-master')}">
        <style:header>
            <xsl:apply-templates select="foIn:static-content[starts-with(@flow-name, 'xsl-region-before')][1]" mode="phase1" />
        </style:header>
        <style:footer>
            <xsl:apply-templates select="foIn:static-content[starts-with(@flow-name, 'xsl-region-after')][1]" mode="phase1" />
        </style:footer>
    </style:master-page>
    
    <xsl:apply-templates select="foIn:flow" mode="phase1" />
</xsl:template>

<!-- Processed the same way as <fo:flow> - its children are processed. -->
<xsl:template match="foIn:static-content" mode="phase1">
    <xsl:apply-templates mode="phase1" />
</xsl:template>

<!-- Outputs <style:page-layout> with properties taken from this <fo:simple-page-master> element and its child <fo:region-body>.
ODF elements <style:header-style> and <style:footer-style> are output for <fo:region-before> and <fo:region-after> children. -->
<xsl:template match="foIn:simple-page-master" mode="phase1">
    <style:page-layout style:name="{my:get-unique-style-name(., 'simple-page-master')}">
        <style:page-layout-properties>
            <xsl:apply-templates select="./foIn:region-body/@*" mode="styles" />
            <xsl:apply-templates select="./@*" mode="styles" />
        </style:page-layout-properties>
        <style:header-style>
            <style:header-footer-properties>
                <xsl:apply-templates select="./foIn:region-before/@*" mode="styles" />
            </style:header-footer-properties>
        </style:header-style>
        <style:footer-style>
            <style:header-footer-properties>
                <xsl:apply-templates select="./foIn:region-after/@*" mode="styles" />
            </style:header-footer-properties>
        </style:footer-style>
    </style:page-layout>
</xsl:template>

</xsl:stylesheet>