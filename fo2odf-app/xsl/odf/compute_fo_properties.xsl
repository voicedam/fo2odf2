<?xml version="1.0"?>

<!--
Templates for obtaining "computed values" of FO properties from their "specified values".
General unit to which all "computed values" for "length" properties are converted is 'pt' (point). 

"Specified values" are values of properties in the source FO document.
These values can be specified as various mathematical expressions
or relative values. "Computed values" are absolute values of properties which
are computed from the "specified values" by evaluating the expressions, relative values, inheritance and so on.

The "computed values" can be used in the phase of transforming the source FO document
into the result document in a given output format. So in the transforming phase we don't already
have to care about computing the values but we focus clearly just on the transformation.

Usage:

<xsl:call-template name="compute-fo-properties">
    <xsl:with-param name="nodes" select="<xpath_in_source_FO_document>" />
</xsl:call-template>

The selected nodes are processed by templates in the mode named "compute-fo-properties".

TODO Properties with default values should be output as well. F.e. when "border-left-style" is
specified, "border-left-width" should be automatically set to default value if this attribute
is missing -> mode="compute-additional-fo-properties" serves this purpose in fact...
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:str="http://exslt.org/strings"
    xmlns:dyn="http://exslt.org/dynamic"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
	xmlns:foIn="http://www.w3.org/1999/XSL/Format"
    xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions"
	exclude-result-prefixes="my log xfc"
    extension-element-prefixes="exsl func str dyn">

<xsl:import href="../common/strings.xsl" />
<xsl:import href="../common/xslt_logging.xsl" />

<xsl:import href="fo2odf_params.xsl" />
<xsl:import href="fo_info_functions.xsl" />

<!-- ===== Relative to absolute properties ===== -->

<!--
In this mode relative properties are converted to absolute properties. 'lr-tb' writing
mode is expected.

Moreover for simplicity attributes ending with ".optimum" are converted to attributes with
the same value but without the ending part. If such an attribute already exists, then it is
omitted (".optimum" is more precise, it has precedence).

Moveover2 for simplicity "keep-*" attributes are preprocessed - see the corresponding
template(s).
-->
<xsl:template match="*" mode="relative-to-absolute-properties">
    <xsl:copy>
        <xsl:apply-templates select="@*" mode="relative-to-absolute-properties" />
        <xsl:apply-templates mode="relative-to-absolute-properties" />
    </xsl:copy>
</xsl:template>

<xsl:template match="@*" mode="relative-to-absolute-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:choose>
        <xsl:when test="../@*[local-name(.) = concat($prop-name, '.optimum')]"><!-- omit this attribute --></xsl:when>
        <xsl:otherwise>
            <xsl:variable name="adjusted-prop-name">
                <xsl:choose>
                    <xsl:when test="my:ends-with($prop-name, '.optimum')">
                        <xsl:value-of select="substring-before($prop-name, '.optimum')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$prop-name" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$adjusted-prop-name != $prop-name">
                <xsl:call-template name="log:log-trace"><xsl:with-param name="msg">Space property '<xsl:value-of select="$prop-name" />' -&gt; '<xsl:value-of select="$adjusted-prop-name" />'</xsl:with-param></xsl:call-template>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="my:is-relative-prop-name($adjusted-prop-name)">
                    <xsl:variable name="absolute-prop-name" select="my:get-absolute-prop-name-if-not-exists(., $adjusted-prop-name)" />
                    <xsl:if test="$absolute-prop-name != ''">
                        <xsl:call-template name="log:log-trace">
                            <xsl:with-param name="msg">Replacing relative property '<xsl:value-of select="$adjusted-prop-name" />' with absolute property '<xsl:value-of select="$absolute-prop-name" />'</xsl:with-param>
                        </xsl:call-template>
                        <xsl:attribute name="{$absolute-prop-name}">
                            <xsl:value-of select="." />
                        </xsl:attribute>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$prop-name = 'float'">
                    <xsl:attribute name="{$prop-name}">
                        <xsl:choose>
                            <xsl:when test=". = 'start'">left</xsl:when>
                            <xsl:when test=". = 'end'">right</xsl:when>
                            <xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="{$adjusted-prop-name}">
                        <xsl:value-of select="." />
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Attributes "keep-with-next.within-page" and "keep-with-next.within-column"
are converted to attribute "keep-with-next" with the same value (precedence is undefined if both are specified).
The same is done for attributes starting with "keep-with-previous" and "keep-together".
This is done because ODF doesn't make any difference between page and column keeps.-->
<xsl:template match="@keep-with-next.within-column | @keep-with-previous.within-column | @keep-together.within-column" mode="relative-to-absolute-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:attribute name="{substring-before($prop-name, '.within-column')}">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>
<xsl:template match="@keep-with-next.within-page | @keep-with-previous.within-page | @keep-together.within-page" mode="relative-to-absolute-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:attribute name="{substring-before($prop-name, '.within-page')}">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<!-- Omit the attrribute if a component attribute is specified on the element as well... -->
<xsl:template match="@keep-with-next| @keep-with-previous | @keep-together.within-page" mode="relative-to-absolute-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:if test="not(../@*[local-name() = concat($prop-name, '.within-page') or local-name() = concat($prop-name, '.within-column')])">
        <xsl:copy-of select="." />
    </xsl:if>
</xsl:template>

<!-- ===== /Relative to absolute properties ===== -->

<!-- ===== "Main" templates ===== -->

<!-- Computes FO properties on the given nodes. -->
<xsl:template name="compute-fo-properties">
    <xsl:param name="nodes" select="." /><!-- node set -->
    
    <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Converting relative properties to absolute properties (plus some additional preprocessing)...</xsl:with-param></xsl:call-template>
    <xsl:variable name="nodes-with-only-absolute-properties">
        <xsl:apply-templates select="$nodes" mode="relative-to-absolute-properties" />
    </xsl:variable>
    
    <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Computing FO properties...</xsl:with-param></xsl:call-template> 
    <xsl:apply-templates select="exsl:node-set($nodes-with-only-absolute-properties)" mode="compute-fo-properties" />
