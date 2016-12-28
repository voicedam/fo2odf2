<!-- Stylesheet for importing/exporting an ODF document from/to 1 simple ("flat") XML file. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- xsl:strip-space elements="*" /--><!-- This would cause problems at elements where white space is important. -->
    <xsl:template match="/">
        <xsl:copy-of select="." />
    </xsl:template>
    <xsl:output method="xml" indent="no" /><!-- Setting indent to "yes" would "create" new white space characters. -->
</xsl:stylesheet>