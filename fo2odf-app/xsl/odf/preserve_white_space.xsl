<?xml version="1.0"?>

<!--
Templates for preserving white space in an ODF document.
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format"
	exclude-result-prefixes="exsl func my log"
    extension-element-prefixes="exsl func">

<xsl:import href="../common/strings.xsl" />
<xsl:import href="../common/xslt_logging.xsl" />

<xsl:template match="text()[parent::foIn:block] | text()[parent::foIn:inline]" mode="phase1">
    <xsl:variable name="str" select="." />
    <xsl:choose>
        <xsl:when test="../@white-space-collapse = 'false' or ../@white-space-treatment = 'ignore'
                or ../@linefeed-treatment = 'ignore' or ../@linefeed-treatment = 'treat-as-zero-width-space'
                or ../@linefeed-treatment = 'preserve'">
            <!-- Preserve or ignore white spaces or linefeeeds... -->
            <xsl:variable name="after-white-space-treatment">
                <xsl:choose>
                    <xsl:when test="../@white-space-treatment = 'ignore'">
                        <xsl:value-of select="my:remove-white-space($str)" />
                    </xsl:when>
                    <xsl:when test="../@white-space-treatment = 'ignore-if-before-linefeed'">
                        <xsl:value-of select="my:remove-white-space-if-before-linefeed($str)" />
                    </xsl:when>
                    <xsl:when test="../@white-space-treatment = 'ignore-if-after-linefeed'">
                        <xsl:value-of select="my:remove-white-space-if-after-linefeed($str)" />
                    </xsl:when>
                    <xsl:when test="../@white-space-treatment = 'ignore-if-surrounding-linefeed' or not(../@white-space-treatment)"><!-- this is the default value -->
                        <xsl:value-of select="my:remove-white-space-if-surrounding-linefeed($str)" />
                    </xsl:when>
                    <xsl:otherwise><!-- 'preserve' -->
                        <xsl:value-of select="$str" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="after-linefeed-treatment">
                <xsl:choose>
                    <xsl:when test="../@linefeed-treatment = 'ignore'">
                        <xsl:value-of select="translate($after-white-space-treatment, '&#x0A;', '')" />
                    </xsl:when>
                    <xsl:when test="../@linefeed-treatment = 'treat-as-space' or not(../@linefeed-treatment)"><!-- this is the default value -->
                        <xsl:value-of select="translate($after-white-space-treatment, '&#x0A;', ' ')" />
                    </xsl:when>
                    <xsl:when test="../@linefeed-treatment = 'treat-as-zero-width-space'">
                        <xsl:value-of select="translate($after-white-space-treatment, '&#x0A;', '&#x200B;')" />
                    </xsl:when>
                    <xsl:otherwise><!-- 'preserve' -->
                        <xsl:value-of select="$after-white-space-treatment" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="text1">
                <xsl:choose>
                    <xsl:when test="../@white-space-collapse = 'false'">
                        <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Generating ODF white-space elements for preserving space...</xsl:with-param></xsl:call-template> 
                        <xsl:call-template name="preserve-white-space">
                            <xsl:with-param name="str" select="$after-linefeed-treatment" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$after-linefeed-treatment" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="text2">
                <xsl:choose>
                    <xsl:when test="../@linefeed-treatment = 'preserve'">
                        <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Generating ODF white-space elements for preserving linefeeds...</xsl:with-param></xsl:call-template> 
                        <xsl:for-each select="exsl:node-set($text1)/node()">
                            <xsl:choose>
                                <xsl:when test="self::text()">
                                    <xsl:call-template name="preserve-white-space-linefeed">
                                        <xsl:with-param name="str" select="." />
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:copy-of select="." />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$text1" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:copy-of select="$text2" />
        </xsl:when>
        <xsl:otherwise>
            <!-- White spaces nor linefeeds must be processed... -->
            <xsl:value-of select="$str" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Note: str:tokenize() could be used for this function but unfortunately Xalan-J runs out of memory quite soon with it. So the recursion used instead is "smaller evil". -->
