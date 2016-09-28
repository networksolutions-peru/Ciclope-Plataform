<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>


<xsl:template match="/">

<html>

<head>
<title>Manage Content</title>

<link rel="stylesheet" type="text/css">
	<xsl:attribute name="href"><!-- #STYLESHEETS:update.css --></xsl:attribute>
</link>

<script type="text/javascript">
	<xsl:attribute name="src"><!-- #TEMPLATES:update.js --></xsl:attribute>
	<xsl:comment>not-empty</xsl:comment>
</script>

<script type="text/javascript">
	<xsl:attribute name="src"><!-- #TEMPLATES:escape.js --></xsl:attribute>
	<xsl:comment>not-empty</xsl:comment>
</script>


<script type="text/javascript">

var return_function = "<xsl:value-of select="item/retf"/>";
var return_path = "<xsl:value-of select="item/retp"/>";
var script_name = "<!-- #EXECUTIVE:SCRIPT_NAME -->";

<![CDATA[

function toParent()
{
	// get rid of XML escaped ampersands
	return_path = return_path.replace(/\x26amp;/g, "\x26");

	window.parent.location = script_name + escapeURL(return_path) + "?f=" + return_function;
}

]]>
</script>

</head>


<body>
	<table border="0" width="100%">
		<tr>
			<td>
				<h1>Administracion de Contenidos</h1>
			</td>
			<td>
				<a href="javascript:toParent()">
					<img border="0" align="top" width="16" height="16">
						<xsl:attribute name="src"><!-- #IMAGES:update-to-parent.gif --></xsl:attribute>
					</img>
					<b>Subir un nivel</b>
				</a>
			</td>
		</tr>
	</table>

	<table border="0" width="100%">
		<tr>
			<th align="left">Documento</th>
			<th align="left">Status</th> 
			<th align="right">Last-Modified</th>
		</tr>
		<tr>
			<td>
				<img border="0" width="16" height="16" align="top">
					<xsl:choose>
						<xsl:when test="item/hidden[. = 'yes']">
							<xsl:attribute name="src"><!-- #IMAGES:update-doc-hidden.gif --></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="src"><!-- #IMAGES:update-doc.gif --></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</img>
				<xsl:value-of select="item/title"/>
			</td>
			<td>
				<xsl:if test="item/locked[.='yes']">
					<span class="state"> Checked out by 
						<xsl:choose>
							<xsl:when test="item/locked-by[.='anonymous']">an anonymous user</xsl:when>
							<xsl:otherwise><xsl:value-of select="item/locked-by"/></xsl:otherwise>
						</xsl:choose>
					</span>
				</xsl:if>
				<xsl:comment>not-empty</xsl:comment>
			</td>
			<td nowrap="nowrap" align="right"><xsl:apply-templates select="item/last-modified"/></td>
		</tr>
	</table>

</body>

</html>

</xsl:template>



<!-- Format last-modified date -->
<!-- #executive:include:date-time.xsl -->
<!-- We'd rather use xsl:include, but the current UNIX XSL processor doesn't support inclusions via HTTP. -->
<xsl:template match="last-modified">
	<xsl:call-template name="render-date-time">
		<xsl:with-param name="date-time" select="."/>
	</xsl:call-template>
</xsl:template>



</xsl:stylesheet>
