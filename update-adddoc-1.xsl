<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>


<xsl:template match="/">

<html>

<head>
<title>Agregar Documentos. Paso 1</title>
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

<![CDATA[

function next()
{
	if (document.main_form.update_file.value.length == 0)
	{
		alert("Por favor busque el documento que desea subir.");
		document.main_form.update_file.focus();
	}
	else
	{
		var last_separator = document.main_form.update_file.value.lastIndexOf("\\");
		var filename;
		if (last_separator != -1)
		{
			filename = document.main_form.update_file.value.substring(last_separator + 1);
		}
		else
		{
			filename = document.main_form.update_file.value;
		}
		
		var parent_path = document.main_form.pp.value;

		// get rid of XML escaped ampersands
		parent_path = parent_path.replace(/\x26amp;/g, "\x26");
		
		filename = parent_path + "/" + filename;

		var qstring = "?f=udocprop" + 
			"$udocprop_upd=yes" +
			"$udocprop_xsl=update-adddoc-2.xsl" + 
			"$udocprop_sel=name;title;path;id;indexed;hidden;field:dc:creator;field:dc:subject" + 
			"$udocprop_sf=update" +
			"$update_d=" +
			"$udocprop_p=" + escapeURL(filename);
		
		document.main_form.action = makeFullURL(qstring);
		
		document.main_form.submit();
	}
}


function cancel()
{
	window.location.search = "?f=udoclist";
}

]]>
</script>
</head>

<body>

<form name="main_form" method="post" enctype="multipart/form-data" onsubmit="next()">
	<input type="hidden" name="update_c" value="put;lock" />
	<input type="hidden" name="update_ow" value="no" />
	<input type="hidden" name="pp">
		<xsl:attribute name="value"><xsl:value-of select="item/path"/></xsl:attribute>
	</input>

	<table border="0">
		<tr>
			<td width="50%" nowrap="nowrap">
				<h1>
					<img border="0" align="top" width="33" height="33">
						<xsl:attribute name="src"><!-- #IMAGES:update-adddoc.gif --></xsl:attribute>
					</img>
					Agregar Documento
				</h1>
			</td>
			<td width="10%"></td>
			<td width="40%">
				<b>Paso 1 - Seleccionar el documento<br/>
				<span class="dim">Paso 2 - Propiedades del documento</span></b>
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<hr/>
			</td>
		</tr>
		<tr>
			<td colspan="3">Seleccione el documento que desea subir <b><xsl:value-of select="item/title"/></b>.
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
				<input type="button" value="Siguiente &gt;" onclick="next()"/>
			</td>
			<td width="40"></td>
			<td>
				<input type="button" value="Cancelar" onclick="cancel()"/>
				<xsl:text> </xsl:text>
				<input type="button" value="Ayuda" onclick="showHelp('add-doc-1')"/>
			</td>
		</tr>
	</table>
</form>

</body>

</html>

</xsl:template>



</xsl:stylesheet>
