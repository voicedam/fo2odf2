<?xml version="1.0"?>

<!--
Templates for expanding "shorthand" FO properties (further using just "shorthands") to individual (not-a-shorthand) properties.
"Expanding" means here that a shorthand property disappears from the result tree and new individual properties
"belonging" to this shorthand property are created instead. 

F.e. the 'border' property is expanded to 'border-width', 'border-style' and 'border-color'.
But as these properties are shorthands too, the processing continues by expanding 'border-width'
to 'border-left-width', 'border-right-width' and so on until only individual properties
are left. Properties to which shorthands are expanded are not
overwritten if they already exist.

Computation of "computed properties" from the "specified properties" usually follows
after shorthands were expanded.

In addition to expanding shorthand properties properties with empty value specified are omitted from
the result tree if empty value doesn't make sense.

This part from XSL specif. is implemented too:
<<<For the remaining ambiguous case, XSL defines the ordering to be
1. "border-style", "border-color", and "border-width" is less precise than
2. "border-top", "border-bottom", "border-right", and "border-left".>>>
This means that this template doesn't create expanded border property if more precise shorthand was specified.

Usage:

<xsl:call-template name="expand-fo-shorthands">
    <xsl:with-param name="nodes" select="<xpath_in_source_FO_document>" />
</xsl:call-template>

The selected nodes are processed by templates in the mode named "expand-fo-shorthands".
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
	exclude-result-prefixes="exsl func str dyn my log"
    extension-element-prefixes="exsl func str dyn">

<xsl:import href="../common/strings.xsl" />
<xsl:import href="../common/xslt_logging.xsl" />

<xsl:import href="fo2odf_params.xsl" />
<xsl:import href="fo_info_functions.xsl" />

<!-- ===== "Main" templates ===== -->

<!-- Expands FO properties on the given nodes. -->
<xsl:template name="expand-fo-shorthands">
    <xsl:param name="nodes" select="." /><!-- node set -->
    <xsl:apply-templates select="$nodes" mode="expand-fo-shorthands" />
</xsl:template>

<!-- Makes a copy of an element. Shorthand properties are expanded to individual properties. -->
<xsl:template match="*" mode="expand-fo-shorthands">
    <xsl:copy>
        <xsl:for-each select="@*">
            <xsl:choose>
                <xsl:when test="normalize-space(.) = '' and (local-name(.) != $global-fo-properties-with-acceptable-empty-value)">
                    <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Ignoring property atttribute '<xsl:value-of select="local-name(.)" />' which contains empty value.</xsl:with-param></xsl:call-template>
                </xsl:when>
                <xsl:when test="my:is-shorthand-fo-property(local-name(.))">
                    <xsl:call-template name="expand-fo-shorthand">
                        <xsl:with-param name="name" select="local-name(.)" />
                        <xsl:with-param name="value" select="." />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="." />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:apply-templates mode="expand-fo-shorthands" />
    </xsl:copy>
</xsl:template>
<!-- Note: Maybe not complete yet:? -->
<xsl:variable name="global-fo-properties-with-acceptable-empty-value" select="str:tokenize('external-destination,internal-destination', ',')" />

<!-- ===== /"Main" templates ===== -->

<!-- ===== "Supporting" templates and functions -->

<!-- Expands a given FO border "mixed" shorthand property. Used for 'border', 'border-left' and similar. -->
<xsl:template name="expand-fo-border-mixed-shorthand">
    <xsl:param name="shorthand-name" /><!-- string -->
    <xsl:param name="shorthand-value" /><!-- string -->
    
    <xsl:variable name="processed-attribute" select="." /><!-- remember it for use in the following 'xsl:for-each' -->
    <xsl:variable name="parts" select="my:get-fo-shorthand-parts($shorthand-value)" />
    <xsl:variable name="inherit-specified" select="normalize-space($shorthand-value) = 'inherit'" />
    
    <xsl:variable name="new-properties">
        <xsl:choose>
            <xsl:when test="$inherit-specified">
                <width>inherit</width>
                <style>inherit</style>
                <color>inherit</color>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$parts">
                    <xsl:variable name="property-name">
                        <xsl:choose>
                            <xsl:when test="my:is-probably-border-width-property(.)">width</xsl:when>
                            <xsl:when test="my:is-probably-border-style-property(.)">style</xsl:when>
                            <xsl:otherwise>color</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="{$property-name}"><xsl:value-of select="." /></xsl:element>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:for-each select="exsl:node-set($new-properties)/*">
        <xsl:variable name="name" select="concat($shorthand-name, '-', local-name(.))" />
        <xsl:variable name="value" select="." />
        <!-- Important: Change context node back to the processed attribute. -->
        <xsl:for-each select="$processed-attribute">
            <xsl:call-template name="create-expanded-fo-property">
                <xsl:with-param name="name" select="$name" />
                <xsl:with-param name="value" select="$value" />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:for-each>
