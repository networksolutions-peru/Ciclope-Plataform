<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ld="http://www.dotsa.com.ar"
	exclude-result-prefixes="ld">

<xsl:output encoding="UTF-8" method="html"/>


<!-- Locale specific strings are included from sync-strings.xml --> 
<!-- #EXECUTIVE:INCLUDE:sync-strings.xml -->
<xsl:variable name="strings" select="document('')/xsl:stylesheet/ld:locale-data"/>

<!-- #EXECUTIVE:INCLUDE:sync-std.xsl -->


<xsl:template match="/">
<xsl:choose>
	<xsl:when test="sync-response/@status='0x00000000'">
		<xsl:call-template name="std-html-redirect">
			<xsl:with-param name="title" select="$strings/ld:str[@id='avail-title']"/>
			<xsl:with-param name="product" select="$strings/ld:str[@id='product']"/>
			<xsl:with-param name="icon" select="'sync-anim.gif'"/>
			<xsl:with-param name="caption" select="$strings/ld:str[@id='checking']"/>
			<xsl:with-param name="text" select="$strings/ld:str[@id='wait-server']"/>
			<xsl:with-param name="form">
				<input type="hidden" name="f" value="sync"/>
				<input type="hidden" name="sync_c" value="avail"/>
				<input type="hidden" name="sync_xsl" value="sync-avail.xsl"/>
				<input type="hidden" name="sync_ver" value="{sync-response/client-state/version}"/>
				<input type="hidden" name="vid" value="{sync-response/client-state/instance}"/>
			</xsl:with-param>
			<xsl:with-param name="form-action" select="sync-response/client-state/gateway-url"/>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="std-html-error">
			<xsl:with-param name="title" select="$strings/ld:str[@id='avail-title']"/>
			<xsl:with-param name="product" select="$strings/ld:str[@id='product']"/>
			<xsl:with-param name="icon" select="'sync-error.gif'"/>
			<xsl:with-param name="caption" select="$strings/ld:str[@id='error']"/>
			<xsl:with-param name="text" select="$strings/ld:str[@id='error-instructions']"/>
			<xsl:with-param name="err-code" select="sync-response/@status"/>
			<xsl:with-param name="strings" select="$strings"/>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>


</xsl:template>


</xsl:stylesheet>
