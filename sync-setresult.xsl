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

<html>
	<xsl:call-template name="std-head">
		<xsl:with-param name="title" select="$strings/ld:str[@id='result-title']"/>
	</xsl:call-template>
	
	<body>
		<xsl:call-template name="std-banner">
			<xsl:with-param name="product" select="$strings/ld:str[@id='product']"/>
		</xsl:call-template>
		
		<xsl:variable name="err-code" select="sync-response/result/code"/>
		<xsl:choose>
			<xsl:when test="$err-code='0x00000000'">
				<xsl:call-template name="std-message">
					<xsl:with-param name="icon" select="'sync-not-needed.gif'"/>
					<xsl:with-param name="caption" select="$strings/ld:str[@id='success']"/>
					<xsl:with-param name="text">
						<xsl:copy-of select="$strings/ld:str[@id='success-instructions']"/>
						<br/><br/><input class="button" type="button" value="{$strings/ld:str[@id='ok']}" onclick="var cg = (referrer != '') ? referrer.substring(0, referrer.indexOf('?')) : ''; window.location = cg + '?f=templates$fn=default.htm$isclient=true'"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="std-error-message">
					<xsl:with-param name="icon" select="'sync-error.gif'"/>
					<xsl:with-param name="caption" select="$strings/ld:str[@id='error']"/>
					<xsl:with-param name="text" select="$strings/ld:str[@id='error-instructions']"/>
					<xsl:with-param name="err-code" select="sync-response/result/code"/>
					<xsl:with-param name="retry-script">if (referrer != "") { var cg = referrer.substring(0, referrer.indexOf("?")); cg += "?f=sync$sync_c=getstate$sync_xsl=sync-getstate.xsl"; window.location = cg; }</xsl:with-param>
					<xsl:with-param name="strings" select="$strings"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</body>
</html>

</xsl:template>


</xsl:stylesheet>
