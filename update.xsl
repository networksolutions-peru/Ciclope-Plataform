<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>
<xsl:variable name="editable_area" select="list-section[not(item) or item/type='Document']"/>
<xsl:variable name="add_content_area" select="list-section/type[.!='site' and .!='folder']"/>

<xsl:template match="@*|/|node()"/>



<xsl:template match="/">

<xsl:choose>

<!-- Redirect immediately to the top of the site if we end up in a read-only area. 
The root node should always be writable, but just in case, we'll not redirect if
we're at the root already. Otherwise an infinite loop could occur. -->
<xsl:when test="list-section/writable = 'no' and list-section/path !=''">
	<html><head><title>Redirecting...</title></head><body><script type="text/javascript">
		var new_url = "<!-- #EXECUTIVE:SCRIPT_NAME -->" + "/?f=" + 
			"<xsl:value-of select="list-section/function"/>" + 
			"$update_c=";
		window.location = new_url;
	</script></body></html>		
</xsl:when>


<xsl:otherwise>	
<html>

<head>
<title>Administrar Contenidos</title>

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

var current_function = "<xsl:value-of select="list-section/function"/>";


<![CDATA[

function openFolder(path)
{
	var new_url = "<!-- #EXECUTIVE:SCRIPT_NAME -->/" +
		escape(path) + 
		"?f=udoclist$udoclist_vpc=first";

	window.location.href = new_url;
}


function setCheckState(state)
{
	for (index = 0; index != document.nodes_form.elements.length; index++)
	{
		if (document.nodes_form.elements[index].name == "checkbox")
		{
			document.nodes_form.elements[index].checked = state;
			updateDomain(document.nodes_form.elements[index]);
		}
	}
}

function updateDomainCbox(checkbox)
{
	var path = checkbox.value;
	//var applet_cero = document.applets[0];
	
	// Accessing the applet by name in this case doesn't work in Netscape (for some unknown reason),
	// so we'll use the array reference approach instead.
	if (checkbox.checked)
	{
		document.nodes_form.update_d.value = path;
		//applet_cero.AddPath(path);
	}
	else
	{
		//applet_cero.RemovePath(path);
		document.nodes_form.update_d.value = "";
	}
}


function forceReload()
{
	// clear out any update commands, and request this page again
	componentRequest("?f=" + current_function + "$update_c=");
}


function checkOutDocument(doc_path)
{
	var download_url = "<!-- #EXECUTIVE:SCRIPT_NAME -->/" + 
		escapeURL(doc_path) + 
		"?f=udocprop" +
		"$udocprop_upd=yes" +
		"$udocprop_xsl=update-download.xsl" + 
		"$udocprop_sel=title;path" + 
		"$udocprop_sf=update" + 
		"$update_c=lock";
	
	if (isIE55())
	{
		download_url += "$udocprop_fss=yes";
	}
	
	var download_window = window.open(download_url, "download", "width=350,height=225,resizable=yes,scrollbars=yes,menubar=yes");
			
	download_window.focus();
}


function checkInDocument(doc_path)
{
	componentRequest(
		"?f=udocprop" + 
		"$udocprop_upd=yes" + 
		"$udocprop_xsl=update-checkin.xsl" + 
		"$udocprop_md=retf=" + current_function +
		"$udocprop_sel=title;path" +
		"$udocprop_p=" + escapeURL(doc_path));
}


function editDocumentProperties(doc_path)
{
	componentRequest(
		"?f=udocprop" +
		"$udocprop_upd=yes" +  
		"$udocprop_xsl=update-props.xsl" +
		"$udocprop_sel=name;title;path;indexed;metadata;hidden;field:dc:creator;field:dc:subject" + 
		"$udocprop_md=retf=" + current_function +
		"$udocprop_p=" + escapeURL(doc_path) +
		"$udocprop_sf=update" + 
		"$update_c=lock" +
		"$update_d=" +
		"$update_fp=" + escapeURL(doc_path));
}


function viewDocument(doc_path)
{
	var view_url = "<!-- #EXECUTIVE:SCRIPT_NAME -->/" + 
		escapeURL(doc_path) +
		"?f=templates" + 
		"$fn=update-view.htm" + 
		"$udocprop_md=retf=" + current_function + ",retp=<!-- #EXECUTIVE:PATH_INFO -->$udocprop_p=" + escapeURL(doc_path);

	window.location = view_url;
}


function createNewFolder()
{
	var folder_name = document.createforlder_form.update_file_name.value;

	if (folder_name.length == 0)
	{
		alert('Ingrese un nombre para la nueva carpeta.');
		document.createforlder_form.update_file_name.focus();
		return false;
	}
	
	if (-1 != folder_name.indexOf("/") || -1 != folder_name.indexOf("\\"))
	{
		alert('The slash characters "/" and "\\" are not allowed in folder names.');
		document.createforlder_form.update_file_name.focus();
		return false;
	}
	
	// set the title as well (to preserve case as they typed it)
	document.createforlder_form.update_prop_title.value = folder_name;
	document.createforlder_form.update_c.value = "mkcol;lock;proppatch;unlock";	
	document.createforlder_form.action = makeFullURL("?f=udoclist$udoclist_vpc=last$udoclist_sf=update");
		
	return true;
}

function confirmDelete(obj)
{
	if (!confirm('Esta seguro que desea borrar todas los archivos y carpetas seleccionadas?'))
	{
		return false;
	}
	
	return true;
}


function confirmUnlock()
{
	if (document.nodes_form.update_d.value.length == 0)
	{
		alert('Utilize los checkboxes para seleccionar los documentos y deshacer el check out.');
		return false;
	}
	
	return true;
}

function addDocumentWizard()
{
	componentRequest("?f=udocprop$udocprop_upd=yes$udocprop_xsl=update-adddoc-1.xsl$udocprop_sel=title;path");
}

function doMultiDocumentOperation(path, action)
{
	var should_submit = false;

	if ( path.indexOf("[") > -1)
		path = String(path).replace(/\[/, "\[");
		
	if ( path.indexOf("]") > -1)
		path = String(path).replace(/\]/, "\]");

	document.nodes_form.update_d.value = path;
	document.nodes_form.update_c.value = action;
	document.nodes_form.action = makeFullURL("?f=" + current_function + "$" + current_function + "_sf=update");
	alert(document.nodes_form.action);
	if (action == "delete")
	{
		should_submit = confirmDelete();
	}
	else if (action == "unlock")
	{
		should_submit = confirmUnlock();
	}
	
	if (should_submit)
	{	
		//alert(document.nodes_form.action+"\n" + document.nodes_form.update_d.value+"\n" + document.nodes_form.update_c.value+"\n" +document.nodes_form.method);
		document.nodes_form.submit();
	}
}

function doMultiDocumentOperationCbox(select)
{
	var command = select[select.selectedIndex].value;
	document.nodes_form.update_c.value = command;
	//document.nodes_form.update_d.value = document.applets[0].GetDomain();
	document.nodes_form.action = makeFullURL("?f=" + current_function + "$" + current_function + "_sf=update");
	
	var should_submit = false;
	if (command == "delete")
	{
		should_submit = confirmDelete();
	}
	else if (command == "unlock")
	{
		should_submit = confirmUnlock();
	}
	
	if (should_submit)
	{
		document.nodes_form.submit();
	}

	select.selectedIndex = 0;
}


function moveViewport(command)
{
	document.viewport_form.elements[0].value = command;
	document.viewport_form.action = makeFullURL("?f=" + current_function);
	document.viewport_form.submit();
}


function setCurrentView(select)
{
	var view = select[select.selectedIndex].value;
	if (view == "folder")
	{
		componentRequest("?f=udoclist$udoclist_vpc=first");
	}
	else
	{
		componentRequest( 
			"?f=uxhitlist" +
			"$uxhitlist_q=[field,locked-by:" + view + "]" +
			"$uxhitlist_x=Server" +
			"$uxhitlist_xsl=update.xsl" +
			"$uxhitlist_vpc=first" + 
			"$uxhitlist_sel=name;path;title;content-type;has-children;last-modified;locked;locked-by;type");
	}
}

]]>
</script>