</xsl:template>

<!-- Expands a given FO "all-sides" shorthand property to given properties. Used f.e. for 'margin'. -->
<xsl:template name="expand-fo-all-sides-shorthand">
    <xsl:param name="shorthand-name" select="''" /><!-- string; specified only when necessary -->
    <xsl:param name="shorthand-value" /><!-- string -->
    <xsl:param name="property-prefix" select="''" /><!-- string -->
    <xsl:param name="property-suffix" select="''" /><!-- string -->
    
    <xsl:variable name="parts" select="my:get-fo-shorthand-parts($shorthand-value)" />
    
    <xsl:choose>
        <xsl:when test="count($parts) &lt;= 4">
            <xsl:call-template name="create-expanded-fo-property">
                <xsl:with-param name="name" select="concat($property-prefix, '-top', $property-suffix)" />
                <xsl:with-param name="value">
                    <xsl:value-of select="$parts[1]" />
                </xsl:with-param>
                <xsl:with-param name="shorthand-name" select="$shorthand-name" />
            </xsl:call-template>
            <xsl:call-template name="create-expanded-fo-property">
                <xsl:with-param name="name" select="concat($property-prefix, '-bottom', $property-suffix)" />
                <xsl:with-param name="value">
                    <xsl:choose>
                        <xsl:when test="count($parts) = 1 or count($parts) = 2">
                            <xsl:value-of select="$parts[1]" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$parts[3]" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="shorthand-name" select="$shorthand-name" />
            </xsl:call-template>
            <xsl:call-template name="create-expanded-fo-property">
                <xsl:with-param name="name" select="concat($property-prefix, '-left', $property-suffix)" />
                <xsl:with-param name="value">
                    <xsl:choose>
                        <xsl:when test="count($parts) = 2 or count($parts) = 3">
                            <xsl:value-of select="$parts[2]" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$parts[count($parts)]" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="shorthand-name" select="$shorthand-name" />
            </xsl:call-template>
            <xsl:call-template name="create-expanded-fo-property">
                <xsl:with-param name="name" select="concat($property-prefix, '-right', $property-suffix)" />
                <xsl:with-param name="value">
                    <xsl:choose>
                        <xsl:when test="count($parts) = 2 or count($parts) = 3">
                            <xsl:value-of select="$parts[2]" />
                        </xsl:when>
                        <xsl:when test="count($parts) = 1">
                            <xsl:value-of select="$parts[1]" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$parts[2]" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="shorthand-name" select="$shorthand-name" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="process-shorthand-not-parsed" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="create-expanded-fo-property">
    <xsl:param name="name" />
    <xsl:param name="value" />
    <xsl:param name="shorthand-name" select="''" />
    <xsl:if test="not(../@*[local-name(.) = $name])">
        <xsl:choose>
            <xsl:when test="my:is-shorthand-fo-property($name)">
                <!-- Call "expand-fo-shorthand" template recursively. -->
                <xsl:call-template name="expand-fo-shorthand">
                    <xsl:with-param name="name" select="$name" />
                    <xsl:with-param name="value" select="$value" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="processed-attribute-name" select="local-name(.)" />
                <xsl:variable name="processed-element" select=".." />
                <xsl:choose>
                    <!-- TODO This is quite ugly long condition... -->
                    <xsl:when test="$name = 'border-left-width' and $shorthand-name = 'border-width' and normalize-space($processed-element/@border-left) != ''
                            or
                            $name = 'border-right-width' and $shorthand-name = 'border-width' and normalize-space($processed-element/@border-right) != ''
                            or
                            $name = 'border-top-width' and $shorthand-name = 'border-width' and normalize-space($processed-element/@border-top) != ''
                            or
                            $name = 'border-bottom-width' and $shorthand-name = 'border-width' and normalize-space($processed-element/@border-bottom) != ''
                            or
                            $name = 'border-left-style' and $shorthand-name = 'border-style' and normalize-space($processed-element/@border-left) != ''
                            or
                            $name = 'border-right-style' and $shorthand-name = 'border-style' and normalize-space($processed-element/@border-right) != ''
                            or
                            $name = 'border-top-style' and $shorthand-name = 'border-style' and normalize-space($processed-element/@border-top) != ''
                            or
                            $name = 'border-bottom-style' and $shorthand-name = 'border-style' and normalize-space($processed-element/@border-bottom) != ''
                            or
                            $name = 'border-left-color' and $shorthand-name = 'border-color' and normalize-space($processed-element/@border-left) != ''
                            or
                            $name = 'border-right-color' and $shorthand-name = 'border-color' and normalize-space($processed-element/@border-right) != ''
                            or
                            $name = 'border-top-color' and $shorthand-name = 'border-color' and normalize-space($processed-element/@border-top) != ''
                            or
                            $name = 'border-bottom-color' and $shorthand-name = 'border-color' and normalize-space($processed-element/@border-bottom) != ''
                            ">
                        <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Ignoring one ore more sides of 'border-width' because more precise shorthand(s) was/were specified.</xsl:with-param></xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="log:log-trace"><xsl:with-param name="msg">Expanding shorthand property: <xsl:value-of select="$processed-attribute-name" />="<xsl:value-of select="." />" -> <xsl:value-of select="$name" />="<xsl:value-of select="$value" />"</xsl:with-param></xsl:call-template>
                        <xsl:attribute name="{$name}"><xsl:value-of select="$value" /></xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<xsl:template name="expand-fo-shorthand">
    <xsl:param name="name" />
    <xsl:param name="value" />
    <xsl:choose>
        <xsl:when test="$name = 'margin' or $name = 'padding'">
            <xsl:call-template name="expand-fo-all-sides-shorthand">
                <xsl:with-param name="shorthand-value" select="$value" />
                <xsl:with-param name="property-prefix" select="$name" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$name = 'border' or $name = 'border-left' or $name = 'border-right' or $name = 'border-top' or $name = 'border-bottom'">
            <xsl:call-template name="expand-fo-border-mixed-shorthand">
                <xsl:with-param name="shorthand-name" select="$name" />
                <xsl:with-param name="shorthand-value" select="$value" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$name = 'border-width'">
            <xsl:call-template name="expand-fo-all-sides-shorthand">
                <xsl:with-param name="shorthand-name" select="'border-width'" />
                <xsl:with-param name="shorthand-value" select="$value" />
                <xsl:with-param name="property-prefix" select="'border'" />
                <xsl:with-param name="property-suffix" select="'-width'" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$name = 'border-style'">
            <xsl:call-template name="expand-fo-all-sides-shorthand">
                <xsl:with-param name="shorthand-name" select="'border-style'" />
                <xsl:with-param name="shorthand-value" select="$value" />
                <xsl:with-param name="property-prefix" select="'border'" />
                <xsl:with-param name="property-suffix" select="'-style'" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$name = 'border-color'">
            <xsl:call-template name="expand-fo-all-sides-shorthand">
                <xsl:with-param name="shorthand-name" select="'border-color'" />
                <xsl:with-param name="shorthand-value" select="$value" />
                <xsl:with-param name="property-prefix" select="'border'" />
                <xsl:with-param name="property-suffix" select="'-color'" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$name = 'white-space'">
            <xsl:call-template name="expand-white-space-shorthand">
                <xsl:with-param name="value" select="normalize-space($value)" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$name = 'background'">
            <xsl:call-template name="expand-background-shorthand">
                <xsl:with-param name="value" select="normalize-space($value)" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$name = 'font'">
            <xsl:call-template name="expand-font-shorthand">
                <xsl:with-param name="value" select="normalize-space($value)" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Shorthand '<xsl:value-of select="$name" />' not supported.</xsl:with-param></xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!--