</xsl:template>

<!-- Makes a copy of an element. Copies all attributes inherited from any ancestor wrapper to the copied element. -->
<xsl:template match="*" mode="compute-fo-properties">
    <xsl:copy>
        <!-- Copy wrapper(s) attributes first, then the element's attributes - these will overwrite attributes with the same name from wrapper. -->
        <xsl:apply-templates select="ancestor::foIn:wrapper/attribute::*" mode="compute-fo-properties" />
        <xsl:if test="my:is-block-element(.)">
            <xsl:apply-templates select="ancestor::*[local-name(.) = 'block' or local-name(.) = 'block-container']/attribute::*[my:is-reference-fo-property(local-name(.))]" mode="compute-fo-properties" />
        </xsl:if>
        <xsl:apply-templates select="@*" mode="compute-fo-properties" />
        <xsl:apply-templates select="." mode="compute-additional-fo-properties" />
        <xsl:apply-templates mode="compute-fo-properties" />
    </xsl:copy>
</xsl:template>

<func:function name="my:is-reference-fo-property">
    <xsl:param name="name" select="local-name(.)" />
    <func:result select="$name = $global-reference-fo-properties" />
</func:function>
<xsl:variable name="global-reference-fo-properties" select="str:tokenize('margin-left,margin-right,start-indent,end-indent', ',')" />

<!-- This default template makes the copy of the atrribute but replaces the original "specified value" by calculated "computed value".
But if the specified value ends with '%', then no computation is done. -->
<xsl:template match="@*" mode="compute-fo-properties">
    <xsl:attribute name="{concat('', local-name(.))}"><!-- Don't add any namespace - didn't work well with Xalan in further processing... - attributes weren't matched as expected -->
        <xsl:choose>
            <xsl:when test="my:ends-with(normalize-space(.), '%')">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="my:compute-fo-property(.)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<!-- Omits the fo:wrapper element, only its children are processed. The properties specified on the wrapper
are retained by copying them to child elements. -->
<xsl:template match="foIn:wrapper" mode="compute-fo-properties">
    <xsl:apply-templates mode="compute-fo-properties" />
</xsl:template>

<!-- Note: A comment inside a wrapper's text would cause creation of an unnecessary "fo:inline"... This can be easily
avoided by using multi-phase processing (f.e. by using "exsl:node-set()") when in the first phase all comments are omitted. -->
<!-- If a text has a fo:wrapper as its parent, then embed this text in an fo:inline element with attributes copied from the wrapper and
possible ancestor wrappers. Otherwise simply copy the text. -->
<xsl:template match="text()" mode="compute-fo-properties">
    <xsl:choose>
        <xsl:when test="parent::foIn:wrapper">
            <foIn:inline>
                <xsl:apply-templates select="ancestor::foIn:wrapper/attribute::*" mode="compute-fo-properties" />
                <xsl:value-of select="." />
            </foIn:inline>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="." />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ===== /"Main" templates ===== -->

<!-- ===== Templates for computing particular FO properties ===== -->

<!-- Don't do anything with these properties. -->
<xsl:template match="@id | @internal-destination | @external-destination" mode="compute-fo-properties">
    <xsl:copy-of select="." />
</xsl:template>

<!-- Computes the value of the "width" properties. If the value ends with '%', it is simply copied without further computations. -->
<xsl:template match="@width | @column-width" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:choose>
            <xsl:when test="my:ends-with(normalize-space(.), '%')">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<xsl:template match="@height | @provisional-label-separation | @provisional-distance-between-starts | @page-width | @page-height" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@extent" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:choose>
            <xsl:when test="my:ends-with(normalize-space(.), '%')">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<xsl:template match="@width[parent::foIn:external-graphic] | @height[parent::foIn:external-graphic]" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:variable name="norm-spec" select="normalize-space(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:choose>
            <xsl:when test="my:ends-with($norm-spec, '%') or $norm-spec = 'auto'">
                <xsl:value-of select="$norm-spec" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<xsl:template match="@content-width | @content-height" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:variable name="norm-spec" select="normalize-space(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:choose>
            <xsl:when test="my:ends-with($norm-spec, '%') or $norm-spec = 'scale-to-fit' or $norm-spec = 'auto'">
                <xsl:value-of select="$norm-spec" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<xsl:template match="@number-columns-repeated | @number-columns-spanned | @number-rows-spanned" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:variable name="value" select="my:compute-fo-property(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:choose>
            <xsl:when test="$value &lt; 1">1</xsl:when>
            <xsl:otherwise><xsl:value-of select="round($value)" /></xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<!-- Computes the value of the "font-size" property. -->
<xsl:template match="@font-size" mode="compute-fo-properties">
    <xsl:variable name="font-size" select="normalize-space(.)" />
    <xsl:variable name="computed-size">
        <xsl:choose>
            <xsl:when test="$font-size = $global-font-size-names">
                <xsl:value-of select="my:compute-fo-length-property(dyn:evaluate(concat('$named-font-size-', $font-size)))" />
            </xsl:when>
            <xsl:when test="$font-size = 'larger'">
                <xsl:value-of select="my:compute-fo-length-property('120%')" />
            </xsl:when>
            <xsl:when test="$font-size = 'smaller'">
                <xsl:value-of select="my:compute-fo-length-property('83.3%')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="my:compute-fo-length-property(.)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="font-size">
        <xsl:value-of select="concat($computed-size, 'pt')" />
    </xsl:attribute>
</xsl:template>
<xsl:variable name="global-font-size-names" select="str:tokenize('xx-small,x-small,small,medium,large,x-large,xx-large', ',')" />

<!-- Computes value of the "letter-spacing" property. -->
<xsl:template match="@letter-spacing" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:choose>
            <xsl:when test="normalize-space(.) = 'normal'">normal</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<!-- Computes value of the "line-height" property. -->
