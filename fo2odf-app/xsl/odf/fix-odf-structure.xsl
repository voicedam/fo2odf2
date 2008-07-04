<?xml version="1.0"?>

<!--
Fixes structure of the ODF document generated in preceding phases so it becomes a nearly valid ODF document.
The following fixes are done:

- <text:bookmark> elements are moved to the first following <text:p> if they are not in a block element yet.
  This happens f.e. for <fo:block> (with @id set) which doesn't result in any <text:p> but they children do. The second
  case is when a block is empty. If no following <text:p> is found after the <text:bookmark>, a new empty <text:p>
  is generated.

- <draw:frame> elements which have text:anchor-type="paragraph" are moved to the first following <text:p>. If such a
  <text:p> is not found, then the generated "float envelope" is removed from the output.
 
- If a <style:style> is the first style that follows after a <style:master-page>, then the "style:master-page-name"
attribute is added to this <style:style> element so paging is implemented right.

This mode doesn't move <style:style> elements to <style:automatic-styles> as this is done in the following
phase(s).
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
	exclude-result-prefixes="exsl func my log"
    extension-element-prefixes="exsl func">

<!-- Copies the element and applies templates on children. -->
<xsl:template match="*" mode="fix-odf-structure">
    <xsl:copy>
        <xsl:copy-of select="@*" />
        <xsl:if test="self::style:style[my:can-have-master-page-name(.)] and my:is-first-style-in-page-sequence(.)">
            <xsl:attribute name="style:master-page-name">
                <xsl:value-of select="preceding-sibling::style:master-page[1]/@style:name" />
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates mode="fix-odf-structure" />
    </xsl:copy>
</xsl:template>

<func:function name="my:is-first-style-in-page-sequence">
    <xsl:param name="element" /><!-- element -->
    <xsl:variable name="preceding-sibling" select="$element/preceding-sibling::*[1]" />
    <xsl:choose>
        <xsl:when test="$preceding-sibling/self::style:master-page">
            <func:result select="true()" />
        </xsl:when>
        <xsl:when test="$preceding-sibling/self::style:style[my:can-have-master-page-name(.)]">
            <func:result select="false()" />
        </xsl:when>
        <xsl:when test="$preceding-sibling">
            <func:result select="my:is-first-style-in-page-sequence($preceding-sibling)" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="false()" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<func:function name="my:can-have-master-page-name">
    <xsl:param name="style" /><!-- <style:style> element -->
    <func:result select="$style/@style:family = 'paragraph' or $style/@style:family = 'table'" />
</func:function>

<!-- Removes the current <text:bookmark> from output if it is not on the right place already. -->
<xsl:template match="text:bookmark" mode="fix-odf-structure">
    <xsl:choose>
        <xsl:when test="ancestor::text:p">
            <xsl:copy-of select="." />
        </xsl:when>
        <xsl:when test="not(following::text:p)">
            <text:p><xsl:copy-of select="." /></text:p>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Omitting &lt;text:bookmark&gt; which is not in a paragraph yet; id = '<xsl:value-of select="./@text:name" />'</xsl:with-param></xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Removes the current <draw:frame> from output if it is going to be moved to the first following paragraph. -->
<xsl:template match="draw:frame[@text:anchor-type='paragraph']" mode="fix-odf-structure">
    <xsl:choose>
        <xsl:when test="following-sibling::text:p">
            <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Omitting &lt;draw:frame&gt; which is not in a paragraph yet</xsl:with-param></xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:copy-of select="./draw:text-box/*" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Copies any <text:bookmark> that directly precedes this paragraph inside the paragraph. -->
<xsl:template match="text:p" mode="fix-odf-structure">
    <xsl:copy>
        <xsl:copy-of select="@*" />
        <xsl:choose>
            <xsl:when test="preceding-sibling::*">
                <xsl:call-template name="copy-bookmarks-preceding-paragraph">
                    <xsl:with-param name="node" select="preceding-sibling::*[1]" />
                </xsl:call-template>
                <xsl:call-template name="copy-floats-preceding-paragraph">
                    <xsl:with-param name="node" select="preceding-sibling::*[1]" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="ancestor::*/preceding-sibling::*">
                <xsl:call-template name="copy-bookmarks-preceding-paragraph">
                    <xsl:with-param name="node" select="ancestor::*[preceding-sibling::*][1]/preceding-sibling::*[1]" />
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        <xsl:apply-templates mode="fix-odf-structure" />
    </xsl:copy>
</xsl:template>

<!-- If the given element is a <text:bookmark>, it copies itself. Template calls itself recursively
for directly preceding element if it is not a <text:p> and if some other conditions are met... -->
<xsl:template name="copy-bookmarks-preceding-paragraph">
    <xsl:param name="node" /><!-- element -->
    <xsl:choose>
        <xsl:when test="$node/self::text:bookmark">
            <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Copying &lt;text:bookmark&gt; into the nearest following paragraph; id = '<xsl:value-of select="$node/@text:name" />'</xsl:with-param></xsl:call-template>
            <xsl:copy-of select="$node" />
        </xsl:when>
        <xsl:when test="$node/descendant::text:bookmark and not($node/descendant::text:p)">
            <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Copying all &lt;text:bookmark&gt;-s in <xsl:value-of select="name($node)" /> into the nearest following paragraph</xsl:with-param></xsl:call-template>
            <xsl:copy-of select="$node/descendant::text:bookmark" />
        </xsl:when>
    </xsl:choose>
    <xsl:if test="not($node/descendant::text:p)">
        <xsl:choose>
            <xsl:when test="$node/preceding-sibling::*[1][not(self::text:p)]">
                <xsl:call-template name="copy-bookmarks-preceding-paragraph">
                    <xsl:with-param name="node" select="$node/preceding-sibling::*[1]" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not($node/preceding-sibling::*) and $node/ancestor::*/preceding-sibling::*">
                <xsl:call-template name="copy-bookmarks-preceding-paragraph">
                    <xsl:with-param name="node" select="$node/ancestor::*[preceding-sibling::*][1]/preceding-sibling::*[1]" />
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- If the given element is a <draw:frame>, it copies itself. Template calls itself recursively
for directly preceding element if it is not a <text:p> and if some other conditions are met... -->
<xsl:template name="copy-floats-preceding-paragraph">
    <xsl:param name="node" /><!-- element -->
    <xsl:choose>
        <xsl:when test="$node/self::draw:frame[@text:anchor-type='paragraph']">
            <xsl:call-template name="log:log-debug"><xsl:with-param name="msg">Copying &lt;draw:frame&gt; into the nearest following paragraph</xsl:with-param></xsl:call-template>
            <xsl:copy-of select="$node" />
        </xsl:when>
    </xsl:choose>
    <xsl:if test="not($node/descendant::text:p)">
        <xsl:choose>
            <xsl:when test="$node/preceding-sibling::*[1][not(self::text:p)]">
                <xsl:call-template name="copy-floats-preceding-paragraph">
                    <xsl:with-param name="node" select="$node/preceding-sibling::*[1]" />
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>