<xsl:template name="preserve-white-space">
    <xsl:param name="str" /><!-- string -->
    <xsl:variable name="str-no-tabs" select="translate($str, '&#x09;', ' ')" /><!-- replaces tabs with spaces -->
    
    <xsl:if test="string-length($str-no-tabs) > 0">
        <xsl:variable name="last-space-pos" select="my:get-last-position-of($str-no-tabs, ' ')" />
        <xsl:if test="$last-space-pos > 0">
            <xsl:text> </xsl:text>
            <xsl:if test="$last-space-pos > 1">
                <text:s text:c="{$last-space-pos - 1}" />
            </xsl:if>
        </xsl:if>
        
        <xsl:variable name="str-after-spaces">
            <xsl:choose>
                <xsl:when test="$last-space-pos > 0"><xsl:value-of select="substring($str-no-tabs, $last-space-pos + 1)" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="$str-no-tabs" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="next-space-pos" select="my:index-of($str-after-spaces, ' ')" />
        
        <xsl:choose>
            <xsl:when test="$next-space-pos > 0">
                <xsl:value-of select="substring($str-after-spaces, 1, $next-space-pos - 1)" />
                <xsl:call-template name="preserve-white-space">
                    <xsl:with-param name="str" select="substring($str-after-spaces, $next-space-pos)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$str-after-spaces" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- Note: str:tokenize() could be used for this function but unfortunately Xalan-J runs out of memory quite soon with it. So the recursion used instead is "smaller evil". -->
<xsl:template name="preserve-white-space-linefeed">
    <xsl:param name="str" /><!-- string -->
    <xsl:variable name="search" select="'&#x0a;'" />
    <xsl:if test="string-length($str) > 0">
        
        <xsl:choose>
            <xsl:when test="contains($str, $search)">
                <xsl:value-of select="substring-before($str, $search)" />
                <xsl:text>&#x0a;</xsl:text><text:line-break />
                <xsl:call-template name="preserve-white-space-linefeed">
                    <xsl:with-param name="str" select="substring-after($str, $search)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$str" />
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:if>
</xsl:template>

<!-- ===== "Supporting" functions ===== -->

<func:function name="my:get-last-position-of">
    <xsl:param name="in" /><!-- string -->
    <xsl:param name="what" /><!-- string -->
    <xsl:param name="last-known-pos" select="'0'" /><!-- number -->
    <xsl:choose>
        <xsl:when test="starts-with($in, $what)">
            <func:result select="my:get-last-position-of(substring-after($in, $what), $what, $last-known-pos + 1)" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="$last-known-pos" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Removes white space characters (i. e. spaces and tabs) from a given string and returns the result. -->
<func:function name="my:remove-white-space">
    <xsl:param name="str" /><!-- string -->
    <func:result select="translate($str, '&#x20;&#x09;', '')" />
</func:function>

<!-- Removes white space characters (i. e. spaces and tabs) from a given string if they precede a linefeed and returns the result. -->
<func:function name="my:remove-white-space-if-before-linefeed">
    <xsl:param name="str" /><!-- string -->
    <xsl:variable name="linefeed-pos" select="my:index-of($str, '&#x0a;')" />
    <xsl:choose>
        <xsl:when test="$linefeed-pos &lt; 1">
            <func:result select="$str" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="str-before-linefeed" select="my:trim-right-spaces(substring($str, 1, $linefeed-pos - 1))" />
            <func:result select="concat($str-before-linefeed, '&#x0a;', my:remove-white-space-if-before-linefeed(substring($str, $linefeed-pos + 1)))" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Removes white space characters (i. e. spaces and tabs) from a given string if they follow a linefeed and returns the result. -->
<func:function name="my:remove-white-space-if-after-linefeed">
    <xsl:param name="str" /><!-- string -->
    <xsl:variable name="linefeed-pos" select="my:last-index-of($str, '&#x0a;')" />
    <xsl:choose>
        <xsl:when test="$linefeed-pos &lt; 1">
            <func:result select="$str" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="str-after-linefeed" select="my:trim-left-spaces(substring($str, $linefeed-pos + 1))" />
            <func:result select="concat(my:remove-white-space-if-after-linefeed(substring($str, 1, $linefeed-pos - 1)), '&#x0a;', $str-after-linefeed)" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Removes white space characters (i. e. spaces and tabs) from a given string if they follow or a precede a linefeed and returns the result. -->
<func:function name="my:remove-white-space-if-surrounding-linefeed">
    <xsl:param name="str" /><!-- string -->
    <func:result select="my:remove-white-space-if-after-linefeed(my:remove-white-space-if-before-linefeed($str))" />
</func:function>

<func:function name="my:trim-left-spaces">
    <xsl:param name="str" /><!-- string -->
    <xsl:choose>
        <xsl:when test="starts-with($str, ' ') or starts-with($str, '&#x09;')">
            <func:result select="my:trim-left-spaces(substring($str, 2))" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="$str" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<func:function name="my:trim-right-spaces">
    <xsl:param name="str" /><!-- string -->
    <xsl:choose>
        <xsl:when test="my:ends-with($str, ' ') or my:ends-with($str, '&#x09;')">
            <func:result select="my:trim-right-spaces(substring($str, 1, string-length($str) - 1))" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="$str" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- ===== /"Supporting" functions ===== -->

</xsl:stylesheet>