</head>

<body>

	<!-- Report Update errors -->
	<xsl:if test="list-section/status[@type!='ok']">
		<script type="text/javascript">
			<xsl:choose>
				<xsl:when test="list-section/status[@type='locked']">
					alert("El documento '<xsl:value-of select="list-section/status/title"/>' ya fue check out por " +
					<xsl:choose><xsl:when test="list-section/status/locked-by[.='anonymous']">"un usuario anonimo.");</xsl:when><xsl:otherwise>"<xsl:value-of select="list-section/status/locked-by"/>.");</xsl:otherwise></xsl:choose>
				</xsl:when>
				<xsl:when test="list-section/status[@type='access-denied']">
					alert("No tiene suficientes permisos para realizar la operacion solicitada..");
				</xsl:when>
				<xsl:when test="list-section/status[@type='exists']">
					alert("La carpeta llamada '<xsl:value-of select="list-section/status/title"/>' ya existe. Por favor elija otro nombre.");
				</xsl:when>
				<xsl:when test="list-section/status[@type='not-locked']">
					alert("No se pudo hacer check out a uno o mas documentos, porque usted no le hizo check out.");
				</xsl:when>
				<xsl:otherwise>
					alert("Ocurrio un error inesperado.\n(<xsl:value-of select="list-section/status/@type"/>)");
				</xsl:otherwise>				
			</xsl:choose>
		</script>
	</xsl:if>
	
	<form name="viewport_form" method="post">
		<xsl:attribute name="action"><!-- #EXECUTIVE:SCRIPT_NAME --></xsl:attribute>
		<input type="hidden" value="">
			<xsl:attribute name="name"><xsl:value-of select="list-section/function"/>_vpc</xsl:attribute>
		</input>
	</form>

	<table border="0" width="100%" cellspacing="5">
		<tr>
			<td width="10%" nowrap="nowrap">
				<h1>Administrar Contenidos</h1>
			</td>
			<td width="10%"></td>
			<td>
				<!-- Display an appropriate list heading -->
				<xsl:choose>
					<xsl:when test="list-section/query">
						<b>Documentos checked out por 
							<xsl:choose>
								<xsl:when test="list-section/user-name[.='anonymous']">un usuario anonimo</xsl:when>
								<xsl:otherwise><xsl:value-of select="list-section/user-name"/></xsl:otherwise>
							</xsl:choose>
						</b>
					</xsl:when>
					<xsl:otherwise>
						<img border="0" align="top" width="16" height="16">
							<xsl:attribute name="src"><!-- #IMAGES:update-folder-open.gif --></xsl:attribute>
						</img>
						<b><xsl:value-of select="list-section/title"/></b>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:if test="list-section/parent-path">
					<a href="">
						<xsl:attribute name="onclick">openFolder("<xsl:value-of select="list-section/parent-path"/>"); return false;</xsl:attribute>
						<img border="0" align="top" width="16" height="16" alt="Subir un nivel">
							<xsl:attribute name="src"><!-- #IMAGES:update-to-parent.gif --></xsl:attribute>
						</img>
						<b>Subir un nivel</b>
					</a>
				</xsl:if>
			</td>
		</tr>
	</table>
	
	<!-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ -->
	<!-- form name="nodes_form" method="post" onsubmit="return createNewFolder();" action="#!-- #EXECUTIVE:SCRIPT_NAME --#">
		<input type="hidden" name="update_c" value=""/>
		<input type="hidden" name="update_d" value=""/>
		<input type="hidden" name="update_fp" value=""/ -->
		
		<table border="0" width="100%">
			<tr>
				<xsl:if test="$editable_area">
	
				<th width="1%" colspan="2">
					<img width="8" height="8">
						<xsl:attribute name="src"><!-- #IMAGES:update-check.gif --></xsl:attribute>
					</img>
				</th>
				<th width="1%" align="left">Editar</th>
				
				</xsl:if>
				
				<th align="left">Titulo</th>
				<th align="left">Estado</th> 
				<th align="right">Ultima Modificacion</th>
			</tr>
			
			<xsl:if test="list-section/view-is-begin[.='no']">
			<tr>
				<td colspan="5" class="scroll">
					<a class="scroll-link" href="javascript:moveViewport('first')"><img border="0" align="top" alt="First Page"><xsl:attribute name="src"><!-- #IMAGES:vlist-first.gif --></xsl:attribute></img></a>
					<a class="scroll-link" href="javascript:moveViewport('prev')"><img border="0" align="top" alt="Previous Page"><xsl:attribute name="src"><!-- #IMAGES:vlist-prev.gif --></xsl:attribute></img>
					<b>More...</b></a>
				</td>
			</tr>
			</xsl:if>
			

			<!-- ========== The nodes get listed here ========== -->
			<xsl:apply-templates select="list-section/item"/>
				
			
			<xsl:if test="list-section/view-is-end[.='no']">
			<tr>
				<td colspan="5" class="scroll">
					<a class="scroll-link" href="javascript:moveViewport('last')"><img border="0" align="top" alt="Last Page"><xsl:attribute name="src"><!-- #IMAGES:vlist-last.gif --></xsl:attribute></img></a>
					<a class="scroll-link" href="javascript:moveViewport('next')"><img border="0" align="top" alt="Next Page"><xsl:attribute name="src"><!-- #IMAGES:vlist-next.gif --></xsl:attribute></img>
					<b>More...</b></a>
				</td>
			</tr>
			</xsl:if>
			
		</table>
	<!-- /form -->
	<!-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ -->
	
	<form name="createforlder_form" method="post" onsubmit="return createNewFolder();" action="#!-- #EXECUTIVE:SCRIPT_NAME --#">
		<input type="hidden" name="update_c" value=""/>
		<input type="hidden" name="update_d" value=""/>
		<input type="hidden" name="update_fp" value=""/>
		
		<table border="0" width="100%">
	
			<tr>
				<!-- td nowrap="nowrap" colspan="2" valign="top">
					<span class="tiny"><a href="javascript:setCheckState(true)">Seleccionar Todos</a></span><br/>
					<span class="tiny"><a href="javascript:setCheckState(false)">DesSeleccionar Todos</a></span></td -->
				<td valign="top" colspan="3">
					<xsl:if test="$editable_area">
						<!-- New folder only available when viewing the contents of a folder - not when querying by state -->
						<xsl:if test="$add_content_area">
							<img border="0" width="18" height="16">
								<xsl:attribute name="src"><!-- #IMAGES:update-folder-new.gif --></xsl:attribute>
							</img>
							Nueva Carpeta: 
							<input type="text" name="update_file_name" size="20"/> 
							<input type="hidden" name="update_prop_title" value=""/> 
							<!-- xsl:text> </xsl:text --><input type="submit" value="Crear"/>
						</xsl:if>
					</xsl:if>
				</td>
			</tr>
		</table>
	</form>
	<hr/>
	
	<!-- Bottom tool area -->
	<form name="tools_form">
		<xsl:attribute name="action"><!-- #EXECUTIVE:SCRIPT_NAME --></xsl:attribute>
		<table border="0" width="100%">
			<tr>
				<td width="33%" valign="top">
				</td>
				
				<!-- Publishing wizard only available when viewing the contents of a folder - not when querying by state -->
				<xsl:choose>
					<xsl:when test="$add_content_area">
						<td width="2%" valign="top">
							<a href="javascript:addDocumentWizard()">
								<img border="0" alt="Agregar Documento" width="33" height="33">
									<xsl:attribute name="src"><!-- #IMAGES:update-adddoc.gif --></xsl:attribute>
								</img>
							</a>
						</td>
						<td valign="top">
							<a href="javascript:addDocumentWizard()"><b>Agregar Documento</b></a><br/>
							a "<xsl:value-of select="list-section/title"/>"
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td width="33%"><xsl:comment>not-empty</xsl:comment></td>
					</xsl:otherwise>
				</xsl:choose>
				
				<td valign="top" width="33%">
					<b>Ver documentos:</b><br />
					<select name="view_options" size="1" onchange="setCurrentView(this)">
						<option value="folder">
							<xsl:if test="list-section[not(query)]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
							En la carpeta actual
						</option>
						<option>
							<xsl:attribute name="value"><xsl:value-of select="list-section/user-name"/></xsl:attribute>
							<xsl:if test="list-section/query"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
							Check out por mi
						</option>
					</select>
				</td>
			</tr>
		</table>
	</form>
	
