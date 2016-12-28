<?xml version="1.0"?>

<!--
Templates for converting FO table elements to corresponding ODF elements.

Note: OpenOffice Writer displays tables correctly even if <table:covered-table-cell>-s are not generated.
Nevertheless according to the ODF specification the covered cells MUST be present when row or column spanning
is used, so this stylesheet meets this requirement.

TODO Calculate table width if not specified explicitly. Otherwise in ODF the table has 100% width.
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
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format">

<!-- Initial implementation of some elements - simply applies templates on the element's children. -->
<xsl:template match="foIn:table-and-caption | foIn:table-caption" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:apply-templates mode="phase1" />
</xsl:template>

<!-- Generates <table:table> from a <fo:table>. -->
<xsl:template match="foIn:table" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:variable name="fo-elem" select="." />
    <xsl:variable name="style-name" select="my:get-unique-style-name(., 'table')" />
    <style:style style:family="table" style:name="{$style-name}">
        <style:table-properties table:align="left"><!-- TODO how to align tables in FO? -->
            <xsl:apply-templates select="$fo-elem/@*" mode="styles" />
            <xsl:call-template name="process-fo-top-and-bottom-properties-from-parent" />
        </style:table-properties>
    </style:style>
    <table:table table:style-name="{$style-name}">
        <!-- Generate table columns... -->
        <xsl:apply-templates select="foIn:table-column" mode="phase1" />
        <!-- This is simplified a lot and it will work only in the simplest tables: -->
        <xsl:variable name="num-of-defined-columns" select="sum(foIn:table-column/@number-columns-repeated)" />
        <xsl:for-each select="foIn:table-body[1]/foIn:table-row[1]/foIn:table-cell[position() > $num-of-defined-columns]">
            <xsl:call-template name="output-odf-table-column" />
        </xsl:for-each>
        
        <xsl:apply-templates select="foIn:table-header" mode="phase1" />
        <xsl:apply-templates select="foIn:table-body" mode="phase1" />
        <xsl:apply-templates select="foIn:table-footer" mode="phase1" />
    </table:table>
</xsl:template>

<!-- Handled explicitly. -->
<xsl:template match="@border-collapse" mode="styles">
</xsl:template>

<!-- <fo:table-header> becomes <table:table-header-rows>, other become <table:table-rows>. -->
<xsl:template match="foIn:table-header | foIn:table-body | foIn:table-footer" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:variable name="odf-el-name">
        <xsl:choose>
            <xsl:when test="local-name(.) = 'table-header' and not(parent::foIn:table/@table-omit-header-at-break = 'true')">table:table-header-rows</xsl:when>
            <xsl:otherwise>table:table-rows</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$odf-el-name}">
        <xsl:apply-templates select="foIn:table-row" mode="phase1" />
    </xsl:element>
</xsl:template>

<!-- Converts <fo:table-row> to ODF's <table-row>. TODO @column-number of cells is ignored. -->
<xsl:template match="foIn:table-row" mode="phase1">
    <xsl:param name="row" select="." /><!-- element -->
    
    <xsl:call-template name="process-fo-id" />
    
    <xsl:variable name="style-name" select="my:get-unique-style-name($row, 'table-row')" />
    <style:style style:family="table-row" style:name="{$style-name}">
        <style:table-row-properties>
            <xsl:apply-templates select="$row/@*" mode="styles" />
        </style:table-row-properties>
    </style:style>
    <table:table-row table:style-name="{$style-name}">
        
        <!-- Find out covered cells from previous rows -->
        <xsl:variable name="ccs">
            <xsl:call-template name="get-row-covered-cells">
                <xsl:with-param name="for-row-number" select="count($row/preceding-sibling::foIn:table-row) + 1" />
            </xsl:call-template>
        </xsl:variable>
        
        <!-- Go through the obtained cells and output table-cells where @rows = 1, otherwise output ODF's covered cell. -->
        <xsl:for-each select="exsl:node-set($ccs)/*">
            <xsl:variable name="cc" select="." />
            <xsl:choose>
                <xsl:when test="@rows = 1">
                    <xsl:variable name="cell-position" select="count($cc/preceding-sibling::*[@rows = 1]) + 1" />
                    <xsl:apply-templates
                            select="$row/foIn:table-cell[$cell-position]"
                            mode="phase1" />
                </xsl:when>
                <xsl:otherwise>
                    <table:covered-table-cell />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        
    </table:table-row>
