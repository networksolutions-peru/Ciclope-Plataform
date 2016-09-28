<?xml version="1.0"?>
<!-- 
	XML Hit List template
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>

<xsl:variable name="view-begin-index" select="/list-section/view-begin-index"/>
<xsl:template match="@*|/|node()"/>
<xsl:template match="/">
	<html>
		<head>
			<title>Resultados de Busqueda</title>

			<link rel="stylesheet" type="text/css"><xsl:attribute name="href"><!-- #STYLESHEETS:xhitlist.css --></xsl:attribute></link>

			<script type="text/javascript">
				<xsl:attribute name="src"><!-- #TEMPLATES:tri-state-check.js --></xsl:attribute>
				<xsl:comment>not empty</xsl:comment>
			</script>
			<script type="text/javascript">
				<xsl:attribute name="src"><!-- #TEMPLATES:jquery.js --></xsl:attribute>
				<xsl:comment>not empty</xsl:comment>
			</script>
			<script type="text/javascript">
				<xsl:attribute name="src"><!-- #TEMPLATES:escape.js --></xsl:attribute>
				<xsl:comment>not empty</xsl:comment>
			</script>
			<script type="text/javascript">
			// globals
			var query = "<xsl:value-of select="list-section/escaped-query"/>";
			var syntax = "<xsl:value-of select="list-section/query-syntax"/>";
			var select = "<xsl:value-of select="list-section/select"/>";
			var is_concept_query = "<xsl:value-of select="list-section/concept-query"/>";
			var hit_count = "<xsl:value-of select="list-section/hit-count"/>";

			<![CDATA[
			<!-- -->
				var hit_selected = null;
				$(document).ready(function()
				{
					// set the correct tab for the search results
					if (parent.setMainTab != null)
					{
						parent.setMainTab("results");
					}
					
					// set up the check boxes
					initStates("#!-- #IMAGES:ui-check-blank.gif --#", "#!-- #IMAGES:ui-check-yes.gif --#", "#!-- #IMAGES:ui-check-no.gif --#");

					hit_selected = gup("hit_selected");
					if (hit_selected != null)
					{
						$("#"+hit_selected).parent().addClass("selected");
					}
				});
				
				function gup( name )
				{
					name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
					var regexS = "[\\?&]"+name+"=([^&#]*)";
					var regex = new RegExp( regexS );
					var results = regex.exec( window.location.href );

					if( results == null )
						return null;
					else
						return results[1];
				}

				function makeFullURL(query_string)
				{
					var cur_url = window.location.href;
					
					// strip existing query string
					var query_offset = cur_url.indexOf('?');
					if (query_offset != -1)
					{
						cur_url = cur_url.substring(0, query_offset);
					}
					
					// make sure we've ONLY got a query string
					query_offset = query_string.indexOf('?');
					if (query_offset != -1)
					{
						query_string = query_string.substring(query_offset, query_string.length);
					}
					
					return cur_url + query_string;
				}


				function moveViewport(command)
				{
					document.viewport_form.xhitlist_vpc.value = command;
					/*document.viewport_form.xhitlist_sel.value = select;
					document.viewport_form.xhitlist_q.value = query;*/

					document.viewport_form.action = makeFullURL("?f=xhitlist"+(hit_selected!=null?"&hit_selected="+hit_selected:""));
					document.viewport_form.submit();
				}
				
				
				function updateDomains(state, path)
				{
					switch (state)
					{
						case 0: // blank
							document.PositiveDomain.RemovePath(path);
							document.NegativeDomain.RemovePath(path);
							break;
						case 1: // yes
							document.PositiveDomain.AddPath(path);
							document.NegativeDomain.RemovePath(path);
							break;
						case 2: // no
							document.PositiveDomain.RemovePath(path);
							document.NegativeDomain.AddPath(path);
							break;
					}
					
					// alert(PositiveDomain.getDomain() + "\n" + NegativeDomain.getDomain());
				}
				
				
				function getFragmentIdentifier(path, content_type, match_number)
				{
					var fragment_id;
					
					if (content_type == "application/pdf")
					{
						// the monstrous fragment identifier here does PDF search highlighting
						
						if (-1 != navigator.userAgent.indexOf("MSIE"))
						{
							// for IE, we need to trim the path down to just the filename to keep the URL short
							path = path.substring(path.lastIndexOf("/") + 1);
							fragment_id = "#xml=" + path +
								"?f=HighlightData$q=" + 
								escapeURL(query) +
								"$x=" + escapeURL(syntax) +
								"$opt=";
						}
						else
						{
							fragment_id = "#xml=" + location.protocol + "//" + location.host + 
								"<!-- #EXECUTIVE:SCRIPT_NAME -->/" + path +
								"?f=HighlightData$q=" + 
								escapeURL(query) +
								"$x=" + escapeURL(syntax) +
								"$opt=";
						}
					}
					else
					{
						fragment_id = "#LPHit" + match_number;
					}
					
					return fragment_id;
				}

				function getCurrentDocument(bUnEscape)
				{
					var current_document = "";
				
					var all_cookies = document.cookie;
				
					var label = "doc=";
					var offset = all_cookies.indexOf(label);
					if (offset != -1)
					{
						var start = offset + label.length;
						var end = all_cookies.indexOf(";", start);
						if (end == -1)
						{
							end = all_cookies.length;
						}
				
						current_document = all_cookies.substring(start, end);
					}
				
					return bUnEscape? unescape(current_document) : current_document;
				}

				function loadDocumentByHitNumber(hit_number)
				{
					var hit_a = document.getElementById("a"+hit_number);
					if (hit_a == null)
						return false;
					
					var onclick_var = String(hit_a.onclick);
					//onclick_var = onclick_var.replace("return ", "");
					//if ( !eval(onclick_var) )
					//	window.execScript(onclick_var);

					onclick_var = onclick_var.replace("function anonymous()", "");
					onclick_var = onclick_var.replace("function onclick(event)", "");
					onclick_var = onclick_var.replace("{", "");
					onclick_var = onclick_var.replace("return onLinkClicked(", "");
					onclick_var = onclick_var.replace(")", "");
					onclick_var = onclick_var.replace("}", "");

					var params_onclick = onclick_var.split("\"");
			
					/*for (i = 0; i<params_onclick.length ; ++i)
					{
						if ( params_onclick[i] != ", " && params_onclick[i] != "" && params_onclick[i] != " " )

							alert(i+": "+params_onclick[i]);
					}*/
					var target_window = top.frames[top.DOC_FRAME];
					if (params_onclick[1] != "" && params_onclick[3] != "" )
					{
						onLinkClicked(params_onclick[1],params_onclick[3],1,hit_number);
						target_window.location = hit_a.href;
					}

					return true;
				}

				function onLinkClicked(path, content_type, match_number, hit_number)
				{
					// get the correct target window for the document
					var current_tab;
					if (top.getMainTab != null)
					{
						current_tab = top.getMainTab();
					}
					/* *** TOCADO ***
					var target_window = (current_tab == "document-results") ? 
							parent.frames[0] : 
							window;
					*/
					var target_window = top.frames[top.DOC_FRAME]; // document window

					// if we have XML escaped ampersands in the query, replace them with normal ampersands
					query = query.replace(/\x26amp;/g, "\x26");

					// build the URL to link to (must include protocol and host for Netscape)
					var url;
					if (is_concept_query == 'yes')
					{
						// We don't want hit highlighting in this case, so don't pass the 
						// query to the document component.
						var url = location.protocol + "//" + location.host + 
							"<!-- #EXECUTIVE:SCRIPT_NAME -->/" + escapeURL(path) +
							"?f=templates$fn=document-frameset.htm";
					}else
					{
						var url = location.protocol + "//" + location.host + 
							"<!-- #EXECUTIVE:SCRIPT_NAME -->/" + escapeURL(path) +
							"?f=templates$fn=document-frameset.htm$q=" + escapeURL(query) +
							"$x=" + escapeURL(syntax);
					}
						
					// the fragment identifier takes us to the first match, or does PDF match highlighting
					url += getFragmentIdentifier(path, content_type, match_number);

					if (hit_selected != null)
						$("#"+hit_selected).parent().removeClass("selected");
					$("#"+hit_number).parent().addClass("selected");
					//document.getElementById(hit_number).className = "selected";
					hit_selected = hit_number;

					top.frames[top.SEARCH_TOOLS_FRAME].setHitNumber(hit_number);

					target_window.location = url;

					var separator = escape("</b> > <b>");
					var document_path = escape(getCurrentDocument(true));
					top.frames[top.DOC_INFO_FRAME].location = "<!-- #TEMPLATES:reference.htm -->$s=" + separator + "$p=" + path;

					return false;
				}
				
				
				function showDocumentExcerpts()
				{
					var sel = document.kwic_form.kwic.selectedIndex;
					var hit_context = "[XML][Kwic," + document.kwic_form.kwic[sel].value + "]";
					
					if (select.indexOf("hit-context") == -1)
					{
						select += ";hit-context";
					}
					
					window.location.search = "?f=xhitlist$xhitlist_sel=" + select + "$xhitlist_hc=" + hit_context;
				}
				
				
				function findSimilar()
				{
					document.findsimilar_form.xhitlist_pcd.value = document.PositiveDomain.GetDomain();
					document.findsimilar_form.xhitlist_ncd.value = document.NegativeDomain.GetDomain();
					
					if (document.findsimilar_form.xhitlist_pcd.value != "" || document.findsimilar_form.xhitlist_ncd.value != "")
					{
						document.findsimilar_form.submit();
					}
					else
					{
						// offer the user a little help
						alert("Use the check boxes to give feedback about the results you like or don't like:\n" +
							"1. Click the check box once to get a green check mark. These are results that you like.\n" +
							"2. Click the check box again to get a red 'x'. These are results you don't like.\n" +
							"3. Click 'Find Similar' to find more documents similar to the ones you like, and fewer you don't like.");
					}
				}
				
				
				function saveSearch()
				{
					// clear the edit to make it look like something happened
					document.named_search_form.userinfo_n.value = document.named_search_form.title.value;
					document.named_search_form.title.value = "";
					
					// preserve the client property
					var banner_win = parent.frames["banner"];
					if (banner_win != null)
					{
						if (banner_win.isClient != null && banner_win.isClient())
						{
							document.named_search_form.isclient.value="true";
						}
					}
					
					return true;
				}
				
				
				function manageSavedSearches()
				{
					var new_window = window.open("<!-- #EXECUTIVE:SCRIPT_NAME -->?f=userinfo$userinfo_cat=saved-search$userinfo_xsl=saved-search.xsl", "savedsearch", "width=500,height=500,resizable=yes,scrollbars=yes"); 
					new_window.focus();
				}
			]]>
				
			</script>
		</head>
			<body>
				<xsl:choose>
					<!-- No active query -->
					<xsl:when test="list-section/translated-query[not(text())]">
						<xsl:attribute name="leftmargin">10</xsl:attribute>
						<xsl:attribute name="topmargin">10</xsl:attribute>
						<h1><img border="0" align="bottom">
							<xsl:attribute name="src"><!-- #IMAGES:ui-failure.gif --></xsl:attribute>
						</img>CICLOPE no detecto busquedas activas</h1>
						<p>No hay ninguna busqueda activa.</p>
						<p>Las busquedas pueden ser realizadas usando el cuadro
						de busqueda en el sector superior izquierdo de la pagina.
						Tambien pueden ser realizadas a traves de la opcion "Busqueda
						por Campos" en la barra de herramientas.</p>
					</xsl:when>
					
					<!-- Query timed out -->
					<xsl:when test="list-section/query-timed-out">
						<xsl:attribute name="leftmargin">10</xsl:attribute>
						<xsl:attribute name="topmargin">10</xsl:attribute>
						<h1><img border="0" align="bottom">
							<xsl:attribute name="src"><!-- #IMAGES:ui-failure.gif --></xsl:attribute>
						</img>CICLOPE no ha finalizado la busqueda</h1>
						<p> La busqueda no ha finalizado dentro de tiempo maximo establecido.
						Esto puede ser a causa de congestion del servidor, o existen demasiados
						aciertos para la busqueda realizada. Intente la busqueda nuevamente.</p>
						<p>El tiempo maximo de busqueda es <xsl:value-of select="list-section/max-time"/>
						milisegundos. Este tiempo maximo puede ser ajustado por el administrador del sitio si es necesario.</p>
						<xsl:if test="list-section/query-syntax[.='Simple' or .='simple']">
							<p>Busqueda realizada para <b><xsl:value-of select="list-section/query"/></b></p>
						</xsl:if>
					</xsl:when>
					
					<!-- No hits from query -->
					<xsl:when test="list-section[not(item)]">
						<xsl:attribute name="leftmargin">10</xsl:attribute>
						<xsl:attribute name="topmargin">10</xsl:attribute>
						<h1><img border="0" align="bottom">
							<xsl:attribute name="src"><!-- #IMAGES:ui-failure.gif --></xsl:attribute>
						</img>CICLOPE no encontro documentos</h1>
						<p>La busqueda de CICLOPE no ha encontrado documentos activos.</p>
						<xsl:if test="list-section/query-syntax[.='Simple' or .='simple']">
							<p>Busqueda realizada para <b><xsl:value-of select="list-section/query"/></b></p>
						</xsl:if>
					</xsl:when>
					
					<!-- Normal case -->
					<xsl:otherwise>
						<xsl:attribute name="leftmargin">0</xsl:attribute>
						<xsl:attribute name="topmargin">0</xsl:attribute>

						<!-- Form for moving the viewport (next/previous page of hits) -->
						<form name="viewport_form" method="post" target="_self"><input type="hidden" name="xhitlist_vpc" value=""/></form>
						
						<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#FFFFFF">
							<tr style="background-color: lightgrey;">
								<xsl:if test="list-section/query-syntax[.='Simple' or .='simple']">
									<td>Resultados para <b><xsl:value-of select="list-section/query"/></b></td>
								</xsl:if>
								<td>
									<xsl:if test="list-section/view-is-begin[.='no']">
										<a class="scroll-link" id="first" href="#" onclick="moveViewport('first');return false;"><img border="0" align="top" alt="First Page"><xsl:attribute name="src"><!-- #IMAGES:hitlist_ico-first.gif --></xsl:attribute></img></a>
										<a class="scroll-link" id="prev"  href="#" onclick="moveViewport('prev'); return false;"><img border="0" align="top" alt="Previous Page"><xsl:attribute name="src"><!-- #IMAGES:hitlist_ico-prev.gif --></xsl:attribute></img></a>
									</xsl:if>
									<xsl:value-of select="list-section/view-begin-index"/>
									a
									<xsl:value-of select="list-section/view-end-index"/>
									<xsl:if test="list-section/view-is-end[.='no']">
										<a class="scroll-link" id="next" href="#" onclick="moveViewport('next');return false;"><img border="0" align="top" alt="Next Page"><xsl:attribute name="src"><!-- #IMAGES:hitlist_ico-next.gif --></xsl:attribute></img></a>
										<a class="scroll-link" id="last" href="#" onclick="moveViewport('last');return false;"><img border="0" align="top" alt="Last Page"><xsl:attribute name="src"><!-- #IMAGES:hitlist_ico-last.gif --></xsl:attribute></img></a>
									</xsl:if>
									de<xsl:value-of select="list-section/hit-count"/>resultados
								</td>
								<td align="right">
									<form name="findsimilar_form" method="get" target="_self">
										<xsl:attribute name="action"><!-- #EXECUTIVE:SCRIPT_NAME --></xsl:attribute>
										<input type="hidden" size="0" name="f" value="xhitlist" />
										<input type="hidden" size="0" name="xhitlist_pcd" value="" />
										<input type="hidden" size="0" name="xhitlist_ncd" value="" />
										<input type="hidden" size="0" name="xhitlist_vpc" value="first" />
										<input type="hidden" size="0" name="xhitlist_d"   value="" />
										<input type="hidden" size="0" name="xhitlist_s"   value="relevance-weight" />
										<input type="hidden" size="0" name="xhitlist_sel" value="title;path;relevance-weight;content-type;home-title" />
										<input type="hidden" size="0" name="xhitlist_hc"  value="" />
									</form>
								</td>
								
								<!-- Find similar/not similar type queries don't work well with KWIC, so we'll
										hide the Document Excerpts drop-down for those queries. -->
								<xsl:if test="list-section[not(concept-query) or concept-query[. != 'yes']]">
									<td align="right">
										<form name="kwic_form">
											<!-- a href="#" onclick="showDocumentExcerpts();return false;">Ver contexto</a -->
											<select name="kwic" onchange="showDocumentExcerpts()">
												<xsl:variable name="lower-case-hit-context" select="translate(list-section/hit-context-param, 'XMLKWIC', 'xmlkwic')"/>
												<option value="0"><xsl:if test="$lower-case-hit-context ='' or $lower-case-hit-context = '[xml][kwic,0]'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Sin Contexto</option>
												<!-- option value="5"><xsl:if test="$lower-case-hit-context = '[xml][kwic,5]'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Corto</option -->
												<option value="10"><xsl:if test="$lower-case-hit-context = '[xml][kwic,10]'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Medio</option>
												<!-- option value="25"><xsl:if test="$lower-case-hit-context = '[xml][kwic,25]'"><xsl:attribute name=4>selected</xsl:attribute></xsl:if>Largo</option -->
											</select>
										</form>
									</td>
								</xsl:if>
							</tr>
						</table>
						
						<form name="nodes_form" method="post">
							<!-- Nodes (the actual hit entries) are inserted here. -->
							<table id="item_table"><xsl:apply-templates/></table>
						</form>
					</xsl:otherwise>
				</xsl:choose>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="list-section"><xsl:apply-templates/></xsl:template>

	<!-- Node (hit list entry) templates -->
	<xsl:template match="item">
		<xsl:variable name="current-item"><xsl:number/></xsl:variable>
		<xsl:variable name="relevance-weight"><xsl:value-of select="relevance-weight"/></xsl:variable>
		<xsl:element name="tr">
			<!-- xsl:choose>
				<xsl:when test="position() mod 2 = 0">
					<xsl:attribute name="style">background-color:#FFFFFF;</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="style">background-color:#AB5312;</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose -->

			<td valign="top" class="item_count">  <!-- class="hit-count" -->
				<xsl:number value="$current-item + $view-begin-index - 1"/>.
			</td>
			
			<xsl:element name="td">
				<xsl:attribute name="class">item_name</xsl:attribute>
				<xsl:attribute name="id"><xsl:number value="$current-item + $view-begin-index - 1"/></xsl:attribute>
				<a>
					<xsl:attribute name="href"><!-- #EXECUTIVE:SCRIPT_NAME -->/<xsl:value-of select="path"/></xsl:attribute>
					<xsl:attribute name="id">a<xsl:number value="$current-item + $view-begin-index - 1"/></xsl:attribute>

					<xsl:attribute name="onclick">return onLinkClicked("<xsl:value-of select="path"/>", "<xsl:value-of select="content-type"/>", "1", "<xsl:number value="$current-item + $view-begin-index - 1"/>")</xsl:attribute>
					<img border="0" align="bottom">
						<xsl:attribute name="src"><!-- #IMAGES:toc-leaf.gif --></xsl:attribute>
					</img>

					<xsl:choose>
						<xsl:when test="home-title='Jurisprudencia'"></xsl:when>
						<xsl:when test="home-title='Doctrina'"></xsl:when>
						<xsl:otherwise> <!-- Legislacion -->
							<xsl:variable name="titulo"><xsl:value-of select="title"/></xsl:variable>
							<xsl:choose>
								<xsl:when test="contains($titulo, '_')">
									<xsl:call-template name="procIDNorma">
										<xsl:with-param name="string" select="$titulo" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$titulo"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</a>
			</xsl:element>
			<!-- td valign="top" class="hit-home-title">
				<xsl:value-of select="home-title"/>
			</td>
			<td valign="top" nowrap="nowrap" class="hit-type">
				<xsl:choose>
					<xsl:when test="content-type[.='text/html']">HTML</xsl:when>
					<xsl:when test="content-type[.='text/xml']">XML</xsl:when>
					<xsl:when test="content-type[.='application/x-html-body-text']">HTML</xsl:when>
					<xsl:when test="content-type[.='application/pdf']">Adobe PDF</xsl:when>
					<xsl:when test="content-type[.='text/plain']">Plain Text</xsl:when>
					<xsl:when test="content-type[.='application/msword']">MS Word</xsl:when>
					<xsl:when test="content-type[.='application/vnd.ms-powerpoint']">MS PowerPoint</xsl:when>
					<xsl:when test="content-type[.='application/vnd.ms-excel']">MS Excel</xsl:when>
					<xsl:when test="content-type[.='application/x-WordPerfect-viewer']">WordPerfect</xsl:when>
					<xsl:when test="content-type[.='application/rtf']">Rich Text</xsl:when>
					<xsl:otherwise><xsl:value-of select="content-type"/></xsl:otherwise>
				</xsl:choose>
			</td -->
		</xsl:element> <!-- /tr -->
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template name="procIDNorma">
		<xsl:param name="string" />
		<span class="tipo_norma" field="tipo_norma"><xsl:call-template name="get_Before"><xsl:with-param name="string" select="$string" /></xsl:call-template></span>
		<xsl:text> </xsl:text>
		<xsl:variable name="string2"><xsl:call-template name="get_After"><xsl:with-param name="string" select="$string" /></xsl:call-template></xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($string2, '_')">
			<span class="numero" field="numero"><xsl:call-template name="get_Before"><xsl:with-param name="string" select="$string2" /></xsl:call-template></span>
			<xsl:text>-</xsl:text>
			<xsl:variable name="string3"><xsl:call-template name="get_After"><xsl:with-param name="string" select="$string2" /></xsl:call-template></xsl:variable>
			<span class="anio" field="anio"><xsl:call-template name="get_Before"><xsl:with-param name="string" select="$string3" /></xsl:call-template></span>

			<xsl:text>-</xsl:text>
			<xsl:variable name="string4"><xsl:call-template name="get_After"><xsl:with-param name="string" select="$string3" /></xsl:call-template></xsl:variable>
			<span class="emisor" field="emisor"><xsl:value-of select="$string4"/></span>
			</xsl:when>
			<xsl:otherwise><span class="numero" field="numero"><xsl:value-of select="$string2"/></span></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="get_Before">
		<xsl:param name="string" />
		<xsl:value-of select="substring-before($string, '_')" />
	</xsl:template>

	<xsl:template name="get_After">
		<xsl:param name="string" />
		<xsl:value-of select="substring-after($string, '_')" />
	</xsl:template>
	
	<xsl:template name="convertTipoNorma">
		<xsl:param name="tipo" />
		<xsl:choose>
			<xsl:when test="$tipo='A'" >Acuerdo</xsl:when>
			<xsl:when test="$tipo='D'" >Decreto</xsl:when>
			<xsl:when test="$tipo='DS'">Decreto Supremo</xsl:when>
			<xsl:when test="$tipo='R'" >Resolucion</xsl:when>
			<xsl:when test="$tipo='L'" >Ley</xsl:when>
			<xsl:otherwise><xsl:value-of select="$tipo"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Hit context templates (words around hits). -->
	<xsl:template match="hit-context">
		<xsl:apply-templates/>
		<tr><td height="10" colspan="5"></td></tr>
	</xsl:template>
	
	<xsl:template match="lp-kwic">
		<tr>
			<td />
			<td>...<xsl:apply-templates/>...</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="lp-hit">
		<a>
			<!-- This href gets overridden in the onLinkClicked handler, we just add it here so the browser knows if the link has been visited or not. -->
			<xsl:attribute name="href"><!-- #EXECUTIVE:SCRIPT_NAME -->/<xsl:value-of select="../../../path"/>#<xsl:value-of select="@count"/></xsl:attribute>
			
			<xsl:attribute name="onclick">return onLinkClicked("<xsl:value-of select="../../../path"/>", "<xsl:value-of select="content-type"/>", "<xsl:value-of select="@count"/>")</xsl:attribute>
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template>
</xsl:stylesheet>
