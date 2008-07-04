<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://xsltsl.org/xsl/documentation/1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:str="http://exslt.org/strings"
    xmlns:my="http://example.com/muj"
    extension-element-prefixes="str"
    exclude-result-prefixes="doc my exsl str"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format"
    version="1.0">

<xsl:import href="../../common/strings.xsl" />

<xsl:import href="common_test_functions.xsl" />

<xsl:include href="../preserve_white_space.xsl" />

<doc:article>
    <doc:title>Preserve White Space Module Test Suite</doc:title>

    <doc:para>This stylesheet tests the Preserve White Space stylesheet module.</doc:para>
</doc:article>

<xsl:template name="preserve_white_space">        
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:get-last-position-of('aaabc', 'a')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:get-last-position-of('aaabc', 'a')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:get-last-position-of('aaabc', 'a')" />
        </xsl:with-param>
        <xsl:with-param name="expect">3</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:get-last-position-of('aaabc', 'b')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:get-last-position-of('aaabc', 'b')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:get-last-position-of('aaabc', 'b')" />
        </xsl:with-param>
        <xsl:with-param name="expect">0</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test preserve-white-space('   3 spaces  then 2 spaces followed by 4 spaces at the end    ')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test preserve-white-space('   3 spaces  then 2 spaces followed by 4 spaces at the end    ')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:variable name="result-rtf">
                <xsl:call-template name="preserve-white-space">
                    <xsl:with-param name="str" select="'   3 spaces  then 2 spaces followed by 4 spaces at the end    '" />
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="my:nodes-to-string(exsl:node-set($result-rtf))" />
        </xsl:with-param>
        <xsl:with-param name="expect"> &lt;text:s text:c=&quot;2&quot; /&gt;3 spaces &lt;text:s text:c=&quot;1&quot; /&gt;then 2 spaces followed by 4 spaces at the end &lt;text:s text:c=&quot;3&quot; /&gt;</xsl:with-param>
         
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:preserve-white-space-linefeed(' aaa  bc  ')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:preserve-white-space-linefeed(' aaa  bc  ')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="preserve-white-space-linefeed">
                <xsl:with-param name="str" select="' aaa  bc  '" />
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect"> aaa  bc  </xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:preserve-white-space-linefeed(' aaa  bc  -linefeed- de')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:preserve-white-space-linefeed(' aaa  bc  -linefeed- de')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:variable name="result-rtf">
                <xsl:call-template name="preserve-white-space-linefeed">
                    <xsl:with-param name="str"> aaa  bc  &#x0a; de</xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="my:nodes-to-string(exsl:node-set($result-rtf))" />
        </xsl:with-param>
        <xsl:with-param name="expect"> aaa  bc  &#x0a;&lt;text:line-break /&gt; de</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:trim-left-spaces('abc  d ')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:trim-left-spaces('abc  d ')</xsl:with-param>
        <xsl:with-param name="result" select="my:trim-left-spaces('abc  d ')" />
        <xsl:with-param name="expect">abc  d </xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:trim-left-spaces('   abc  d ')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:trim-left-spaces('   abc  d ')</xsl:with-param>
        <xsl:with-param name="result" select="my:trim-left-spaces('   abc  d ')" />
        <xsl:with-param name="expect">abc  d </xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:trim-right-spaces(' abc  d')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:trim-right-spaces(' abc  d')</xsl:with-param>
        <xsl:with-param name="result" select="my:trim-right-spaces(' abc  d')" />
        <xsl:with-param name="expect"> abc  d</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:trim-right-spaces(' abc  d   ')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:trim-right-spaces(' abc  d   ')</xsl:with-param>
        <xsl:with-param name="result" select="my:trim-right-spaces(' abc  d   ')" />
        <xsl:with-param name="expect"> abc  d</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:remove-white-space(' Space Between Tab&#x09;Between  ')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:remove-white-space(' Space Between Tab&#x09;Between  ')</xsl:with-param>
        <xsl:with-param name="result" select="my:remove-white-space(' Space Between Tab&#x09;Between  ')" />
        <xsl:with-param name="expect">SpaceBetweenTabBetween</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:remove-white-space-if-before-linefeed(' Line1  &#x0a;   Line2  ')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:remove-white-space-if-before-linefeed(' Line1  &#x0a;   Line2  ')</xsl:with-param>
        <xsl:with-param name="result" select="my:remove-white-space-if-before-linefeed(' Line1  &#x0a;   Line2  ')" />
        <xsl:with-param name="expect"> Line1&#x0a;   Line2  </xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:remove-white-space-if-after-linefeed(' Line1  &#x0a;   Line2  ')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:remove-white-space-if-after-linefeed(' Line1  &#x0a;   Line2  ')</xsl:with-param>
        <xsl:with-param name="result" select="my:remove-white-space-if-after-linefeed(' Line1  &#x0a;   Line2  ')" />
        <xsl:with-param name="expect"> Line1  &#x0a;Line2  </xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:remove-white-space-if-surrounding-linefeed(' Line1  &#x0a;   Line2  ')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:remove-white-space-if-surrounding-linefeed(' Line1  &#x0a;   Line2  ')</xsl:with-param>
        <xsl:with-param name="result" select="my:remove-white-space-if-surrounding-linefeed(' Line1  &#x0a;   Line2  ')" />
        <xsl:with-param name="expect"> Line1&#x0a;Line2  </xsl:with-param>
    </xsl:call-template>
    
</xsl:template>

</xsl:stylesheet>