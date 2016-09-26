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

	<link rel="stylesheet" type="text/css">
		<xsl:attribute name="href"><!-- #STYLESHEETS:main.css --></xsl:attribute>
	</link>

	<script type="text/javascript">
		<xsl:attribute name="src"><!-- #TEMPLATES:tri-state-check.js --></xsl:attribute>
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

	<![CDATA[
	
	
		function initPage()
		{
			// set the correct tab for the search results
			if (parent.setMainTab != null)
			{
				parent.setMainTab("results");
			}
			
			// set up the check boxes
			initStates("<!-- #IMAGES:ui-check-blank.gif -->", "<!-- #IMAGES:ui-check-yes.gif -->", "<!-- #IMAGES:ui-check-no.gif -->");
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
			document.viewport_form.elements[0].value = command;
			document.viewport_form.action = makeFullURL("?f=xhitlist");
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


		function onLinkClicked(path, content_type, match_number)
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
			var target_window = parent.parent.frames[3];	// document window.

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
			}
			else
			{
				var url = location.protocol + "//" + location.host + 
					"<!-- #EXECUTIVE:SCRIPT_NAME -->/" + escapeURL(path) +
					"?f=templates$fn=document-frameset.htm$q=" + escapeURL(query) +
					"$x=" + escapeURL(syntax);
			}
				
			// the fragment identifier takes us to the first match, or does PDF match highlighting
			url += getFragmentIdentifier(path, content_type, match_number);
			
			target_window.location = url;
			
			// override the link's href attribute
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

<body onload="initPage()">
	
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
			<form name="viewport_form" method="post" target="_self">
				<input type="hidden" value="" name="xhitlist_vpc" />
			</form>
			
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#FFFFFF">
				<tr>
					<xsl:if test="list-section/query-syntax[.='Simple' or .='simple']">
						<td>
							Resultados para <b><xsl:value-of select="list-section/query"/></b>
						</td>
					</xsl:if>
					<td>
						<xsl:value-of select="list-section/view-begin-index"/> - <xsl:value-of select="list-section/view-end-index"/> de <xsl:value-of select="list-section/hit-count"/> resultados
					</td>
					<td align="right">
						<form name="findsimilar_form" method="get" target="_self">
							<xsl:attribute name="action"><!-- #EXECUTIVE:SCRIPT_NAME --></xsl:attribute>
							<input type="hidden" size="0" name="f" value="xhitlist" />
							<input type="hidden" size="0" name="xhitlist_pcd" value="" />
							<input type="hidden" size="0" name="xhitlist_ncd" value="" />
							<input type="hidden" size="0" name="xhitlist_vpc" value="first" />
							<input type="hidden" size="0" name="xhitlist_d"	  value="" />
							<input type="hidden" size="0" name="xhitlist_s"	  value="relevance-weight" />
							<input type="hidden" size="0" name="xhitlist_sel" value="title;path;relevance-weight;content-type;home-title" />							
							<input type="hidden" size="0" name="xhitlist_hc"  value="" />
						</form>
					</td>
					
					<!-- Find similar/not similar type queries don't work well with KWIC, so we'll
							hide the Document Excerpts drop-down for those queries. -->
					<xsl:if test="list-section[not(concept-query) or concept-query[. != 'yes']]">
						<td align="right">
							<form name="kwic_form">
								Ver resumen:
								<select name="kwic" onchange="showDocumentExcerpts()">
									<xsl:variable name="lower-case-hit-context" select="translate(list-section/hit-context-param, 'XMLKWIC', 'xmlkwic')"/>
									<option value="0"><xsl:if test="$lower-case-hit-context ='' or $lower-case-hit-context = '[xml][kwic,0]'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>No</option>
									<option value="5"><xsl:if test="$lower-case-hit-context = '[xml][kwic,5]'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Corto</option>
									<option value="10"><xsl:if test="$lower-case-hit-context = '[xml][kwic,10]'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Medio</option>
									<option value="25"><xsl:if test="$lower-case-hit-context = '[xml][kwic,25]'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Largo</option>
								</select>
							</form>
						</td>
					</xsl:if>
				</tr>
			</table>
			
			<table width="100%">
				<tr>
					<td class="hit-head" align="right" width="1%">&#160;</td>
					
					<!--xsl:if test="list-section/item/relevance-weight">
						'<td class="hit-head" align="right" width="1%">Ranking</td>
					</xsl:if-->
					
					<!--td class="hit-head" align="center" width="1%"><img alt="'Find Similar' feedback"><xsl:attribute name="src">#!-- #IMAGES:ui-similar-w.gif --#</xsl:attribute></img></td-->
					<td class="hit-head">Titulo</td>
					<td class="hit-head">Ubicacion</td>
					<td class="hit-head">Tipo</td>
				</tr>
		
				<!-- Previous results page buttons -->
				<xsl:if test="list-section/view-is-begin[.='no']">
				<tr>
					<td colspan="6" class="scroll" valign="top">
						<a class="scroll-link" href="" onclick="moveViewport('first');return false;"><img border="0" align="top" alt="First Page"><xsl:attribute name="src"><!-- #IMAGES:vlist-first.gif --></xsl:attribute></img></a>
						<a class="scroll-link" href="" onclick="moveViewport('prev');return false;"><img border="0" align="top" alt="Previous Page"><xsl:attribute name="src"><!-- #IMAGES:vlist-prev.gif --></xsl:attribute></img>
						mas...</a>
					</td>
				</tr>
				<tr><td height="15"></td></tr>
				</xsl:if>
				
				<form name="nodes_form" method="post">
					<!-- Nodes (the actual hit entries) are inserted here. -->
					<xsl:apply-templates/>
				</form>
				
				<!-- Next results page buttons -->
				<xsl:if test="list-section/view-is-end[.='no']">
				<tr><td height="15"></td></tr>
				<tr>
					<td colspan="6" class="scroll">
						<a class="scroll-link" href="" onclick="moveViewport('last');return false;"><img border="0" align="top" alt="Last Page"><xsl:attribute name="src"><!-- #IMAGES:vlist-last.gif --></xsl:attribute></img></a>
						<a class="scroll-link" href="" onclick="moveViewport('next');return false;"><img border="0" align="top" alt="Next Page"><xsl:attribute name="src"><!-- #IMAGES:vlist-next.gif --></xsl:attribute></img>
						mas...</a>
					</td>
				</tr>
				</xsl:if>
				
			</table>
		</xsl:otherwise>
	</xsl:choose>

</body>

</html>

</xsl:template>


<xsl:template match="list-section">
	<xsl:apply-templates/>
</xsl:template>


<!-- Node (hit list entry) templates -->

<xsl:template match="item">

	<xsl:variable name="current-item"><xsl:number/></xsl:variable>
	<xsl:variable name="relevance-weight"><xsl:value-of select="relevance-weight"/></xsl:variable>

	<xsl:element name="tr">
		<xsl:choose>
			<xsl:when test="position() mod 2 = 0">
				<xsl:attribute name="bgcolor">#E7E7E7</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="bgcolor">#FFFF00</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>

		<td align="right" valign="top" class="hit-count">
			<xsl:number value="$current-item + $view-begin-index - 1"/>.
		</td>
		
		<!--xsl:if test="relevance-weight">
			<td align="right" valign="top" class="hit-rank">
				<xsl:number value="$relevance-weight div 10"/>
			</td>
		</xsl:if-->
		
		<!--td align="center" valign="top">
			<a href="">
				<xsl:attribute name="onclick">updateDomains(cycleState(img<xsl:number/>), "<xsl:value-of select="path"/>");return false</xsl:attribute>
				<img border="0" align="bottom" alt="find similar / not similar">
					<xsl:attribute name="name">img<xsl:number/></xsl:attribute>
					<xsl:attribute name="src">#!-- #IMAGES:ui-check-blank.gif --#</xsl:attribute>
				</img></a>
		</td-->
		<td valign="top" class="hit-title">
			<a>
				<!-- This href gets overridden in the onLinkClicked handler, we just add it here so the browser knows if the link has been visited or not. -->
				<xsl:attribute name="href"><!-- #EXECUTIVE:SCRIPT_NAME -->/<xsl:value-of select="path"/></xsl:attribute>

				<xsl:attribute name="onclick">return onLinkClicked("<xsl:value-of select="path"/>", "<xsl:value-of select="content-type"/>", "1")</xsl:attribute>
				<img border="0" align="bottom">
					<xsl:attribute name="src"><!-- #IMAGES:toc-leaf.gif --></xsl:attribute>
				</img>
				<xsl:value-of select="title"/>
			</a>
		</td>
		<td valign="top" class="hit-home-title">
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
		</td>
	</xsl:element> <!-- /tr -->
	<xsl:apply-templates/>
</xsl:template>



<!-- Hit context templates (words around hits). -->

<xsl:template match="hit-context">
	<xsl:apply-templates/>
	<tr><td height="10" colspan="5"></td></tr>
</xsl:template>


<xsl:template match="lp-kwic">
	<tr>
		<td />
		<td colspan="5" class="hit-context">
			...<xsl:apply-templates/>...
		</td>
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
