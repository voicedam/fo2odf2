<?xml version="1.0"?>

<!-- Templates for converting FO attributes to ODF attributes or elements. FO attributes are already expanded,
computed and further preprocessed in the preceding phase(s), so the conversion here can be usually quite
straightforward. -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:func="http://exslt.org/functions"
    xmlns:dyn="http://exslt.org/dynamic"
    xmlns:str="http://exslt.org/strings"
    xmlns:str2="http://exslt.org/strings2"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
    extension-element-prefixes="func dyn str"
	exclude-result-prefixes="func str str2 dyn my log"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format">

<xsl:import href="../common/strings.xsl" />
<xsl:import href="../common/colors.xsl" />
<xsl:import href="../common/xslt_logging.xsl" />
<xsl:import href="fo2odf_params.xsl" />

<!-- Colors related variables -->
<xsl:key name="color" match="colors/color" use="@name" />
<xsl:variable name="file.colors" select="document('colors.xml')" />

<!-- Attributes for which no transformation is needed. -->
<xsl:template match="@font-weight | @font-variant | @text-transform" mode="styles">
    <xsl:attribute name="{concat('fo:', local-name(.))}">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@font-size" mode="styles">
    <xsl:attribute name="fo:font-size">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<!--
Note: "font-family" property not fully implemented as there is no simple way to find out (from pure XSLT)
whether a given font is available on the given system. So the first font from fonts separated by commas is taken and copied.
-->
<xsl:template match="@font-family" mode="styles">
    <xsl:attribute name="fo:font-family">
        <xsl:choose>
            <xsl:when test="contains(., ',')"><xsl:value-of select="substring-before(., ',')" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<!--
XSL values: baseline | sub | super | <percentage> | <length> | inherit
ODF values: <percentage> | sub | super, optionally followed by <percentage> of current font-height
-->
<xsl:template match="@baseline-shift" mode="styles">
    <xsl:choose>
        <xsl:when test=". = 'baseline' or . = 'inherit'" />
        <xsl:otherwise>
            <xsl:attribute name="style:text-position">
                <xsl:choose>
                    <xsl:when test=". = 'sub' or . = 'super' or my:ends-with(., '%')">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise><!-- TODO Try to compute the percentages from the given length - actual font-height must be found out -->
                        <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">This style doesn't support "fo:baseline-shift" given as a length - zero shift applied</xsl:with-param></xsl:call-template>
                        <xsl:text>0% 100%</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Note: There is no counterpart for 'backslant' value in ODF - fallbacked to 'normal'. -->
<xsl:template match="@font-style" mode="styles">
    <xsl:attribute name="fo:font-style">
        <xsl:choose>
            <xsl:when test=". = 'backslant'">
                <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">There is no counterpart for 'backslant' value in ODF - fallbacked to 'normal'</xsl:with-param></xsl:call-template>
                <xsl:text>normal</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="." />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<xsl:template match="@padding-top | @padding-bottom | @padding-left | @padding-right" mode="styles">
    <xsl:attribute name="{concat('fo:', local-name(.))}">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@margin-top | @margin-bottom | @margin-left | @margin-right" mode="styles">
    <xsl:attribute name="{concat('fo:', local-name(.))}">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@width" mode="styles">
    <xsl:variable name="output-prop-name">
        <xsl:choose>
            <xsl:when test="my:ends-with(., '%')">style:rel-width</xsl:when>
            <xsl:otherwise>style:width</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="{$output-prop-name}">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@page-width | @page-height" mode="styles">
    <xsl:attribute name="{concat('fo:', local-name(.))}">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@extent" mode="styles">
    <xsl:attribute name="fo:min-height">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@border-collapse" mode="styles">
    <xsl:attribute name="table:border-model">
        <xsl:choose>
            <xsl:when test=". = 'collapse' or . = 'collapse-with-precedence'">collapsing</xsl:when>
            <xsl:otherwise>separating</xsl:otherwise>
        </xsl:choose>
        <xsl:if test=". = 'collapse-with-precedence'">
            <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Value 'collapse-with-precedence' of the 'border-collapse' property is not supported - using 'collapse' instead.</xsl:with-param></xsl:call-template>
        </xsl:if>
    </xsl:attribute>
</xsl:template>

<xsl:template match="@column-width | @width[parent::foIn:table-cell]" mode="styles">
    <xsl:choose>
        <xsl:when test="my:ends-with(., '%')">
            <xsl:attribute name="style:rel-column-width">
                <xsl:value-of select="translate(., '%', '*')" />
            </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="style:column-width">
                <xsl:value-of select="." />
            </xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- "height" attribute is supported only on table-row. 'auto' and percentage values are not supported. -->