Expands the "white-space" shorthand property.
-->
<xsl:template name="expand-white-space-shorthand">
    <xsl:param name="value" />
    <xsl:variable name="this" select="." />
    <xsl:variable name="expanded-properties">
        <xsl:choose>
            <xsl:when test="$value = 'normal'">
                <exp-prop name="linefeed-treatment" value="treat-as-space" />
                <exp-prop name="white-space-collapse" value="true" />
                <exp-prop name="white-space-treatment" value="ignore-if-surrounding-linefeed" />
                <exp-prop name="wrap-option" value="wrap" />
            </xsl:when>
            <xsl:when test="$value = 'pre'">
                <exp-prop name="linefeed-treatment" value="preserve" />
                <exp-prop name="white-space-collapse" value="false" />
                <exp-prop name="white-space-treatment" value="preserve" />
                <exp-prop name="wrap-option" value="no-wrap" />
            </xsl:when>
            <xsl:when test="$value = 'nowrap'">
                <exp-prop name="linefeed-treatment" value="treat-as-space" />
                <exp-prop name="white-space-collapse" value="true" />
                <exp-prop name="white-space-treatment" value="ignore-if-surrounding-linefeed" />
                <exp-prop name="wrap-option" value="no-wrap" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Wrong value of the 'white-space' shorthand property: '<xsl:value-of select="$value" />'</xsl:with-param></xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="exsl:node-set($expanded-properties)/*">
        <xsl:variable name="exp-prop" select="." />
        <xsl:for-each select="$this">
            <xsl:call-template name="create-expanded-fo-property">
                <xsl:with-param name="name" select="$exp-prop/@name" />
                <xsl:with-param name="value" select="$exp-prop/@value" />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:for-each>
</xsl:template>

