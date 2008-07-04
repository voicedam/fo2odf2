<?xml version="1.0"?>

<!--
Templates for converting FO "image" elements to corresponding ODF elements.
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:my="http://example.com/muj"
    xmlns:log="http://example.com/logging"
    xmlns:php="http://php.net/xsl"
    xmlns:myjavautils="MyJavaUtils"
	exclude-result-prefixes="exsl func my log php myjavautils"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
    xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    xmlns:foIn="http://www.w3.org/1999/XSL/Format">

<!-- Converts <fo:external-graphic> to ODF elements. -->
<xsl:template match="foIn:external-graphic" mode="phase1">
    <xsl:variable name="style-name" select="my:get-unique-style-name(., 'graphic')" />
    
    <xsl:variable name="src-path" select="my:get-url-content(string(@src))" />
    <xsl:variable name="image-info" select="my:get-image-info($src-path)" />
    
    <xsl:variable name="rtf-image-props">
    <xsl:choose>
        <xsl:when test="starts-with($image-info, 'Error: ')">
            <!-- File not found or some other error -->
            <xsl:call-template name="log:log-error"><xsl:with-param name="msg">Error while getting info about image file: <xsl:value-of select="substring-after($image-info, 'Error: ')" /></xsl:with-param></xsl:call-template>
            <base64data>-1</base64data>
            <xsl:variable name="fallback-width">
                <xsl:choose>
                    <xsl:when test="my:ends-with(@width, 'pt')"><xsl:value-of select="my:get-number-length(@width)" /></xsl:when>
                    <xsl:when test="my:ends-with(@content-width, 'pt')"><xsl:value-of select="my:get-number-length(@content-width)" /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$default-width-for-corrupt-images" /></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="fallback-height">
                <xsl:choose>
                    <xsl:when test="my:ends-with(@height, 'pt')"><xsl:value-of select="my:get-number-length(@height)" /></xsl:when>
                    <xsl:when test="my:ends-with(@content-height, 'pt')"><xsl:value-of select="my:get-number-length(@content-height)" /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$default-height-for-corrupt-images" /></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <content-width><xsl:value-of select="$fallback-width" /></content-width>
            <content-height><xsl:value-of select="$fallback-height" /></content-height>
            <area-width><xsl:value-of select="$fallback-width" /></area-width>
            <area-height><xsl:value-of select="$fallback-height" /></area-height>
        </xsl:when>
        <xsl:otherwise>
            <!-- File was found and it is a supported image -->
            
            <!-- Find out image size -->
            <xsl:variable name="intrinsic-width" select="my:get-info-item($image-info, 'width')" />
            <xsl:variable name="intrinsic-height" select="my:get-info-item($image-info, 'height')" />
            
            <!-- Obtain image data in BASE64 encoding (ODF request) -->
            <xsl:variable name="base64data" select="my:get-file-in-base64($src-path)" />
            <xsl:choose>
                <xsl:when test="starts-with($base64data, 'Error: ')">
                    <xsl:call-template name="log:log-error"><xsl:with-param name="msg">Error while reading contents of image file: <xsl:value-of select="substring-after($base64data, 'Error: ')" /></xsl:with-param></xsl:call-template>
                    <base64data>-1</base64data>
                </xsl:when>
                <xsl:otherwise>
                    <base64data><xsl:value-of select="$base64data" /></base64data>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Compute effective image width and height -->
            <xsl:variable name="content-width-step1">
                <xsl:choose>
                    <xsl:when test="@content-width = 'auto' or (@content-width = 'scale-to-fit' and not(my:ends-with(@width, 'pt')))">
                        <xsl:value-of select="$intrinsic-width" />
                    </xsl:when>
                    <xsl:when test="@content-width = 'scale-to-fit'"><!-- and my:ends-with(@width, 'pt') -->
                        <xsl:value-of select="my:get-number-length(@width)" />
                    </xsl:when>
                    <xsl:when test="my:ends-with(@content-width, '%')">
                        <xsl:value-of select="substring-before(@content-width, '%') div 100 * $intrinsic-width" />
                    </xsl:when>
                    <xsl:otherwise><!-- absolute length was specified -->
                        <xsl:value-of select="my:get-number-length(@content-width)" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="content-height-step1">
                <xsl:choose>
                    <xsl:when test="@content-height = 'auto' or (@content-height = 'scale-to-fit' and not(my:ends-with(@height, 'pt')))">
                        <xsl:value-of select="$intrinsic-height" />
                    </xsl:when>
                    <xsl:when test="@content-height = 'scale-to-fit'"><!-- and my:ends-with(@height, 'pt') -->
                        <xsl:value-of select="my:get-number-length(@height)" />
                    </xsl:when>
                    <xsl:when test="my:ends-with(@content-height, '%')">
                        <xsl:value-of select="substring-before(@content-height, '%') div 100 * $intrinsic-height" />
                    </xsl:when>
                    <xsl:otherwise><!-- absolute length was specified -->
                        <xsl:value-of select="my:get-number-length(@content-height)" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="content-width">
                <xsl:choose>
                    <xsl:when test="(@content-width = 'auto' and @content-height != 'auto')
                            or (@content-width = 'scale-to-fit' and @width = 'auto' and @height != 'auto')">
                        <xsl:value-of select="($content-height-step1 div $intrinsic-height) * $intrinsic-width" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$content-width-step1" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="content-height">
                <xsl:choose>
                    <xsl:when test="(@content-height = 'auto' and @content-width != 'auto')
                            or (@content-height = 'scale-to-fit' and @height = 'auto' and @width != 'auto')">
                        <xsl:value-of select="($content-width-step1 div $intrinsic-width) * $intrinsic-height" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$content-height-step1" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="area-width">
                <xsl:choose>
                    <xsl:when test="my:ends-with(@width, 'pt')"><xsl:value-of select="my:get-number-length(@width)" /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$content-width" /></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="area-height">
                <xsl:choose>
                    <xsl:when test="my:ends-with(@height, 'pt')"><xsl:value-of select="my:get-number-length(@height)" /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$content-height" /></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <content-width><xsl:value-of select="$content-width" /></content-width>
            <content-height><xsl:value-of select="$content-height" /></content-height>
            <area-width><xsl:value-of select="$area-width" /></area-width>
            <area-height><xsl:value-of select="$area-height" /></area-height>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:variable>

    <xsl:variable name="image-props" select="exsl:node-set($rtf-image-props)" />
    
    <!-- Compute ODF attributes from the computed dimensions -->
    
    <xsl:variable name="content-minus-area-width" select="$image-props/content-width - $image-props/area-width" />
    <xsl:variable name="content-minus-area-height" select="$image-props/content-height - $image-props/area-height" />
    
    <xsl:variable name="top-crop">
        <xsl:choose>
            <xsl:when test="@display-align = 'center'"><xsl:value-of select="$content-minus-area-height div 2" /></xsl:when>
            <xsl:when test="@display-align = 'after'"><xsl:value-of select="$content-minus-area-height" /></xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bottom-crop">
        <xsl:choose>
            <xsl:when test="@display-align = 'center'"><xsl:value-of select="$content-minus-area-height div 2" /></xsl:when>
            <xsl:when test="@display-align = 'after'">0</xsl:when>
            <xsl:otherwise><xsl:value-of select="$content-minus-area-height" /></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="left-crop">
        <xsl:choose>
            <xsl:when test="@text-align = 'center'"><xsl:value-of select="$content-minus-area-width div 2" /></xsl:when>
            <xsl:when test="@text-align = 'right' or @text-align = 'end'"><xsl:value-of select="$content-minus-area-width" /></xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="right-crop">
        <xsl:choose>
            <xsl:when test="@text-align = 'center'"><xsl:value-of select="$content-minus-area-width div 2" /></xsl:when>
            <xsl:when test="@text-align = 'right' or @text-align = 'end'">0</xsl:when>
            <xsl:otherwise><xsl:value-of select="$content-minus-area-width" /></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- example value: 'rect(0pt 0pt 0pt 0pt)' -->
    <xsl:variable name="odf-clip-value" select="concat('rect(', $top-crop, 'pt ', $right-crop, 'pt ', $bottom-crop, 'pt ', $left-crop, 'pt)')" />
    
    <xsl:variable name="odf-width" select="$image-props/area-width
            + my:get-number-length(@padding-left) + my:get-number-length(@padding-right)
            + my:get-number-length(@border-left-width) + my:get-number-length(@border-right-width)" />
    <xsl:variable name="odf-height" select="$image-props/area-height
            + my:get-number-length(@padding-top) + my:get-number-length(@padding-bottom)
            + my:get-number-length(@border-top-width) + my:get-number-length(@border-bottom-width)" />
    
    <!-- Generate ODF elements for the image -->
    
    <style:style style:family="graphic" style:name="{$style-name}" style:parent-style-name="Graphics">
        <style:graphic-properties text:anchor-type="as-char" style:vertical-pos="top"
                style:vertical-rel="baseline" fo:clip="{$odf-clip-value}">
            <xsl:apply-templates select="./@*" mode="styles" />
        </style:graphic-properties>
    </style:style>
    
    <xsl:if test="$image-props/base64data != -1 or $display-corrupt-images = 'yes'">
        <draw:frame draw:style-name="{$style-name}" svg:width="{concat($odf-width, 'pt')}" svg:height="{concat($odf-height, 'pt')}">
            <xsl:choose>
                <xsl:when test="$image-props/base64data != -1">
                    <draw:image>
                        <office:binary-data><xsl:value-of select="$image-props/base64data" /></office:binary-data>
                    </draw:image>
                </xsl:when>
                <xsl:otherwise>
                    <draw:image>
                        <office:binary-data></office:binary-data>
                    </draw:image>
                </xsl:otherwise>
            </xsl:choose>
        </draw:frame>
    </xsl:if>
