<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>

<xsl:template match="/">

<html>

<head>
<title>Propiedades</title>

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

var form_changed = false;


function onChangeProperty()
{
	form_changed = true;
}


function save()
{
	var form = document.main_form;
	form.action = makeFullURL("?f=" + return_function);
	
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


function cancel()
{
	document.main_form.update_c.value = "unlock";
	document.main_form.action = makeFullURL("?f=" + return_function);

	document.main_form.submit();
}


]]>
</script>

</head>

<body>

	<!-- Report Update errors -->
	<xsl:if test="item/status[@type!='ok']">
		<script type="text/javascript">
			<xsl:choose>
				<xsl:when test="item/status[@type='locked']">
					alert("The document '<xsl:value-of select="item/status/title"/>' is already checked out by <xsl:value-of select="item/status/locked-by"/>.");	
					history.back();
				</xsl:when>
				<xsl:when test="item/status[@type='access-denied']">
					alert("You do not have sufficient rights to edit this document's properties.");
					history.back();
				</xsl:when>
				<xsl:otherwise>
					<xsl:comment>not-empty</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</script>
	</xsl:if>
	
<form name="main_form" method="post" action="?f=udoclist" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.0/">

	<input type="hidden" name="update_c" value="proppatch;unlock"/>
	<input type="hidden" value="update">
		<xsl:attribute name="name"><xsl:value-of select="item/retf"/>_sf</xsl:attribute>
	</input>
	<input type="hidden" name="update_d" value=""/>
	<input type="hidden" name="update_fp">
		<xsl:attribute name="value"><xsl:value-of select="item/path"/></xsl:attribute>
	</input>
	<input type="hidden" name="update_prop_metadata"/>

	<table border="0">
		<tr>
			<td colspan="3">
				<h1>
					<img border="0" align="top" width="33" height="33">
						<xsl:attribute name="src"><!-- #IMAGES:update-properties.gif --></xsl:attribute>
					</img>
					Propiedades
				</h1>
				<hr/>
				
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
					<xsl:choose>
						<xsl:when test="item/metadata/rdf:RDF/rdf:Description/dc:subject">
							<xsl:attribute name="value"><xsl:value-of select="item/metadata/rdf:RDF/rdf:Description/dc:subject"/></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="value"><xsl:value-of select="item/field[@name = 'dc:subject']"/></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</input>
				</p>
				
				<p><label for="author" accesskey="a">Autor:</label><br/>
				<input type="text" id="author" name="author" size="50" onchange="onChangeProperty()">
					<xsl:choose>
						<xsl:when test="item/metadata/rdf:RDF/rdf:Description/dc:creator">
							<xsl:attribute name="value"><xsl:value-of select="item/metadata/rdf:RDF/rdf:Description/dc:creator"/></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="value"><xsl:value-of select="item/field[@name = 'dc:creator']"/></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</input>
				</p>
				
				<p><label for="description" accesskey="d">Comentarios:</label><br/>
				<textarea id="description" name="description" rows="4" cols="50" wrap="virtual" onchange="onChangeProperty()"><xsl:value-of select="item/metadata/rdf:RDF/rdf:Description/dc:description"/></textarea>
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
				
				<hr/>
				
			</td>
		</tr>

		<tr>
			<td>
				<input type="button" value=" Guardar " onclick="save()"/>
				<xsl:text> </xsl:text>
			 	<input type="button" value="Cancelar" onclick="cancel()"/>
			 </td>
			<td width="40">&#160;</td>
			<td>
				<input type="button" value="Ayuda" onclick="showHelp('edit-props')"/>
			</td>
		</tr>
	</table>
	
</form>

</body>

</html>

</xsl:template>



</xsl:stylesheet>
