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
				<xsl:attribute name="src"><!-- #TEMPLATES:CLPSessionSaveSearchs.js --></xsl:attribute>
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

			var orden;
			var firstClicked = {};
			var classHitSelected = "hit_selected";
			<![CDATA[
			<!-- -->
				var hit_selected = null;
				$(document).ready(function()
				{
					if (hit_count<=0)
						return;
					// set the correct tab for the search results
					if (parent.setMainTab != null)
					{
						parent.setMainTab("results");
					}
					
					if (getSearch(TMP_SEARCH_NAME) == null)
					{
						$(".save_from_tmp").each(function(){ $(this).hide(); });
					}else
						$(".save_from_tmp").each(function(){ $(this).show(); });
					
					// set up the check boxes
					initStates("#!-- #IMAGES:ui-check-blank.gif --#", "#!-- #IMAGES:ui-check-yes.gif --#", "#!-- #IMAGES:ui-check-no.gif --#");

					hit_selected = gup("hit_selected");
					if (hit_selected != null)
					{
						$("#"+hit_selected).parent().addClass(classHitSelected);
						$("#"+hit_selected).addClass(classHitSelected);
					}else
					{ 
						onLinkClicked(firstClicked.p,firstClicked.s,firstClicked.t,firstClicked.c);
					}
					top.countEnd();
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
						target_window.reload();
						target_window.location = hit_a.href+"#LPHit1";
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

					// if we have XML escaped ampersands in the query, replace them with normal ampersands
					query = query.replace(/\x26amp;/g, "\x26");

					if (top.frames[top.TOC_FRAME] != null && top.frames[top.TOC_FRAME].synchronize)
						top.frames[top.TOC_FRAME].synchronize(path); //Sincronizar automaticamente con el documento seleccionado en la hitlist
						
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
					{
						$("#"+hit_selected).parent().removeClass(classHitSelected);
						$("#"+hit_selected).removeClass(classHitSelected);
					}
					$("#"+hit_number).parent().addClass(classHitSelected);
					$("#"+hit_number).addClass(classHitSelected);

					hit_selected = hit_number;

					if (top.frames[top.TOOLS_FRAME].setHitNumber)
						top.frames[top.TOOLS_FRAME].setHitNumber(hit_number);

					top.frames[top.DOC_FRAME].location = url;

					var separator = escape("</b> > <b>");
					var document_path = escape(getCurrentDocument(true));
					top.frames[top.DOC_INFO_FRAME].location = "<!-- #TEMPLATES:reference.htm -->$p=" + path;

					if (top.frames[top.TOOLS_FRAME].showSearchTools)
						top.frames[top.TOOLS_FRAME].showSearchTools();
					return false;
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
				
				function manageSavedSearches()
				{
					var new_window = window.open("<!-- #EXECUTIVE:SCRIPT_NAME -->?f=userinfo$userinfo_cat=saved-search$userinfo_xsl=saved-search.xsl", "savedsearch", "width=500,height=500,resizable=yes,scrollbars=yes"); 
					new_window.focus();
				}

				function showDocumentExcerpts(val)
				{
					var hit_context = "[XML][Kwic," + val + "]";
					if (select.indexOf("hit-context") == -1)
					{
						select += ";hit-context";
					}
					
					window.location.search = "?f=xhitlist$xhitlist_sel=" + select + "$xhitlist_hc=" + hit_context;
				}
//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
	function fnc_ordenar(obj)
	{
		var orden = $(obj).val();
		
		document.ordenar.xhitlist_s.value = orden;
		document.ordenar.submit();
	}
	
	function fnc_hitcount(obj)
	{
		var mh = $(obj).val();
		document.ordenar.xhitlist_mh.value = mh;
		document.ordenar.submit();
	}

	function toggleSearchInfo()
	{
		//alert(document.cookie);
		var search_name_in_use = getSearchInUse();
		var _searchTmp = getSearch(search_name_in_use);
		if (_searchTmp == null)
		{
			alert("toggleSearchInfo: " + search_name_in_use);
			return;
		}
		//alert(_searchTmp.toString());
		//alert(_searchTmp.getHTMLValuesTable());
		$('#searchValues').html(_searchTmp.getHTMLValuesTable());
		$('#searchInfo').toggle();
	}
	function doSaveSearch()
	{
		saveSearchFromTMP(null, document.location.href);
		document.location.reload(true);
	}
	function doPrintXitlist()
	{
		window.parent.HitList.focus();
		window.print();
	}
	function thitlist(obj)
	{
		
		top.expandHitlistToggle($('#hl-expand-img'));
	}
//------------------------------------------------------------------------------------------------------------------------------------
				]]>
			</script>
			<style>
				.bottom_panel
				{
					position:absolute;
					bottom:2px;
				}
				.save_from_tmp
				{
					display:none;
				}
			</style>
		</head>
			<body>
				<form name="ordenar" method="get" target="_self">
					<xsl:attribute name="action"><!-- #EXECUTIVE:SCRIPT_NAME --></xsl:attribute>
					<!-- 
						<input type="hidden" size="0" name="xhitlist_xsl" value="xhitlist.xsl" />
					-->
						<input type="hidden" size="0" name="global"	      value="G_" />
						<input type="hidden" size="0" name="G_QUERY"      value="" />
					<input type="hidden" size="0" name="f"            value="xhitlist" />
					<input type="hidden" size="0" name="xhitlist_x"	  value="">
						<xsl:attribute name="value"><xsl:value-of select="list-section/query-syntax"/></xsl:attribute>
					</input>
					<input type="hidden" size="0" name="xhitlist_mh"  value="">
						<xsl:attribute name="value"><xsl:value-of select="list-section/max-hits"/></xsl:attribute>
					</input>
					<input type="hidden" size="0" name="xhitlist_s"	  value="">
						<xsl:attribute name="value"><xsl:value-of select="list-section/sort"/></xsl:attribute>
					</input>
					<input type="hidden" size="0" name="xhitlist_d"	  value="">
						<xsl:attribute name="value"><xsl:value-of select="list-section/domain"/></xsl:attribute>
					</input>
					<input type="hidden" size="0" name="xhitlist_q"	  value="">
						<xsl:attribute name="value"><xsl:value-of select="list-section/escaped-query"/></xsl:attribute>
					</input>
					<input type="hidden" size="0" name="xhitlist_hc"  value="" />
					<input type="hidden" size="0" name="xhitlist_vpc" value="first" />
					<input type="hidden" size="0" name="xhitlist_sel" value="">
						<xsl:attribute name="value"><xsl:value-of select="list-section/select"/></xsl:attribute>
					</input>
				</form>
				<xsl:choose>
					<!-- No active query -->
					<xsl:when test="list-section/translated-query[not(text())]">
						<xsl:attribute name="leftmargin">10</xsl:attribute>
						<xsl:attribute name="topmargin">10</xsl:attribute>
						<h1><img border="0" align="bottom">
							<xsl:attribute name="src"><!-- #IMAGES:ui-failure.gif --></xsl:attribute>
						</img>No se detectaron busquedas activas</h1>
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
						</img>No ha finalizado la busqueda</h1>
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
						</img>No se encontraron documentos</h1>
						<p>La busqueda no ha encontrado documentos activos.</p>
						<xsl:if test="list-section/query-syntax[.='Simple' or .='simple']">
							<p>Busqueda realizada para <b><xsl:value-of select="list-section/query"/></b></p>
						</xsl:if>
					</xsl:when>
					
					<!-- Normal case -->
					<xsl:otherwise>
						<xsl:attribute name="leftmargin">0</xsl:attribute>
						<xsl:attribute name="topmargin">0</xsl:attribute>

						<script type="text/javascript">
							firstClicked = {
								p:'<xsl:value-of select="list-section/item/path"/>',
								s:'<xsl:value-of select="list-section/item/content-type"/>',
								t:'1',
								c:'1'
							};
						</script>
						
						<!-- Form for moving the viewport (next/previous page of hits) -->
						<form name="viewport_form" method="post" target="_self">
							<input type="hidden" name="xhitlist_vpc" value=""/>
						</form>
						<xsl:call-template name="hitlist_tools_bar"></xsl:call-template>
						
						<div id="searchInfo" style="display:none;border:2px solid black;padding:3px;width:95%;">
							<b>Busqueda actual:</b>
							<hr/>
							<div id="searchValues"/>
						</div>
						
						<form name="nodes_form" method="post">
							<!-- Nodes (the actual hit entries) are inserted here. -->
							<table id="item_table"><xsl:apply-templates/></table>
						</form>
						
						<br/>
						<xsl:call-template name="hitlist_tools_bar">
							<xsl:with-param name="show_buttons" select="'no'"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="list-section"><xsl:apply-templates/></xsl:template>
	
	<xsl:template name="hitlist_navigate_tools">
		<td>
			<xsl:if test="list-section/query-syntax[.='Simple' or .='simple']">
				<td>Resultados para <b><xsl:value-of select="list-section/query"/></b></td>
			</xsl:if>
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
			de
			<xsl:variable name="actual_hc" select="sum(list-section/max-hits[number(.)=number(.)])"/>
			<select onchange="fnc_hitcount(this)">
				<option value="50" ><xsl:if test="$actual_hc &gt; 0 and $actual_hc &lt; 51" ><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>50</option>
				<option value="100"><xsl:if test="$actual_hc &gt; 50 and $actual_hc &lt; 101"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>100</option>
				<option value="200"><xsl:if test="$actual_hc &gt; 100 and $actual_hc &lt; 201"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>200</option>
				<option value="300"><xsl:if test="$actual_hc &gt; 200 and $actual_hc &lt; 301"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>300</option>
				<option value="400"><xsl:if test="$actual_hc &gt; 300 and $actual_hc &lt; 401"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>400</option>
				<option value="500"><xsl:if test="$actual_hc &gt; 400 and $actual_hc &lt; 501"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>500</option>
				<option value="10000"><xsl:if test="$actual_hc &gt; 500"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>&gt;500</option>
			</select>
			<!-- xsl:value-of select="list-section/hit-count"/ -->
			aciertos
		</td>
	</xsl:template>
	
	<xsl:template name="hitlist_tools_bar">
		<xsl:param name="show_buttons" select="'yes'"/>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#FFFFFF">
			<tr style="background-color: lightgrey; height: 25px;">
				<xsl:call-template name="hitlist_navigate_tools"></xsl:call-template>
				<xsl:if test="$show_buttons='yes'">
				<xsl:if test="list-section[not(concept-query) or concept-query[. != 'yes']]">
					<td align="right" style="width:1px;">
						<!-- select name="kwic" onchange="showDocumentExcerpts(this)">
							<xsl:variable name="lower-case-hit-context" select="translate(list-section/hit-context-param, 'XMLKWIC', 'xmlkwic')"/>
							<option value="0"><xsl:if test="$lower-case-hit-context ='' or $lower-case-hit-context = '[xml][kwic,0]'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Sin Contexto</option>
							<option value="10"><xsl:if test="$lower-case-hit-context = '[xml][kwic,10]'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Contexto Medio</option>
							<option value="25"><xsl:if test="$lower-case-hit-context = '[xml][kwic,25]'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Contexto Largo</option>
						</select -->
						<xsl:call-template name="WriteContexto">
							<xsl:with-param name="prev_type" select="/list-section/hit-context-param" />
						</xsl:call-template>
					</td>
					<td align="left" style="width:1px;">
						<a href="#" onclick="javascript:toggleSearchInfo()">
							<img border="0">
								<xsl:attribute name="src"><!-- #IMAGES:info_search.JPG --></xsl:attribute>
								<xsl:attribute name="alt">Ver/Ocultar terminos de busqueda.</xsl:attribute>
								<xsl:attribute name="title">Ver/Ocultar terminos de busqueda.</xsl:attribute>
							</img>
						</a>
					</td>
					<td align="left" style="width:1px;">
						<a href="#" class="save_from_tmp" onclick="javascript:doSaveSearch();">
							<img border="0">
								<xsl:attribute name="src"><!-- #IMAGES:save.png --></xsl:attribute>
								<xsl:attribute name="alt">Guardar la busqueda actual.</xsl:attribute>
								<xsl:attribute name="title">Guardar la busqueda actual.</xsl:attribute>
							</img> </a>
					</td>
					<td align="left" style="width:1px;">
						<a href="#" class="print_frame" onclick="javascript:doPrintXitlist();">
							<img border="0">
								<xsl:attribute name="src"><!-- #IMAGES:print.png --></xsl:attribute>
								<xsl:attribute name="alt">Imprimir la lista de resultados.</xsl:attribute>
								<xsl:attribute name="title">Imprimir la lista de resultados.</xsl:attribute>
							</img> </a>
					</td>
					<td align="right" style="width:1px;">
						
						<select syle="width: 50px;" onchange="fnc_ordenar(this)">
							<xsl:variable name="actual_sort" select="list-section/sort"/>
							<option value="">
								<xsl:if test="$actual_sort=''">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>Ordernar por:
							</option>
							<option value="Field:tipo_norma,ASC;Field:fecha_server_publicacion,DESC">
								<xsl:if test="$actual_sort='Field:tipo_norma,ASC;Field:fecha_server_publicacion,DESC'">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>Tipo Norma
							</option>
							<option value="Field:emisor,ASC;Field:tipo_norma,ASC;Field:numero,ASC">
								<xsl:if test="$actual_sort='Field:emisor,ASC;Field:tipo_norma,ASC;Field:numero,ASC'">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>Org. Emisor
							</option>
							<option value="Field:estado,DESC;Field:tipo_norma,ASC;Field:numero,ASC">
								<xsl:if test="$actual_sort='Field:estado,DESC;Field:tipo_norma,ASC;Field:numero,ASC'">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>Estado
							</option>
							<option value="Field:fecha_server_publicacion,DESC;Field:tipo_norma,ASC;Field:numero,ASC">
								<xsl:if test="$actual_sort='Field:fecha_server_publicacion,DESC;Field:tipo_norma,ASC;Field:numero,ASC'">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>Fecha
							</option>
						</select>
					</td>
				</xsl:if>
					<td align="left" style="width:1px;">
						<a href="#" onclick="javascript:thitlist();">
							<img id="hl-expand-img" src="#!-- #IMAGES:m1.gif --#" alt="Expandir/Contraer HitList" title="Expandir/Contraer HitList" border="0"/>
						</a>
					</td>
				</xsl:if>
			</tr>
		</table>
	</xsl:template>

	<xsl:template name="WriteContexto">
		<xsl:param name="prev_type" select="none"/>
		<a href="#">
		<xsl:choose>
			<xsl:when test="$prev_type='[XML][Kwic,0]'" ><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(10);</xsl:text></xsl:attribute></xsl:when>
			<xsl:when test="$prev_type='[XML][Kwic,10]'"><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(25);</xsl:text></xsl:attribute></xsl:when>
			<xsl:when test="$prev_type='[XML][Kwic,25]'"><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(0);</xsl:text></xsl:attribute></xsl:when>
			<xsl:otherwise><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(25);</xsl:text></xsl:attribute></xsl:otherwise>
		</xsl:choose>
		<img src="#!-- #IMAGES:update-checkout.gif --#" alt="Cambiar Contexto" title="Cambiar Contexto" border="0"/></a>
	</xsl:template>
			
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
				<xsl:variable name="id_norma_title"><xsl:call-template name="WriteTituloNorma"><xsl:with-param name="string" select="title/text()" /></xsl:call-template></xsl:variable>				
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
							<xsl:value-of select="$id_norma_title"/>
							
							<xsl:variable name="fecha_publicacion"><xsl:value-of select="field[@name='fecha_publicacion']"/></xsl:variable>
							(<xsl:value-of select="field[@name='estado']"/>
							<xsl:if test="$fecha_publicacion!='' and field[@name='estado']">
								- 
							</xsl:if>
							<xsl:if test="$fecha_publicacion!=''">
								<xsl:value-of select="$fecha_publicacion"/>
							</xsl:if>)
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

	<xsl:template name="WriteTituloNorma">
		<xsl:param name="string" />
		<xsl:choose>
			<xsl:when test="contains($string, '_')">
				<!-- Escribir tipo de documento -->
				<xsl:call-template name="convertTipoNorma"><xsl:with-param name="tipo"><xsl:call-template name="get_Before"><xsl:with-param name="string" select="$string" /></xsl:call-template></xsl:with-param></xsl:call-template><xsl:text>&#160;</xsl:text>
				<xsl:variable name="string2">
					<xsl:call-template name="get_After">
						<xsl:with-param name="string" select="$string" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="contains($string2, '_')">
						 <!-- el numero -->
						<xsl:call-template name="get_Before"><xsl:with-param name="string" select="$string2" /></xsl:call-template>
						  <!-- segundo guion bajo por - -->

						<xsl:variable name="string3"><xsl:call-template name="get_After"><xsl:with-param name="string" select="$string2" /></xsl:call-template></xsl:variable>

						<xsl:choose>
							<xsl:when test="contains($string3, '_')">
								<xsl:text>-</xsl:text>
								<!-- Colocar anio -->
								<xsl:call-template name="get_Before"><xsl:with-param name="string" select="$string3" /></xsl:call-template>
								  
								  <!-- Tercer guion bajo-->
								  <xsl:text>-</xsl:text>

								  <!-- El resto -->
								  <xsl:call-template name="get_After"><xsl:with-param name="string" select="$string3" /></xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>-</xsl:text>
								<xsl:value-of select="$string3"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<span class="numero" field="numero"><xsl:value-of select="$string2"/></span>
					</xsl:otherwise> 
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
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
			<xsl:when test="$tipo='AD'" >Acuerdo De Directorio</xsl:when>
			<xsl:when test="$tipo='AR'" >Acuerdo Regional</xsl:when>
			<xsl:when test="$tipo='ADI'" >Auto Divisional</xsl:when>
			<xsl:when test="$tipo='CCI'" >Carta Circular</xsl:when>
			<xsl:when test="$tipo='CIR'" >Circular</xsl:when>
			<xsl:when test="$tipo='COM'" >Comunicado</xsl:when>
			<xsl:when test="$tipo='CPP'" >Constitucion Politica Del Peru</xsl:when>
			<xsl:when test="$tipo='CONVINT'" >Convenio Internacional</xsl:when>
			<xsl:when test="$tipo='CONVOIT'" >Convenio Oit</xsl:when>
			<xsl:when test="$tipo='DEA'" >Decisión Andina</xsl:when>
			<xsl:when test="$tipo='DEC'" >Decreto</xsl:when>
			<xsl:when test="$tipo='DA'" >Decreto De Alcaldia</xsl:when>
			<xsl:when test="$tipo='DU'" >Decreto De Urgencia</xsl:when>
			<xsl:when test="$tipo='DER'" >Decreto Ejecutivo Regional</xsl:when>
			<xsl:when test="$tipo='DLEG'" >Decreto Legislativo</xsl:when>
			<xsl:when test="$tipo='DL'" >Decreto Ley</xsl:when>
			<xsl:when test="$tipo='DR'" >Decreto Regional</xsl:when>
			<xsl:when test="$tipo='DS'" >Decreto Supremo</xsl:when>
			<xsl:when test="$tipo='DSE'" >Decreto Supremo Extraordinario</xsl:when>
			<xsl:when test="$tipo='D'" >Directiva</xsl:when>
			<xsl:when test="$tipo='E'" >Edicto</xsl:when>
			<xsl:when test="$tipo='EXP'" >Expediente</xsl:when>
			<xsl:when test="$tipo='INS'" >Instructivo</xsl:when>
			<xsl:when test="$tipo='INV'" >Investigacion</xsl:when>
			<xsl:when test="$tipo='L'" >Ley</xsl:when>
			<xsl:when test="$tipo='LC'" >Ley Constitucional</xsl:when>
			<xsl:when test="$tipo='LR'" >Ley Regional</xsl:when>
			<xsl:when test="$tipo='MAND'" >Mandato</xsl:when>
			<xsl:when test="$tipo='OF'" >Oficio</xsl:when>
			<xsl:when test="$tipo='OCI'" >Oficio Circular</xsl:when>
			<xsl:when test="$tipo='O'" >Ordenanza</xsl:when>
			<xsl:when test="$tipo='OR'" >Ordenanza Regional</xsl:when>
			<xsl:when test="$tipo='REC'" >Recomendación</xsl:when>
			<xsl:when test="$tipo='REG'" >Regulacion</xsl:when>
			<xsl:when test="$tipo='R'" >Resolucion</xsl:when>
			<xsl:when test="$tipo='RAD'" >Resolucion Administrativa</xsl:when>
			<xsl:when test="$tipo='RC'" >Resolución Cambiaria</xsl:when>
			<xsl:when test="$tipo='RCONASEV'" >Resolución Conasev</xsl:when>
			<xsl:when test="$tipo='RA'" >Resolucion De Alcaldia</xsl:when>
			<xsl:when test="$tipo='RCON'" >Resolución De Contraloría </xsl:when>
			<xsl:when test="$tipo='RDEF'" >Resolucion Defensorial</xsl:when>
			<xsl:when test="$tipo='RD'" >Resolucion Directoral</xsl:when>
			<xsl:when test="$tipo='RE'" >Resolucion Ejecutiva</xsl:when>
			<xsl:when test="$tipo='RJ'" >Resolucion Jefatural</xsl:when>
			<xsl:when test="$tipo='RLEG'" >Resolucion Legislativa</xsl:when>
			<xsl:when test="$tipo='RLR'" >Resolucion Legislativa Regional</xsl:when>
			<xsl:when test="$tipo='RM'" >Resolucion Ministerial</xsl:when>
			<xsl:when test="$tipo='RMP'" >Resolución Ministerio Público</xsl:when>
			<xsl:when test="$tipo='RSEN'" >Resolucion Senatorial</xsl:when>
			<xsl:when test="$tipo='RS'" >Resolucion Suprema</xsl:when>
			<xsl:when test="$tipo='RVM'" >Resolucion Vice Ministerial</xsl:when>
			<xsl:when test="$tipo='STC'" >Sentencia Del Tribunal Constitucional</xsl:when>
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
			<td>...<xsl:apply-templates mode="quitarjs"/>...</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="lp-hit" mode="quitarjs">
		<a>
			<!-- This href gets overridden in the onLinkClicked handler, we just add it here so the browser knows if the link has been visited or not. -->
			<xsl:attribute name="href"><!-- #EXECUTIVE:SCRIPT_NAME -->/<xsl:value-of select="../../../path"/>#<xsl:value-of select="@count"/></xsl:attribute>
			
			<xsl:attribute name="onclick">return onLinkClicked("<xsl:value-of select="../../../path"/>", "<xsl:value-of select="content-type"/>", "<xsl:value-of select="@count"/>")</xsl:attribute>
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="text()" mode="quitarjs">
	<xsl:choose>
		<xsl:when test="contains(., 'popup.focus();  }')">
			<xsl:value-of select="substring-after (., 'popup.focus();  }')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="." />
		</xsl:otherwise>
	</xsl:choose>
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
