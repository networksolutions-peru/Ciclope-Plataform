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

	<xsl:call-template name="std-html-redirect">
		<xsl:with-param name="title" select="$strings/ld:str[@id='apply-title']"/>
		<xsl:with-param name="product" select="$strings/ld:str[@id='product']"/>
		<xsl:with-param name="icon" select="'sync-anim.gif'"/>
		<xsl:with-param name="caption" select="$strings/ld:str[@id='applying']"/>
		<xsl:with-param name="text" select="$strings/ld:str[@id='wait-apply']"/>
		<xsl:with-param name="form">
			<input type="hidden" name="f" value="sync"/>
			<input type="hidden" name="sync_c" value="applysync"/>
			<input type="hidden" name="sync_xsl" value="sync-apply.xsl"/>
			<input type="hidden" name="sync_sarpath" value="{sync-response/sync_sarpath}"/>
		</xsl:with-param>
	</xsl:call-template>

</xsl:template>


</xsl:stylesheet>
