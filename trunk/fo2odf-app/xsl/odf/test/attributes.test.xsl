<?xml version="1.0"?>
<!-- TODO Tests of radix conversions (dec2hex...) should be moved to a separate file. -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://xsltsl.org/xsl/documentation/1.0" xmlns:str="http://xsltsl.org/string"
    exclude-result-prefixes="doc" version="1.0">

    <xsl:include href="../attributes.xsl" />

    <doc:article>
        <doc:title>Attributes Module Test Suite</doc:title>

        <doc:para>This stylesheet tests the attributes stylesheet module.</doc:para>
    </doc:article>

    <xsl:template name="attributes">        
        
        <xsl:call-template name="debug"><xsl:with-param name="msg">get.color.code test (white)</xsl:with-param></xsl:call-template>
        
        <xsl:call-template name="test">

            <xsl:with-param name="description">get.color.code test (white)</xsl:with-param>

            <xsl:with-param name="result">
                <xsl:call-template name="get-color-code">
                    <xsl:with-param name="fo-color-code">white</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="expect">#ffffff</xsl:with-param>

        </xsl:call-template>
        
        <xsl:call-template name="debug"><xsl:with-param name="msg">get.color.code test (green)</xsl:with-param></xsl:call-template>
        
        <xsl:call-template name="test">

            <xsl:with-param name="description">get.color.code test (green)</xsl:with-param>

            <xsl:with-param name="result">
                <xsl:call-template name="get-color-code">
                    <xsl:with-param name="fo-color-code">green</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="expect">#008000</xsl:with-param>

        </xsl:call-template>

        <xsl:call-template name="debug"><xsl:with-param name="msg">get.color.code test (#0fa)</xsl:with-param></xsl:call-template>
        
        <xsl:call-template name="test">

            <xsl:with-param name="description">get.color.code test (#0fa)</xsl:with-param>

            <xsl:with-param name="result">
                <xsl:call-template name="get-color-code">
                    <xsl:with-param name="fo-color-code">#0fa</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="expect">#00ffaa</xsl:with-param>

        </xsl:call-template>
        
        <xsl:call-template name="debug"><xsl:with-param name="msg">get.color.code test (rgb(0, 255, 160))</xsl:with-param></xsl:call-template>
        
        <xsl:call-template name="test">

            <xsl:with-param name="description">get.color.code test (rgb(0, 255, 160))</xsl:with-param>

            <xsl:with-param name="result">
                <xsl:call-template name="get-color-code">
                    <xsl:with-param name="fo-color-code">rgb(0, 255, 160)</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="expect">#00ffa0</xsl:with-param>

        </xsl:call-template>
        
        <xsl:call-template name="debug"><xsl:with-param name="msg">get.color.code test (rgb(0%, 100%, 62.7%))</xsl:with-param></xsl:call-template>
        
        <xsl:call-template name="test">

            <xsl:with-param name="description">get.color.code test (rgb(0%, 100%, 62.7%))</xsl:with-param>

            <xsl:with-param name="result">
                <xsl:call-template name="get-color-code">
                    <xsl:with-param name="fo-color-code">rgb(0%, 100%, 62.7%)</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="expect">#00ffa0</xsl:with-param>

        </xsl:call-template>
        
        <xsl:call-template name="debug"><xsl:with-param name="msg">dec2hex test (3)</xsl:with-param></xsl:call-template>
        
        <xsl:call-template name="test">

            <xsl:with-param name="description">dec2hex test (3)</xsl:with-param>

            <xsl:with-param name="result">
                <xsl:call-template name="dec2hex">
                    <xsl:with-param name="number">3</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="expect">3</xsl:with-param>

        </xsl:call-template>
        
        <xsl:call-template name="debug"><xsl:with-param name="msg">dec2hex test (10)</xsl:with-param></xsl:call-template>
        
        <xsl:call-template name="test">

            <xsl:with-param name="description">dec2hex test (10)</xsl:with-param>

            <xsl:with-param name="result">
                <xsl:call-template name="dec2hex">
                    <xsl:with-param name="number">10</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="expect">a</xsl:with-param>

        </xsl:call-template>
        
        <xsl:call-template name="debug"><xsl:with-param name="msg">dec2hex test (254)</xsl:with-param></xsl:call-template>
        
        <xsl:call-template name="test">

            <xsl:with-param name="description">dec2hex test (254)</xsl:with-param>

            <xsl:with-param name="result">
                <xsl:call-template name="dec2hex">
                    <xsl:with-param name="number">254</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="expect">fe</xsl:with-param>

        </xsl:call-template>
        
        <xsl:call-template name="debug"><xsl:with-param name="msg">dec2hex_align2 test (10)</xsl:with-param></xsl:call-template>
        
        <xsl:call-template name="test">

            <xsl:with-param name="description">dec2hex_align2 test (10)</xsl:with-param>

            <xsl:with-param name="result">
                <xsl:call-template name="dec2hex_align2">
                    <xsl:with-param name="number">10</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="expect">0a</xsl:with-param>

        </xsl:call-template>
        
        <xsl:call-template name="debug"><xsl:with-param name="msg">dec2hex_align2 test (254)</xsl:with-param></xsl:call-template>
        
        <xsl:call-template name="test">

            <xsl:with-param name="description">dec2hex_align2 test (254)</xsl:with-param>

            <xsl:with-param name="result">
                <xsl:call-template name="dec2hex_align2">
                    <xsl:with-param name="number">254</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="expect">fe</xsl:with-param>

        </xsl:call-template>
        
    </xsl:template>

</xsl:stylesheet>