</xsl:template>

<xsl:template name="get-row-covered-cells">
    <xsl:param name="for-row-number" />
    <xsl:variable name="rows" select=".." />
    <xsl:choose>
        <xsl:when test="$for-row-number = 1">
            <xsl:for-each select="$rows/foIn:table-row[1]/foIn:table-cell">
                <xsl:call-template name="to-table-cc">
                    <xsl:with-param name="cell" select="." />
                    <xsl:with-param name="for-first-row" select="true()" />
                </xsl:call-template>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="first-row-ccs">
                <xsl:for-each select="$rows/foIn:table-row[1]/foIn:table-cell">
                    <xsl:call-template name="to-table-cc">
                        <xsl:with-param name="cell" select="." />
                        <xsl:with-param name="for-first-row" select="false()" />
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:variable>
            <xsl:call-template name="get-row-covered-cells-cont">
                <xsl:with-param name="for-row-number" select="$for-row-number" />
                <xsl:with-param name="current-row-number" select="2" />
                <xsl:with-param name="previous-row-ccs" select="exsl:node-set($first-row-ccs)" />
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="get-row-covered-cells-cont">
    <xsl:param name="for-row-number" />
    <xsl:param name="current-row-number" />
    <xsl:param name="previous-row-ccs" />
    
    <xsl:variable name="row" select="../foIn:table-row[$current-row-number]" />
    
    <xsl:choose>
        <xsl:when test="$current-row-number >= $for-row-number">
            <!-- Finished -->
            <xsl:copy-of select="$previous-row-ccs" />
        </xsl:when>
        <xsl:otherwise>
            <!-- Obtain current row cc-s -->
            <xsl:variable name="ccs">
                <!-- Go through the previous row cc-s and output new cc where @rows = 1, otherwise output the cc with @rows decreased by 1. -->
                <xsl:for-each select="$previous-row-ccs/*">
                    <xsl:variable name="cc" select="." />
                    <xsl:choose>
                        <xsl:when test="@rows = 1">
                            <xsl:variable name="cell" select="$row/foIn:table-cell[count($cc/preceding-sibling::*[@rows = 1]) + 1]" />
                            <xsl:if test="$cell"><!-- all cells were not processed yet... -->
                                <xsl:call-template name="to-table-cc">
                                    <xsl:with-param name="cell" select="$cell" />
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <cc rows="{@rows - 1}" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <!-- Go to the next row -->
            <xsl:call-template name="get-row-covered-cells-cont">
                <xsl:with-param name="for-row-number" select="$for-row-number" />
                <xsl:with-param name="current-row-number" select="$current-row-number + 1" />
                <xsl:with-param name="previous-row-ccs" select="exsl:node-set($ccs)" />
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="to-table-cc">
    <xsl:param name="cell"  />
    <xsl:param name="for-first-row" select="false()" />
    <xsl:variable name="rows">
        <xsl:choose>
            <xsl:when test="$for-first-row">1</xsl:when>
            <xsl:otherwise><xsl:value-of select="$cell/@number-rows-spanned" /></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <cc rows="{$rows}" />
    <xsl:if test="not($for-first-row)">
        <xsl:call-template name="output-table-cc-colspan">
            <xsl:with-param name="times" select="$cell/@number-columns-spanned - 1" />
            <xsl:with-param name="rows" select="$rows" />
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- Outputs helping <cc> specified number times. -->
<xsl:template name="output-table-cc-colspan">
    <xsl:param name="times" /><!-- number -->
    <xsl:param name="rows" /><!-- number -->
    <xsl:if test="$times > 0">
        <cc rows="{$rows}" colspan="yes" />
        <xsl:call-template name="output-table-cc-colspan">
            <xsl:with-param name="times" select="$times - 1" />
            <xsl:with-param name="rows" select="$rows" />
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- Converts <fo:table-cell> to <table:table-cell>. It outputs (@number-columns-spanned - 1) <table:table-covered-cell>-s
right after as well.

