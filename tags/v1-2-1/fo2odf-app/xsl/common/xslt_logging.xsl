<?xml version="1.0"?>

<!--
A simple logging framework for XSLT stylesheets. F.e. it doesn't support setting logging
level "per package" or various "logging appenders" (unlike f.e. Log4J).

An "xsl:message" is created for each message whose level is equal to or higher than the current global
"global-log-level" parameter.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:log="http://example.com/logging"
    exclude-result-prefixes="log">

<!-- Supported values (from "lowest" to "highest"): trace, debug, info, warn, error, off. If a given
level is set, the level and all higher levels are considered to be "active". Only messages 
with the active levels will be logged. Level 'off' is used to suppress all messages. -->
<!-- TODO I don't know how to pass parameter with a namespace to xsltproc so until it is solved, 'log:level' is renamed to 'global-log-level' -->
<xsl:param name="global-log-level" select="'info'" />

<!-- Simply calls 'log:log' template with the passed parameters and 
'level' parameter set to 'debug'. -->
<xsl:template name="log:log-debug">
    <xsl:param name="msg" select="''" /><!-- string -->
    <xsl:param name="node" select="." /><!-- node -->
    <xsl:call-template name="log:log">
        <xsl:with-param name="level" select="'debug'" />
        <xsl:with-param name="msg" select="$msg" />
        <xsl:with-param name="node" select="$node" />
    </xsl:call-template>
</xsl:template>

<!-- Simply calls 'log:log' template with the passed parameters and 
'level' parameter set to 'info'. -->
<xsl:template name="log:log-info">
    <xsl:param name="msg" select="''" /><!-- string -->
    <xsl:param name="node" select="." /><!-- node -->
    <xsl:call-template name="log:log">
        <xsl:with-param name="level" select="'info'" />
        <xsl:with-param name="msg" select="$msg" />
        <xsl:with-param name="node" select="$node" />
    </xsl:call-template>
</xsl:template>

<!-- Simply calls 'log:log' template with the passed parameters and 
'level' parameter set to 'warn'. -->
<xsl:template name="log:log-warn">
    <xsl:param name="msg" select="''" /><!-- string -->
    <xsl:param name="node" select="." /><!-- node -->
    <xsl:call-template name="log:log">
        <xsl:with-param name="level" select="'warn'" />
        <xsl:with-param name="msg" select="$msg" />
        <xsl:with-param name="node" select="$node" />
    </xsl:call-template>
</xsl:template>

<!-- Simply calls 'log:log' template with the passed parameters and 
'level' parameter set to 'error'. -->
<xsl:template name="log:log-error">
    <xsl:param name="msg" select="''" /><!-- string -->
    <xsl:param name="node" select="." /><!-- node -->
    <xsl:call-template name="log:log">
        <xsl:with-param name="level" select="'error'" />
        <xsl:with-param name="msg" select="$msg" />
        <xsl:with-param name="node" select="$node" />
    </xsl:call-template>
</xsl:template>

<!-- Simply calls 'log:log' template with the passed parameters and 
'level' parameter set to 'trace'. -->
<xsl:template name="log:log-trace">
    <xsl:param name="msg" select="''" /><!-- string -->
    <xsl:param name="node" select="." /><!-- node -->
    <xsl:call-template name="log:log">
        <xsl:with-param name="level" select="'trace'" />
        <xsl:with-param name="msg" select="$msg" />
        <xsl:with-param name="node" select="$node" />
    </xsl:call-template>
</xsl:template>

<!-- The main logging method. Makes a 'xsl:message' from the given $msg
if the given $level is equal or "higher" than the $global-log-level global parameter.
"More comfortable" templates like f.e. 'log:log-debug' should be used instead
of using this template directly.
TODO Parameter $node is ignored for now. -->
<xsl:template name="log:log">
    <xsl:param name="level" select="''" /><!-- string -->
    <xsl:param name="msg" select="''" /><!-- string -->
    <xsl:param name="node" select="." /><!-- node -->
    
    <xsl:variable name="is-level-active">
        <xsl:call-template name="log:_is-level-active">
            <xsl:with-param name="level" select="$level" />
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:if test="$is-level-active = 'true'">
        <xsl:message>
            <xsl:call-template name="log:_get-message-prefix">
                <xsl:with-param name="level" select="$level" />
            </xsl:call-template>
            <xsl:value-of select="$msg" />
            <xsl:call-template name="log:_get-message-suffix">
                <xsl:with-param name="level" select="$level" />
            </xsl:call-template>
        </xsl:message>
    </xsl:if>
</xsl:template>

<!-- Returns whether a given level is active by comparing it to the global
$global-log-level parameter. -->
<xsl:template name="log:_is-level-active">
    <xsl:param name="level" select="''" />
    <xsl:variable name="level-number">
        <xsl:call-template name="log:_get-level-number">
            <xsl:with-param name="level" select="$level" />
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="global-level-number">
        <xsl:call-template name="log:_get-level-number">
            <xsl:with-param name="level" select="$global-log-level" />
        </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$level-number != -1 and $global-level-number != -1">
            <xsl:value-of select="$level-number >= $global-level-number" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:message>LOGGING ERROR: Unknown level of debugging: message level = '<xsl:value-of select="$level" />', global level = '<xsl:value-of select="$global-log-level" />'</xsl:message>
            <xsl:value-of select="false()" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Returns number representing a given named level. Higher levels have higher level number.
Returns -1 if the given level is not defined. -->
<xsl:template name="log:_get-level-number">
    <xsl:param name="level" select="''" /><!-- string -->
    <xsl:choose>
        <xsl:when test="$level = 'trace'">0</xsl:when>
        <xsl:when test="$level = 'debug'">10</xsl:when>
        <xsl:when test="$level = 'info'">20</xsl:when>
        <xsl:when test="$level = 'warn'">30</xsl:when>
        <xsl:when test="$level = 'error'">40</xsl:when>
        <xsl:when test="$level = 'off'">1000000</xsl:when>
        <xsl:otherwise>-1</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Returns message prefix for a given level. -->
<xsl:template name="log:_get-message-prefix">
    <xsl:param name="level" select="''" /><!-- string -->
    <xsl:choose>
        <xsl:when test="$level = 'trace'">TRACE: </xsl:when>
        <xsl:when test="$level = 'debug'">DEBUG: </xsl:when>
        <xsl:when test="$level = 'info'">INFO: </xsl:when>
        <xsl:when test="$level = 'warn'">WARNING: </xsl:when>
        <xsl:when test="$level = 'error'">ERROR: </xsl:when>
    </xsl:choose>
</xsl:template>

<!-- Returns message suffix for a given level. -->
<xsl:template name="log:_get-message-suffix">
    <xsl:param name="level" select="''" /><!-- string -->
    <xsl:choose>
        <xsl:when test="$level = 'trace'"></xsl:when>
        <xsl:when test="$level = 'debug'"></xsl:when>
        <xsl:when test="$level = 'info'"></xsl:when>
        <xsl:when test="$level = 'warn'"></xsl:when>
        <xsl:when test="$level = 'error'"></xsl:when>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>