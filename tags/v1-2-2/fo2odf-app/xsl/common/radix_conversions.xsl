<?xml version="1.0"?>

<!-- Functions for converting numbers among various radixes. -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://exslt.org/strings"
	exclude-result-prefixes="str">

<!-- f.e. '160' => 'a0', '10' => '0a' -->
<xsl:template name="dec2hex_align2">
    <xsl:param name="number" select="0" />
    <xsl:call-template name="str:align">
        <xsl:with-param name="string">
            <xsl:call-template name="dec2hex">
                <xsl:with-param name="number" select="$number" />
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="padding" select="'00'" />
        <xsl:with-param name="alignment" select="'right'" />
    </xsl:call-template>
</xsl:template>

<!-- Converts a decimal number to a hexadecimal number. -->
<xsl:template name="dec2hex">
    <xsl:param name="number" select="0" />
    <xsl:choose>
        <xsl:when test="$number = ''" />
        <xsl:when test="$number &lt; 10">
            <xsl:value-of select="$number" />
        </xsl:when>
        <xsl:when test="$number >= 10 and $number &lt; 16">
            <xsl:value-of select="translate($number - 10, '012345', 'abcdef')" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="dec2hex">
                <xsl:with-param name="number" select="floor($number div 16)" />
            </xsl:call-template>
            <xsl:call-template name="dec2hex">
                <xsl:with-param name="number" select="$number mod 16" />
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- see exslt.org -->
<xsl:template name="str:align">
    <xsl:param name="string" select="''" />
    <xsl:param name="padding" select="''" />
    <xsl:param name="alignment" select="'left'" />
    <xsl:variable name="str-length" select="string-length($string)" />
    <xsl:variable name="pad-length" select="string-length($padding)" />
    <xsl:choose>
        <xsl:when test="$str-length >= $pad-length">
            <xsl:value-of select="substring($string, 1, $pad-length)" />
        </xsl:when>
        <xsl:when test="$alignment = 'center'">
            <xsl:variable name="half-remainder" select="floor(($pad-length - $str-length) div 2)" />
            <xsl:value-of select="substring($padding, 1, $half-remainder)" />
            <xsl:value-of select="$string" />
            <xsl:value-of select="substring($padding, $str-length + $half-remainder + 1)" />
        </xsl:when>
        <xsl:when test="$alignment = 'right'">
            <xsl:value-of select="substring($padding, 1, $pad-length - $str-length)" />
            <xsl:value-of select="$string" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$string" />
            <xsl:value-of select="substring($padding, $str-length + 1)" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>