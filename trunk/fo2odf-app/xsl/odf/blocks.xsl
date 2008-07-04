<?xml version="1.0"?>

<!--
Templates for converting FO "block level" elements to corresponding ODF elements.

Templates for some elements output ODF's <text:bookmark> element which must be moved to the nearest following
<text:p> element in the following phase(s).

ODF's <style:style> elements are output in front of every corresponding element. These style elements must be
moved to <style:automatic-styles> elements in the following phase(s).
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
    extension-element-prefixes="exsl func"
	exclude-result-prefixes="exsl func my log xfc"
    xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format"
    xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions">

<xsl:include href="blocks-tables.xsl" />

<!-- Removes any helping attribute (which came from the "preprocess-fo-for-odf" mode/phase). -->
<xsl:template match="@*[starts-with(local-name(.), 'temp-')]" mode="styles" />

<!-- Simply apply templates on children of the block container. -->
<xsl:template match="foIn:block-container" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:apply-templates mode="phase1" />
</xsl:template>

<!-- Simply apply templates on children of block which contains other blocks - the block itself won't generate any paragraphs.
Note: All coherent inline contents of the block were surrounded by block-s in the "preprocess-fo-for-odf" mode/phase. -->
<xsl:template match="foIn:block[*[my:is-block-element(.)]]" mode="phase1">
    <xsl:call-template name="process-fo-id" />
    <xsl:apply-templates mode="phase1" />
</xsl:template>

<!-- Generates <text:p> containing descendants of this block.

TODO Empty blocks should be omitted from the output somehow... -->
<xsl:template match="foIn:block[not(*[my:is-block-element(.)])]" mode="phase1">
    <xsl:variable name="style-name" select="my:get-unique-style-name(., 'block')" />
    
    <!-- Generate ODF style element. -->
    <style:style style:family="paragraph" style:name="{$style-name}">
        <style:paragraph-properties>
            <xsl:apply-templates select="./@*[my:is-paragraph-property(.)]" mode="styles" />
            <xsl:call-template name="process-fo-top-and-bottom-properties-from-parent" />
            <xsl:call-template name="process-fo-leader" />
        </style:paragraph-properties>
        <style:text-properties>
            <xsl:apply-templates select="./@*[my:is-text-property(.)]" mode="styles" />
        </style:text-properties>
    </style:style>
    
    <!-- Generate ODF text:p element. -->
    <text:p text:style-name="{$style-name}">
        <xsl:call-template name="process-fo-id" />
        <xsl:apply-templates mode="phase1" />
    </text:p>
</xsl:template>

<!-- Converts <fo:float> to ODF's <draw:frame>. It must be moved to the nearest following paragraph in the
following phase(s). TODO The implementation is still quite imprecise. -->
<xsl:template match="foIn:float" mode="phase1">
    <xsl:choose>
        <xsl:when test="@float = 'none' or @float = 'before'">
            <!-- No floating required ('none') or not possible ('before') - simply apply templates on children -->
            <xsl:apply-templates mode="phase1" />
        </xsl:when>
        <xsl:otherwise>
            <!-- Some floating is required... -->
            <xsl:variable name="style-name" select="my:get-unique-style-name(., 'frame')" />
            
            <!-- Generate ODF style element. -->
            <!-- Note: Without the @style:parent-style-name="Frame" attribute the frame wouldn't be displayed well in OO Writer
            - this is a little mystery... - maybe because the default parent style defines some width or height property... -->
            <style:style style:family="graphic" style:name="{$style-name}" style:parent-style-name="Frame">
                <xsl:variable name="float-opposite">
                    <xsl:choose>
                        <xsl:when test="@float = 'left'">right</xsl:when>
                        <xsl:when test="@float = 'right'">left</xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Value of "float" attribute not supported: '<xsl:value-of select="@float" />'</xsl:with-param></xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <style:graphic-properties style:wrap="{$float-opposite}"
                    style:number-wrapped-paragraphs="no-limit" style:vertical-pos="top"
                    style:vertical-rel="paragraph" style:horizontal-pos="{@float}"
                    style:horizontal-rel="paragraph" fo:border="none" fo:padding="0pt"
                    fo:margin-left="0pt" fo:margin-right="0pt" fo:margin-top="0pt" fo:margin-bottom="0pt">
                </style:graphic-properties>
            </style:style>
            
            <!-- Generate ODF draw:frame element. -->
            <!-- Note: @text:anchor-type at <style:graphic-properties> specifies only the *default* anchor type for new frames -->
            <draw:frame draw:style-name="{$style-name}" text:anchor-type="paragraph" fo:min-width="0cm" fo:min-height="0cm">
                <draw:text-box>
                    <!-- Apply templates on children... -->
                    <xsl:apply-templates mode="phase1" />
                </draw:text-box>
            </draw:frame>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- A "shorthand" template. -->
<xsl:template name="process-fo-top-and-bottom-properties-from-parent">
    <xsl:call-template name="process-fo-top-properties-from-parent" />
    <xsl:call-template name="process-fo-bottom-properties-from-parent" />