<!-- TODO If a number is specified, this number and not the calculated value should be inherited. -->
<xsl:template match="@line-height" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:variable name="norm-spec" select="normalize-space(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:choose>
            <xsl:when test="$norm-spec = 'normal'">normal</xsl:when>
            <xsl:when test="string(number($norm-spec)) != 'NaN'">
                <xsl:value-of select="concat(my:compute-fo-length-property(concat($norm-spec * 100, '%')), 'pt')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(my:compute-fo-length-property($norm-spec), 'pt')" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<!-- Computes the value of the "border-[top | right | bottom | left]-width" property. -->
<xsl:template match="@border-top-width | @border-right-width | @border-bottom-width | @border-left-width" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:variable name="border-position" select="substring-before(substring-after($prop-name, 'border-'), '-width')" />
        <xsl:variable name="border-style-prop-name" select="concat('border-', $border-position, '-style')" />
        <xsl:variable name="border-style-prop-value" select="normalize-space(../@*[local-name(.) = $border-style-prop-name])" />
        <xsl:choose>
            <xsl:when test="$border-style-prop-value = 'none' or $border-style-prop-value = 'hidden'">0pt</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="border-width" select="normalize-space(.)" />
                <xsl:choose>
                    <xsl:when test="$border-width = $global-border-width-names">
                        <xsl:value-of select="dyn:evaluate(concat('$named-border-width-', $border-width))" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>
<xsl:variable name="global-border-width-names" select="str:tokenize('thin,medium,thick', ',')" />

<!-- If a corresponding border width property does not exist and border style is not set to 'none' or 'hidden', then the border width
property is output with the default value. The matched attribute is processed as well. -->
<xsl:template match="@border-top-style | @border-right-style | @border-bottom-style | @border-left-style | 
        @border-top-color | @border-right-color | @border-bottom-color | @border-left-color" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:variable name="border-position" select="substring-before(substring-after($prop-name, 'border-'), '-')" />
    <xsl:variable name="border-style-prop-name" select="concat('border-', $border-position, '-style')" />
    <xsl:variable name="border-width-prop-name" select="concat('border-', $border-position, '-width')" />
    <xsl:if test="not(../@*[local-name(.) = $border-width-prop-name]) and (../@*[local-name(.) = $border-style-prop-name and . != 'none' and . != 'hidden'])">
        <xsl:attribute name="{$border-width-prop-name}">
            <xsl:value-of select="$named-border-width-medium" />
        </xsl:attribute>
    </xsl:if>
    <xsl:attribute name="{$prop-name}">
        <xsl:value-of select="my:compute-fo-property(.)" />
    </xsl:attribute>
</xsl:template>

<!-- Computes value of the "padding properties". It doesn't handle conditionality. -->
<xsl:template match="@padding-top | @padding-right | @padding-bottom | @padding-left" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
    </xsl:attribute>
</xsl:template>

<!-- Computes value of the "margin properties". It doesn't handle conditionality.
Relative properties are simply transformed to absolute properties. Calculation of left and right margins is done
with respect to reference area ("fo:container-block" or "fo:block" element) margins (differs from XSL specif.).

TODO Paddings and borders should be considered in the calculations of margins. -->
<xsl:template match="@margin-top | @margin-right | @margin-bottom | @margin-left" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:variable name="reference-area-computed-attribute">
        <xsl:if test="my:ends-with($prop-name, '-left') or my:ends-with($prop-name, '-right')">
            <xsl:variable name="block-container" select="../ancestor::*[local-name(.) = 'block' or local-name(.) = 'block-container']
                    [@*[local-name(.) = $prop-name]][1]" />
            <xsl:for-each select="$block-container/@*[local-name(.) = $prop-name]">
                <xsl:value-of select="my:compute-fo-length-property(.)" />
            </xsl:for-each>
        </xsl:if>
    </xsl:variable>  
    <xsl:attribute name="{$prop-name}">
        <xsl:choose>
            <xsl:when test="$reference-area-computed-attribute != ''">
                <xsl:value-of select="concat(my:compute-fo-length-property(.) + $reference-area-computed-attribute, 'pt')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<xsl:template match="@text-align-last" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:variable name="value" select="my:compute-fo-property(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:choose>
            <xsl:when test="$value = 'relative'">
                <xsl:variable name="text-align">
                    <xsl:variable name="text-align-attrib" select="../ancestor-or-self::*[@text-align][1]/@text-align[1]" />
                    <xsl:choose>
                        <xsl:when test="$text-align-attrib">
                            <xsl:for-each select="$text-align-attrib">
                                <xsl:value-of select="my:compute-fo-property(.)" />
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$default-text-align" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$text-align = 'justify'">start</xsl:when>
                    <xsl:otherwise><xsl:value-of select="$text-align" /></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:template>

<!-- Note: Percentages not supported. -->
<xsl:template match="@text-indent" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
    </xsl:attribute>
</xsl:template>

<!-- Extension attribute defined by XMLMind's XFC. TODO Test the 'xfc' namespace of the attribute. -->
<xsl:template match="@tab-position" mode="compute-fo-properties">
    <xsl:variable name="prop-name" select="local-name(.)" />
    <xsl:attribute name="{$prop-name}">
        <xsl:value-of select="concat(my:compute-fo-length-property(.), 'pt')" />
    </xsl:attribute>
</xsl:template>

<!-- ===== /Templates for particular FO properties ===== -->

<!-- ===== mode="compute-additional-fo-properties" ===== -->

<xsl:template match="node()" mode="compute-additional-fo-properties" />

<xsl:template match="foIn:simple-page-master" mode="compute-additional-fo-properties">
    <xsl:if test="not(@page-width)">
        <xsl:attribute name="page-width">
            <xsl:value-of select="concat(my:compute-fo-length-property($default-page-width), 'pt')" />
        </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@page-height)">
        <xsl:attribute name="page-height">
            <xsl:value-of select="concat(my:compute-fo-length-property($default-page-height), 'pt')" />
        </xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="foIn:*" mode="compute-additional-fo-properties">
    <!-- 'keep-with-previous' is not available in ODF, so the simplest thing we can do is to 
    put 'keep-with-next' on this element if the following sibling contains 'keep-with-previous': -->
    <xsl:if test="not(@keep-with-next) and following-sibling::*[1]/@keep-with-previous">
        <xsl:attribute name="keep-with-next"><xsl:value-of select="following-sibling::*[1]/@keep-with-previous" /></xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="foIn:block" mode="compute-additional-fo-properties">
    <xsl:if test="not(@orphans)">
        <xsl:attribute name="orphans"><xsl:value-of select="$default-orphans" /></xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@widows)">
        <xsl:attribute name="widows"><xsl:value-of select="$default-widows" /></xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="foIn:float" mode="compute-additional-fo-properties">
    <xsl:if test="not(@float)">
        <xsl:attribute name="float"><xsl:value-of select="$default-float" /></xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="foIn:table" mode="compute-additional-fo-properties">
    <xsl:if test="not(@border-collapse)">
        <xsl:attribute name="border-collapse"><xsl:value-of select="$default-border-collapse" /></xsl:attribute>
    </xsl:if>
