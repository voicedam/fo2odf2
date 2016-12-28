<?xml version="1.0"?>

<!--
Concatenates all sample FO documents to one single FO file. No input document is needed.
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
    extension-element-prefixes="exsl func"
	exclude-result-prefixes="exsl func my log"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match="/">
<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions">
    <fo:layout-master-set>
        <fo:simple-page-master margin-bottom="1.5cm" margin-left="1.5cm" margin-right="1.5cm"
            margin-top="1.5cm" master-name="all-pages" page-height="29.7cm" page-width="21cm">
            <fo:region-body border-style="solid" border-width="1pt" margin-bottom="0.5cm" margin-top="0.5cm"
                padding="7.5pt" />
    
            <fo:region-before display-align="before" extent="0.5cm" />
    
            <fo:region-after display-align="after" extent="0.5cm" />
        </fo:simple-page-master>
    </fo:layout-master-set>
    
    <xsl:copy-of select="document('font-attributes.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('font-size.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('paragraph-attributes.fo')/fo:root/fo:page-sequence" />
    
    <xsl:copy-of select="document('fo_expressions.fo')/fo:root/fo:page-sequence" />
    
    <xsl:copy-of select="document('embeding_and_inheritance.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('leaders.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('lists.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('tables.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('tables-headers_and_footers.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('images.fo')/fo:root/fo:page-sequence" />
    
    <xsl:copy-of select="document('footnotes.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('floats.fo')/fo:root/fo:page-sequence" />
    
    <xsl:copy-of select="document('borders.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('margins.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('paddings.fo')/fo:root/fo:page-sequence" />
    
    <xsl:copy-of select="document('keeps_and_breaks.fo')/fo:root/fo:page-sequence" />
    <xsl:copy-of select="document('page-numbers_and_links.fo')/fo:root/fo:page-sequence" />
    
    <xsl:copy-of select="document('white-space.fo')/fo:root/fo:page-sequence" />
</fo:root>
</xsl:template>

</xsl:stylesheet>