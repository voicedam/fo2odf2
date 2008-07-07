<?xml version="1.0"?>

<!-- Common functions for working with strings. -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:str="http://exslt.org/strings"
    xmlns:str2="http://exslt.org/strings2"
    xmlns:my="http://example.com/muj"
    extension-element-prefixes="exsl func str"
    exclude-result-prefixes="exsl func str str2 my">
<!-- Note: Because of Xalan EXSLT functions defined here are defined in another namespace ("str2"). Otherwise it didn't work. -->

<!-- Returns whether a string ("haystack") ends with another string ("needle"). -->
<func:function name="my:ends-with">
    <xsl:param name="haystack" select="''" />
    <xsl:param name="needle" select="''" />
    <xsl:choose>
        <xsl:when test="string-length($haystack) >= string-length($needle)">
            <func:result select="substring($haystack, string-length($haystack) - string-length($needle) + 1) = $needle" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="false()" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Returns character at a given position in a given string.
Examples:
my:char-at('abcde', 4) returns 'd'
-->
<func:function name="my:char-at">
    <xsl:param name="in" />
    <xsl:param name="at" />
    <func:result select="substring($in, $at, 1)" />
</func:function>

<!-- Returns position of a string in another string.
Examples:
my:index-of('abcdea', 'ab') returns 1
my:index-of('abcdea', 'ad') returns -1
my:index-of('abcdea', 'a', 2) returns 6
my:index-of('abcdea', '') returns -1
-->
<func:function name="my:index-of">
    <xsl:param name="in" />
    <xsl:param name="what" />
    <xsl:param name="from" select="1" />
    <xsl:variable name="searched-part" select="concat('_', substring($in, $from))" />
    <xsl:variable name="substring-before" select="substring-before($searched-part, $what)" />
    <xsl:choose>
        <xsl:when test="$substring-before = ''">
            <func:result select="'-1'" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="string-length($substring-before) + ($from - 1)" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Returns last position of a string in another string.
Examples:
my:index-of('abcdea', 'a') returns 6
my:index-of('aaabcd', 'aa') returns 2
my:index-of('abcdea', 'f') returns 0
-->
<func:function name="my:last-index-of">
    <xsl:param name="in" /><!-- string -->
    <xsl:param name="what" /><!-- string -->
    <xsl:param name="_last-known-index" select="'0'" /><!-- number (private) -->
    <xsl:variable name="index" select="my:index-of($in, $what)" />
    <xsl:choose>
        <xsl:when test="$index &lt; 1">
            <func:result select="$_last-known-index" />
        </xsl:when>
        <xsl:otherwise>
            <func:result select="my:last-index-of(substring($in, $index + 1), $what, $_last-known-index + $index)" />
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!-- Returns whether a given character is a numeric character, i.e. whether it is '0', '1', .., '9' or '.'. -->
<func:function name="my:is-numeric-char">
    <xsl:param name="c" select="." /><!-- char -->
    <func:result select="$c = '.' or $c = '1' or $c = '2' or $c = '3' or $c = '4' or $c = '5' or $c = '6' or $c = '7' or $c = '8' or $c = '9' or $c = '0'" />
</func:function>

<!--
Returns text representation of the given nodes. Attributes of each element are sorted by name.

Example:
- input (symbolically): <element atrib="value">text<empty /></element>
- result (textually): <element atrib="value">text<empty /></element>
-->
<func:function name="my:nodes-to-string">
    <xsl:param name="nodes" select="." /><!-- node set -->
    <xsl:variable name="rtf-result">
        <xsl:apply-templates select="$nodes" mode="_nodes-to-string" />
    </xsl:variable>
    <func:result select="string($rtf-result)" />
</func:function>

<xsl:template match="*" mode="_nodes-to-string">
    <xsl:variable name="is-empty" select="not(*) and . = ''" />
    
    <!-- Output opening tag (for empty element this becomes the closing tag as well) -->
    <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name(.)" />
        <xsl:for-each select="@*">
            <xsl:sort select="name(.)" />
            <xsl:apply-templates select="." mode="_nodes-to-string" />
        </xsl:for-each>
    <xsl:if test="$is-empty"> /</xsl:if>    
    <xsl:text>&gt;</xsl:text>
    
    <!-- Process children of an non-empty element and output closing tag -->
    <xsl:if test="not($is-empty)">
        <xsl:apply-templates mode="_nodes-to-string" />
        
        <xsl:text>&lt;/</xsl:text>
            <xsl:value-of select="name(.)" />
        <xsl:text>&gt;</xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="@*" mode="_nodes-to-string">
    <xsl:value-of select="concat(' ', name(.), '=&quot;', ., '&quot;')" />
