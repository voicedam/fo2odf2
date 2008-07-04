<?xml version="1.0"?>

<!-- Generates the "meta" part of a document. TODO The meta information are only hardcoded constants now. -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
	exclude-result-prefixes=""
    xmlns:foIn="http://www.w3.org/1999/XSL/Format">

<xsl:template name="document-meta-part">
	<!-- office:document-meta xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:ooo="http://openoffice.org/2004/office" office:version="1.0" -->
		<office:meta>
			<meta:generator>FO2ODF Converter</meta:generator>
			<dc:title>Title</dc:title>
			<meta:initial-creator>Creator</meta:initial-creator>
			<dc:creator>Updater</dc:creator>
			<!--<meta:creation-date>2007-05-06T13:03:00</meta:creation-date>-->
			<!--<dc:date>2007-05-11T08:58:54</dc:date>-->
			<!--<dc:language>cs-CZ</dc:language>-->
		</office:meta>
	<!-- /office:document-meta -->
</xsl:template>

</xsl:stylesheet>