</body>

</html>

</xsl:otherwise>
</xsl:choose>

</xsl:template>



<!-- Folder items (sub-infobase, empty documents) -->
<xsl:template match="item[has-children[. = 'yes'] or not(content-type)]">
	<tr>
		<td nowrap="nowrap" valign="top">
			<form method="post" action="" onsubmit="this.action = makeFullURL('?f=' + current_function + '$' + current_function + '_sf=update'); return confirmDelete(this); ">
				<xsl:attribute name="name"><xsl:text>has_child_delete_form_</xsl:text><xsl:value-of select="path"/></xsl:attribute>
				<input type="hidden" name="update_c" value="delete"/>
				<input type="hidden" name="update_fp"/>
				<input type="hidden" name="update_d" value="">
					<xsl:attribute name="value"><xsl:value-of select="path"/></xsl:attribute>
				</input>
				<input type="image" src="#!-- #IMAGES:update-delete.gif --#">
					<xsl:attribute name="alt"><xsl:text>Borrar elemento</xsl:text></xsl:attribute>
					<xsl:attribute name="title"><xsl:text>Borrar elemento</xsl:text></xsl:attribute>
				</input>
			</form>
		</td>

		<td nowrap="nowrap" valign="top">
			<xsl:if test="$editable_area">
				<xsl:if test="locked[. = 'yes' or locked-by[. = /list-section/user-name]]">
				<form method="post" action="" onsubmit="this.action = makeFullURL('?f=' + current_function + '$' + current_function + '_sf=update');">
					<xsl:attribute name="name"><xsl:text>unlock_form_</xsl:text><xsl:value-of select="path"/></xsl:attribute>
					<input type="hidden" name="update_c" value="unlock"/>
					<input type="hidden" name="update_fp" value=""/>
					<input type="hidden" name="update_d" value="">
						<xsl:attribute name="value"><xsl:value-of select="path"/></xsl:attribute>
					</input>
					<input type="image" src="#!-- #IMAGES:update-undocheckout.gif --#">
						<xsl:attribute name="alt"><xsl:text>Deshacer check-out</xsl:text></xsl:attribute>
						<xsl:attribute name="title"><xsl:text>Deshacer check-out</xsl:text></xsl:attribute>
					</input>
				</form>
				</xsl:if>
			</xsl:if>
		</td>
		<td nowrap="nowrap" align="right" valign="top">
			<xsl:if test="locked[. = 'no' or locked-by[. = /list-section/user-name]]">
				<a href=""><xsl:attribute name="onclick">editDocumentProperties("<xsl:value-of select="path"/>"); return false;</xsl:attribute>
					<img border="0" alt="Editar propiedades" width="16" height="16">
					<xsl:attribute name="src"><!-- #IMAGES:update-edit-properties.gif --></xsl:attribute></img></a>
			</xsl:if>
		</td>
		<td valign="top">
			<a title="Abrir Carpeta" href="">
				<xsl:attribute name="onclick">openFolder("<xsl:value-of select="path"/>"); return false;</xsl:attribute>
				
				<img border="0" alt="Abrir Carpeta" width="16" height="16">
					<xsl:choose>
						<xsl:when test="hidden[. = 'yes']">
							<xsl:attribute name="src"><!-- #IMAGES:update-folder-hidden.gif --></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="src"><!-- #IMAGES:update-folder.gif --></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</img>
				<xsl:value-of select="title"/>
			</a>
		</td>
		<td></td>
		<td nowrap="nowrap" align="right"><xsl:apply-templates/></td>
	</tr>