</xsl:template>

<!-- It computes some of cell's attributes if they are not present. -->
<xsl:template match="foIn:table-cell" mode="compute-additional-fo-properties">
    <xsl:if test="not(@column-number)">
        <xsl:attribute name="column-number">
            <xsl:value-of select="my:get-table-cell-column-number(.)" />
        </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@number-columns-spanned)">
        <xsl:attribute name="number-columns-spanned">1</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@number-rows-spanned)">
        <xsl:attribute name="number-rows-spanned">1</xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="foIn:table-column" mode="compute-additional-fo-properties">
    <xsl:if test="not(@number-columns-repeated)">
        <xsl:attribute name="number-columns-repeated">1</xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="foIn:list-block" mode="compute-additional-fo-properties">
    <xsl:if test="not(@provisional-distance-between-starts)">
        <xsl:attribute name="provisional-distance-between-starts"><xsl:value-of select="$default-provisional-distance-between-starts" /></xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@provisional-label-separation)">
        <xsl:attribute name="provisional-label-separation"><xsl:value-of select="$default-provisional-label-separation" /></xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="foIn:leader" mode="compute-additional-fo-properties">
    <xsl:if test="not(@leader-pattern)">
        <xsl:attribute name="leader-pattern"><xsl:value-of select="$default-leader-pattern" /></xsl:attribute>
    </xsl:if>
</xsl:template>

<!-- Returns 'column-number' of a given cell. This function expects that the cell is contained in a 'table-row' element. -->
<func:function name="my:get-table-cell-column-number">
    <xsl:param name="cell" select="." /><!-- element -->
    <xsl:choose>
        <xsl:when test="$cell/@column-number"><func:result select="$cell/@column-number" /></xsl:when>
        <xsl:when test="not($cell/preceding-sibling::foIn:table-cell)"><func:result select="'1'" /></xsl:when>
        <xsl:otherwise>
            <xsl:variable name="preceding-cell" select="$cell/preceding-sibling::foIn:table-cell[1]" />
            <xsl:variable name="cols-spanned">
                <xsl:choose>
                    <xsl:when test="$preceding-cell/@number-columns-spanned"><xsl:value-of select="$preceding-cell/@number-columns-spanned" /></xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <func:result select="my:get-table-cell-column-number($preceding-cell) + $cols-spanned" /> 
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<xsl:template match="foIn:external-graphic" mode="compute-additional-fo-properties">
    <xsl:if test="not(@width)">
        <xsl:attribute name="width">auto</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@content-width)">
        <xsl:attribute name="content-width">auto</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@height)">
        <xsl:attribute name="height">auto</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@content-height)">
        <xsl:attribute name="content-height">auto</xsl:attribute>
    </xsl:if>
</xsl:template>

<!-- ===== /mode="compute-additional-fo-properties" ===== -->

<!-- ===== "Supporting" templates and functions -->

<!-- Computes value of a property from its specified value.
Actual context node must be the attribute which specifies the property otherwise the
function will not work properly in many cases, f.e. when relative values are specified.
normalize-space() is applied on the specified value. -->
<func:function name="my:compute-fo-property">
    <xsl:param name="spec" select="." /><!-- string -->
    <xsl:param name="prop-name" select="/.." /><!-- (optional) string - if you don't know type of property which will be computed -->
    <xsl:choose>
        <xsl:when test="$prop-name and my:is-fo-length-property($prop-name)">
            <func:result select="my:compute-fo-length-property($spec)" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="n-spec" select="normalize-space($spec)" />
            <xsl:variable name="evaluation-xpath" select="my:prepare-fo-property-evaluation-xpath($spec, false())" />
            <xsl:choose>
                <xsl:when test="$n-spec = $evaluation-xpath">
                    <func:result select="$n-spec" /><!-- no evaluation needed -->
                </xsl:when>
                <xsl:otherwise>
                    <func:result select="dyn:evaluate($evaluation-xpath)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Does the same as the 'my:compute-fo-property' function but in addition it expects that
