<?xml version="1.0"?>

<!--
Templates for preprocessing FO elements before their transformation to ODF:

- Lists are converted to tables.
- Coherent texts in "mixed" blocks (fo:block-s containing other blocks as well as inline text) are embeded to newly generated fo:block-s.
- For each block element which is child of a <fo:block> or <fo:block-container> @temp-is-first and @temp-is-last boolean attributes are output.
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
    extension-element-prefixes="exsl func"
	exclude-result-prefixes="exsl func my log"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format">

<func:function name="my:get-number-length">
    <xsl:param name="node" />
    <xsl:choose>
        <xsl:when test="$node and string(number(substring-before($node, 'pt'))) != 'NaN'">
            <func:result select="number(substring-before($node, 'pt'))" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="'0'" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<xsl:template match="foIn:list-block" mode="preprocess-fo-for-odf">
    <xsl:call-template name="make-list-block-for-odf" />
</xsl:template>

<xsl:template name="make-list-block-for-odf">
    <foIn:table>
        <xsl:copy-of select="@*" />
        <xsl:call-template name="output-add-info-attributes" />
        <xsl:variable name="table-width">
            <xsl:choose>
                <xsl:when test="ancestor::foIn:table-cell">
                    <!-- a list inside a table -->
                    <xsl:variable name="ancestor-table-cell" select="ancestor::foIn:table-cell[1]" />
                    <xsl:value-of select="$ancestor-table-cell/ancestor::foIn:table[1]/foIn:table-column[position() = $ancestor-table-cell/@column-number]/@column-width" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(my:get-content-width(.), 'pt')" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="width"><xsl:value-of select="$table-width" /></xsl:attribute>
        <foIn:table-column column-width="{@provisional-distance-between-starts}" number-columns-repeated="1" />
        <foIn:table-column column-width="{concat(my:get-number-length($table-width) - my:get-number-length(@provisional-distance-between-starts), 'pt')}" number-columns-repeated="1" />
        <foIn:table-body>
            <xsl:apply-templates select="foIn:list-item" mode="preprocess-fo-for-odf" />
        </foIn:table-body>
    </foIn:table>
</xsl:template>

<!-- TODO Handle margin and padding properties - some conversion must be made... -->
<xsl:template match="foIn:list-item" mode="preprocess-fo-for-odf">
    <foIn:table-row>
        <xsl:copy-of select="@*" />
        <foIn:table-cell column-number="1" number-rows-spanned="1" number-columns-spanned="1">
            <xsl:copy-of select="foIn:list-item-label/@*" />
            <xsl:apply-templates select="foIn:list-item-label/*" mode="preprocess-fo-for-odf" />
        </foIn:table-cell>
        <foIn:table-cell column-number="2" number-rows-spanned="1" number-columns-spanned="1">
            <xsl:copy-of select="foIn:list-item-body/@*" />
            <xsl:apply-templates select="foIn:list-item-body/*" mode="preprocess-fo-for-odf" />
        </foIn:table-cell>
    </foIn:table-row>
</xsl:template>

<xsl:template match="*" mode="preprocess-fo-for-odf">
    <xsl:copy>
        <xsl:copy-of select="@*" />
        <xsl:apply-templates mode="preprocess-fo-for-odf" />
    </xsl:copy>
</xsl:template>

<!-- Will be applied only on the top level (children of fo:static-content or fo:flow). -->
<xsl:template match="foIn:block | foIn:block-container" mode="preprocess-fo-for-odf">
    <xsl:copy>
        <xsl:copy-of select="@*" />
        <xsl:apply-templates select="." mode="preprocess-fo-block-children" />
    </xsl:copy>
</xsl:template>

<xsl:template match="foIn:block" mode="preprocess-fo-block-children">
    <xsl:variable name="this" select="." />
    <xsl:choose>
        <xsl:when test="*[my:is-block-element(.)]">
            <xsl:for-each select="node()[my:is-block-element(.)
                    or self::foIn:float
                    or (position() = 1 and not(self::text()[normalize-space(.) = '']))
                    or (preceding-sibling::node()[1][my:is-block-element(.) or self::foIn:float] and not(position() = last() and self::text()[normalize-space(.) = '']))]">
                <xsl:choose>
                    <xsl:when test="self::*[my:is-block-element(.)] or self::foIn:float">
                        <xsl:choose>
                            <xsl:when test="self::foIn:list-block">
                                <xsl:call-template name="make-list-block-for-odf" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy>
                                    <xsl:copy-of select="@*" />
                                    <xsl:call-template name="output-add-info-attributes" />
                                    <xsl:apply-templates select="." mode="preprocess-fo-block-children" />
                                </xsl:copy>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="not(self::text()[normalize-space(.) = ''] and following-sibling::*[1][my:is-block-element(.)])">
                        <foIn:block>
                            <xsl:copy-of select="../@*[not(my:is-bottom-property(.) or my:is-top-property(.) or local-name(.) = 'id')]" />
                            <xsl:call-template name="output-add-info-attributes" />
                            <xsl:call-template name="copy-self-inline-and-go-next">
                                <xsl:with-param name="node" select="." />
                            </xsl:call-template>
                        </foIn:block>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates mode="preprocess-fo-for-odf" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="foIn:block-container" mode="preprocess-fo-block-children">
    <xsl:variable name="this" select="." />
    <xsl:if test="text()[normalize-space(.) != ''] or *[not(my:is-block-element(.))]">
        <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Inline text in a "fo:block-container" will be ignored as the container can contain only block elements.</xsl:with-param></xsl:call-template>
    </xsl:if>
    <xsl:for-each select="*[my:is-block-element(.)]">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:call-template name="output-add-info-attributes" />
            <xsl:apply-templates select="." mode="preprocess-fo-block-children" />
        </xsl:copy>
    </xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="preprocess-fo-block-children">
    <xsl:apply-templates mode="preprocess-fo-for-odf" />
</xsl:template>

<xsl:template name="output-add-info-attributes">
    <xsl:if test="position() = 1"><!-- TODO And what about the first block after one or more floats? -->
        <xsl:attribute name="temp-is-first">yes</xsl:attribute>
    </xsl:if>
    <xsl:if test="position() = last()">
        <xsl:attribute name="temp-is-last">yes</xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template name="copy-self-inline-and-go-next">
    <xsl:param name="node" select="." />
    <xsl:copy-of select="$node" />
    <xsl:if test="$node/following-sibling::node()[1][not(my:is-block-element(.) or self::foIn:float)]">
        <xsl:call-template name="copy-self-inline-and-go-next">
            <xsl:with-param name="node" select="$node/following-sibling::node()[1]" />
        </xsl:call-template>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>