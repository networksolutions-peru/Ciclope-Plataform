<?xml version="1.0"?>

<!-- 

	Statistics template

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>

<!-- #executive:include:date-time.xsl -->
<!-- We'd rather use xsl:include, but the current UNIX XSL processor doesn't support inclusions via HTTP. -->


<xsl:template match="/">

<html>

<head>
	<title>Message Log</title>
	
	<link rel="stylesheet" type="text/css">
		<xsl:attribute name="href"><!-- #STYLESHEETS:main.css --></xsl:attribute>
	</link>

	<link rel="stylesheet" type="text/css">
		<xsl:attribute name="href"><!-- #STYLESHEETS:statistics.css --></xsl:attribute>
	</link>

</head>

<body>

	<!-- We really only expect a single log... -->	
	<xsl:for-each select="document/log">

		<table cellpadding="3">
		
			<tr>
				<td class="title" colspan="4"><h1>Message Log: <xsl:value-of select="properties/property[@name='name']"/></h1></td>
			</tr>
			
			<tr>
				<th>Time</th>
				<th>Severity</th>
				<th>Status</th>
				<th>Text</th>
			</tr>

			<xsl:for-each select="messages/message">

				<tr>
					<td>
						<xsl:call-template name="render-iso8601-date-time">
							<xsl:with-param name="date-time" select="property[@name='timestamp']"/>
							<xsl:with-param name="format" select="'short'"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:choose>
							<xsl:when test="property[@name='severity' and . = '0']">Error</xsl:when>
							<xsl:when test="property[@name='severity' and . = '1']">Warning</xsl:when>
							<xsl:otherwise>Info</xsl:otherwise>
						</xsl:choose>
					</td>
					<td><xsl:choose><xsl:when test="property[@name = 'status' and . = '0']">OK (0x0000000)</xsl:when><xsl:otherwise>Error (0x<xsl:value-of select="property[@name='status']"/>)</xsl:otherwise></xsl:choose></td>
					<td><xsl:value-of select="property[@name='message']"/></td>
				</tr>

			</xsl:for-each>

		</table>

	</xsl:for-each>

</body>

</html>

</xsl:template>




</xsl:stylesheet>