</xsl:template>

<!-- If the current element is the first element embeded in another block, then copy "top" properties from the parent.
This is done recursively for the parent.

TODO Properties from nested elements shouldn't be simply overwritten by properties from parent elements in every case. -->
<xsl:template name="process-fo-top-properties-from-parent">
    <xsl:if test="self::*[@temp-is-first = 'yes']">
        <xsl:apply-templates select="parent::*/@*[my:is-top-property(.) and not(local-name(.) = 'break-before' and . = 'auto')]" mode="styles" />
        <xsl:for-each select="parent::*">
            <xsl:call-template name="process-fo-top-properties-from-parent" />
        </xsl:for-each>
    </xsl:if>
</xsl:template>

<!-- Does the same as "process-fo-top-properties-from-parent", only for "bottom" properties. The same TODO applies. -->
<xsl:template name="process-fo-bottom-properties-from-parent">
    <xsl:if test="self::*[@temp-is-last = 'yes']">
        <xsl:apply-templates select="parent::*/@*[my:is-bottom-property(.) and not(local-name(.) = 'break-after' and . = 'auto')]" mode="styles" />
        <xsl:for-each select="parent::*">
            <xsl:call-template name="process-fo-bottom-properties-from-parent" />
        </xsl:for-each>
    </xsl:if>
</xsl:template>

<!-- If a <fo:leader> element is found in the current block, then a corresponding <style:tab-stops> element is generated. -->
<!-- TODO Implementation is not exact yet. -->
<xsl:template name="process-fo-leader">
    <xsl:variable name="parent-block" select="." />
    <xsl:variable name="leader" select="descendant::foIn:leader[1]" />
    <xsl:if test="$leader">
        <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">&lt;fo:leader&gt; found for the current paragraph - transforming it to &lt;style-tab-stops&gt;</xsl:with-param></xsl:call-template>
        <xsl:variable name="tab-type">
            <xsl:choose>
                <xsl:when test="$parent-block/@text-align-last = 'justify'">right</xsl:when>
                <xsl:otherwise>left</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="leader-text">
            <xsl:choose>
                <xsl:when test="$leader/@leader-pattern = 'use-content'"><xsl:value-of select="$leader" /></xsl:when>
                <xsl:when test="$leader/@leader-pattern = 'space'"><xsl:text> </xsl:text></xsl:when>
                <xsl:otherwise />
            </xsl:choose>
        </xsl:variable>
        <style:tab-stops>
            <xsl:variable name="tab-position">
                <xsl:choose>
                    <xsl:when test="$leader/@tab-position"><!-- Support the XFC's tab-position extension attribute -->
                        <!-- TODO How to test the namespace of the attribute as well? "$leader/@xfc:tab-position" doesn't work. -->
                        <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Extension attribute 'tab-position' found and processed; computed value = '<xsl:value-of select="$leader/@tab-position" />'</xsl:with-param></xsl:call-template>
                        <xsl:variable name="x-tab-position" select="my:get-number-length($leader/@tab-position)" />
                        <xsl:choose>
                            <xsl:when test="$x-tab-position >= 0"><!-- relative to left margin -->
                                <xsl:value-of select="$x-tab-position" />
                            </xsl:when>
                            <xsl:otherwise><!-- relative to right margin -->
                                <xsl:value-of select="my:get-page-body-width($parent-block) - my:get-number-length($parent-block/@margin-left) + $x-tab-position" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise><!-- Output some default tab position -->
                        <xsl:variable name="right-margin">
                            <xsl:choose>
                                <xsl:when test="$tab-type = 'left'">
                                    <xsl:value-of select="$default-right-margin-of-left-tab" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$default-right-margin-of-right-tab" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="my:get-page-body-width($parent-block) - my:get-number-length($parent-block/@margin-left) - $right-margin" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <style:tab-stop style:position="{concat($tab-position, 'pt')}" style:type="{$tab-type}" style:leader-type="single"
                    style:leader-style="dotted">
                <xsl:if test="$leader-text != ''">
                    <xsl:attribute name="style:leader-text"><xsl:value-of select="$leader-text" /></xsl:attribute>
                </xsl:if>
            </style:tab-stop>
        </style:tab-stops>
    </xsl:if>
</xsl:template>

<!-- Returns whether given attribute is a "bottom" property, i. e. whether it is f. e. "margin-bottom" or "border-bottom-style". -->
<func:function name="my:is-bottom-property">
    <xsl:param name="prop" select="." /><!-- attribute -->
    <xsl:variable name="name" select="local-name($prop)" />
    <func:result select="contains($name, '-bottom') or $name = 'break-after' or $name = 'keep-with-next'" />
</func:function>

<!-- Returns whether given attribute is a "top" property, i. e. whether it is f. e. "margin-top" or "border-top-style". -->
<func:function name="my:is-top-property">
    <xsl:param name="prop" select="." /><!-- attribute -->
    <xsl:variable name="name" select="local-name($prop)" />
    <func:result select="contains($name, '-top') or $name = 'break-before'" />
</func:function>

</xsl:stylesheet>