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
		<xsl:with-param name="title" select="$strings/ld:str[@id='log-title']"/>
		<xsl:with-param name="product" select="$strings/ld:str[@id='product']"/>
		<xsl:with-param name="icon" select="'sync-anim.gif'"/>
		<xsl:with-param name="caption" select="$strings/ld:str[@id='logging']"/>
		<xsl:with-param name="text" select="$strings/ld:str[@id='wait-server']"/>
		<xsl:with-param name="form-action" select="sync-response/client-state/gateway-url"/>
		<xsl:with-param name="form">
			<input type="hidden" name="f" value="sync"/>
			<input type="hidden" name="sync_c" value="setresult"/>
			<input type="hidden" name="sync_xsl" value="sync-setresult.xsl"/>
			<input type="hidden" name="sync_ver" value="{sync-response/result/version}"/>
			<input type="hidden" name="sync_res" value="{sync-response/result/code}"/>
		</xsl:with-param>
	</xsl:call-template>

</xsl:template>


</xsl:stylesheet>