</xsl:template>



<!-- Document items -->
<xsl:template match="item[has-children[.='no'] and content-type]">
<tr>
	<td nowrap="nowrap" valign="top">
			<form method="post" action="" onsubmit="this.action = makeFullURL('?f=' + current_function + '$' + current_function + '_sf=update'); return confirmDelete(this); ">
				<xsl:attribute name="name"><xsl:text>delete_form_</xsl:text><xsl:value-of select="path"/></xsl:attribute>
				<input type="hidden" name="update_c" value="delete"/>
				<input type="hidden" name="update_fp"/>
				<input type="hidden" name="update_d" value="">
					<xsl:attribute name="value"><xsl:value-of select="path"/></xsl:attribute>
				</input>
				<input type="image" src="#!-- #IMAGES:update-delete.gif --#">
					<xsl:attribute name="alt"><xsl:text>Borrar elemento</xsl:text></xsl:attribute>
					<xsl:attribute name="title"><xsl:text>Borrar elemento</xsl:text></xsl:attribute>
				</input>
			</form>
	</td>
	
	<td nowrap="nowrap" valign="top">
			<xsl:if test="locked[. = 'yes' or locked-by[. = /list-section/user-name]]">
			<form method="post" action="" onsubmit="this.action = makeFullURL('?f=' + current_function + '$' + current_function + '_sf=update');">
				<xsl:attribute name="name"><xsl:text>unlock_form_</xsl:text><xsl:value-of select="path"/></xsl:attribute>
				<input type="hidden" name="update_c" value="unlock"/>
				<input type="hidden" name="update_fp" value=""/>
				<input type="hidden" name="update_d" value="">
					<xsl:attribute name="value"><xsl:value-of select="path"/></xsl:attribute>
				</input>
				<input type="image" src="#!-- #IMAGES:update-undocheckout.gif --#">
					<xsl:attribute name="alt"><xsl:text>Deshacer check-out</xsl:text></xsl:attribute>
					<xsl:attribute name="title"><xsl:text>Deshacer check-out</xsl:text></xsl:attribute>
				</input>
			</form>
			</xsl:if>
		</td>
	<td nowrap="nowrap" align="right" valign="top">

		<xsl:choose>
			<xsl:when test="locked[.='no']">
				<a href=""><xsl:attribute name="onclick">checkOutDocument("<xsl:value-of select="path"/>"); return false;</xsl:attribute>
					<img border="0" width="16" height="16" align="top">
						<xsl:attribute name="src"><!-- #IMAGES:update-checkout.gif --></xsl:attribute>
						<xsl:attribute name="alt"><xsl:text>Check Out</xsl:text></xsl:attribute>
						<xsl:attribute name="title"><xsl:text>Check Out</xsl:text></xsl:attribute>
					</img></a>

				<a href=""><xsl:attribute name="onclick">editDocumentProperties("<xsl:value-of select="path"/>"); return false;</xsl:attribute>
					<img border="0" width="16" height="16" align="top">
					<xsl:attribute name="src"><!-- #IMAGES:update-edit-properties.gif --></xsl:attribute>
					<xsl:attribute name="alt"><xsl:text>Editar Propiedades</xsl:text></xsl:attribute>
					<xsl:attribute name="title"><xsl:text>Editar Propiedades</xsl:text></xsl:attribute>
				</img></a>
			</xsl:when>
			<xsl:when test="locked-by[. = /list-section/user-name]">
				<a href=""><xsl:attribute name="onclick">checkInDocument("<xsl:value-of select="path"/>"); return false;</xsl:attribute>
					<img border="0" width="16" height="16" align="top">
					<xsl:attribute name="src"><!-- #IMAGES:update-checkin.gif --></xsl:attribute>
					<xsl:attribute name="alt"><xsl:text>Check In</xsl:text></xsl:attribute>
					<xsl:attribute name="title"><xsl:text>Check In</xsl:text></xsl:attribute>
				</img></a>

				<a href=""><xsl:attribute name="onclick">editDocumentProperties("<xsl:value-of select="path"/>"); return false;</xsl:attribute>
					<img border="0" width="16" height="16" align="top">
					<xsl:attribute name="src"><!-- #IMAGES:update-edit-properties.gif --></xsl:attribute>
					<xsl:attribute name="alt"><xsl:text>Editar Propiedades</xsl:text></xsl:attribute>
					<xsl:attribute name="title"><xsl:text>Editar Propiedades</xsl:text></xsl:attribute>
				</img></a>
			</xsl:when>
			<xsl:otherwise>&#160;</xsl:otherwise>
		</xsl:choose>

	</td>
	<td valign="top">
		<a title="Ver Documento" href="">
			<xsl:attribute name="onclick">viewDocument("<xsl:value-of select="path"/>"); return false;</xsl:attribute>
			<img border="0" alt="Ver Documento" width="16" height="16" align="top">
				<xsl:choose>
					<xsl:when test="hidden[. = 'yes']">
						<xsl:attribute name="src"><!-- #IMAGES:update-doc-hidden.gif --></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="src"><!-- #IMAGES:update-doc.gif --></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</img>
			<xsl:value-of select="title"/>
		</a>
	</td>
	<td>
		<xsl:if test="locked[.='yes']">
			<span class="state"> Check out por
				<xsl:choose>
					<xsl:when test="locked-by[.='anonymous']">un usuario anonimo</xsl:when>
					<xsl:otherwise><xsl:value-of select="locked-by"/></xsl:otherwise>
				</xsl:choose>
			</span>
		</xsl:if>
		<xsl:comment>not-empty</xsl:comment>
	</td>
	<td nowrap="nowrap" align="right"><xsl:apply-templates/></td>
