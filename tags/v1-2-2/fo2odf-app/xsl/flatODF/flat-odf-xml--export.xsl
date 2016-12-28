<!-- Stylesheet for importing/exporting an ODF document from/to 1 simple ("flat") XML file. -->
<!-- Workaround for OO hanging when using "copy-of" for the whole document on export. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:strip-space elements="*" />
    <xsl:output method="xml" indent="yes" />
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>