a length property is specified. If result of evaluation ends with '%', then no suffix is appended. -->
<func:function name="my:compute-fo-length-property">
    <xsl:param name="spec" select="." /><!-- string -->
    <xsl:variable name="n-spec" select="normalize-space($spec)" />
    <xsl:variable name="units-length" select="my:get-units-length($n-spec)" />
    <xsl:choose>
        <xsl:when test="$units-length > 0">
            <!-- Compute a simple length, f.e. '10pt' or '0.5em' -->
            <xsl:variable name="before-units" select="substring($n-spec, 1, string-length($n-spec) - $units-length)" />
            <xsl:variable name="units" select="substring($n-spec, string-length($n-spec) - $units-length + 1)" />
            <func:result select="my:to-points($before-units, $units)" />
        </xsl:when>
        <xsl:otherwise>
            <!-- Compute a length which can contain operators and/or functions -->
            <xsl:variable name="evaluation-xpath" select="my:prepare-fo-property-evaluation-xpath($spec)" />
            <xsl:choose>
                <xsl:when test="$n-spec = $evaluation-xpath">
                    <func:result select="$n-spec" /><!-- no evaluation needed -->
                </xsl:when>
                <xsl:otherwise>
                    <func:result select="dyn:evaluate($evaluation-xpath)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<func:function name="my:get-units-length">
    <xsl:param name="spec" select="." /><!-- string -->
    <xsl:variable name="units-length">
        <xsl:choose>
            <xsl:when test="substring($spec, string-length($spec) - 1) = $global-fo-unit-names[string-length(.) = 2]">2</xsl:when>
            <xsl:when test="substring($spec, string-length($spec)) = $global-fo-unit-names[string-length(.) = 1]">1</xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="($units-length > 0) and (string(number(substring($spec, 1, string-length($spec) - $units-length))) != 'NaN')">
            <func:result select="$units-length" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="'0'" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Prepares XPath expression for computing absolute value of a property from its specified value.
Numeric values with known units are converted to call to "to-points(<number>, <unit>)" function and
FO "properties" functions are converted to call to "fo-function-<fo_function>('[<param>]')" functions.
The rest of the specified value (f.e. mathematical operators or brackets) is returned unchanged
as it should be compatible with XPath. normalize-space() is applied on the specified value. -->
<func:function name="my:prepare-fo-property-evaluation-xpath">
    <xsl:param name="spec" select="." /><!-- string -->
    <xsl:param name="is-length-property" select="true()" /><!-- boolean -->
    <xsl:variable name="norm-spec" select="normalize-space($spec)" />
    <xsl:choose>
        <xsl:when test="$norm-spec = 'inherit'">
            <!-- 'inherit' FO keyword is treated the same way as the 'from-parent()' FO function. -->
            <func:result select="my:prepare-fo-property-evaluation-xpath('from-parent()')" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="step1">
                <xsl:choose>
                    <xsl:when test="$is-length-property"><xsl:value-of select="my:replace-units-with-functions($norm-spec, $global-fo-unit-names)" /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$norm-spec" /></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="step2" select="my:replace-functions($step1, 'my:fo-function-', $global-fo-function-names)" />
            <func:result select="$step2" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>
<xsl:variable name="global-fo-unit-names" select="str:tokenize('pt,cm,mm,in,pc,px,%,em', ',')" />
<xsl:variable name="global-fo-function-names" select="str:tokenize('inherited-property-value,label-end,body-start,from-parent,from-nearest-specified-value,from-table-column,proportional-column-width,merge-property-values,system-font', ',')" />

<!-- Replaces occurences of <function>(<param>) by "<prefix><function>('<param>')". This is done for each function from the passed node set.
@see my:replace-function()
-->
<func:function name="my:replace-functions">
    <xsl:param name="in" /><!-- a string -->
    <xsl:param name="prefix" /><!-- a string -->
    <xsl:param name="functions" /><!-- a node set -->
    <xsl:choose>
        <xsl:when test="$functions[1]">
            <xsl:variable name="first-function-replaced" select="my:replace-function($in, $prefix, $functions[1])" />
            <func:result select="my:replace-functions($first-function-replaced, $prefix, $functions[position() > 1])" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="$in" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Replaces occurences of <function>(<param>) by "<prefix><function>('<param>')" (more function parameters taken as one).
Examples:
my:replace-function('2 * from-parent()', 'my:fo-function-', 'from-parent') returns "2 * my:fo-function-from-parent('')"
my:replace-function('from-parent(color)', 'my:fo-function-', 'from-parent') returns "my:fo-function-from-parent('color')"
-->
<func:function name="my:replace-function">
    <xsl:param name="in" /><!-- a string -->
    <xsl:param name="prefix" /><!-- a string -->
    <xsl:param name="function" /><!-- a string -->
    <xsl:variable name="index-of-function" select="my:index-of($in, $function)" />
    <xsl:variable name="after-function-name" select="substring($in, $index-of-function + string-length($function))" />
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:choose>
        <xsl:when test="$index-of-function &gt; 0 and starts-with(normalize-space($after-function-name), '(')">
            <!-- ...function string is present and is followed by '(' -> this is probably a function -->
            <xsl:variable name="index-of-ending-bracket" select="my:index-of($after-function-name, ')')" />
            <xsl:choose>
                <xsl:when test="$index-of-ending-bracket &gt; 0">
                    <!-- ...and function's end bracket is present - make the replacement -->
                    <xsl:variable name="function-param" select="substring-before(substring-after($after-function-name, '('), ')')" /> 
                    <xsl:variable name="before-function-name" select="substring($in, 1, $index-of-function - 1)" />
                    <xsl:variable name="replaced" select="concat($before-function-name, $prefix, $function, '(', $apos, $function-param, $apos, ')')" />
                    <func:result select="concat($replaced, my:replace-function(substring($after-function-name, $index-of-ending-bracket + 1), $prefix, $function))" />
                </xsl:when>
                <xsl:otherwise>
                    <!-- ...and function's bracket is not present - this is probably an error but continue parsing... -->
                    <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Probably ending bracket is missing for FO function '<xsl:value-of select="$function" />' in: <xsl:value-of select="$in" /></xsl:with-param></xsl:call-template></xsl:variable>
                    <func:result select="concat(substring($in, $index-of-function + string-length($function)), my:replace-function($after-function-name, $prefix, $function))" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="$index-of-function &gt; 0">
            <!-- ...function string found but not followed by '(' -> continue searching for function -->
            <func:result select="concat(substring($in, $index-of-function + string-length($function)), my:replace-function($after-function-name, $prefix, $function))" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="$in" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Replaces occurences of <number><unit> by "my:to-points(<number>, '<unit>')". This is done for each unit from the passed node set.
