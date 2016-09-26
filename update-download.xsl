<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>


<xsl:template match="/">

<html>

<head>
<title>Check Out</title>

<link rel="stylesheet" type="text/css">
	<xsl:attribute name="href"><!-- #STYLESHEETS:update.css --></xsl:attribute>
</link>

<script type="text/javascript">
	<xsl:attribute name="src"><!-- #TEMPLATES:update.js --></xsl:attribute>
	<xsl:comment>not-empty</xsl:comment>
</script>

<script type="text/javascript">

<![CDATA[

function startDownload()
{
	// IE 4 has a bug (see MS Knowledgebase Article ID: Q182315) that prevents
	// us from forcing a download in some cases, so we'll warn IE 4 users.
	// IE 5.5 seems to have regressed back to this bug (even though we reported the
	// fact to them before it shipped...)
	if (navigator.appName.indexOf("Microsoft") != -1)
	{
		// the appVersion of IE 4 AND ABOVE start with "4", so be careful here
		var version_prefix = "MSIE ";
		var version_pos = navigator.appVersion.indexOf(version_prefix) + version_prefix.length;
		var version_str = navigator.appVersion.substr(version_pos);
		
		var ver_4 = "4";
		var ver_55 = "5.5";
		
		if (version_str.substr(0, ver_4.length) == ver_4 || version_str.substr(0, ver_55.length) == ver_55)
		{
			alert("Note to Internet Explorer users:\nIf the document appears in this window instead of downloading, you may save it manually by choosing 'Save As...' from the 'File' menu.");
		}
	}
	
	window.location.search = "?f=update$update_c=get";
}


function refreshMainWindow()
{
	var main_win = window.opener;
	main_win.location.search = "?f=udoclist";
}


]]>
</script>

</head>

<body onload="startDownload()" onunload="refreshMainWindow()">

	<!-- Report Update errors -->
	<xsl:if test="item/status[@type!='ok']">
		<script type="text/javascript">
			<xsl:choose>
				<xsl:when test="item/status[@type='locked']">
					alert("El documento '<xsl:value-of select="item/status/title"/>' actualmente esta check out por <xsl:value-of select="item/status/locked-by"/>.");	
					window.close();
				</xsl:when>
				<xsl:when test="item/status[@type='access-denied']">
					alert("No tiene suficientes premisos para hacerle check out a este documentos			.");
					window.close();
				</xsl:when>
				<xsl:otherwise>
					<xsl:comment>not-empty</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</script>
	</xsl:if>
	
	<h1>Descargando, espere...</h1>
	<p>Documento:<br/><b><xsl:value-of select="item/title"/></b></p>
	<p>Cierre esta ventana cuando se complete la descarga.</p>
	<form><center><input type="button" value="Cerrar" onclick="window.close()"/></center></form>
	
	<form name="download_form" method="get">
		<xsl:attribute name="action"><!-- #EXECUTIVE:SCRIPT_NAME --></xsl:attribute>
		<input type="hidden" name="update_c" value="get" />		
		<input type="hidden" name="update_fp">
			<xsl:attribute name="value"><xsl:value-of select="item/path"/></xsl:attribute>
		</input>
	</form>
	
</body>

</html>

</xsl:template>



</xsl:stylesheet>