</tr>
</xsl:template>


<!-- Writable containers and super-container folders -->
<xsl:template match="item[type[.='infobase' or .='folder']]">
	<tr>
		<td>
			<a title="Abrir Carpeta" href="">
				<xsl:attribute name="onclick">openFolder("<xsl:value-of select="path"/>"); return false;</xsl:attribute>
				
				<img border="0" alt="Abrir Carpeta" width="16" height="16">
					<xsl:choose>
						<xsl:when test="hidden[. = 'yes']">
							<xsl:attribute name="src"><!-- #IMAGES:update-folder-hidden.gif --></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="src"><!-- #IMAGES:update-folder.gif --></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</img>
				<xsl:value-of select="title"/>
			</a>
		</td>
		<td></td>
		<td align="right"><xsl:apply-templates/></td>
	</tr>
</xsl:template>


<!-- Read-only containers -->
<xsl:template match="item[writable = 'no']">
	<tr>
		<td valign="top">
			<img border="0" width="16" height="16">
				<xsl:attribute name="src"><!-- #IMAGES:update-folder-ro.gif --></xsl:attribute>
			</img>
			<xsl:value-of select="title"/>
		</td>
		<td><span class="state">Solo Lectura</span></td>
		<td nowrap="nowrap" align="right"><xsl:apply-templates/></td>
	</tr>
</xsl:template>
<!-- Format last-modified date -->
<!-- #executive:include:date-time.xsl -->
<!-- We'd rather use xsl:include, but the current UNIX XSL processor doesn't support inclusions via HTTP. -->
<xsl:template match="last-modified">
<!--	<xsl:call-template name="render-date-time"> -->
	<xsl:call-template name="render-iso8601-date-time">
		<xsl:with-param name="date-time" select="."/>
	</xsl:call-template>
</xsl:template>
</xsl:stylesheet>