Examples:
my:replace-units-with-functions('10.5cm + 1in', <node-set>('cm', 'in')) returns "my:to-points(10.5, 'cm') + my:to-points(1, 'in')"
-->
<func:function name="my:replace-units-with-functions">
    <xsl:param name="in" /><!-- a string -->
    <xsl:param name="units" /><!-- a node set -->
    <xsl:choose>
        <xsl:when test="$units[1]">
            <xsl:variable name="first-unit-replaced" select="my:replace-unit-with-function($in, $units[1])" />
            <func:result select="my:replace-units-with-functions($first-unit-replaced, $units[position() > 1])" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="$in" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Replaces occurences of <number><unit> by "my:to-points(<number>, '<unit>')".
Examples:
my:replace-unit-with-function('10.5cm + 1cm', 'cm') returns "my:to-points(10.5, 'cm') + my:to-points(1, 'cm')"
my:replace-unit-with-function('some-in-function() + 1in', 'in') returns "some-in-function() + my:to-points(1, 'in')"
-->
<func:function name="my:replace-unit-with-function">
    <xsl:param name="in" /><!-- string -->
    <xsl:param name="unit" /><!-- string -->
    <xsl:variable name="index-of-unit" select="my:index-of($in, $unit)" />
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:choose>
        <xsl:when test="$index-of-unit &gt; 0">
            <!-- ...unit string is present -->
            <xsl:variable name="index-of-cont" select="$index-of-unit + string-length($unit)" />
            <xsl:variable name="index-of-number" select="my:get-number-index-from-right($in, $index-of-unit - 1)" />
            <xsl:choose>
                <xsl:when test="$index-of-number &gt; 0">
                    <!-- ...number is present before the unit - make the replacement -->
                    <xsl:variable name="number" select="substring($in, $index-of-number, $index-of-unit - $index-of-number)" />
                    <xsl:variable name="replaced" select="concat(substring($in, 1, $index-of-number - 1), 'my:to-points(', $number, ', ', $apos, $unit, $apos, ')')" />
                    <func:result select="concat($replaced, my:replace-unit-with-function(substring($in, $index-of-cont), $unit))" />
                </xsl:when>
                <xsl:otherwise>
                    <!-- ...number is not present before the unit - continue replacing in the rest of the string -->
                    <func:result select="concat(substring($in, 1, $index-of-cont - 1), my:replace-unit-with-function(substring($in, $index-of-cont), $unit))" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <func:result select="$in" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Returns starting position of a number which is searched from right to left from a given position.
Examples:
my:get-number-index-from-right('1 + 5.8cm', 7) returns 5
my:get-number-index-from-right('1 + 5.8cm', 8) returns -1 (not found)
-->
<func:function name="my:get-number-index-from-right">
    <xsl:param name="in" /><!-- string -->
    <xsl:param name="from" /><!-- number -->
    <xsl:choose>
        <xsl:when test="$from &lt; 1">
            <!-- recursion end or illegal parameter -->
            <func:result select="-1" />
        </xsl:when>
        <xsl:when test="my:is-numeric-char(my:char-at($in, $from))">
            <!-- A number char is present at the current position -->
            <xsl:variable name="previousNumberIndex" select="my:get-number-index-from-right($in, $from - 1)" />
            <xsl:choose>
                <xsl:when test="$previousNumberIndex = -1">
                    <!-- The current position is the beginning of the number - return this position -->
                    <func:result select="$from" />
                </xsl:when>
                <xsl:otherwise>
                    <!-- Beginning of the number is somewhere at previous position -->
                    <func:result select="$previousNumberIndex" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <!-- A number char is not present at the current position -->
            <func:result select="-1" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Returns absolute length in points ('pt') for a given length.
Examples:
- my:to-points(1, 'pt') returns 1
- my:to-points(2, 'in') returns 144
- my:to-points(1.2, 'em') returns 12 provided that font size of the current element is '10pt'
- my:to-points(120, '%') returns 12 provided that it is counted for a 'font-size' attribute AND font size of the parent element is '10pt'

