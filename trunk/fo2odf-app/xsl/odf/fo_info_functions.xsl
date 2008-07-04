<?xml version="1.0"?>

<!--
Functions for obtaining information about XSL FO objects and properties.
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:str="http://exslt.org/strings"
    xmlns:str2="http://exslt.org/strings2"
    xmlns:dyn="http://exslt.org/dynamic"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
	xmlns:foIn="http://www.w3.org/1999/XSL/Format"
	exclude-result-prefixes="exsl func str dyn my log"
    extension-element-prefixes="exsl func str dyn">

<xsl:import href="../common/strings.xsl" />

<!-- Returns whether a given element is a FO "block level element". -->
<func:function name="my:is-block-element">
    <xsl:param name="n" select="." />
    <xsl:variable name="name" select="local-name($n)" />
    <func:result select="$name = $global-fo-block-elements" />
</func:function>
<!-- TODO Not complete list yet -->
<xsl:variable name="global-fo-block-elements" select="str:tokenize('block,block-container,table-and-caption,table,list-block', ',')" />

<!-- Returns absolute property name corresponding to a given relative property name.
It expects 'lt-tb' writing mode. -->
<func:function name="my:get-absolute-prop-name">
    <xsl:param name="rel-prop-name" /><!-- string -->
    <xsl:variable name="step1" select="str2:replace($rel-prop-name, $global-relative-property-parts, $global-absolute-property-parts)" />
    <func:result select="$step1" />
</func:function>
<xsl:variable name="global-relative-property-parts" select="str:tokenize('start-indent,end-indent,start,end,before,after,space', ',')" />
<xsl:variable name="global-absolute-property-parts" select="str:tokenize('margin-left,margin-right,left,right,top,bottom,margin', ',')" />

<!-- Returns relative property name corresponding to a given absolute property name.
It expects 'lt-tb' writing mode. -->
<func:function name="my:get-relative-prop-name">
    <xsl:param name="abs-prop-name" /><!-- string -->
    <xsl:variable name="step1" select="str2:replace($abs-prop-name, $global-absolute-property-parts, $global-relative-property-parts)" />
    <func:result select="$step1" />
</func:function>

<!-- Returns whether a given property is a relative property (relative to writing mode). -->
<func:function name="my:is-relative-prop-name">
    <xsl:param name="prop-name" /><!-- string -->
    <func:result select="$prop-name = $global-relative-fo-properties" />
</func:function>
<!-- add all relative properties to this variable: -->
<xsl:variable name="global-relative-fo-properties" select="str:tokenize('start-indent,end-indent,space-before,space-after,padding-start,padding-end,padding-before,padding-after,border-start-width,border-start-color,border-start-style,border-start-precedence,border-end-width,border-end-color,border-end-style,border-end-precedence,border-before-width,border-before-color,border-before-style,border-before-precedence,border-after-width,border-after-color,border-after-style,border-after-precedence', ',')" />

<!-- Returns whether a given attribute is a FO "inherited" property (according to XSL specif.). -->
<func:function name="my:is-inherited-fo-property">
    <xsl:param name="prop-name" select="." /><!-- string -->
    <func:result select="$prop-name = $global-inherited-fo-properties" />
</func:function>
<xsl:variable name="global-inherited-fo-properties" select="str:tokenize('font-size,reference-orientation,writing-mode,auto-restore,azimuth,border-collapse,border-separation,border-spacing,caption-side,color,country,direction,display-align,elevation,empty-cells,end-indent,font,font-family,font-selection-strategy,font-size-adjust,font-stretch,font-style,font-variant,font-weight,glyph-orientation-horizontal,glyph-orientation-vertical,hyphenate,hyphenation-character,hyphenation-keep,hyphenation-ladder-count,hyphenation-push-character-count,hyphenation-remain-character-count,intrusion-displace,keep-together,language,last-line-end-indent,leader-alignment,leader-length,leader-pattern,leader-pattern-width,letter-spacing,line-height,line-height-shift-adjustment,line-stacking-strategy,linefeed-treatment,orphans,page-break-inside,pitch,pitch-range,provisional-distance-between-starts,provisional-label-separation,relative-align,richness,rule-style,rule-thickness,score-spaces,script,speak,speak-header,speak-numeral,speak-punctuation,speech-rate,start-indent,stress,text-align,text-align-last,text-indent,text-transform,visibility,voice-family,volume,white-space,white-space-collapse,white-space-treatment,widows,word-spacing,wrap-option', ',')" />

