<?xml version="1.0"?>

<!-- Generates the "manifest" of a document. -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes=""
    xmlns:foIn="http://www.w3.org/1999/XSL/Format">

<xsl:template name="document-manifest">
	<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">
		<manifest:file-entry manifest:full-path="/" manifest:media-type="application/vnd.oasis.opendocument.text" />
		<manifest:file-entry manifest:full-path="meta.xml" manifest:media-type="text/xml" />
		<manifest:file-entry manifest:full-path="settings.xml" manifest:media-type="text/xml" />
		<manifest:file-entry manifest:full-path="styles.xml" manifest:media-type="text/xml" />
		<manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml" />
	</manifest:manifest>
</xsl:template>

</xsl:stylesheet>