<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://xsltsl.org/xsl/documentation/1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:str="http://exslt.org/strings"
    xmlns:my="http://example.com/muj"
    extension-element-prefixes="str"
    exclude-result-prefixes="doc my exsl str" version="1.0">

<xsl:import href="common_test_functions.xsl" />

<xsl:include href="../expand_fo_shorthands.xsl" />

<doc:article>
    <doc:title>Expand FO Shorthands Module Test Suite</doc:title>

    <doc:para>This stylesheet tests the Expand FO Shorthands stylesheet module.</doc:para>
</doc:article>

<xsl:template name="expand_fo_shorthands">        
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test expand-fo-shorthands(margin) - basic</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc1">
        <block margin="10pt" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test expand-fo-shorthands(margin) - basic</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc1)/block">
                        <xsl:call-template name="expand-fo-shorthands" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">margin-bottom="10pt" margin-left="10pt" margin-right="10pt" margin-top="10pt"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test expand-fo-shorthands(margin, margin-left)</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc2">
        <block margin="10pt" margin-left="20pt" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test expand-fo-shorthands(margin, margin-left)</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc2)/block">
                        <xsl:call-template name="expand-fo-shorthands" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">margin-bottom="10pt" margin-left="20pt" margin-right="10pt" margin-top="10pt"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test expand-fo-shorthands(border, border-left, border-width, ...) - complete test</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc3">
        <block border="1pt solid black" border-left="10pt dotted red" border-width="3pt" border-top-width="7pt" border-top="4pt solid green" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test expand-fo-shorthands(border, border-left, border-width, ...) - complete test</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc3)/block">
                        <xsl:call-template name="expand-fo-shorthands" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">border-bottom-color="black" border-bottom-style="solid" border-bottom-width="3pt" border-left-color="red" border-left-style="dotted" border-left-width="10pt" border-right-color="black" border-right-style="solid" border-right-width="3pt" border-top-color="green" border-top-style="solid" border-top-width="7pt"</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="debug"><xsl:with-param name="msg">test expand-fo-shorthands(margin, margin-left)</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc4">
        <block border-left="1pt solid" border-right="dotted red" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test expand-fo-shorthands(border-left="1pt solid" border-right="dotted red")</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc4)/block">
                        <xsl:call-template name="expand-fo-shorthands" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">border-left-style="solid" border-left-width="1pt" border-right-color="red" border-right-style="dotted"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test expand-fo-shorthands(background="red")</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc5">
        <block background="red" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test expand-fo-shorthands(background="red")</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc5)/block">
                        <xsl:call-template name="expand-fo-shorthands" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">background-color="red"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test expand-fo-shorthands(background="repeat-x #ff0000")</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc6">
        <block background="repeat-x #ff0000" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test expand-fo-shorthands(background="repeat-x #ff0000")</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc6)/block">
                        <xsl:call-template name="expand-fo-shorthands" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">background-color="#ff0000"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test expand-fo-shorthands("900 italic small-cap 15pt Times")</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc7">
        <block font="900 italic small-caps 15pt Times" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test expand-fo-shorthands(font="900 italic small-caps 15pt Times")</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc7)/block">
                        <xsl:call-template name="expand-fo-shorthands" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">font-family="Times" font-size="15pt" font-style="italic" font-variant="small-caps" font-weight="900"</xsl:with-param>
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