<!-- Returns whether a given FO property is a shorthand property. -->
<func:function name="my:is-shorthand-fo-property">
    <xsl:param name="property-name" select="." /><!-- string -->
    <func:result select="$property-name = $global-shorthand-properties" />
</func:function>
<xsl:variable name="global-shorthand-properties" select="str:tokenize('background,background-position,border,border-bottom,border-color,border-left,border-right,border-spacing,border-style,border-top,border-width,cue,font,margin,max-height,max-width,min-height,min-width,padding,page-break-after,page-break-before,page-break-inside,pause,position,size,vertical-align,white-space', ',')" />

<!-- Returns whether a given attribute is a FO "length" property. TODO Implement... -->
<func:function name="my:is-fo-length-property">
    <xsl:param name="prop-name" select="." /><!-- string -->
    <!-- <func:result select="$prop-name = $global-fo-length-properties" />-->
    <func:result select="true()" />
</func:function>
<!-- TODO Fill the list... -->
<xsl:variable name="global-fo-length-properties" select="str:tokenize('font-size,...', ',')" />

<!--
Returns content width for a given node in a FO document.
TODO This function returns the result of "my:get-page-body-width($node) - my:get-number-length($node/@margin-left)" now.
-->
<func:function name="my:get-content-width">
    <xsl:param name="node" select="." />
    <func:result select="my:get-page-body-width($node) - my:get-number-length($node/@margin-left)" />
</func:function>

<!-- Returns page body width for a given node in a FO document. -->
<func:function name="my:get-page-body-width">
    <xsl:param name="node" select="." />
    <xsl:variable name="simple-page-master" select="my:get-simple-page-master($node)" />
    <xsl:variable name="region-body" select="$simple-page-master/foIn:region-body[1]" />
    <!-- ODF ignores a padding if corresponding border width is zero: -->
    <xsl:variable name="padding-left">
        <xsl:choose>
            <xsl:when test="my:get-number-length($region-body/@border-left-width) > 0"><xsl:value-of select="$region-body/@padding-left" /></xsl:when>
            <xsl:otherwise>0pt</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="padding-right">
        <xsl:choose>
            <xsl:when test="my:get-number-length($region-body/@border-right-width) > 0"><xsl:value-of select="$region-body/@padding-right" /></xsl:when>
            <xsl:otherwise>0pt</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <func:result select="my:get-number-length($simple-page-master/@page-width) - my:get-number-length($simple-page-master/@margin-left)
            - my:get-number-length($simple-page-master/@margin-right)
            - my:get-number-length($padding-left) - my:get-number-length($padding-right)
            - my:get-number-length($region-body/@border-left-width) - my:get-number-length($region-body/@border-right-width)" /> 
</func:function>

