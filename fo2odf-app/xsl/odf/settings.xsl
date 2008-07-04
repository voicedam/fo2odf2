<?xml version="1.0"?>

<!-- Generates the "settings" part of a document. -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes=""
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format">

<xsl:template name="document-settings-part">
	<!-- office:document-settings xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0" xmlns:ooo="http://openoffice.org/2004/office" office:version="1.0" -->
		<office:settings>
			<!--
			<config:config-item-set config:name="ooo:view-settings">			
				<config:config-item config:name="ViewAreaTop" config:type="int">0</config:config-item>
			</config:config-item-set>
			<config:config-item-set config:name="ooo:configuration-settings">
				<config:config-item config:name="AddParaTableSpacing" config:type="boolean">true</config:config-item>
			</config:config-item-set>
			-->
		</office:settings>
	<!-- /office:document-settings -->
</xsl:template>

</xsl:stylesheet>