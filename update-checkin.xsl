<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>


<xsl:template match="/">

<html>

<head>
<title>Check-In</title>

<link rel="stylesheet" type="text/css">
	<xsl:attribute name="href"><!-- #STYLESHEETS:update.css --></xsl:attribute>
</link>

<script type="text/javascript">
	<xsl:attribute name="src"><!-- #TEMPLATES:update.js --></xsl:attribute>
	<xsl:comment>not-empty</xsl:comment>
</script>

<script type="text/javascript">

var return_function = "<xsl:value-of select="item/retf"/>";

<![CDATA[

function checkIn()
{
	if (document.main_form.update_file.value.length == 0)
	{
		alert('Navegue hasta el documento que quiere subir.');
		document.main_form.update_file.focus();
		return false;
	}
	
	document.main_form.action = makeFullURL("?f=" + return_function);
	
	return true;
}


function cancel()
{
	document.location = makeFullURL("?f=" + return_function);
}

]]>
</script>
</head>

<body>

<form name="main_form" action="?f=udoclist" method="post" enctype="multipart/form-data" onsubmit="return checkIn()">
	<input type="hidden" name="update_c" value="put;unlock" />
	<input type="hidden" name="update_d" value=""/>
	<input type="hidden" name="update_fp">
		<xsl:attribute name="value"><xsl:value-of select="item/path"/></xsl:attribute>
	</input>
	<input type="hidden" value="update">
		<xsl:attribute name="name"><xsl:value-of select="item/retf"/>_sf</xsl:attribute>
	</input>
	

	<table border="0">
		<tr>
			<td width="50%" nowrap="nowrap">
				<h1><img border="0" src="#!-- #IMAGES:update-checkin-big.gif --#" align="absmiddle" width="33" height="33"/>
				Check-In</h1>
			</td>
			<td width="10%"></td>
			<td width="40%"></td>
		</tr>
		<tr>
			<td colspan="3">
				<hr/>
			</td>
		</tr>
		<tr>
			<td colspan="3">Seleccione el documento para <b><xsl:value-of select="item/title"/></b>.
				<p><label for="file" accesskey="f">Nombre del documento:</label><br/>
					<input id="file" type="file" name="update_file" size="30"/></p>
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<hr/>
			</td>
		</tr>
		<tr>
			<td>
				<input type="submit" value="Check In"/>
			</td>
			<td width="40"></td>
			<td>
				<input type="button" value="Cancelar" onclick="cancel()"/>
				<xsl:text> </xsl:text>
				<input type="button" value="Ayuda" onclick="showHelp('check-in')"/>
			</td>
		</tr>
	</table>
</form>

</body>

</html>

</xsl:template>



</xsl:stylesheet>