<xsl:template match="@height[parent::foIn:table-row]" mode="styles">
    <xsl:attribute name="style:row-height">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@display-align" mode="styles">
    <xsl:attribute name="style:vertical-align">
        <xsl:choose>
            <xsl:when test=". = 'auto' or . = 'before'">top</xsl:when>
            <xsl:when test=". = 'after'">bottom</xsl:when>
            <xsl:when test=". = 'center'">middle</xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="log:log-error"><xsl:with-param name="msg">Wrong value of the 'display-align' attribute: '<xsl:value-of select="." />'</xsl:with-param></xsl:call-template>
                <xsl:value-of select="." />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<xsl:template match="@text-align" mode="styles">
    <xsl:attribute name="fo:text-align">
        <xsl:choose>
            <xsl:when test=". = 'start' or . = 'end' or . = 'left' or . = 'right' or . = 'center' or . = 'justify'">
                <xsl:value-of select="." />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">These values of 'text-align' property are not supported: 'inside', 'outside' and &lt;string&gt; - using 'start' instead (specified '<xsl:value-of select="." />').</xsl:with-param></xsl:call-template>
                <xsl:value-of select="'start'" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<xsl:template match="@text-align-last" mode="styles">
    <xsl:attribute name="fo:text-align-last">
        <xsl:choose>
            <xsl:when test=". = 'start' or . = 'center' or . = 'justify'">
                <xsl:value-of select="." />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Unsupported value of the 'text-align-last' property specified: '<xsl:value-of select="." />'.</xsl:with-param></xsl:call-template>
                <xsl:value-of select="." />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<!-- Note: Percentages not supported. -->
<xsl:template match="@text-indent" mode="styles">
    <xsl:attribute name="fo:text-indent">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<!-- ===== Keeps and breaks attributes ===== -->

<!-- Note: @keep-with-previous is already converted to @keep-with-next in previous phases. -->
<!-- Note: @keep-* components ".within-page" and ".with-column" are already "removed" in previous phases. -->

<xsl:template match="@keep-with-next | @keep-together" mode="styles">
    <xsl:choose>
        <xsl:when test=". = 'always' or . = 'auto'">
            <xsl:attribute name="{concat('fo:', local-name(.))}">
                <xsl:value-of select="." />
            </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Unsupported value of the '<xsl:value-of select="local-name(.)" />' property specified: '<xsl:value-of select="." />' - property ignored (only 'always' and 'auto' values are supported).</xsl:with-param></xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="@break-before | @break-after" mode="styles">
    <xsl:variable name="odf-value">
        <xsl:choose>
            <xsl:when test=". = 'auto' or . = 'column' or . = 'page'">
                <xsl:value-of select="." />
            </xsl:when>
            <xsl:when test=". = 'odd-page' or . = 'even-page'">
                <xsl:value-of select="'page'" />
                <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">'<xsl:value-of select="local-name(.)" />' property value '<xsl:value-of select="." />' not supported - using 'page' value instead.</xsl:with-param></xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Wrong value of the '<xsl:value-of select="local-name(.)" />' property specified: '<xsl:value-of select="." />' - property ignored.</xsl:with-param></xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:if test="$odf-value != ''">
        <xsl:attribute name="{concat('fo:', local-name(.))}">
            <xsl:value-of select="$odf-value" />
        </xsl:attribute>
    </xsl:if>
</xsl:template>

<!-- ===== /Keeps and breaks attributes ===== -->

<!-- @orphans and @widows attributes are defined the same way in ODF (except that it relates only to paragraphs) -->
<xsl:template match="@orphans | @widows" mode="styles">
    <xsl:attribute name="{concat('fo:', local-name(.))}">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<!-- @text-decoration: none | [ [ underline | no-underline] || [ overline | no-overline ] || [ line-through | no-line-through ] || [ blink | no-blink ] ] | inherit -->
<!--
specif.:
========
The color(s) required for the text decoration should be derived from the "color" property value.

This property is not inherited, but descendant boxes of a block box should be formatted with the same decoration (e.g., they should all be underlined). The color of decorations should remain the same even if descendant elements have different "color" values.

