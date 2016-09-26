<?xml version="1.0"?>

<!-- 
This style sheet only appears in error cases. When the "getsync" works,
a SAR file is the response.
-->	

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ld="http://www.dotsa.com.ar"
	exclude-result-prefixes="ld">
	
<xsl:output encoding="UTF-8" method="html"/>

<!-- Locale specific strings are included from sync-strings.xml --> 
<!-- #EXECUTIVE:INCLUDE:sync-strings.xml -->
<xsl:variable name="strings" select="document('')/xsl:stylesheet/ld:locale-data"/>

<!-- #EXECUTIVE:INCLUDE:sync-std.xsl -->
<!-- #EXECUTIVE:INCLUDE:sync-date-time.xsl -->


<xsl:template match="/">

	<xsl:call-template name="std-html-error">
		<xsl:with-param name="title" select="$strings/ld:str[@id='get-title']"/>
		<xsl:with-param name="product" select="$strings/ld:str[@id='product']"/>
		<xsl:with-param name="icon" select="'sync-error.gif'"/>
		<xsl:with-param name="caption" select="$strings/ld:str[@id='error']"/>
		<xsl:with-param name="text" select="$strings/ld:str[@id='error-instructions']"/>
		<xsl:with-param name="err-code" select="sync-response/@status"/>
		<xsl:with-param name="strings" select="$strings"/>
	</xsl:call-template>

</xsl:template>


</xsl:stylesheet>