</xsl:template>

<!-- Example: my:get-info-item('width: 10; height: 20;', 'height') returns '20' -->
<func:function name="my:get-info-item">
    <xsl:param name="info" />
    <xsl:param name="item-name" />
    <func:result select="substring-before(substring-after($info, concat($item-name, ': ')), ';')" />
</func:function>

<func:function name="my:get-image-info">
    <xsl:param name="filepath" />
    <xsl:choose>
        <xsl:when test="function-available('php:function')">
            <func:result select="php:function('getImageInfo', $filepath, $pixels-to-points-ratio)" />
        </xsl:when>
        <xsl:when test="function-available('myjavautils:getImageInfo')">
            <func:result select="myjavautils:getImageInfo($filepath, $pixels-to-points-ratio)" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="'Error: PHP nor Java function is available for my:get-image-info()'" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<func:function name="my:get-file-in-base64">
    <xsl:param name="filepath" />
    <xsl:choose>
        <xsl:when test="function-available('php:function')">
            <func:result select="php:function('getFileInBase64', $filepath)" />
        </xsl:when>
        <xsl:when test="function-available('myjavautils:getFileInBase64')">
            <func:result select="myjavautils:getFileInBase64($filepath)" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="'Error: PHP nor Java function is available for my:get-file-in-base64()'" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

</xsl:stylesheet>