Notes:
======
There is no ODF counterpart to 'overline' value. It could be emulated by '<style:border-line-width-top>', but this is only applicable to paragraphs and wouldn't probably work well. Fallbacked to default value.
-->
<xsl:template match="@text-decoration" mode="styles">
    <xsl:variable name="value" select="normalize-space(.)" />
    <xsl:choose>
        <xsl:when test="$value = 'underline'">
            <xsl:attribute name="style:text-underline-type">single</xsl:attribute>
            <xsl:attribute name="style:text-underline-style">solid</xsl:attribute>
            <xsl:attribute name="style:text-underline-width">auto</xsl:attribute>
            <xsl:attribute name="style:text-underline-color">font-color</xsl:attribute>
            <xsl:attribute name="style:text-underline-mode">continuous</xsl:attribute>
        </xsl:when>
        <xsl:when test="$value = 'no-underline'">
            <xsl:attribute name="style:text-underline-type">none</xsl:attribute>
        </xsl:when>
        <xsl:when test="$value = 'line-through'">
            <xsl:attribute name="style:text-line-through-type">single</xsl:attribute>
            <xsl:attribute name="style:text-line-through-style">solid</xsl:attribute>
            <xsl:attribute name="style:text-line-through-width">auto</xsl:attribute>
            <xsl:attribute name="style:text-line-through-color">font-color</xsl:attribute>
            <xsl:attribute name="style:text-line-through-mode">continuous</xsl:attribute>
        </xsl:when>
        <xsl:when test="$value = 'no-line-through'">
            <xsl:attribute name="style:text-line-through-type">none</xsl:attribute>
        </xsl:when>
        <xsl:when test="$value = 'blink'">
            <xsl:attribute name="style:text-blinking">true</xsl:attribute>
        </xsl:when>
        <xsl:when test="$value = 'no-blink'">
            <xsl:attribute name="style:text-blinking">false</xsl:attribute>
        </xsl:when>
        <xsl:when test="$value = 'none'">
            <xsl:attribute name="style:text-underline-type">none</xsl:attribute>
            <xsl:attribute name="style:text-line-through-type">none</xsl:attribute>
            <xsl:attribute name="style:text-blinking">none</xsl:attribute>
        </xsl:when>
        <xsl:when test="$value = 'overline' or $value = 'no-overline'"><!-- fallback: overline not available so nothing is done here -->
            <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">'overline' and 'no-overline' values of the 'text-decoration' property are not supported - property ignored</xsl:with-param></xsl:call-template>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<xsl:template match="@letter-spacing" mode="styles">
    <xsl:attribute name="fo:letter-spacing">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<!--
FO: If the property is set on a block-level element whose content is composed of inline-level elements, it specifies the minimal height of each generated inline box.
ODF (fo:line-height): Use the fo:line-height property to specify a fixed line height either as a length or a percentage that relates to the highest character in a line. A special value of normal activates the default line height calculation. It is also used to deactivate the effects of the style:line-height-at-least and style:line-spacing properties. The value of this property can be a length, a percentage, or a value of normal. See §7.15.4 of [XSL] for details.
ODF (style:line-height-at-least): The value of this property is a length. There is no normal value for the property.
-->
<xsl:template match="@line-height" mode="styles">
    <xsl:variable name="value" select="normalize-space(.)" />
    <xsl:choose>
        <xsl:when test="$value = 'normal'">            
            <xsl:attribute name="fo:line-height">normal</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="style:line-height-at-least">
                <xsl:value-of select="." />
            </xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="@language | @country" mode="styles">
    <xsl:attribute name="{concat('fo:', local-name(.))}">
        <xsl:choose>
            <xsl:when test="normalize-space(.) = 'none'"></xsl:when>
            <xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<!-- Note: Only "hyphenation-character" property is not supported in ODF. -->
<xsl:template match="@hyphenate | @hyphenation-ladder-count" mode="styles">
    <xsl:attribute name="{concat('fo:', local-name(.))}">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@hyphenation-keep" mode="styles">
    <xsl:attribute name="{concat('fo:', local-name(.))}">
        <xsl:choose>
            <xsl:when test="normalize-space(.) = 'column'">page</xsl:when><!-- fallback -->
            <xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<xsl:template match="@hyphenation-push-character-count" mode="styles">
    <xsl:attribute name="fo:hyphenation-push-char-count">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@hyphenation-remain-character-count" mode="styles">
    <xsl:attribute name="fo:hyphenation-remain-char-count">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<!--
@color and @background-color - treated the same way.

FALLBACK:
Implemented except these XSL color functions: rgb-icc() (RGB fallback used) and system-color() (ignored)
-->
<xsl:template match="@color | @background-color" mode="styles">
    <xsl:attribute name="{concat('fo:', local-name(.))}">
        <xsl:call-template name="get-color-code">
            <xsl:with-param name="fo-color-code" select="."></xsl:with-param>
        </xsl:call-template>
    </xsl:attribute>
</xsl:template>