</xsl:template>

<func:function name="my:simple-replace">
    <xsl:param name="str" /><!-- string -->
    <xsl:param name="search" select="/.." />
    <xsl:param name="replace" select="/.." />
    
    <xsl:choose>
        <xsl:when test="string-length($str) = 0">
            <func:result select="''" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="contains($str, $search)">
                    <func:result select="concat(
                        substring-before($str, $search),
                        $replace,
                        my:simple-replace(substring-after($str, $search), $search, $replace))" />
                </xsl:when>
                <xsl:otherwise>
                    <func:result select="$str" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</func:function>

<!--
Returns content of an URL string.

Examples:
- my:get-url-content("url('file.txt')") returns 'file.txt'
- my:get-url-content("url(file.txt)") returns 'file.txt'
- my:get-url-content("file.txt") returns 'file.txt'
 -->
<func:function name="my:get-url-content">
    <xsl:param name="url" />
    <xsl:variable name="apos">'</xsl:variable>
    <func:result>
        <xsl:choose>
            <xsl:when test="starts-with($url, 'url(')">
                <xsl:variable name="in-url" select="substring-before(substring-after($url, 'url('), ')')" />
                <xsl:choose>
                    <xsl:when test="starts-with($in-url, $apos)">
                        <xsl:value-of select="substring-before(substring-after($in-url, $apos), $apos)" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$in-url" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><!-- expect URL specified directly -->
                <xsl:value-of select="$url" />
            </xsl:otherwise>
        </xsl:choose>
    </func:result>
</func:function>