Border and padding properties of the parent table are "inherited" by appropriate cells here because ODF supports specifying
these properties only on the table-cell level. TODO This should be done for table-body/table-header/table-footer and table-row
parent elements as well. TODO It won't always work well in the case of row spanning. -->
<xsl:template match="foIn:table-cell" mode="phase1">
    <xsl:variable name="fo-elem" select="." />
    <xsl:variable name="style-name" select="my:get-unique-style-name(., 'table-cell')" />
    <xsl:variable name="parent-table" select="ancestor::foIn:table[1]" />
    <style:style style:family="table-cell" style:name="{$style-name}">
        <style:table-cell-properties>
            <xsl:if test="not($fo-elem/preceding-sibling::foIn:table-cell)"><!-- cell in the last column -->
                <xsl:apply-templates select="$parent-table/@*[starts-with(local-name(.), 'border-left-') or local-name(.) = 'padding-left']" mode="styles" />
            </xsl:if>
            <xsl:if test="not($fo-elem/following-sibling::foIn:table-cell)"><!-- cell in the last column -->
                <xsl:apply-templates select="$parent-table/@*[starts-with(local-name(.), 'border-right-') or local-name(.) = 'padding-right']" mode="styles" />
            </xsl:if>
            <xsl:if test="not($fo-elem/parent::foIn:table-row[preceding-sibling::foIn:table-row or parent::*/preceding-sibling::*/foIn:table-row])"><!-- cell in the first row -->
                <xsl:apply-templates select="$parent-table/@*[starts-with(local-name(.), 'border-top-') or local-name(.) = 'padding-top']" mode="styles" />
            </xsl:if>
            <xsl:if test="not($fo-elem/parent::foIn:table-row[following-sibling::foIn:table-row or parent::*/following-sibling::*/foIn:table-row])"><!-- cell in the last row -->
                <xsl:apply-templates select="$parent-table/@*[starts-with(local-name(.), 'border-bottom-') or local-name(.) = 'padding-bottom']" mode="styles" />
            </xsl:if>
            <xsl:apply-templates select="$fo-elem/@*[my:is-table-cell-property(.)]" mode="styles" />
        </style:table-cell-properties>
        <style:paragraph-properties>
            <xsl:apply-templates select="$fo-elem/@*[not(my:is-table-cell-property(.)) and my:is-paragraph-property(.)]" mode="styles" />
        </style:paragraph-properties>
        <style:text-properties>
            <xsl:apply-templates select="$fo-elem/@*[not(my:is-table-cell-property(.)) and my:is-text-property(.)]" mode="styles" />
        </style:text-properties>
    </style:style>
    <table:table-cell table:style-name="{$style-name}">
        <xsl:if test="@number-columns-spanned > 1">
            <xsl:attribute name="table:number-columns-spanned"><xsl:value-of select="@number-columns-spanned" /></xsl:attribute>
        </xsl:if>
        <xsl:if test="@number-rows-spanned > 1">
            <xsl:attribute name="table:number-rows-spanned"><xsl:value-of select="@number-rows-spanned" /></xsl:attribute>
        </xsl:if>
        <xsl:call-template name="process-fo-id" />
        <xsl:apply-templates mode="phase1" />
    </table:table-cell>
    <xsl:call-template name="output-odf-covered-table-cell">
        <xsl:with-param name="times" select="@number-columns-spanned - 1" />
    </xsl:call-template>
</xsl:template>

<!-- Outputs ODF's <table:covered-table-cell> specified number times. -->
<xsl:template name="output-odf-covered-table-cell">
    <xsl:param name="times" select="'1'" /><!-- number -->
    <xsl:if test="$times > 0">
        <table:covered-table-cell />
        <xsl:call-template name="output-odf-covered-table-cell">
            <xsl:with-param name="times" select="$times - 1" />
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template match="foIn:table-column" mode="phase1">
    <xsl:call-template name="output-odf-table-column" />
</xsl:template>

<xsl:template name="output-odf-table-column">
    <xsl:variable name="fo-elem" select="." />
    <xsl:variable name="style-name" select="my:get-unique-style-name(., 'table-column')" />
    <style:style style:family="table-column" style:name="{$style-name}">
        <style:table-column-properties style:use-optimal-column-width="false"><!-- TODO What with this attribute? -->
            <xsl:apply-templates select="$fo-elem/@*" mode="styles" />
        </style:table-column-properties>
    </style:style>
    <table:table-column table:style-name="{$style-name}">
        <xsl:apply-templates select="@number-columns-repeated" mode="phase1" />
    </table:table-column>
</xsl:template>

<xsl:template match="@number-columns-repeated" mode="phase1">
    <xsl:if test=". > 1">
        <xsl:attribute name="table:number-columns-repeated">
            <xsl:value-of select="." />
        </xsl:attribute>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>