<!-- Returns <fo:simple-page-master> element which is effective for a given node in a <fo:page-sequence>. -->
<func:function name="my:get-simple-page-master">
    <xsl:param name="node" select="." />
    
    <xsl:variable name="page-sequence" select="$node/ancestor-or-self::foIn:page-sequence[1]" />
    <xsl:if test="not($page-sequence)">
    	<xsl:variable name="xalan"><xsl:call-template name="log:log-error"><xsl:with-param name="msg">&lt;fo:page-sequence&gt; could not be found for a node in FO document</xsl:with-param></xsl:call-template></xsl:variable>
    </xsl:if>
    
    <xsl:variable name="simple-page-master-name">
        <xsl:choose>
            <xsl:when test="/foIn:root/foIn:layout-master-set/foIn:simple-page-master[@master-name = $page-sequence/@master-reference]">
                <xsl:value-of select="$page-sequence/@master-reference" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="page-sequence-master" select="/foIn:root/foIn:layout-master-set/foIn:page-sequence-master[@master-name = $page-sequence/@master-reference][1]" />
                <!-- TODO This is simplified - conditional masters are ignored, simply the first @master-reference is taken...: -->
                <xsl:value-of select="$page-sequence-master/descendant::*/@master-reference[1]" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="simple-page-master" select="/foIn:root/foIn:layout-master-set/foIn:simple-page-master[@master-name = $simple-page-master-name][1]" />
    <xsl:if test="not($simple-page-master)">
        <xsl:variable name="xalan"><xsl:call-template name="log:log-error"><xsl:with-param name="msg">&lt;fo:simple-page-master&gt; for master-reference="<xsl:value-of select="$page-sequence/@master-reference" />" could not be found</xsl:with-param></xsl:call-template></xsl:variable>
    </xsl:if>
    
    <func:result select="$simple-page-master" /> 
</func:function>

<!-- ===== is-probably-...() functions ===== -->

<func:function name="my:is-probably-border-width-property">
    <xsl:param name="value" select="." />
    <xsl:variable name="fc" select="substring($value, 1, 1)" />
    <func:result select="my:is-numeric-char($fc) or $value = $fif_global-border-width-names" /> 
</func:function>
<xsl:variable name="fif_global-border-width-names" select="str:tokenize('thin,medium,thick', ',')" />

<func:function name="my:is-probably-border-style-property">
    <xsl:param name="value" select="." />
    <func:result select="$value = $fif_global-fo-border-style-values" /> 
</func:function>
<xsl:variable name="fif_global-fo-border-style-values" select="str:tokenize('none,hidden,dotted,dashed,solid,double,groove,ridge,inset,outset', ',')" />

<func:function name="my:is-probably-color-property">
    <xsl:param name="value" select="." />
    <func:result select="$value = $fif_global-color-names or starts-with($value, '#') or starts-with($value, 'rgb(')
            or starts-with($value, 'rgb-icc(') or starts-with($value, 'system-color(')" /> 
</func:function>
<xsl:variable name="fif_global-color-names" select="str:tokenize('black,silver,gray,white,maroon,red,purple,fuchsia,green,lime,olive,yellow,navy,blue,teal,aqua', ',')" />

<func:function name="my:is-probably-font-weight-property">
    <xsl:param name="value" select="." />
    <func:result select="$value = $fif_font-weight-names" /> 
</func:function>
<xsl:variable name="fif_font-weight-names" select="str:tokenize('bold,bolder,lighter,100,200,300,400,500,600,700,800,900', ',')" />

<func:function name="my:is-probably-font-variant-property">
    <xsl:param name="value" select="." />
    <func:result select="$value = 'small-caps'" /> 
</func:function>

<func:function name="my:is-probably-font-style-property">
    <xsl:param name="value" select="." />
    <func:result select="$value = 'italic' or $value = 'oblique' or $value = 'backslant'" /> 
</func:function>

<func:function name="my:is-probably-font-size-property">
    <xsl:param name="value" select="." />
    <func:result select="$value = $fif_global-font-size-names or
            (my:is-numeric-char(my:char-at($value, 1)) and not(my:is-numeric-char(my:char-at($value, string-length($value))))) " /> 
</func:function>
<xsl:variable name="fif_global-font-size-names" select="str:tokenize('xx-small,x-small,small,medium,large,x-large,xx-large,smaller,larger', ',')" />

<func:function name="my:is-system-font-name">
    <xsl:param name="value" select="." />
    <func:result select="$value = $fif_global-system-font-names" /> 
</func:function>
<xsl:variable name="fif_global-system-font-names" select="str:tokenize('caption,icon,menu,message-box,small-caption,status-bar', ',')" />

<!-- ===== /is-probably-...() functions ===== -->

</xsl:stylesheet>