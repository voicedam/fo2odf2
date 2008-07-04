<?xml version="1.0"?>

<!-- Common functions for working with representations of colors. -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../common/radix_conversions.xsl" />

<!-- Converts color from the "rgb(number, number, number)" or "rgb(number%, number%, number%)" format
to the "#rrggbb" format. -->
<xsl:template name="rgb-color2hex-color">
    <xsl:param name="rgb-color" select="'rgb(0, 0, 0)'" />
    <xsl:variable name="percentage">
        <xsl:choose>
            <!-- f.e. 'rgb(0%, 100%, 62.7%)' = '#00ffA0' -->
            <xsl:when test="contains($rgb-color, '%')">%</xsl:when>
            <!-- f.e. 'rgb(0, 255, 160)' = '#00ffA0' -->
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="compSepar" select="concat($percentage, ',')" />

    <xsl:variable name="afterRGBPrefix" select="substring-after($rgb-color, 'rgb(')" /><!-- '0%, 100%, 62.7%)' -->
    <xsl:variable name="comp1" select="normalize-space(substring-before($afterRGBPrefix, $compSepar))" /><!-- '0' -->
    <xsl:variable name="afterComp1" select="substring-after($afterRGBPrefix, $compSepar)" /><!-- ' 100%, 62.7%)' -->
    <xsl:variable name="comp2" select="normalize-space(substring-before($afterComp1, $compSepar))" /><!-- '100' -->
    <xsl:variable name="afterComp2" select="substring-after($afterComp1, $compSepar)" /><!-- ' 62.7%' -->
    <xsl:variable name="comp3"
        select="normalize-space(substring-before($afterComp2, concat($percentage, ')')))" /><!-- '62.7' -->

    <xsl:variable name="comp1decimal">
        <xsl:choose>
            <xsl:when test="$percentage = '%'">
                <xsl:value-of select="round($comp1 div 100 * 255)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$comp1" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="comp2decimal">
        <xsl:choose>
            <xsl:when test="$percentage = '%'">
                <xsl:value-of select="round($comp2 div 100 * 255)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$comp2" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="comp3decimal">
        <xsl:choose>
            <xsl:when test="$percentage = '%'">
                <xsl:value-of select="round($comp3 div 100 * 255)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$comp3" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="comp1hex">
        <xsl:call-template name="dec2hex_align2">
            <xsl:with-param name="number" select="$comp1decimal" />
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="comp2hex">
        <xsl:call-template name="dec2hex_align2">
            <xsl:with-param name="number" select="$comp2decimal" />
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="comp3hex">
        <xsl:call-template name="dec2hex_align2">
            <xsl:with-param name="number" select="$comp3decimal" />
        </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="concat('#', $comp1hex, $comp2hex, $comp3hex)" />
</xsl:template>

</xsl:stylesheet>