Implementation note:
This function can call the 'compute-fo-length-property()' function when relative unit is passed. This function can in turn
call the 'to-points()' function recursively.
-->
<func:function name="my:to-points">
    <xsl:param name="number" /><!-- string -->
    <xsl:param name="unit" /><!-- string -->
    <xsl:choose>
        <xsl:when test="$unit = $global-absolute-fo-units">
            <!-- ..."absolute" length -->
            <!-- from XSL specif.: in = 2.54cm, pt = 1/72in, pc = 12pt -->
            <xsl:variable name="ratio">
                <xsl:choose>
                    <xsl:when test="$unit = 'pt'">1</xsl:when>
                    <xsl:when test="$unit = 'cm'">28.3464567</xsl:when><!-- = 1 / 2.54 * 72 -->
                    <xsl:when test="$unit = 'mm'">2.83464567</xsl:when>
                    <xsl:when test="$unit = 'in'">72</xsl:when>
                    <xsl:when test="$unit = 'pc'">12</xsl:when>
                    <xsl:when test="$unit = 'px'"><xsl:value-of select="$pixels-to-points-ratio" /></xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes">FATAL: Ooops. This should never happen - error in stylesheet logic.</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <func:result select="$ratio * $number" />
        </xsl:when>
        <xsl:when test="$unit = '%' or $unit = 'em'">
            <!-- Convert $number to percentages. -->
            <!-- <xsl:message>Counting: <xsl:value-of select="concat($number, $unit)" /></xsl:message> -->
            <xsl:variable name="percentages">
                <xsl:choose>
                    <xsl:when test="$unit = '%'">
                        <xsl:choose>
                            <xsl:when test="local-name(.) = 'font-size' or local-name(.) = 'line-height'">
                                <xsl:value-of select="$number" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Percentages are supported only at 'font-size' and 'line-height' properties, not at the '<xsl:value-of select="local-name(.)" />' property.</xsl:with-param></xsl:call-template></xsl:variable>
                                <xsl:value-of select="$number" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise><!-- $unit = 'em' -->
                        <xsl:value-of select="$number * 100" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$percentages = ''">
                    <func:result select="$number div 100" /><!-- this will "work" provided that it is used to multiply some length -->
                </xsl:when>
                <xsl:otherwise>
                    <!-- Calculate the points as percentages of the current element or ancestor element font size. -->
                    <!-- TODO Computing referenced font size always again is a bit inefficient. But maybe it is simpler than "remembering"
                    the compute font size somehow accross all calculations. Or maybe compute font-size in a separate phase would be a better solution. -->
                    <xsl:variable name="referenced-axis">
                        <xsl:choose>
                            <xsl:when test="local-name(.) = 'font-size'">
                                <xsl:value-of select="'ancestor'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'ancestor-or-self'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="referenced-font-size">
                        <xsl:variable name="attrib" select="dyn:evaluate(concat('../', $referenced-axis, '::*[@font-size][1]/@font-size'))" />
                        <xsl:choose>
                            <xsl:when test="$attrib">
                                <xsl:for-each select="$attrib">
                                    <xsl:value-of select="my:compute-fo-length-property(.)" />
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise><xsl:value-of select="my:compute-fo-length-property($default-font-size)" /></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <func:result select="$referenced-font-size * $percentages div 100" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Unknown unit for length '<xsl:value-of select="concat($number, $unit)" />' - using 'pt'</xsl:with-param></xsl:call-template></xsl:variable>
            <!-- TODO This fallback is probably not the best solution... -->
            <func:result select="$number" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>
<xsl:variable name="global-absolute-fo-units" select="str:tokenize('pt,cm,mm,in,pc,px', ',')" />

<func:function name="my:fo-function-label-end">
    <xsl:param name="foo-param" select="''" />
    <!-- <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">label-end() FO function not supported / not implemented yet</xsl:with-param></xsl:call-template></xsl:variable>-->
    <func:result select="'0'" />
</func:function>

<func:function name="my:fo-function-body-start">
    <xsl:param name="foo-param" select="''" />
    <!-- <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">body-start() FO function not supported / not implemented yet</xsl:with-param></xsl:call-template></xsl:variable>-->
    <func:result select="'0'" />
</func:function>

<func:function name="my:fo-function-from-table-column">
    <xsl:param name="foo-param" select="''" />
    <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">from-table-column() FO function not supported / not implemented yet</xsl:with-param></xsl:call-template></xsl:variable>
    <func:result select="'0'" />
</func:function>

<func:function name="my:fo-function-merge-property-values">
    <xsl:param name="foo-param" select="''" />
    <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">merge-property-values() FO function not supported / not implemented yet</xsl:with-param></xsl:call-template></xsl:variable>
    <func:result select="'0'" />
</func:function>

<func:function name="my:fo-function-system-font">
    <xsl:param name="foo-param" select="''" />
    <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">system-font() FO function not supported / not implemented yet</xsl:with-param></xsl:call-template></xsl:variable>
    <func:result select="''" />
</func:function>

<!-- Implements the 'from-parent()' FO function.
TODO Shorthand properties are not supported. -->
<func:function name="my:fo-function-from-parent">
    <xsl:param name="a-prop-name" select="''" /><!-- string -->
    <xsl:variable name="prop-name">
        <xsl:choose>
            <xsl:when test="$a-prop-name = ''">
                <xsl:value-of select="local-name(.)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$a-prop-name" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="../../@*[local-name(.) = $prop-name]">
            <!-- use parent property value -->
            <xsl:for-each select="../../@*[local-name(.) = $prop-name][1]">
                <func:result select="my:compute-fo-property(., $prop-name)" />
             </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <!-- use default property value -->
            <xsl:if test="my:is-shorthand-fo-property($a-prop-name)">
                <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Shorthand properties are not supported with the 'from-parent()' function - using default value for
                    the '<xsl:value-of select="local-name(.)" />' property.</xsl:with-param></xsl:call-template></xsl:variable>
            </xsl:if>
            <xsl:variable name="default-value" select="dyn:evaluate(concat('$default-', local-name(.)))" />
            <func:result select="my:compute-fo-property($default-value, $prop-name)" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Implements the 'inherited-property-value()' FO function.
XSL specif.: "...It is an error if this property is not an inherited property..." - this check is implemented.
TODO Shorthand properties are not supported.
-->
<func:function name="my:fo-function-inherited-property-value">
    <xsl:param name="a-prop-name" select="''" /><!-- string -->
    <xsl:variable name="prop-name">
        <xsl:choose>
            <xsl:when test="$a-prop-name = ''">
                <xsl:value-of select="local-name(.)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$a-prop-name" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="my:is-inherited-fo-property($prop-name)">
            <func:result select="my:fo-function-from-nearest-specified-value($prop-name)" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">'inherited-property-value()' cannot be used for '<xsl:value-of select="$prop-name" />' property
            as this property is not defined as inherited.</xsl:with-param></xsl:call-template></xsl:variable>
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Implements the 'from-nearest-specified-value()' FO function.
TODO Shorthand properties are not supported. -->
<func:function name="my:fo-function-from-nearest-specified-value">
    <xsl:param name="a-prop-name" select="''" /><!-- string -->
    <xsl:variable name="prop-name">
        <xsl:choose>
            <xsl:when test="$a-prop-name = ''">
                <xsl:value-of select="local-name(.)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$a-prop-name" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="../ancestor::*/@*[local-name(.) = $prop-name]">
            <!-- use parent property value -->
            <func:result>
                <xsl:for-each select="../ancestor::*/@*[local-name(.) = $prop-name][1]">
                    <xsl:value-of select="my:compute-fo-property(., $prop-name)" />
                </xsl:for-each>
            </func:result>
        </xsl:when>
        <xsl:otherwise>
            <!-- use default property value -->
            <xsl:if test="my:is-shorthand-fo-property($a-prop-name)">
                <xsl:variable name="xalan"><xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Shorthand properties are not supported with the 'from-nearest-specified-value()' function - using default value for
                    the '<xsl:value-of select="local-name(.)" />' property.</xsl:with-param></xsl:call-template></xsl:variable>
            </xsl:if>
            <xsl:variable name="default-value" select="dyn:evaluate(concat('$default-', local-name(.)))" />
            <func:result select="my:compute-fo-property($default-value, $prop-name)" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Implements the 'proportional-column-width()' FO function. It returns percentages if table