<!-- (Missing in Xalan, available in xsltproc.)
Some fixes in the original implementation where necessary in order to this function worked properly. -->
<func:function name="str2:replace">
    <xsl:param name="string" select="''" />
   <xsl:param name="search" select="/.." />
   <xsl:param name="replace" select="/.." />
   <xsl:choose>
      <xsl:when test="not($string)">
        <func:result select="/.." />
      </xsl:when>

      <xsl:when test="true()"><!-- original condition "function-available('exsl:node-set')" returns false in Xalan :( -->
         <!-- this converts the search and replace arguments to node sets
              if they are one of the other XPath types -->
         <xsl:variable name="search-nodes-rtf">
           <xsl:copy-of select="$search" />
         </xsl:variable>
         <xsl:variable name="replace-nodes-rtf">
           <xsl:copy-of select="$replace" />
         </xsl:variable>
         <xsl:variable name="replacements-rtf">

            <xsl:for-each select="exsl:node-set($search-nodes-rtf)/node()">
               <xsl:variable name="pos" select="position()" />
               <replace search="{.}">
                  <xsl:copy-of select="exsl:node-set($replace-nodes-rtf)/node()[$pos]" />
               </replace>
            </xsl:for-each>
         </xsl:variable>
         <xsl:variable name="sorted-replacements-rtf">
            <xsl:for-each select="exsl:node-set($replacements-rtf)/replace">

               <xsl:sort select="string-length(@search)" data-type="number" order="descending" />
               <xsl:copy-of select="." />
            </xsl:for-each>
         </xsl:variable>
         <xsl:variable name="result">
           <xsl:choose>
              <xsl:when test="not($search)">
                <xsl:value-of select="$string" />
              </xsl:when>

             <xsl:otherwise>
               <xsl:call-template name="str2:_replace">
                  <xsl:with-param name="string" select="$string" />
                  <xsl:with-param name="replacements" select="exsl:node-set($sorted-replacements-rtf)/replace" />
               </xsl:call-template>
             </xsl:otherwise>
           </xsl:choose>
         </xsl:variable>
         <func:result select="string($result)" /><!-- originally: "exsl:node-set($result)/node()" was not working... -->

      </xsl:when>
      <xsl:otherwise>
         <xsl:message terminate="yes">
            FATAL: function implementation of str2:replace() relies on exsl:node-set().
         </xsl:message>
      </xsl:otherwise>
   </xsl:choose>
</func:function>

<xsl:template name="str2:_replace">
  <xsl:param name="string" select="''" />

  <xsl:param name="replacements" select="/.." />
  <xsl:choose>
    <xsl:when test="not($string)" />
    <xsl:when test="not($replacements)">
      <xsl:value-of select="$string" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="replacement" select="$replacements[1]" />
      <xsl:variable name="search" select="$replacement/@search" />

      <xsl:choose>
        <xsl:when test="not(string($search))">
          <xsl:value-of select="substring($string, 1, 1)" />
          <xsl:copy-of select="$replacement/node()" />
          <xsl:call-template name="str2:_replace">
            <xsl:with-param name="string" select="substring($string, 2)" />
            <xsl:with-param name="replacements" select="$replacements" />
          </xsl:call-template>
        </xsl:when>

        <xsl:when test="contains($string, $search)">
          <xsl:call-template name="str2:_replace">
            <xsl:with-param name="string" select="substring-before($string, $search)" />
            <xsl:with-param name="replacements" select="$replacements[position() > 1]" />
          </xsl:call-template>      
          <xsl:copy-of select="$replacement/node()" />
          <xsl:call-template name="str2:_replace">
            <xsl:with-param name="string" select="substring-after($string, $search)" />
            <xsl:with-param name="replacements" select="$replacements" />

          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="str2:_replace">
            <xsl:with-param name="string" select="$string" />
            <xsl:with-param name="replacements" select="$replacements[position() > 1]" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- (Xalan implementation of str:tokenize caused OutOfMemory exceptions.) -->
<func:function name="str2:tokenize">
    <xsl:param name="string" select="''" />
  <xsl:param name="delimiters" select="' &#x9;&#xA;'" />
  <xsl:choose>
    <xsl:when test="not($string)">
      <func:result select="/.." />
    </xsl:when>
    <xsl:when test="false()"><!-- original condition "function-available('exsl:node-set')" returns false in Xalan :( -->
      <xsl:message terminate="yes">
        ERROR: EXSLT - Functions implementation of str2:tokenize relies on exsl:node-set().
      </xsl:message>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="tokens">
        <xsl:choose>
          <xsl:when test="not($delimiters)">
            <xsl:call-template name="str:_tokenize-characters">
              <xsl:with-param name="string" select="$string" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="str:_tokenize-delimiters">
              <xsl:with-param name="string" select="$string" />
              <xsl:with-param name="delimiters" select="$delimiters" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <func:result select="exsl:node-set($tokens)/token" />
    </xsl:otherwise>
  </xsl:choose>
</func:function>

<xsl:template name="str:_tokenize-characters">
  <xsl:param name="string" />
  <xsl:if test="$string">
    <token><xsl:value-of select="substring($string, 1, 1)" /></token>
    <xsl:call-template name="str:_tokenize-characters">
      <xsl:with-param name="string" select="substring($string, 2)" />
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="str:_tokenize-delimiters">
  <xsl:param name="string" />
  <xsl:param name="delimiters" />
  <xsl:variable name="delimiter" select="substring($delimiters, 1, 1)" />
  <xsl:choose>
    <xsl:when test="not($delimiter)">
      <token><xsl:value-of select="$string" /></token>
    </xsl:when>
    <xsl:when test="contains($string, $delimiter)">
      <xsl:if test="not(starts-with($string, $delimiter))">
        <xsl:call-template name="str:_tokenize-delimiters">
          <xsl:with-param name="string" select="substring-before($string, $delimiter)" />
          <xsl:with-param name="delimiters" select="substring($delimiters, 2)" />
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="str:_tokenize-delimiters">
        <xsl:with-param name="string" select="substring-after($string, $delimiter)" />
        <xsl:with-param name="delimiters" select="$delimiters" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="str:_tokenize-delimiters">
        <xsl:with-param name="string" select="$string" />
        <xsl:with-param name="delimiters" select="substring($delimiters, 2)" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>