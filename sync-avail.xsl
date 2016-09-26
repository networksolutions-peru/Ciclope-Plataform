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
<!-- #EXECUTIVE:INCLUDE:sync-date-time.xsl -->


<xsl:template match="/">

<html>

<head>
	<xsl:call-template name="std-head-content">
		<xsl:with-param name="title" select="$strings/ld:str[@id='avail-title']"/>
	</xsl:call-template>
	<script type="text/javascript">
	
		function getSync(client_version)
		{
			// Generate a file name to stick into the URL in a couple of places to help
			// the browser know to download this file and to get the right extension.
			var now = new Date();
			var fname = now.getTime() + ".sar";
			window.location = window.location.pathname + "/" + fname + "?f=sync$sync_c=getsync$sync_xsl=sync-get.xsl$sync_ver=" + escapeURL(client_version) + "$fname=" + fname;
//			window.location.search = "f=sync$sync_c=getsync$sync_xsl=sync-get.xsl$sync_ver=" + escapeURL(client_version) + "$file=x.sar";
		}
	
	</script>
</head>

<body>
	<xsl:call-template name="std-banner">
		<xsl:with-param name="product" select="$strings/ld:str[@id='product']"/>
	</xsl:call-template>

	<form>
		<xsl:choose>
			<xsl:when test="sync-response/archive">
				<xsl:call-template name="std-message">
					<xsl:with-param name="icon" select="'sync-needed.gif'"/>
					<xsl:with-param name="caption" select="$strings/ld:str[@id='avail-yes']"/>
					<xsl:with-param name="text">
						<xsl:copy-of select="$strings/ld:str[@id='avail-yes-instructions']"/><br/><br/>
						<xsl:value-of select="$strings/ld:str[@id='date-label']"/>&#160;
						<xsl:call-template name="render-iso8601-date-time">
							<xsl:with-param name="date-time" select="substring-after(sync-response/archive/version, '@')"/>
							<xsl:with-param name="has-separators" select="'no'"/>
						</xsl:call-template><br/>
						<xsl:value-of select="$strings/ld:str[@id='size-label']"/>&#160;<xsl:value-of select="sync-response/archive/kbytes"/>KB<br/>
						<xsl:value-of select="$strings/ld:str[@id='time-label']"/>&#160; 
						<xsl:call-template name="data-transfer-time">
							<xsl:with-param name="kbytes"><xsl:value-of select="sync-response/archive/kbytes"/></xsl:with-param>
						</xsl:call-template>
						<br/><br/>
						<input class="button" type="button" value="{$strings/ld:str[@id='install']}" onclick="getSync('{sync-response/client-version}'); return false"/> &#160;
						<input class="button" type="button" value="{$strings/ld:str[@id='cancel']}" onclick="var cg = (referrer != '') ? referrer.substring(0, referrer.indexOf('?')) : ''; window.location = cg + '?f=templates$fn=default.htm$isclient=true'"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="std-message">
					<xsl:with-param name="icon" select="'sync-not-needed.gif'"/>
					<xsl:with-param name="caption" select="$strings/ld:str[@id='avail-no']"/>
					<xsl:with-param name="text">
						<xsl:copy-of select="$strings/ld:str[@id='avail-no-instructions']"/>
						<br/><br/><input class="button" type="button" value="{$strings/ld:str[@id='ok']}" onclick="var cg = (referrer != '') ? referrer.substring(0, referrer.indexOf('?')) : ''; window.location = cg + '?f=templates$fn=default.htm$isclient=true'"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</form>	
</body>

</html>

</xsl:template>



<xsl:template name="data-transfer-time">
	<xsl:param name="kbytes"/>
	<xsl:param name="kbps" select="28.8"/>
	
	<xsl:variable name="seconds" select="$kbytes * 8 div $kbps"/>
	
	<xsl:choose>
		<xsl:when test="$seconds &lt; 60.0">&lt; 1 <xsl:value-of select="$strings/ld:str[@id='minute']"/></xsl:when>
		<xsl:when test="$seconds &lt; 90.0">1 <xsl:value-of select="$strings/ld:str[@id='minute']"/></xsl:when>
		<xsl:when test="$seconds &lt; 3600.0"><xsl:value-of select="floor($seconds div 60.0)"/> <xsl:value-of select="$strings/ld:str[@id='minutes']"/></xsl:when>
		<xsl:otherwise>
			<xsl:variable name="hours"  select="floor($seconds div 3600.0)"/>
			<xsl:variable name="minutes"  select="floor(($seconds mod 3600.0) div 60.0)"/>
			<xsl:value-of select="$hours"/>
				<xsl:choose>
					<xsl:when test="$hours=1"> <xsl:value-of select="$strings/ld:str[@id='hour']"/>,</xsl:when>
					<xsl:otherwise> <xsl:value-of select="$strings/ld:str[@id='hours']"/>,</xsl:otherwise>
				</xsl:choose>
			&#160;<xsl:value-of select="$minutes"/>
			<xsl:choose>
				<xsl:when test="$minutes=1"> <xsl:value-of select="$strings/ld:str[@id='minute']"/></xsl:when>
				<xsl:otherwise> <xsl:value-of select="$strings/ld:str[@id='minutes']"/></xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:template>



</xsl:stylesheet>
