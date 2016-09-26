<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>

<xsl:template match="/">

<html>

<head>
<title>Agregar Documentos. Paso 2</title>
<link rel="stylesheet" type="text/css">
	<xsl:attribute name="href"><!-- #STYLESHEETS:update.css --></xsl:attribute>
</link>


<script type="text/javascript">
	<xsl:attribute name="src"><!-- #TEMPLATES:update.js --></xsl:attribute>
	<xsl:comment>not-empty</xsl:comment>
</script>

<script type="text/javascript">

var form_changed = false;

function onChangeProperty()
{
	form_changed = true;
}


function finish()
{
	var form = document.main_form;
	form.action = makeFullURL("?f=udoclist$udoclist_vpc=last");

	if (!form_changed)
	{
		// just unlock -- skip the proppatch
		form.update_c.value = "unlock";
		form.submit();
		return;
	}

	if (form.hidden.checked)
	{
		form.update_prop_hidden.value = "yes";
	}
	else
	{
		form.update_prop_hidden.value = "no";
	}
	
	form.update_prop_metadata.value = formatMetadata(form.update_prop_title.value, form.author.value, form.subject.value, form.description.value);

	form.submit();
}


function back()
{
	document.main_form.update_c.value = "delete";
	document.main_form.action = makeFullURL("?f=udocprop$udocprop_upd=yes$udocprop_xsl=update-adddoc-1.xsl$udocprop_sel=title;path$udocprop_sf=update");
	
	document.main_form.submit();
}


function cancel()
{
	document.main_form.update_c.value = "delete";
	document.main_form.action = makeFullURL("?f=udoclist$udoclist_vpc=last");
	
	document.main_form.submit();
}

</script>

</head>

<body>

	<!-- Report Update errors -->
	<xsl:if test="item/status[@type!='ok']">
		<script type="text/javascript">
			<xsl:choose>
				<xsl:when test="item/status[@type='no-data']">
					alert("El archivo no se pudo encontrar, o no contiene ningun dato. Comprueba que la ruta sea la correcta.");
					history.back();	
				</xsl:when>
				<xsl:when test="item/status[@type='exists']">
					alert("El documento con el nombre '<xsl:value-of select="item/status/name"/>' (con el titulo '<xsl:value-of select="item/status/title"/>') ya existe en la carpeta. Para reemplazarlo, primero realize un check out.");
					history.back();	
				</xsl:when>
				<xsl:when test="item/status[@type='locked']">
					alert("El documento esta bloqueado.");
					history.back();	
				</xsl:when>
				<xsl:when test="item/status[@type='access-denied']">
					alert("No tienes suficiente permiso para subir este documento aqui.");
					history.back();	
				</xsl:when>
			</xsl:choose>
		</script>
	</xsl:if>

<form name="main_form" method="post">

	<input type="hidden" name="udoclist_sf" value="update"/>
	<input type="hidden" name="update_c" value="proppatch;unlock"/>
	<input type="hidden" name="update_d" value=""/>
	<input type="hidden" name="update_fp"><xsl:attribute name="value"><xsl:value-of select="item/path"/></xsl:attribute></input>
	<input type="hidden" name="update_prop_metadata"/>

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
			<td width="10%">&#160;</td>
			<td width="40%">
				<b><span class="dim">Paso 1 - Seleccionar el documento</span><br/>
				Paso 2 - Propiedades del documento</b>
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<hr/>
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<p>Nombre:<br/>
				<xsl:value-of select="item/name"/>
				</p>
				
				<p><label for="title" accesskey="t">Titulo:</label><br/>
				<input type="text" id="title" name="update_prop_title" size="50" maxlength="127" onchange="onChangeProperty()">
					<xsl:attribute name="value"><xsl:value-of select="item/title"/></xsl:attribute>
				</input>
				</p>
				
				<p><label for="subject" accesskey="s">Asunto:</label><br/>
				<input type="text" id="subject" name="subject" size="50" onchange="onChangeProperty()">
					<xsl:attribute name="value"><xsl:value-of select="item/field[@name = 'dc:subject']"/></xsl:attribute>
				</input>
				</p>
				
				<p><label for="author" accesskey="a">Autor:</label><br/>
				<input type="text" id="author" name="author" size="50" onchange="onChangeProperty()">
					<xsl:attribute name="value"><xsl:value-of select="item/field[@name = 'dc:creator']"/></xsl:attribute>
				</input>
				</p>
				
				<p><label for="description" accesskey="d">Comentarios:</label><br/>
				<textarea id="description" name="description" rows="4" cols="50" wrap="virtual" onchange="onChangeProperty()"></textarea>
				</p>
				
				<p><input type="checkbox" id="hidden" name="hidden" onclick="onChangeProperty()">
					<xsl:if test="item/hidden[.='yes']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="hidden" accesskey="h">El documento quedara oculto en la TOC</label>
				</p>
				<!-- Use a separate hidden input for the value, since the checkbox's value only gets sent when the checkbox is checked. -->
				<input type="hidden" name="update_prop_hidden" />
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<hr/>
			</td>
		</tr>
		<tr>
			<td>
				<input type="button" value="&lt; Volver" onclick="back()"/>
				<xsl:text> </xsl:text>
				<input type="button" value="Terminar" onclick="finish()"/>
			</td>
			<td width="40">&#160;</td>
			<td>
				<input type="button" value="Cancelar" onclick="cancel()"/>
				<xsl:text> </xsl:text> 
				<input type="button" value="Ayuda" onclick="showHelp('add-doc-2')"/>
			</td>
		</tr>
	</table>
</form>

</body>

</html>

</xsl:template>



</xsl:stylesheet>