<!-- Converts FO border to ODF border. Undocumented ODF 1.0/1.1 property "style:join-border" must be set to "false"
in order to avoid joining borders of adjacent elements (paragraphs). -->
<xsl:template match="@border-left-width | @border-right-width | @border-top-width | @border-bottom-width" mode="styles">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:variable name="border-position" select="substring-before(substring-after($prop-name, 'border-'), '-width')" />
    <xsl:variable name="border-color-prop-name" select="concat('border-', $border-position, '-color')" />
    <xsl:variable name="border-color-attribute" select="../@*[local-name(.) = $border-color-prop-name]" />
    <xsl:variable name="border-color">
        <xsl:call-template name="get-color-code">
            <xsl:with-param name="fo-color-code">
                <xsl:choose>
                    <xsl:when test="$border-color-attribute">
                        <xsl:value-of select="$border-color-attribute" />
                    </xsl:when>
                    <xsl:when test="../@color">
                        <xsl:value-of select="../@color" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$default-color" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:variable>
    <xsl:attribute name="{concat('fo:', substring-before(local-name(.), '-width'))}">
        <xsl:value-of select="concat(., ' solid ', $border-color)" />
    </xsl:attribute>
    <xsl:attribute name="style:join-border">false</xsl:attribute>
</xsl:template>

<!-- Ignore attributes processed elsewhere and/or not applicable for "styles" mode. -->
<xsl:template match="@border-top-style | @border-right-style | @border-bottom-style | @border-left-style | 
        @border-top-color | @border-right-color | @border-bottom-color | @border-left-color |
        @number-columns-repeated | @number-columns-spanned | @number-rows-spanned | @table-layout | @column-number" mode="styles" />

<!-- Issue log warning if an unknown attribute is to be processed. -->
<xsl:template match="@*" mode="styles">
    <xsl:variable name="name" select="local-name(.)" />
    <xsl:if test="$warn-on-unknown-attribute = 'yes'">
        <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Ignoring unknown property attribute: <xsl:value-of select="concat(name(.), '=&quot;', ., '&quot;')" /></xsl:with-param></xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- Returns a hexadecimal form (#rrggbb) of a color code suitable for ODF's color attributes. -->
<xsl:template name="get-color-code">
    <xsl:param name="fo-color-code" /><!-- the parameter is expected to be already normalized (f.e. by normalize-space()) -->
    <xsl:choose>
        <xsl:when test="starts-with($fo-color-code, '#')">
            <xsl:choose>
                <xsl:when test="string-length($fo-color-code) = 4">
                    <!-- f.e. '#cef' = '#cceeff' -->
                    <xsl:value-of select="concat('#', substring($fo-color-code, 2, 1), substring($fo-color-code, 2, 1), substring($fo-color-code, 3, 1), substring($fo-color-code, 3, 1), substring($fo-color-code, 4, 1), substring($fo-color-code, 4, 1))" />
                </xsl:when>
                <xsl:otherwise>
                    <!-- f.e. '#cceeff' -->
                    <xsl:value-of select="$fo-color-code" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="starts-with($fo-color-code, 'rgb(')">
            <xsl:call-template name="rgb-color2hex-color">
                <xsl:with-param name="rgb-color" select="$fo-color-code" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="starts-with($fo-color-code, 'rgb-icc(')">
            <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Using RGB fallback for rgb-icc() function (color profiles not implemented)</xsl:with-param></xsl:call-template>
            <xsl:variable name="afterOpeningBracket" select="substring-after($fo-color-code, 'rgb-icc(')" />
            <xsl:variable name="rgbParts" select="str2:tokenize($afterOpeningBracket, ',')" />
            <xsl:variable name="rgbPartsConcat" select="concat($rgbParts[1], ',', $rgbParts[2], ',', $rgbParts[3])" />
            <xsl:variable name="fo-rgb-color-code" select="concat('rgb(', $rgbPartsConcat, ')')" />
            <xsl:call-template name="rgb-color2hex-color">
                <xsl:with-param name="rgb-color" select="$fo-rgb-color-code" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="starts-with($fo-color-code, 'system-color(')">
            <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">system-color() color function not implemented - property ignored</xsl:with-param></xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <!-- f.e. 'white' = '#ffffff' -->
            <xsl:for-each select="$file.colors">
                <xsl:variable name="color.code" select="key('color', $fo-color-code)/@code" />
                <xsl:choose>
                    <xsl:when test="not($color.code)">
                        <!-- color code for color name not found -->
                        <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Unknown color code: '<xsl:value-of select="$fo-color-code" />', using 'black' (#000000)</xsl:with-param></xsl:call-template>
                        <xsl:value-of select="'#000000'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$color.code" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>