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

<xsl:import href="common_test_functions.xsl" />

<xsl:include href="../compute_fo_properties.xsl" />

<doc:article>
    <doc:title>Compute FO Properties Module Test Suite</doc:title>

    <doc:para>This stylesheet tests the Compute FO Properties stylesheet module.</doc:para>
</doc:article>

<xsl:template name="compute_fo_properties">
    <xsl:variable name="apos">'</xsl:variable> 
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">my:get-number-index-from-right test ('10pt', 2)</xsl:with-param></xsl:call-template>
    
    <xsl:call-template name="test">

        <xsl:with-param name="description">my:get-number-index-from-right test ('10pt', 2)</xsl:with-param>

        <xsl:with-param name="result">
            <xsl:value-of select="my:get-number-index-from-right('10pt', 2)" />
        </xsl:with-param>
        <xsl:with-param name="expect">1</xsl:with-param>

    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">my:get-number-index-from-right test ('1 + 5.8cm', 7)</xsl:with-param></xsl:call-template>
    
    <xsl:call-template name="test">

        <xsl:with-param name="description">my:get-number-index-from-right test ('1 + 5.8cm', 7)</xsl:with-param>

        <xsl:with-param name="result">
            <xsl:value-of select="my:get-number-index-from-right('1 + 5.8cm', 7)" />
        </xsl:with-param>
        <xsl:with-param name="expect">5</xsl:with-param>

    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">my:get-number-index-from-right test ('1 + 5.8cm', 8)</xsl:with-param></xsl:call-template>
    
    <xsl:call-template name="test">

        <xsl:with-param name="description">my:get-number-index-from-right test ('1 + 5.8cm', 8)</xsl:with-param>

        <xsl:with-param name="result">
            <xsl:value-of select="my:get-number-index-from-right('1 + 5.8cm', 8)" />
        </xsl:with-param>
        <xsl:with-param name="expect">-1</xsl:with-param>

    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">my:index-of test ('abcdea', 'ab')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">my:index-of test ('abcdea', 'ab')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:index-of('abcdea', 'ab')" />
        </xsl:with-param>
        <xsl:with-param name="expect">1</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">my:index-of test ('abcdea', 'ad')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">my:index-of test ('abcdea', 'ad')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:index-of('abcdea', 'ad')" />
        </xsl:with-param>
        <xsl:with-param name="expect">-1</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">my:index-of test ('abcdea', 'a', 2)</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">my:index-of test ('abcdea', 'a', 2)</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:index-of('abcdea', 'a', 2)" />
        </xsl:with-param>
        <xsl:with-param name="expect">6</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">my:index-of test ('abcdea', '')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">my:index-of test ('abcdea', '')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:index-of('abcdea', '')" />
        </xsl:with-param>
        <xsl:with-param name="expect">-1</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:last-index-of('abcdea', 'a')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:last-index-of('abcdea', 'a')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:last-index-of('abcdea', 'a')" />
        </xsl:with-param>
        <xsl:with-param name="expect">6</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:last-index-of('aaabcd', 'aa')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:last-index-of('aaabcd', 'aa')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:last-index-of('aaabcd', 'aa')" />
        </xsl:with-param>
        <xsl:with-param name="expect">2</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:last-index-of('abcdea', 'f')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:last-index-of('abcdea', 'f')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:last-index-of('abcdea', 'f')" />
        </xsl:with-param>
        <xsl:with-param name="expect">0</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:simple-replace('aabcdeabc', 'abc', 'ABC')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:simple-replace('aabcdeabc', 'abc', 'ABC')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:simple-replace('aabcdeabc', 'abc', 'ABC')" />
        </xsl:with-param>
        <xsl:with-param name="expect">aABCdeABC</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:get-url-content(url('file.txt'))</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:get-url-content(url('file.txt'))</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:get-url-content(concat('url(', $apos, 'file.txt', $apos, ')'))" />
        </xsl:with-param>
        <xsl:with-param name="expect">file.txt</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:get-url-content(url(file.txt))</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:get-url-content(url(file.txt))</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:get-url-content('url(file.txt)')" />
        </xsl:with-param>
        <xsl:with-param name="expect">file.txt</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:get-url-content('file.txt')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:get-url-content('file.txt')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:get-url-content('file.txt')" />
        </xsl:with-param>
        <xsl:with-param name="expect">file.txt</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:replace-unit-with-function('10.5cm + 1cm', 'cm')</xsl:with-param></xsl:call-template>
    
    <xsl:call-template name="test">

        <xsl:with-param name="description">test my:replace-unit-with-function('10.5cm + 1cm', 'cm')</xsl:with-param>

        <xsl:with-param name="result">
            <xsl:value-of select="my:replace-unit-with-function('10.5cm + 1cm', 'cm')" />
        </xsl:with-param>
        <xsl:with-param name="expect">my:to-points(10.5, 'cm') + my:to-points(1, 'cm')</xsl:with-param>

    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:replace-unit-with-function('some-in-function() + 1in', 'in')</xsl:with-param></xsl:call-template>
    
    <xsl:call-template name="test">

        <xsl:with-param name="description">test my:replace-unit-with-function('some-in-function() + 1in', 'in')</xsl:with-param>

        <xsl:with-param name="result">
            <xsl:value-of select="my:replace-unit-with-function('some-in-function() + 1in', 'in')" />
        </xsl:with-param>
        <xsl:with-param name="expect">some-in-function() + my:to-points(1, 'in')</xsl:with-param>

    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:replace-units-with-functions('10.5cm + 1in', &lt;node-set&gt;('cm', in'))</xsl:with-param></xsl:call-template>
    
    <xsl:call-template name="test">

        <xsl:with-param name="description">test my:replace-units-with-functions('10.5cm + 1in', &lt;node-set&gt;('cm', in'))</xsl:with-param>

        <xsl:with-param name="result">
            <xsl:value-of select="my:replace-units-with-functions('10.5cm + 1in', str:tokenize('cm,in', ','))" />
        </xsl:with-param>
        <xsl:with-param name="expect">my:to-points(10.5, 'cm') + my:to-points(1, 'in')</xsl:with-param>

    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:replace-function('2 * from-parent()', 'my:fo-function-', 'from-parent')</xsl:with-param></xsl:call-template>
    
    <xsl:call-template name="test">

        <xsl:with-param name="description">test my:replace-function('2 * from-parent()', 'my:fo-function-', 'from-parent')</xsl:with-param>

        <xsl:with-param name="result">
            <xsl:value-of select="my:replace-function('2 * from-parent()', 'my:fo-function-', 'from-parent')" />
        </xsl:with-param>
        <xsl:with-param name="expect">2 * my:fo-function-from-parent('')</xsl:with-param>

    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:replace-function('2 * from-parent(color)', 'my:fo-function-', 'from-parent')</xsl:with-param></xsl:call-template>
    
    <xsl:call-template name="test">

        <xsl:with-param name="description">test my:replace-function('2 * from-parent(color)', 'my:fo-function-', 'from-parent')</xsl:with-param>

        <xsl:with-param name="result">
            <xsl:value-of select="my:replace-function('2 * from-parent(color)', 'my:fo-function-', 'from-parent')" />
        </xsl:with-param>
        <xsl:with-param name="expect">2 * my:fo-function-from-parent('color')</xsl:with-param>

    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:to-points(1, 'pt')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:to-points(1, 'pt')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:to-points(1, 'pt')" />
        </xsl:with-param>
        <xsl:with-param name="expect">1</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:to-points(2, 'in')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:to-points(2, 'in')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:to-points(2, 'in')" />
        </xsl:with-param>
        <xsl:with-param name="expect">144</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:to-points(120, '%')</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc1">
        <block font-size="10pt">
            <block font-size="120%">text</block>
        </block>
    </xsl:variable>
    <xsl:for-each select="exsl:node-set($doc1)/block/block/@font-size">
        <xsl:call-template name="test">
            <xsl:with-param name="description">test my:to-points(120, '%')</xsl:with-param>
            <xsl:with-param name="result">
                <xsl:value-of select="my:to-points(120, '%')" />
            </xsl:with-param>
            <xsl:with-param name="expect">12</xsl:with-param>
        </xsl:call-template>
    </xsl:for-each>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:to-points(1.2, 'em') [font-size from parent]</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc2">
        <block font-size="10pt">
            <block margin-top="1.2em">text</block>
        </block>
    </xsl:variable>
    <xsl:for-each select="exsl:node-set($doc2)/block/block/@margin-top">
        <xsl:call-template name="test">
            <xsl:with-param name="description">test my:to-points(1.2, 'em') [font-size from parent]</xsl:with-param>
            <xsl:with-param name="result">
                <xsl:value-of select="my:to-points(1.2, 'em')" />
            </xsl:with-param>
            <xsl:with-param name="expect">12</xsl:with-param>
        </xsl:call-template>
    </xsl:for-each>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:to-points(1.2, 'em') [font-size=120% from current element]</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc3">
        <block font-size="10pt">
            <block font-size="120%" margin-top="1.2em">text</block>
        </block>
    </xsl:variable>
    <xsl:for-each select="exsl:node-set($doc3)/block/block/@margin-top">
        <xsl:call-template name="test">
            <xsl:with-param name="description">test my:to-points(1.2, 'em') [font-size=120% from current element]</xsl:with-param>
            <xsl:with-param name="result">
                <xsl:value-of select="my:to-points(1.2, 'em')" />
            </xsl:with-param>
            <xsl:with-param name="expect">14.4</xsl:with-param>
        </xsl:call-template>
    </xsl:for-each>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:compute-fo-length-property('10pt + 1in')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:compute-fo-length-property('10pt + 1in')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:compute-fo-length-property('10pt + 1in')" />
        </xsl:with-param>
        <xsl:with-param name="expect">82</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:compute-fo-length-property('(109 mod 10) * 1pt + 1in div 10')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:compute-fo-length-property('(109 mod 10) * 1pt + 1in div 10')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:compute-fo-length-property('(109 mod 10) * 1pt + 1in div 10')" />
        </xsl:with-param>
        <xsl:with-param name="expect">16.2</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test of giving precedence to absolute properties</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc4">
        <block margin-top="10pt" space-before="20pt">
        </block>
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test of giving precedence to absolute properties</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc4)/block">
                        <xsl:call-template name="compute-fo-properties" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">margin-top="10pt"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test of computing absolute properties from relative properties</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc5">
        <block space-before="20pt" end-indent="30pt">
        </block>
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test of computing absolute properties from relative properties</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc5)/block">
                        <xsl:call-template name="compute-fo-properties" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">margin-right="30pt" margin-top="20pt"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test of computing margin with respect to reference area (fo:block-container)</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc6">
        <foIn:block-container start-indent="1pt" margin-left="10pt" end-indent="20pt"><!-- "start-indent" attribute should be ignored in computation -->
            <block start-indent="20pt" margin-right="30pt">text</block>
        </foIn:block-container>
    </xsl:variable>
    <xsl:variable name="whole-result">
        <xsl:for-each select="exsl:node-set($doc6)/foIn:block-container">
            <xsl:call-template name="compute-fo-properties" />
        </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test of computing margin with respect to reference area (fo:block-container)</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-element-sorted-attributes">
                <xsl:with-param name="element" select="exsl:node-set($whole-result)/*/block" />
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">margin-left="30pt" margin-right="50pt"</xsl:with-param>
    </xsl:call-template>

    <!-- ===== Borders ===== -->
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test: border-left-style="solid" border-left-width="1pt"</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc7">
        <block border-left-style="solid" border-left-width="1pt" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test: border-left-style="solid" border-left-width="1pt"</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc7)/block">
                        <xsl:call-template name="compute-fo-properties" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">border-left-style="solid" border-left-width="1pt"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test: border-left-style="none" border-left-width="1pt"</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc8">
        <block border-left-style="none" border-left-width="1pt" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test: border-left-style="none" border-left-width="1pt"</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc8)/block">
                        <xsl:call-template name="compute-fo-properties" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">border-left-style="none" border-left-width="0pt"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test: border-left-color="red" (zero border width)</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc9">
        <block border-left-color="red" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test: border-left-color="red" (zero border width)</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc9)/block">
                        <xsl:call-template name="compute-fo-properties" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">border-left-color="red"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test: border-left-color="red" border-left-style="none" (zero border width)</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc10">
        <block border-left-color="red" border-left-style="none" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test: border-left-color="red" border-left-style="none" (zero border width)</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc10)/block">
                        <xsl:call-template name="compute-fo-properties" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">border-left-color="red" border-left-style="none"</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test: border-left-color="red" border-left-style="solid" (medium border width)</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc11">
        <block border-left-color="red" border-left-style="solid" />
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test: border-left-color="red" border-left-style="solid" (medium border width)</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:call-template name="_get-result-tree-element-sorted-attributes">
                <xsl:with-param name="element">
                    <xsl:for-each select="exsl:node-set($doc11)/block">
                        <xsl:call-template name="compute-fo-properties" />
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="expect">border-left-color="red" border-left-style="solid" border-left-width="<xsl:value-of select="$named-border-width-medium" />"</xsl:with-param>
    </xsl:call-template>
    
    <!-- ===== /Borders ===== -->
    
    <!-- ===== Tables ===== -->
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test: get-table-cell-column-number(1st cell)</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc12">
        <foIn:table-row>
            <foIn:table-cell>a</foIn:table-cell>
            <foIn:table-cell>b</foIn:table-cell>
            <foIn:table-cell>c</foIn:table-cell>
        </foIn:table-row>
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test: get-table-cell-column-number(1st cell)</xsl:with-param>
        <xsl:with-param name="result"><xsl:value-of select="my:get-table-cell-column-number(exsl:node-set($doc12)/foIn:table-row/foIn:table-cell[1])" /></xsl:with-param>
        <xsl:with-param name="expect">1</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test: get-table-cell-column-number(2nd cell)</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc13">
        <foIn:table-row>
            <foIn:table-cell>a</foIn:table-cell>
            <foIn:table-cell>b</foIn:table-cell>
            <foIn:table-cell>c</foIn:table-cell>
        </foIn:table-row>
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test: get-table-cell-column-number(2nd cell)</xsl:with-param>
        <xsl:with-param name="result"><xsl:value-of select="my:get-table-cell-column-number(exsl:node-set($doc12)/foIn:table-row/foIn:table-cell[2])" /></xsl:with-param>
        <xsl:with-param name="expect">2</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test: get-table-cell-column-number(cell after cell with number-columns-spanned="2" after cell with column-number="3")</xsl:with-param></xsl:call-template>
    <xsl:variable name="doc14">
        <foIn:table-row>
            <foIn:table-cell column-number="3">a</foIn:table-cell>
            <foIn:table-cell number-columns-spanned="2">b</foIn:table-cell>
            <foIn:table-cell>c</foIn:table-cell>
        </foIn:table-row>
    </xsl:variable>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test: get-table-cell-column-number(cell after cell with number-columns-spanned="2" after cell with column-number="3")</xsl:with-param>
        <xsl:with-param name="result"><xsl:value-of select="my:get-table-cell-column-number(exsl:node-set($doc14)/foIn:table-row/foIn:table-cell[3])" /></xsl:with-param>
        <xsl:with-param name="expect">6</xsl:with-param>
    </xsl:call-template>
    
    <!-- ===== /Tables ===== -->
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:get-units-length('10pt')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:get-units-length('10pt')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:get-units-length('10pt')" />
        </xsl:with-param>
        <xsl:with-param name="expect">2</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:get-units-length('2 * 10pt')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:get-units-length('2 * 10pt')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:get-units-length('2 * 10pt')" />
        </xsl:with-param>
        <xsl:with-param name="expect">0</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:get-units-length('0cm')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:get-units-length('0cm')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:get-units-length('0cm')" />
        </xsl:with-param>
        <xsl:with-param name="expect">2</xsl:with-param>
    </xsl:call-template>
    
    <!--    
    <xsl:call-template name="debug"><xsl:with-param name="msg">test my:compute-fo-property('xxx')</xsl:with-param></xsl:call-template>
    <xsl:call-template name="test">
        <xsl:with-param name="description">test my:compute-fo-property('xxx')</xsl:with-param>
        <xsl:with-param name="result">
            <xsl:value-of select="my:compute-fo-property('xxx')" />
        </xsl:with-param>
        <xsl:with-param name="expect">yyy</xsl:with-param>
    </xsl:call-template>
    -->
</xsl:template>

</xsl:stylesheet>
