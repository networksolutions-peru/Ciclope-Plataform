<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>


<xsl:variable name="title">NXT Support: System Information</xsl:variable>


<!-- This comes from the default NXT template set. -->
<!-- #executive:include:date-time.xsl -->

<xsl:template match="/">

<html>

<head>
<title><xsl:value-of select="$title"/></title>

<link rel="stylesheet" type="text/css" href="#!-- #stylesheets:support.css --#"/>

<script type="text/javascript">
<![CDATA[


]]>
</script>

</head>

<body>

	<!-- Header -->
	<div class="header">
		<table width="100%" border="0">
			<tr>
				<td valign="top">
					<b><script type="text/javascript">document.write(window.location.host + "#!-- #executive:script_name --#");</script></b>
				</td>
				<td align="right">
					<h1><xsl:value-of select="$title"/></h1>
				</td>
			</tr>
			<tr>
				<td align="right" colspan="2">
					<a href="?f=templates$fn=support.htm">Return to NXT Support Console</a>
				</td>
			</tr>
		</table>
	</div>
	

	<!-- Main Body -->
	<table border="0" cellspacing="0">

		<xsl:apply-templates/>		

	</table>

</body>
</html>

</xsl:template>



<xsl:template match="system-information">

	<!-- Do known system properties explicitly. -->
	<xsl:variable name="known-properties">
		operating-system
		number-of-processors
		total-bytes-physical-memory
		available-bytes-physical-memory
		total-bytes-virtual-memory
		available-bytes-virtual-memory
		total-kbytes-on-intall-drive
		kbytes-free-on-install-drive
		install-location
	</xsl:variable>
	<tr><td style="text-align: right"><b>Operating System:</b></td>
		<td><xsl:value-of select="operating-system"/></td></tr>
	<tr><td style="text-align: right"><b>Number of Processors:</b></td>
		<td><xsl:value-of select="number-of-processors"/></td></tr>
	<tr><td style="text-align: right"><b>Total Physical Memory:</b></td>
		<td><xsl:call-template name="format-bytes"><xsl:with-param name="bytes" select="total-bytes-physical-memory"/></xsl:call-template></td></tr>
	<tr><td style="text-align: right"><b>Available Physical Memory:</b></td>
		<td><xsl:call-template name="format-bytes"><xsl:with-param name="bytes" select="available-bytes-physical-memory"/></xsl:call-template></td></tr>
	<tr><td style="text-align: right"><b>Total Virtual Memory:</b></td>
		<td><xsl:call-template name="format-bytes"><xsl:with-param name="bytes" select="total-bytes-virtual-memory"/></xsl:call-template></td></tr>
	<tr><td style="text-align: right"><b>Available Virtual Memory:</b></td>
		<td><xsl:call-template name="format-bytes"><xsl:with-param name="bytes" select="available-bytes-virtual-memory"/></xsl:call-template></td></tr>
	<tr><td style="text-align: right"><b>NXT Install Location:</b></td>
		<td><xsl:value-of select="install-location"/></td></tr>
	<tr><td style="text-align: right"><b>Total Install Drive Space:</b></td>
		<td><xsl:call-template name="format-kbytes"><xsl:with-param name="kbytes" select="total-kbytes-on-intall-drive"/></xsl:call-template></td></tr>
	<tr><td style="text-align: right"><b>Available Install Drive Space:</b></td>
		<td><xsl:call-template name="format-kbytes"><xsl:with-param name="kbytes" select="kbytes-free-on-install-drive"/></xsl:call-template></td></tr>

	<!-- Do any other properties that happen to show up implicitly. -->
	<xsl:for-each select="*">
		<xsl:if test="not(contains($known-properties, name(.)))">
 			<tr><td style="text-align: right"><b><xsl:value-of select="name(.)"/>:</b></td><td><xsl:value-of select="."/></td></tr>
		</xsl:if>
	</xsl:for-each>

</xsl:template>



<xsl:template name="format-bytes">
	<xsl:param name="bytes"/>

	<xsl:choose>
		<xsl:when test="number($bytes) &gt; 10485760">
			<xsl:number value="round(number($bytes) div 1048576)" grouping-size="3" grouping-separator=","/> MB
		</xsl:when>
		<xsl:when test="number($bytes) &gt; 500">
			<xsl:number value="round(number($bytes) div 1024)" grouping-size="3" grouping-separator=","/> KB
		</xsl:when>
		<xsl:otherwise>
			1 KB
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<xsl:template name="format-kbytes">
	<xsl:param name="kbytes"/>

	<xsl:choose>
		<xsl:when test="number($kbytes) &gt; 10240">
			<xsl:number value="round(number($kbytes) div 1024)" grouping-size="3" grouping-separator=","/> MB
		</xsl:when>
		<xsl:otherwise>
			<xsl:number value="number($kbytes)" grouping-size="3" grouping-separator=","/> KB
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>





</xsl:stylesheet>