width is specified as percentages or is not specified (considered 100%). That's why the result
cannot be used in an expression containing some other tokens... (TODO)
TODO Widths of other - non-proportional columns - is not considered in calculations. -->
<func:function name="my:fo-function-proportional-column-width">
    <xsl:param name="pc-width" /><!-- number -->
    <xsl:variable name="col" select="parent::foIn:table-column" />
    <xsl:choose>
        <xsl:when test="$col">
            <xsl:variable name="table" select="$col/parent::foIn:table" />
            
            <!-- Find out the parent table width -->
            <xsl:variable name="table-width">
                <xsl:variable name="table-width-attrib" select="$table/@table-width[1]" />
                <xsl:choose>
                    <xsl:when test="$table-width-attrib">
                        <xsl:for-each select="$table-width-attrib">
                            <xsl:value-of select="my:compute-fo-length-property(.)" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>100%</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- Find out sum of all proportional column widths -->
            <xsl:variable name="xalan1"><xsl:call-template name="log:log-trace"><xsl:with-param name="msg">Finding out sum of all proportional column widths...</xsl:with-param></xsl:call-template></xsl:variable>
            <xsl:variable name="pc-widths-sum" select="my:get-sum-of-proportional-column-widths($table)" />
            <xsl:variable name="xalan2"><xsl:call-template name="log:log-trace"><xsl:with-param name="msg">...sum = <xsl:value-of select="$pc-widths-sum" /></xsl:with-param></xsl:call-template></xsl:variable>
            
            <!-- Compute column width -->
            <xsl:choose>
                <xsl:when test="my:ends-with($table-width, '%') and $pc-widths-sum > 0">
                    <!-- Compute column width as percentages -->
                    <func:result select="concat(substring-before($table-width, '%') div $pc-widths-sum * $pc-width, '%')" />
                </xsl:when>
                <xsl:when test="$pc-widths-sum > 0">
                    <!-- Compute column width as points -->
                    <func:result select="concat($table-width div $pc-widths-sum * $pc-width, 'pt')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="xalan3"><xsl:call-template name="log:log-error"><xsl:with-param name="msg">Failed computing table width - result was: '<xsl:value-of select="$table-width" />'</xsl:with-param></xsl:call-template></xsl:variable>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="xalan4"><xsl:call-template name="log:log-error"><xsl:with-param name="msg">Property function 'proportional-column-width()' cannot be used within other property than 'table-column'.</xsl:with-param></xsl:call-template></xsl:variable>
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Returns absolute property name corresponding to a given relative or absolute property name.
If the given $rel-prop is a relative property and the corresponding absolute property already exists
on the same element, then empty string is returned. -->
<func:function name="my:get-absolute-prop-name-if-not-exists">
    <xsl:param name="rel-prop" select="." /><!-- attribute -->
    <xsl:param name="rel-prop-name" select="local-name(.)" /><!-- string -->
    <xsl:variable name="abs-prop-name" select="my:get-absolute-prop-name($rel-prop-name)" />
    <xsl:choose>
        <xsl:when test="($rel-prop-name != $abs-prop-name) and ../@*[local-name(.) = $abs-prop-name]">
            <func:result select="''" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="$abs-prop-name" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Returns the sum of all proportional column widths specified on columns of a given table. -->
<func:function name="my:get-sum-of-proportional-column-widths">
    <xsl:param name="table" /><!-- element -->
    <func:result>
        <xsl:call-template name="add-proportional-column-width-and-go-next">
            <xsl:with-param name="sum" select="'0'" />
            <xsl:with-param name="col" select="$table/foIn:table-column[@column-width][1]" />
        </xsl:call-template>
    </func:result>
</func:function>

<!--
Adds proportional column width (if present) to the $sum parameter and calls this template for next sibling column.
If no sibling column is already present, the new sum is returned.

Note: 'number-columns-repeated' attribute value is not considered in the calculation.
This will work as long as 'number-columns-repeated' is further processed and used in transformation...
-->
<xsl:template name="add-proportional-column-width-and-go-next">
    <xsl:param name="sum" select="'0'" /><!-- number -->
    <xsl:param name="col" /><!-- element -->
    <xsl:variable name="col-width-attrib" select="$col/@column-width" />
    <xsl:variable name="pc-width" select="normalize-space(substring-before(substring-after(substring-after($col-width-attrib, 'proportional-column-width'), '('), ')'))" />
    <xsl:variable name="new-sum">
        <xsl:choose>
            <xsl:when test="string(number($pc-width)) != 'NaN'">
                <xsl:call-template name="log:log-trace"><xsl:with-param name="msg">Adding proportional column width to sum of widths: <xsl:value-of select="$pc-width" /></xsl:with-param></xsl:call-template>
                <xsl:value-of select="$sum + $pc-width" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sum" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$col/following-sibling::foIn:table-column[@column-width]">
            <xsl:call-template name="add-proportional-column-width-and-go-next">
                <xsl:with-param name="sum" select="$new-sum" />
                <xsl:with-param name="col" select="$col/following-sibling::foIn:table-column[@column-width][1]" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$new-sum" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ===== /"Supporting" templates and functions -->

</xsl:stylesheet>