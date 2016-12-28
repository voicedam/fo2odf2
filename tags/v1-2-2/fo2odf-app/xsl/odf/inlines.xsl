<?xml version="1.0"?>

<!--
Templates for converting FO "inline level" elements to corresponding ODF elements.

ODF's <style:style> elements are output in front of every corresponding element. These style elements must be
moved to <style:automatic-styles> elements in the next phase.
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
	exclude-result-prefixes="my log"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
    xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format">

<xsl:include href="inlines-images.xsl" />

<!-- Initial implementation of some elements - simply applies templates on the element's children. -->
<xsl:template match="foIn:inline-container" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:apply-templates mode="phase1" />
</xsl:template>

<!-- Generates <text:span> from <fo:inline> or <foIn:bidi-override> element. Applies templates to child nodes. -->
<xsl:template match="foIn:inline" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:variable name="fo-elem" select="." />
    <xsl:variable name="style-name" select="my:get-unique-style-name(., 'inline')" />
    <text:span text:style-name="{$style-name}"><xsl:apply-templates mode="phase1" /></text:span>
    <style:style style:family="text" style:name="{$style-name}">
        <style:text-properties>
            <xsl:apply-templates select="$fo-elem/@*[my:is-text-property(.)]" mode="styles" />
        </style:text-properties>
    </style:style>
</xsl:template>

<!-- Simply puts ODF's <text:tab /> in the place of the FO's <fo:leader>. Style for the corresponding
<text:tab-stop> is generated when processing parent block of this leader. Embeds the tab in a <text:span>
with style properties from the leader - this is nearly the same code as for <fo:inline>. -->
<xsl:template match="foIn:leader" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:call-template name="generate-odf-text-span">
        <xsl:with-param name="span-content"><text:tab /></xsl:with-param>
    </xsl:call-template>
</xsl:template>

<!-- Transforms <fo:page-number> to ODF's <text:page-number />. Implementation similar to "foIn:leader" template. -->
<xsl:template match="foIn:page-number" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:call-template name="generate-odf-text-span">
        <xsl:with-param name="span-content"><text:page-number /></xsl:with-param>
    </xsl:call-template>
</xsl:template>

<!-- Transforms <fo:page-number-citation> to ODF. It issues a log warning if the referenced element is not found in the document. -->
<xsl:template match="foIn:page-number-citation" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:if test="not(@ref-id) or not(key('element-with-id', @ref-id))">
        <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">'ref-id' of the 'page-number-citation' missing or illegal, value: '<xsl:value-of select="@ref-id" />'</xsl:with-param></xsl:call-template>
    </xsl:if>
    <xsl:call-template name="generate-odf-text-span">
        <xsl:with-param name="span-content"><text:bookmark-ref text:ref-name="{@ref-id}" text:reference-format="page">0</text:bookmark-ref></xsl:with-param>
    </xsl:call-template>
</xsl:template>

<!--
Transforms <fo:basic-link> to ODF. The following formats of 'fo:external-destination' are accepted:
- url(http://example.org)
- url('http://example.org')
- http://example.org
It issues a log warning if the element referenced by 'fo:internal-destination' is not found in the document.
-->
<xsl:template match="foIn:basic-link" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:if test="@internal-destination and not(key('element-with-id', @internal-destination))">
        <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">'internal-destination' of the 'basic-link' is probably wrong - no element with id '<xsl:value-of select="@internal-destination" />' found in the document</xsl:with-param></xsl:call-template>
    </xsl:if>
    <xsl:variable name="href">
        <xsl:choose>
            <xsl:when test="@internal-destination"><!-- ignore @external-destination if specified as well -->
                <xsl:value-of select="concat('#', @internal-destination)" />
            </xsl:when>
            <xsl:otherwise><!-- @external-destination -->
                <xsl:value-of select="my:get-url-content(@external-destination)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <text:a xlink:href="{$href}">
        <xsl:call-template name="generate-odf-text-span">
            <xsl:with-param name="span-content"><xsl:apply-templates mode="phase1" /></xsl:with-param>
        </xsl:call-template>
    </text:a>
</xsl:template>

<!-- Transforms <fo:footnote> to ODF's <text:note>. -->
<xsl:template match="foIn:footnote" mode="phase1">
    <xsl:apply-templates select="foIn:inline[1]" mode="phase1" /><!-- only one <fo:inline> must be present -->
    <text:note>
        <!-- &#x200B; = "zero width space" -->
        <text:note-citation text:label="&#x200B;"> </text:note-citation><!-- without "text:label" citation number would be automatically generated -->
        <text:note-body>
            <xsl:apply-templates select="foIn:footnote-body[1]/*" mode="phase1" /><!-- only one <fo:footnote-body> must be present -->
        </text:note-body>
    </text:note>
</xsl:template>

<!-- Generate ODF's <text:span> element with a given content for the current element. -->
<xsl:template name="generate-odf-text-span">
    <xsl:param name="span-content" select="/.." />
    <xsl:variable name="fo-elem" select="." />
    <xsl:variable name="style-name" select="my:get-unique-style-name(., 'inline')" />
    <text:span text:style-name="{$style-name}"><xsl:copy-of select="$span-content" /></text:span>
    <style:style style:family="text" style:name="{$style-name}">
        <style:text-properties>
            <xsl:apply-templates select="$fo-elem/@*[my:is-text-property(.)]" mode="styles" />
        </style:text-properties>
    </style:style>
</xsl:template>

</xsl:stylesheet>