<!--
Expands the "background" shorthand property. Only "color" part is implemented.
-->
<xsl:template name="expand-background-shorthand">
    <xsl:param name="value" />
    <xsl:variable name="this" select="." />
    <xsl:variable name="parts" select="my:get-fo-shorthand-parts($value)" />
    <xsl:for-each select="$parts">
        <xsl:if test="my:is-probably-color-property(.)">
            <xsl:variable name="exp-value" select="." />
            <xsl:for-each select="$this">
                <xsl:call-template name="create-expanded-fo-property">
                    <xsl:with-param name="name" select="'background-color'" />
                    <xsl:with-param name="value" select="$exp-value" />
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<!--
Expands the "font" shorthand property.
XSL specifies these possible values: [ [ <font-style> || <font-variant> || <font-weight> ]? <font-size> [ / <line-height>]? <font-family> ] | caption | icon | menu | message-box | small-caption | status-bar | inherit
TODO Check order of the parts. F. e. font-family should be the last one. Moreover it can contain spaces - in this case the implementation fails now.
-->
<xsl:template name="expand-font-shorthand">
    <xsl:param name="value" />
    <xsl:variable name="this" select="." />
    <xsl:variable name="expanded-properties">
        <xsl:choose>
            <xsl:when test="my:is-system-font-name($value)">
                <xsl:variable name="font-properties">
                    <xsl:choose>
                        <xsl:when test="$value = 'caption'"><holder xsl:use-attribute-sets="system-font-caption-properties" /></xsl:when>
                        <xsl:when test="$value = 'icon'"><holder xsl:use-attribute-sets="system-font-icon-properties" /></xsl:when>
                        <xsl:when test="$value = 'menu'"><holder xsl:use-attribute-sets="system-font-menu-properties" /></xsl:when>
                        <xsl:when test="$value = 'message-box'"><holder xsl:use-attribute-sets="system-font-message-box-properties" /></xsl:when>
                        <xsl:when test="$value = 'small-caption'"><holder xsl:use-attribute-sets="system-font-small-caption-properties" /></xsl:when>
                        <xsl:when test="$value = 'status-bar'"><holder xsl:use-attribute-sets="system-font-status-bar-properties" /></xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:for-each select="exsl:node-set($font-properties)/*/@*">
                    <exp-prop name="{name(.)}" value="{.}" />
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="parts" select="my:get-fo-shorthand-parts($value)" />
                <xsl:for-each select="$parts">
                    <xsl:choose>
                        <xsl:when test="./preceding-sibling::* = '/'">
                            <exp-prop name="line-height" value="{.}" />
                        </xsl:when>
                        <xsl:when test="my:is-probably-font-weight-property(.)">
                            <exp-prop name="font-weight" value="{.}" />
                        </xsl:when>
                        <xsl:when test="my:is-probably-font-variant-property(.)">
                            <exp-prop name="font-variant" value="{.}" />
                        </xsl:when>
                        <xsl:when test="my:is-probably-font-style-property(.)">
                            <exp-prop name="font-style" value="{.}" />
                        </xsl:when>
                        <xsl:when test="my:is-probably-font-size-property(.)">
                            <exp-prop name="font-size" value="{.}" />
                        </xsl:when>
                        <xsl:otherwise><!-- probably font-family -->
                            <exp-prop name="font-family" value="{.}" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="exsl:node-set($expanded-properties)/*">
        <xsl:variable name="exp-prop" select="." />
        <xsl:for-each select="$this">
            <xsl:call-template name="create-expanded-fo-property">
                <xsl:with-param name="name" select="$exp-prop/@name" />
                <xsl:with-param name="value" select="$exp-prop/@value" />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:for-each>
</xsl:template>

<!-- Returns values of properties to which a shorthand value will be expanded. The shorthand value
is space-normalized before processing.
The function simply takes the shorthand value and splits it by space character(s) directly into the values.

Note: A more sofisticated splitting could be done as space can occur inside the shorthand's parts as well
because these parts can be any FO expression strings. But f.e. XEP and XFC both support only this
simple splitting (as tried out) so it's not so critical feature... -->
<func:function name="my:get-fo-shorthand-parts">
    <xsl:param name="shorthand-value" select="." /><!-- string -->
    <func:result select="str:tokenize(normalize-space($shorthand-value), ' ')" />
</func:function>

<xsl:template name="process-shorthand-not-parsed">
    <xsl:param name="shorthand" select="." /><!-- attribute -->
    <xsl:call-template name="log:log-warn"><xsl:with-param name="msg">Shorthand property '<xsl:value-of select="local-name($shorthand)" />' value '<xsl:value-of select="$shorthand" />'
        could not be parsed - ignoring this property.</xsl:with-param>
    </xsl:call-template>
</xsl:template>

<!-- ===== /"Supporting" templates and functions -->

</xsl:stylesheet>