<?xml version="1.0"?>
<!-- 
	XML Hit List template
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>

<xsl:variable name="view-begin-index" select="/list-section/view-begin-index"/>
<xsl:template match="@*|/|node()"/>
<xsl:template match="/">

	<html><head>
			<title>Resultados de Busqueda</title>
			
			<!-- <link rel="stylesheet" type="text/css"><xsl:attribute name="href"><!-- #STYLESHEETS:xhitlist.css --></xsl:attribute></link> -->
   			<link rel="stylesheet" type="text/css"><xsl:attribute name="href"><!-- #STYLESHEETS:style.css --></xsl:attribute></link>
   			<link rel="stylesheet" type="text/css"><xsl:attribute name="href"><!-- #STYLESHEETS:jquery-ui-1.8.6.custom.css --></xsl:attribute></link>            
            
   			<link rel="stylesheet" type="text/css"><xsl:attribute name="href"><!-- #STYLESHEETS:preloader/css/queryLoader.css --></xsl:attribute></link>        
            <!-- Liker -->

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
              <!-- OWN -->        
           <script type="text/javascript">
				<xsl:attribute name="src"><!-- #TEMPLATES:jquery.ui.core.js --></xsl:attribute>
				<xsl:comment>not empty</xsl:comment>
			</script>               
           <script type="text/javascript">
				<xsl:attribute name="src"><!-- #TEMPLATES:jquery.ui.datepicker-es.js --></xsl:attribute>
				<xsl:comment>not empty</xsl:comment>
			</script>
           <script type="text/javascript">
				<xsl:attribute name="src"><!-- #TEMPLATES:jquery.ui.datepicker.js --></xsl:attribute>
				<xsl:comment>not empty</xsl:comment>
			</script>
            <script type="text/javascript">
				<xsl:attribute name="src"><!-- #TEMPLATES:script.js --></xsl:attribute>
				<xsl:comment>not empty</xsl:comment>
			</script>     
            
             
            <!-- OWN -->
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
						//onLinkClicked(firstClicked.p,firstClicked.s,firstClicked.t,firstClicked.c);
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
				//	alert(params_onclick[1] + ' - ' + params_onclick[3] + ' - ' + 1 + ' - ' + hit_number);
				//	return;
					var target_window = top.frames[top.TOC_FRAME];
					if (params_onclick[1] != "" && params_onclick[3] != "" )
					{	
						onLinkClicked(params_onclick[1],params_onclick[3],1,hit_number);
						//target_window.reload();
						//alert('ECO');
					//	target_window.location = hit_a.href+"#LPHit1";
					}
					//
					
					top.toogleLayout_document();
					
					return true;
				}

				function documento() 
			{
			//var topFrame = top.document.all("topFrame");
			//if (topFrame.old_rows)
			//	topFrame.rows = topFrame.old_rows;
			top.frames[top.TOOLS_FRAME].closeToc();
			}
			
			// numeracion ... 
			var hit_number = 1;
			function mNextAcert(){
				++hit_number;
				return hit_number;
			}
			
			function mPrevAcert(){
				--hit_number;
				return hit_number;
				
			}
			
			function mGetAcert(){				
				return hit_number;				
			}
			
			function mSetAcert(num){				
				hit_number = num;
			//	return hit_number;				
			}
			//***************//
			
/*			function synchronize(current_document)
			{
				window.location = "<!-- #TEMPLATES:contents-frame-h.htm -->" + "&tf=main&cp=" + current_document + "&c=100&sync=2#TOCSYNC";
			}
			
*/		///////////////////	
		var _shit = '';
///////						
				function onLinkClicked(path, content_type, match_number, hit_number)
				{
					top.toogleLayout_document();
					// get the correct target window for the document
					
					var current_tab;
					if (top.getMainTab != null)
					{
						current_tab = top.getMainTab();
					}

					// if we have XML escaped ampersands in the query, replace them with normal ampersands
				//	documento();
					query = query.replace(/\x26amp;/g, "\x26");

				//	if (top.frames[top.TOC_FRAME] != null && top.frames[top.TOC_FRAME].synchronize)
				//		top.frames[top.TOC_FRAME].synchronize(path); //Sincronizar automaticamente con el documento seleccionado en la hitlist
						
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
					
//								alert(classHitSelected + ' - ' + hit_selected);

					mSetAcert(hit_number);
			//		if (top.frames[top.DOC_INFO_FRAME].setHitNumber)
			//			top.frames[top.DOC_INFO_FRAME].setHitNumber(hit_number);
					//top.frames['view_doc'].location = 'about:blank';
					var pos = url.indexOf('?f=templates');
					var org = url.substring(0, pos);
					if (_shit == org){
						top.frames['view_doc'].location.reload();
					}else{
						_shit = org; // asigno la cipia de la uRL clave
						top.frames['view_doc'].location = url;
					}
					
										
				//	_shit = url;
				//	no_cache = "$nc=" + Math.round(Math.random() * 10000);
				//	alert(url+no_cache);			//ESTO 2 LINEAS STAN X USTOS	 ---- XD
				///	top.frames['view_doc'].location = url+no_cache;
					//top.frames['view_doc'].location.reload();
				//	top.frames['view_doc'].location.reload();
					var separator = escape("</b> > <b>");
					var document_path = escape(getCurrentDocument(true));
					top.frames[top.DOC_INFO_FRAME].location = "<!-- #TEMPLATES:reference.htm -->$p=" + path;

			/*	alert(document_path.toString());
					return false;					*/ 		//Debugge
					top.showReference();
			//		if (top.frames[top.TOOLS_FRAME].showSearchTools)
			//			top.frames[top.TOOLS_FRAME].showSearchTools();
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
				//	alert("?f=xhitlist$xhitlist_sel=" + select + "$xhitlist_hc=" + hit_context);
					window.location.search = "?f=xhitlist$xhitlist_sel=" + select + "$xhitlist_hc=" + hit_context;
				}
				
//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
// Funcion para Filtrar por el Tipo de Dominio
	function fnc_filtrar_dominio(obj)
	{
		var dominio = $(obj).text();
	//	 $(obj).parent().css('background-color', 'white');
	//	 $(obj).css('color', '#333');
	//	 $('focus_on').value =  $(obj).parent().attr('id');
//		alert(orden);
		document.ordenar.xhitlist_d.value = "title;path;relevance-weight;content-type;home-title;hit-context;Field:tipo_norma;Field:estado;Field:emisor;Field:fecha_publicacion;Field:fecha_server_publicacion;Field:autor;Field:tipo_coleccion";
		
		document.ordenar.xhitlist_d.value = dominio;
		document.ordenar.xhitlist_hc.value = '[XML][Kwic,10]';
		document.ordenar.submit();
	}
	/*
		function fnc_finish()
	{
			setTimeout("test_finish()",10000) ;
		//	$('domi_Legislacion').css('background-color', 'white');
	}

	function test_finish(){
		alert($('hautasaa').text());
	}
			*/	
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
	/*******************////  MORE sCRIPT 06.08.2012 ... EXEC QUERY
				var emisores_exacto = false;
			



			

/* Inicio roger */
function colecciones(obj,dato){
	var campo = $_('xhitlist_d');	// asigno el ID del Control del FOrmulario
	if(!obj.checked)	{
			unCheckid(dato, campo);
	}else{
			checkid(dato, campo);
	}
}

function checkid(dato, hidden_){

//	var campo = hidden_.value;
	var campo = Colections_.push(dato);
	campo = Colections_.join(',');

	hidden_.value = campo;	
}

function $_(x){
	return 	document.getElementById(x);
}
// Arrat de ka cibkecuibes d edatis,
var Colections_ = new Array();
// FUNCIONA QUE DESCHEA
function unCheckid(dato, hidden_){
	
	if ( Colections_.indexOf(dato) > -1 ){
		Colections_.splice(Colections_.indexOf(dato), 1);
		hidden_.value = Colections_.join(',');
	}
	
}

/* Fin roger */			
	
	
//////////////
/////////////////*******
/**********************/

			function makeQuery()
			{
				/*top.frames.DocNav.total_hits=0;
				top.frames.DocNav.current_hit=-1;*/
						
	//	top.frames[top.TOOLS_FRAME].closeToc();
					//saveSearch(TMP_SEARCH_NAME);
							
				if (submitAdvQuery())
				{
					//top.frames[top.TOOLS_FRAME].closeToc();
				//	top.toogleLayout();
				
					self.goToPreloader();	// Display el Preoloader
					return true;
				}				
				return false;
			}

		function submitAdvQuery()
			{
				var q = "";

				//////////////////////////////////////////
				// Campos: pegan cosas en q (query)     //
				//////////////////////////////////////////
				var tipos_norma = "";
				$.each($("#tipo_de_normas input[@type='checkbox']:checked"), function()
				{
//				tipos_norma += ((tipos_norma != "")?"or":"") + "[Field tipo_norma:"+$(this).val()+"]";
				     tipos_norma += ((tipos_norma != "")?"or":"") + "[Field tipo_norma:'"+$(this).val()+"']";
				});
				q += ((q != "")?"&":"") + tipos_norma;
				
				var norma_id = $("#submore_legis #norma_id").val();		// Refactoring after
				/* ADD NOW (15.08.2012)	*/
				var norma_id_jur= $("#submore_jurisp #norma_id").val();		// Refactoring after				
				if (norma_id == "")	
				{
					norma_id = norma_id_jur;
				}			
				//

				var autor = $("#autor").val();
				if (autor != "")
				q += ((q != "")?"&":"") + "[Field Autor:*"+autor+"*]";				
				//
				var area = $("#area").val();
				if (area != "")
				q += ((q != "")?"&":"") + "[Field area:*"+area+"*]";
				var materias = $("#materias").val();
				if (materias != "")
				q += ((q != "")?"&":"") + "[Field materias:*"+materias+"*]or"+"[Field submaterias:*"+materias+"*]or"+"[Field subsubmaterias:*"+materias+"*]";

				/* End Now	*/
				
				if ( (norma_id != "" ) && (typeof(norma_id) != 'undefined' ) )
				{										
					norma_id = norma_id.replace(/\s|\.|\/|-|_/g, "\?");
					q += ((q != "")?"&":"") + "[Field norma_id:"+norma_id+"*]";
				}

				var nro_norma = $("#number").val();
				if (nro_norma != "")
					q += ((q != "")?"&":"") + "[Field numero:"+nro_norma+"]";
				
				var anio_norma = $("#anio").val();
				if (anio_norma.length > 2 && parseInt(anio_norma)<=1999)
					anio_norma = anio_norma.substring(2);
				if (anio_norma != "")
					q += ((q != "")?"&":"") + "[Field anio:"+anio_norma+"]";
					
				var estado = $("#Estado").val();
				if (estado != "")
					q += ((q != "")?"&":"") + "[Field estado:"+estado+"]";
					
				var FechaInicio = date2aaaammdd($("#FechaInicio").val());
				if (FechaInicio != "")
					q += ((q != "")?"&":"") + "[Field fecha_server_publicacion:>="+FechaInicio+"]";

				var FechaFin = date2aaaammdd($("#FechaFin").val());
				if (FechaFin != "")
					q += ((q != "")?"&":"") + "[Field fecha_server_publicacion:<="+FechaFin+"]";
					
				
				var emisores = $("#emisor").val().split(",");
				if (emisores != "")
				{
					var emisores_qry="";
					for  (var i=0 ; i<emisores.length ; ++i)
					{
						var asterisco = "*";
						if (emisores_exacto == true)
							asterisco = "";
						
						emisores_qry += ((emisores_qry != "")?"or":"") + "[Field emisor:"+asterisco+emisores[i]+asterisco+"]";
					}
					if (emisores_qry != "")
						q += ((q != "")?"&":"") + emisores_qry;
				}
		
// Retirado por mlugo,para quitar busqueda	por temas

//				var tema_sub = $("#Tema").val();
// 				if (tema_sub != "")
// 				q += ((q != "")?"&":"") + "[Field materias:*"+tema_sub+"*]or[Field areas:*"+tema_sub+"*]";
					
				var Sumilla = $("#submore_legis #Sumilla").val();
				/* BEGIN ADD NOW */
				
				var Sumilla_jur= $("#submore_jurisp #Sumilla").val();		// Refactoring after				
				if (Sumilla == "")	
				{
					Sumilla = Sumilla_jur;
				}	
				
				/* END ADD NOW*/
				if ( (Sumilla != "")  &&  (typeof(Sumilla) != 'undefined' ) )
				{
					Sumilla = Sumilla.replace(/ó|ú|á|é|í|ó/g, "\?"); //
					//alert("Sumilla: " +Sumilla);
					q += ((q != "")?"&":"") + "[Field sumilla:*"+Sumilla+"*]";
				}

				//////////////////////////////////////////
				// Campos generales                     //
				//////////////////////////////////////////
					
				var text = $("#text").val();
				if (text != ""  && (typeof(text) != 'undefined' ) )
				{
					text = text.replace(/ó|ú|á|é|í|ó/g, "\?"); //
					q += ((q != "")?"&":"") + text;
					q += ((q != "")?" or ":"") + "[Field keywords:"+text+"]";
				}
//				alert("HolAAA" + norma_id);return;	
				if (q == "")
				{
					alert("Debe completar al menos un campo del formulario de búsqueda");
					return false;
				}
				
				//alert(q);
				saveSearch(TMP_SEARCH_NAME, HITLISTX_FRAME_OBJ);
				
				//$("#xhitlist_d").val('Legislacion');	
				$("#xhitlist_d").val(top.NAME_CLASS_MENU.substring(1));
				$("#xhitlist_q").val(q);
				top.countStart(); //Tiempo en MS que tarda la busqueda
				$("#ordenar").submit();
				
				return true;
			}

/*
function submitQuery()
{
	var ui = document.ui_form;
	var request = document.request_form;

	if (ui.q.value.indexOf('[rank') != -1)
	{
		request.xhitlist_s.value = 'Relevance-Weight';
	}
	
	request.xhitlist_q.value = ui.q.value;
	//alert(request.xhitlist_q.value);
	if (request.xhitlist_q.value != "")
	{
		//SetupQuery();
		request.submit();
		top.toogleLayout();
	//	top.frames[top.TOOLS_FRAME].closeToc();
		saveSearch(TMP_SEARCH_NAME);
	}
	else
	{
		alert("Ingrese algun criterio de busqueda.");
	}
}

*/
///////////////////****** More Script 03/03/2012
			function date2aaaammdd(val)
			{
				if (val == null || val == "")
					return val;
					
				var val_split = val.split("/");
				var new_date = "";
				for (var i=(val_split.length-1) ; i>-1 ; --i)
				{
					var item = val_split[i];
					if (item.length == 1) item = "0"+item;
					new_date += item;
				}
				return new_date;
			}
		// SHot tocer!
/*	$(document).ready(function() {
		$("#left_rheaders li a").click(funcion(){
			if( ! $(this).hasClass('selecti') ) {
					$(this).addClass('selecti');
			}
			return false;
		});
	});				*/

//------------------
//-------------------
function setNameClass(obj)
{
	top.NAME_CLASS_MENU = obj.id ;
	fnc_filtrar_dominio(obj)
	//alert(top.NAME_CLASS_MENU);
}

function goToPreloader(){
	$("#preloader").css('display', 'block');
}

$(document).ready(function() {
	
  $("#preloader").delay(700).fadeOut("slow");	
  // Handler for .ready() called.
 // alert('EcoMas');
 $('#'+top.NAME_CLASS_MENU).addClass('selectMenu');
 	//alert(top.NAME_CLASS_MENU);
 if ( top.NAME_CLASS_MENU == 'mLegislacion'){
	/* $('#moreOptionShow').css('display', 'none');	*/
	$('#submore_jurisp').css('display', 'none');
	$('#submore_doctrina').css('display', 'none');
	// Los tipos
	$('#sub_tipo_jurisp').css('display', 'none');
	// Texto a Mostrar
	$("#text_domino").html("Búsqueda Avanzada  de Legislación");
	
 }else  if ( top.NAME_CLASS_MENU == 'mJurisprudencia'){
	/* $('#moreOptionShow').css('display', 'none');	*/
	$('#submore_legis').css('display', 'none');
	$('#submore_doctrina').css('display', 'none');
	// Los tipos
	$('#sub_tipo_legis').css('display', 'none');	
	// Texto a Mostrar
	$("#text_domino").html("Búsqueda Avanzada  de Jurisprudencia");	
	
 }else  if ( top.NAME_CLASS_MENU == 'mDoctrina'){
	/* $('#moreOptionShow').css('display', 'none');	*/
	$('#submore_legis').css('display', 'none');
	$('#submore_jurisp').css('display', 'none');		
	// Oculto x q este dominio no tiene tipo de norma
	$('#clickiTN').css('display', 'none');
	// Texto a Mostrar
	$("#text_domino").html("Búsqueda Avanzada  de Doctrina");	
	
 }else {
	/* 	$('#clickiTN').css('display', 'none');
		$('#clicki').css('display', 'none');	*/
 }	
})

//------------------------

$(document).ready(function(){	
// para el mouse over
	$("#item_table .yesrow").mouseover(function(){
		$(this).css('background-color', '#E1F0F9');		
		$(this).next().css('background-color', '#E1F0F9');				
	});
	$("#item_table .yesrow").next().mouseover(function(){
		$(this).css('background-color', '#E1F0F9');		
		$(this).prev().css('background-color', '#E1F0F9');		
	});
// para el mouse out	
	$("#item_table .yesrow").mouseout(function(){
		$(this).css('background-color', '#FFF');		
		$(this).next().css('background-color', '#FFF');				
	});
	$("#item_table .yesrow").next().mouseout(function(){
		$(this).css('background-color', '#FFF');		
		$(this).prev().css('background-color', '#FFF');		
	});	
});


// funciones de mas // xD
/*
function onColorRow(obj, id){
	$(obj).css('background-color', '#E1F0F9');
	$(obj).next().css('background-color', '#E1F0F9');
	
}
function onColorRowOut(obj, id){
	$(obj).css('background-color', '#FFF');
	$(obj).next().css('background-color', '#FFF');
	
}
*/
//---------------------------
	
	
	function showerContent()
	{
		top.toogleLayout_AcerContent();
	}
	
//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
// Funcion para Filtrar por el Tipo de Dominio
	function fnc_filtrar_dominio(obj)
	{
		var dominio = $(obj).attr('id').substring(1);
		//alert(dominio);
	//	 $(obj).parent().css('background-color', 'white');
	//	 $(obj).css('color', '#333');
	//	 $('focus_on').value =  $(obj).parent().attr('id');
//		alert(orden);
		
		document.ordenar.xhitlist_d.value = dominio;
		document.ordenar.xhitlist_hc.value = '[XML][Kwic,10]';
		document.ordenar.submit();
	}
	

				function doPrintXitlist_()
				{
					//window.parent.view_doc.frames[0].focus();
					window.print();
				}	
//------------------------------------------------------------------------------------------------------------------------------------
// Return Home
function goHome(){
	top.toogleLayout_home();		
}

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
				
/*				#zone_cont_content_2 {
					padding: 15px 20px;
					
				}	*/
#submore_legis {
	
}
#submore_jurisp {
	
}
#submore_doctrina { 

}

/* Type style CheckBox	*/
#sub_tipo_jurisp {
	
}
#sub_tipo_legis {
	
}

.my_style_preloader {
	z-index:40000;
	position:fixed;
	height:100%;
	width:100%;
	background-color:#fff;
	opacity: 0.9;
	filter: alpha(opacity = 90);
	top: 0; 
	text-align:center;
	
/*				*/
  position:fixed;
  _position:absolute;
  top:0;
  _top:expression(eval(document.body.scrollTop));
  overflow: hidden; 
	
}
			</style>

<link rel="stylesheet" href="http://dataonline.gacetajuridica.com.pe/autocompletado/autocomplete_2/autocomplete/autocomplete.css" type="text/css" media="screen" />
<script src="http://dataonline.gacetajuridica.com.pe/autocompletado/autocomplete_2/autocomplete/dimensions.js" type="text/javascript"></script>
<script src="http://dataonline.gacetajuridica.com.pe/autocompletado/autocomplete_2/autocomplete/autocomplete.js" type="text/javascript"></script>
<script src="http://dataonline.gacetajuridica.com.pe/autocompletado/autocomplete_2/autocomplete/my_js.js" type="text/javascript"></script>            

<script type="text/javascript">
	$(function(){
	    setAutoComplete("text", "results", "http://dataonline.gacetajuridica.com.pe/autocompletado/autocomplete_2/autocomplete/autocomplete.php?part=");
	});
</script>            
<script type="text/javascript">
//	$(document).ready(function() {
	 
//	}
</script>            
		</head>
			<body>
            
<div id="preloader" class="my_style_preloader">
 
    <div id="preloaderWrapper" style="width:150px;margin:20% auto;text-align:center;background:none">     
        <img src="#!-- #IMAGES:loading7.gif --#" width="150" /><br />     
  
    </div>
 
</div>            
            
            <div id="main">
	<div id="container">    	
    	<div id="header">
<!--        	<div id="spacing_top"></div> -->
            <div id="menu_logo">
            	<div id="logo">
                	<a title="Ir a la Home" href="javascript:goHome();"><img width="326" height="71" border="0">
                    	<xsl:attribute name="src"><!-- #IMAGES:logo.jpg --></xsl:attribute>
                        </img></a>
                </div>
                <div id="conte_menu">
                	<ul id="menu">
                        <li><a href="#" id="mLegislacion" onclick="setNameClass(this);">Legislación <!-- <xsl:value-of select="list-section/home-title" /> --></a></li> 
                        <li><a href="#" id="mJurisprudencia" onclick="setNameClass(this);">Jurisprudencia</a></li> 
                        <li><a href="#" id="mDoctrina" onclick="setNameClass(this);">Doctrina</a></li>
                        <li><a href="#" title="Volver al Buscador" class="icon_home" onclick="javascript:goHome();">Volver</a></li>                                
                        <li><a href="#" class="icon_logout" onclick="javascript:top.deleteYeahCookies();">Cerrar</a></li>                                              
					</ul>
                </div>            
            </div>
        </div>
        
        <div id="content">
        	<div id="content_forms">
            <form name="ui_form" onsubmit="makeQuery(); return false;" target="_self">
            	<div id="form_controls" style="background-color: #FFF;">
                	<div class="single_line">
	                    Búsqueda Libre! <a href="#" title="Ayuda" onClick="javascript:open_popup('libre');" id="helps_home"><img style="margin-left:5px;" src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /></a>          
                        
                        <a id="clickSaved" onclick="javascript:consultaSearchs();" style="color:#595959; margin-left: 10px;; font-weight: 600;" href="#">(Ver Búsqueda(s) guardada(s))</a>   
                                       
                        <div id="shower_saved_search" style="padding:0px;overflow: auto; height: auto; width: 300px;">
                        	<div style="height: 20px; text-align: right;"><a style="color:#FFF; margin-right: 5px;" href="#" onclick="javascript:goSilverSaved();">Cerrar</a></div>
                        	<iframe style="height:auto" id="myIframe" src="about:blank" marginheight="0" marginwidth="0" frameborder="0" width="300"></iframe>
                        </div>


         
                    </div>
                    <div class="single_line" style="margin-bottom: 5px; " id="meta_auto">
	                    <input type="text" value="" autocomplete="off" id="text" name="text" class="ieField" style="width: 280px; margin-right: 3px" />                    
                        
                        <input type="submit" value="Buscar" id="submit" class="ieBoton" />
                    </div>
               <!--     <div class="single_line">
                    	<label for="chk_legis"><input type="checkbox" name="chk_legis" id="chk_legis" value="Legislacion" onClick="colecciones(this,this.value)" />Legislación</label>
                        <label for="chk_jurisp"><input type="checkbox" name="chk_jurisp" id="chk_jurisp" value="Jurisprudencia" onClick="colecciones(this,this.value);" />Jurisprudencia</label>
                        <label for="chk_Doctrina"><input type="checkbox" name="chk_Doctrina" id="chk_Doctrina" value="Doctrina" onClick="colecciones(this,this.value)" />Doctrina</label>
                     </div>		-->
                     <div class="single_line" id="moreOptionShow">
	                   <a style="margin:0 5px 0 0;" id="clicki" href="#"> <img style="margin-right: 5px;" src="#!-- #IMAGES:flech.jpg --#" width="7" height="13" border="0" alt="fecha" /> <span style="display:inline; float:none;" id="text_domino">Búsqueda Avanzada  de Legislación</span> <!--<span style="font-size:12px; display: inline; float: none; ">(Llenar al menos un campo)</span>--></a>               <a id="clickiTN" href="#"> <img src="#!-- #IMAGES:flech.jpg --#" width="7" height="13" border="0" alt="fecha" /> Tipos de Normas</a>
                    </div>
                    </div>
                  <!-- TOpis de Normas-->
                	<div id="tipo_de_normas" style="padding:0px;overflow: auto; height: 345px; width: 280px">
                    	<div id="sub_tipo_legis">
							<ul>
								<a onclick="toggleType('Acuerdos', this);" href="#"><b>+ Acuerdos</b></a>
								<ul class="tipo_de_norma_subitem" id="Acuerdos">
									<li><label value="En Acuerdo"><input type="checkbox" value="A " id="A " name="A" /></label><b>Acuerdo</b>
									</li><li><label value="En Acuerdo De Directorio"><input type="checkbox" value="AD" id="AD" name="AD" /></label>Acuerdo De Directorio
									</li><li><label value="En Acuerdo Regional"><input type="checkbox" value="AR" id="AR" name="AR" /></label>Acuerdo Regional
								</li></ul>
								<li><label value="En Carta Circular"><input type="checkbox" value="CCI" id="CCI" name="CCI" /></label>Carta Circular
								</li><li><label value="En Circular"><input type="checkbox" value="CIR" id="CIR" name="CIR" /></label>Circular
								</li><li><label value="En Comunicado"><input type="checkbox" value="COM" id="COM" name="COM" /></label>Comunicado
								</li><li><label value="En Constitucion Politica Del Peru"><input type="checkbox" value="CPP" id="CPP" name="CPP" /></label>Constitucion Politica Del Peru
								</li><li><label value="En Decisión Andina"><input type="checkbox" value="DECISION" id="DECISION" name="DECISION" /></label>Decisión Andina
								</li><li>
									<a onclick="toggleType('Decretos', this);" href="#"><b>+ Decretos</b></a>
									<ul class="tipo_de_norma_subitem" id="Decretos">
										<li><label value="En Decreto"><input type="checkbox" value="DEC" id="DEC" name="DEC" /></label>Decreto
										</li><li><label value="En Decreto De Alcaldia"><input type="checkbox" value="DA" id="DA" name="DA" /></label>Decreto De Alcaldia
										</li><li><label value="En Decreto De Urgencia"><input type="checkbox" value="DU" id="DU" name="DU" /></label>Decreto De Urgencia
										</li><li><label value="En Decreto Ejecutivo Regional"><input type="checkbox" value="DER" id="DER" name="DER" /></label>Decreto Ejecutivo Regional
										</li><li><label value="En Decreto Legislativo"><input type="checkbox" value="DLEG" id="DLEG" name="DLEG" /></label>Decreto Legislativo
										</li><li><label value="En Decreto Ley"><input type="checkbox" value="DL" id="DL" name="DL" /></label>Decreto Ley
										</li><li><label value="En Decreto Regional"><input type="checkbox" value="DR" id="DR" name="DR" /></label>Decreto Regional
										</li><li><label value="En Decreto Supremo"><input type="checkbox" value="DS" id="DS" name="DS" /></label>Decreto Supremo
										</li><li><label value="En Decreto Supremo Extraordinario"><input type="checkbox" value="DSE" id="DSE" name="DSE" /></label>Decreto Supremo Extraordinario
									</li></ul>
								</li>
								<li><label value="En Directiva"><input type="checkbox" value="D" id="D" name="D" /></label>Directiva
								</li><li><label value="En Edicto"><input type="checkbox" value="E" id="E" name="E" /></label>Edicto
								</li><li><label value="En Expediente"><input type="checkbox" value="EXP" id="EXP" name="EXP" /></label>Expediente
								</li><li>
									<a onclick="toggleType('Leyes', this);" href="#"><b>+ Leyes</b></a>
									<ul class="tipo_de_norma_subitem" id="Leyes">
										<li><label value="En Ley"><input type="checkbox" value="L" id="L" name="L" /></label>Ley
										</li><li><label value="En Ley Constitucional"><input type="checkbox" value="LC" id="LC" name="LC" /></label>Ley Constitucional
										</li><li><label value="En Ley Regional"><input type="checkbox" value="LR" id="LR" name="LR" /></label>Ley Regional
									</li></ul>
								</li>
								<li>
									<a onclick="toggleType('Oficios', this);" href="#"><b>+ Oficios</b></a>
									<ul class="tipo_de_norma_subitem" id="Oficios">
										<li><label value="En Oficio"><input type="checkbox" value="OF" id="OF" name="OF" /></label>Oficio
										</li><li><label value="En Oficio Circular"><input type="checkbox" value="OCI" id="OCI" name="OCI" /></label>Oficio Circular

									</li></ul>
								</li>
								<li>
									<a onclick="toggleType('Ordenanzas', this);" href="#"><b>+ Ordenanzas</b></a>
									<ul class="tipo_de_norma_subitem" id="Ordenanzas">
										<li><label value="En Ordenanza"><input type="checkbox" value="O" id="O" name="O" /></label>Ordenanza
										</li><li><label value="En Ordenanza Regional"><input type="checkbox" value="OR" id="OR" name="OR" /></label>Ordenanza Regional
									</li></ul>
								</li>
								<li>
									<a onclick="toggleType('Resoluciones', this);" href="#"><b>+ Resoluciones</b></a>
									<ul class="tipo_de_norma_subitem" id="Resoluciones">
										<li><label value="En Resolucion"><input type="checkbox" value="R" id="R" name="R" /></label>Resolucion
										</li><li><label value="En Resolucion Administrativa"><input type="checkbox" value="RAD" id="RAD" name="RAD" /></label>Resolucion Administrativa
										</li><li><label value="En Resolución Cambiaria"><input type="checkbox" value="RC" id="RC" name="RC" /></label>Resolución Cambiaria
										</li><li><label value="En Resolucion De Alcaldia"><input type="checkbox" value="RA" id="RA" name="RA" /></label>Resolucion De Alcaldia
										</li><li><label value="En Resolucion Directoral"><input type="checkbox" value="RD" id="RD" name="RD" /></label>Resolucion Directoral
										</li><li><label value="En Resolucion Ejecutiva"><input type="checkbox" value="RE" id="RE" name="RE" /></label>Resolucion Ejecutiva
										</li><li><label value="En Resolucion Jefatural"><input type="checkbox" value="RJ" id="RJ" name="RJ" /></label>Resolucion Jefatural
										</li><li><label value="En Resolucion Legislativa"><input type="checkbox" value="RLEG" id="RLEG" name="RLEG" /></label>Resolucion Legislativa
										</li><li><label value="En Resolucion Legislativa Regional"><input type="checkbox" value="RLR" id="RLR" name="RLR" /></label>Resolucion Legislativa Regional
										</li><li><label value="En Resolucion Ministerial"><input type="checkbox" value="RM" id="RM" name="RM" /></label>Resolucion Ministerial
										</li><li><label value="En Resolucion Senatorial"><input type="checkbox" value="RSEN" id="RSEN" name="RSEN" /></label>Resolucion Senatorial
										</li><li><label value="En Resolucion Suprema"><input type="checkbox" value="RS" id="RS" name="RS" /></label>Resolucion Suprema
										</li><li><label value="En Resolucion Vice Ministerial"><input type="checkbox" value="RVM" id="RVM" name="RVM" /></label>Resolucion Vice Ministerial 
									</li></ul>
								</li>
								<li>
									<a onclick="toggleType('Otros', this);" href="#"><b>+ Otros</b></a>
									<ul class="tipo_de_norma_subitem" id="Otros">
										<li><label value="En Auto Divisional"><input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Auto Divisional
										</li><li><label value="En Instructivo"><input type="checkbox" value="INS" id="INS" name="INS" /></label>Instructivo
										</li><li><label value="En Investigacion"><input type="checkbox" value="INV" id="INV" name="INV" /></label>Investigacion
										</li><li><label value="En Mandato"><input type="checkbox" value="MAND" id="MAND" name="MAND" /></label>Mandato
										</li><li><label value="En Recomendación"><input type="checkbox" value="REC" id="REC" name="REC" /></label>Recomendación
										</li><li><label value="En Regulacion"><input type="checkbox" value="REG" id="REG" name="REG" /></label>Regulacion		
										 
									</li></ul>
								</li>
						</ul>
                        </div>
                        	<div id="sub_tipo_jurisp">
                            	<ul>
								<li><label value="En Acción Contencioso Administrativa"><input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Acción Contencioso Administrativa
								</li><li><label value="En Acción Popular ">              <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Acción Popular 
								</li><li><label value="En Acuerdo">                      <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Acuerdo
								</li><li><label value="En Casación">                     <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Casación
								</li><li><label value="En Consulta">                     <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Consulta
								</li><li><label value="En Expediente">                   <input type="checkbox" value="EXP" id="EXP" name="EXP" /></label>Expediente
								</li><li><label value="En Habeas Corpus">                <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Habeas Corpus
								</li><li><label value="En Instrucción">                  <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Instrucción
								</li><li><label value="En Proceso">                      <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Proceso
								</li><li><label value="En Queja">                        <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Queja
								</li><li><label value="En Recurso de Nulidad">           <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Recurso de Nulidad
								</li><li><label value="En Resolución Administrativa">    <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Resolución Administrativa
								</li><li><label value="En Resolución Directoral">        <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Resolución Directoral
								</li><li><label value="En Resolución Ministerial">       <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Resolución Ministerial
								</li><li><label value="En Resolución Suprema">           <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Resolución Suprema
								</li><li><label value="En Resolución Tribunal Fiscal">   <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Resolución Tribunal Fiscal
								</li><li><label value="En Resolución Tribunal Registral"><input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Resolución Tribunal Registral
								</li><li><label value="En Resolución Vice Ministerial">  <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Resolución Vice Ministerial
								</li><li><label value="En Sala Civil">                   <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Sala Civil
								</li><li><label value="En Sentencia">                    <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Sentencia
								</li><li><label value="En Sentencia del TC">             <input type="checkbox" value="ADI" id="ADI" name="ADI" /></label>Sentencia del TC
							</li></ul>
                            </div>
                        </div>              
                <!-- end Tipo de Normas -->
            <!-- Begin More Options -->
                    <div id="poption_more">
                    	<div id="submore_legis">
	                     <div class="single_line spacing_single">
                            <span>Tipo y Número:</span> <input class="fheight ieField" type="text" name="norma_id" id="norma_id" style=" margin-right: 3px" />                    
                            <a href="#" title="Ayuda" onClick="javascript:open_popup('Identificador');" id="hTipo_Numero"><img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /> </a><a href="#" onClick="toggleFiltroEmisores('mas_tipo_dispo');"><span class="subtitulo">Ver lista de dispositivos</span></a>
                            
                  		  </div> 
                          
                          <!--  BEGIN ADD FIELDS OLD--> 
                          <div class="single_line spacing_single tipo_de_norma_subitem" id="mas_tipo_dispo">
                            <span style="color: #fff;">field</span>
                            <ul id="tipo_dispositivo" class="tipo_de_norma_subitem" style="display: block;">
														<select id='lsttipocliente' name='lsttipocliente' onChange='actualizar(this)'>
														    <option value="" selected="selected">Elija un dispositivo</option>
															  <option value="A ">Acuerdo</option>
															  <option value="ADI ">Acuerdo de Directorio</option>
															  <option value="AR ">Acuerdo Regional</option>
															  <option value="ADIV ">Auto Divisional</option>
															  <option value="CCI  ">Carta Circular</option>
															  <option value="CIR ">Circular</option>
															  <option value="COM ">Comunicado</option>
															  <option value="CPP ">Constitucion Politica Del Peru</option>
															  <option value="DECISION ">Decisión Andina</option>
															  <option value="DEC ">Decreto</option>
															  <option value="DA ">Decreto de Alcaldia</option>
															  <option value="DU ">Decreto de Urgencia</option>
															  <option value="DER ">Decreto Ejecutivo Regional</option>
															  <option value="DLEG ">Decreto Legislativo</option>
															  <option value="DL ">Decreto Ley</option>
															  <option value="DR ">Decreto Regional</option>
															  <option value="DS ">Decreto Supremo</option>
															  <option value="DSE ">Decreto Supremo Extraordinario</option>
															  <option value="D ">Directiva</option>
															  <option value="E ">Edicto</option>
															  <option value="EXP ">Expediente</option>
															  <option value="INS ">Instructivo</option>
															  <option value="INV ">Investigacion</option>
															  <option value="L ">Ley</option>
															  <option value="LC ">Ley Constitucional</option>
															  <option value="LR ">Ley Regional</option>
															  <option value="MAND ">Mandato</option>
															  <option value="OF ">Oficio</option>
															  <option value="OCI ">Oficio Circular</option>
															  <option value="O ">Ordenanza</option>
															  <option value="OR ">Ordenanza Regional</option>
															  <option value="REC ">Recomendación</option>
															  <option value="REG ">Regulación</option>
															  <option value="R ">Resolución</option>
															  <option value="RAD ">Resolución Administrativa</option>
															  <option value="RC ">Resolución Cambiaria</option>
															  <option value="RA ">Resolución de Alcaldía</option>
															  <option value="RD ">Resolución Directoral</option>
															  <option value="RE ">Resolución Ejecutiva</option>
															  <option value="RJ ">Resolución Jefatural</option>
															  <option value="RLEG ">Resolución Legislativa</option>
															  <option value="RLR "> Resolución Legislativa Regional</option>
															  <option value="RM "> Resolución Ministerial</option>
															  <option value="RS ">Resolución Suprema</option>
															  <option value="RVM ">Resolución Vice Ministerial</option>
													    </select>	
													</ul>
                  		  </div>
                          <!-- END ADD FIELDS OLD -->
                          
                           <div class="single_line spacing_single">
                            <span>Numero:</span> <input class="fheight ieField" type="text" name="number" id="number"  style=" margin-right: 3px; width: 50px;" />                    
                              <a href="#" title="Ayuda" id="hnumber"><img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /> </a>
                              <!-- Begin ToolTip -->
                            	<div id="capaHelp_hnumber">
                                <div class="capHel_left"></div>
                                <div class="capHel_center">
                                	<strong>Número</strong>  <br /><em> Puede prescindir de los ceros <br /> a la izquierda</em>
                                </div>
                                <div class="capHel_right"></div>                                
								</div>
                             <!-- End TOolTip -->
                             Año: <input class="fheight ieField" type="text"  name="anio" id="anio" style=" margin-right: 3px; width: 50px;" />                    
                             <a href="#" title="Ayuda" id="hanio"><img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /> </a>
                                <!-- Begin ToolTip -->
                            	<div id="capaHelp_hanio">
                                <div class="capHel_left"></div>
                                <div class="capHel_center">
                                	<strong>Año</strong>  <br /><em> Ingresar los 4 dígitos del año<br /> </em>
                                </div>
                                <div class="capHel_right"></div>      
								</div>
                             <!-- End TOolTip -->          
                  		  </div>                          
                                                 
                          
                            <div class="single_line spacing_single">
                            <span>Organismo Emisor:</span> <input class="fheight ieField" type="text"  name="emisor" id="emisor"  style="margin-right: 3px" />                    
                             <a href="#" id="horgaemiso"><img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /></a>
                             <a href="#" onClick="toggleFiltroEmisoresXD('mas_tipo_filtro', this);" style="margin-left: 5px;"><span class="subtitulo">Mostrar Filtro</span></a>
                               <!-- Begin ToolTip -->
                            	<div id="capaHelp_horgaemiso">
                               <div class="capHel_left"></div>
                                <div class="capHel_center" style="width: 440px;">
                                	<strong>Órgano emisor</strong>  <br /><em>Coloque abreviaturas o siglas o cliquee <strong>"Mostrar Filtro"</strong><br />para obtener lista de organismos emisores y cliquee para seleccionarlos </em>
                                </div>
                                <div class="capHel_right"></div>  
								</div>
                             <!-- End TOolTip -->    
                  		  </div> 
        				  
                          
                          <!--  BEGIN ADD FIELDS OLD--> 
                          <div class="single_line spacing_single tipo_de_norma_subitem" id="mas_tipo_filtro">
<!--                          <span>&nbsp;</span> 	-->
<div id="FiltroEmisores" style="display:block; z-index: 8000;">
<script src="http://www.java.com/js/deployJava.js"></script>
<script>

	var IE= navigator.userAgent.toLowerCase().indexOf('msie') > -1;
	if (IE){
		//alert(deployJava.getJREs()+ ' \n '+  deployJava.isPlugin2());
			if (!deployJava.isPlugin2()){
			//alert(deployJava.getJREs()+ ' \n '+  deployJava.isPlugin2());
				document.write("<span style='font-weight:bold; display: block; width: 100%;'> Necesita el complemento Java(TM). Para descargar click <a href='http://www.java.com/en/download/testjava.jsp' target='_blank' >Aquí.</a></span>");
		}	
	}
	
	var firefox= navigator.userAgent.toLowerCase().indexOf('firefox/') > -1;
	if (firefox){ 
		if (deployJava.getJREs()==undefined || deployJava.getJREs()=='' )
						document.write("<span style='font-weight:bold; display: block; width: 100%;'> Necesita el complemento Java(TM). Para descargar click <a href='http://www.java.com/en/download/testjava.jsp' target='_blank' >Aquí.</a></span>");
	}
	

</script>
													<applet archive="JWW.jar"
														  code="EditBox.class"
														  codeBase="/CLP/Applets"
														  name="EmisorEditBox"
														  width="300" 
														  height="22">
														
															<param name="background"  value="0xAAAAAA" />
															<param name="bordercolor" value="0xb0b0b0" />
															<param name="textcolor"   value="0x000000" />

															<param name="wordwheel"	 value="EmisorWordWheel" /> 
															<param name="query"		 value="[Field,emisor:*]" />
															<param name="ScriptName" value="#!-- #EXECUTIVE:SCRIPT_NAME --#" />
													</applet>
													<br/>
													<applet 
														  archive="JWW.jar"
														  code="WordWheel.class"
														  codeBase="/CLP/Applets"
														  name="EmisorWordWheel"
														  width="400"
														  height="200"	>
														  
															<param name="background"	  value="0xAAAAAA" />
															<param name="buttoncolor"	  value="0xb0b0b0" />
															<param name="scrollcolor"	  value="0xd0d0d0" />
															<param name="bordercolor"	  value="0xb0b0b0" />
															<param name="textcolor"	      value="0x000000" />
															<param name="selectcolor"	  value="0xe0e0e0" />
															<param name="selecttextcolor" value="0x000000" />

															<PARAM NAME="cachesize"	 VALUE="500" />
															<PARAM NAME="chunksize"	 VALUE="500" />
															<PARAM NAME="domain"	 VALUE="" />
															<PARAM NAME="inserthook" VALUE="tipo_normaInsertWWHook" />
															<PARAM NAME="selecthook" VALUE="emisoresWWHook" />
															<PARAM NAME="extdll"	 VALUE="#!-- #EXECUTIVE:SCRIPT_NAME --#" />
															<PARAM NAME="query"		 VALUE="[Field,emisor:*]" />
															<PARAM NAME="selectable" VALUE="1" />
															<param NAME="editbox"	 VALUE="EmisorEditBox" />
													</applet>
												</div>
                            
                  		  </div>
                          <!-- END ADD FIELDS OLD -->                        
                                             
						<div class="single_line spacing_single">
                            <span>Estado:</span>
                            <select name="Estado" id="Estado" style="width: 150px;" class="ieField">
                              <option value="">-- Estado --</option>
                              <option value="Vigente">Vigente</option>
                              <option value="Derogada">Derogada</option>
                              <!-- <option value="DerogadoTacitamente">Derogado Tacitamente</option>
														<option value="Caduco">Caduco</option>
														<option value="EnSuspenso">En Suspenso</option>
														<option value="Inconstitucional">Inconstitucional</option> -->
                            </select>
                            <a href="#" id="hestado" style="margin-left:2px;"> <img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /> </a>
                            <!-- Begin ToolTip -->
                            	<div id="capaHelp_hestado">
                                    <div class="capHel_left"></div>
                                <div class="capHel_center">
                                	<strong>Estado</strong>  <br /><em> Seleccione uno de los estados<br /> </em>
                                </div>
                                <div class="capHel_right"></div>  
								</div>
                             <!-- End TOolTip -->   
           		    </div>                                             
                                             
                          <div class="single_line spacing_single">
                            <span>Buscar en sumillas:</span> <input class="fheight ieField" type="text" name="Sumilla" id="Sumilla" style="margin-right: 3px" />                    
                             <a href="#" id="hsumilla"><img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /> </a>
                             <!-- Begin ToolTip -->
                            	<div id="capaHelp_hsumilla">  
								<div class="capHel_left"></div>
                                <div class="capHel_center" style="width: 250px;">
                                	  <strong>Título de la norma </strong>  <br /><em>Búsqueda por palabras contenidas en el título de las normas</em>
                                </div>
                                <div class="capHel_right"></div> 
                                <div class="capHel_rigth"></div>                                
								</div>
                             <!-- End TOolTip -->    
                  		  </div>     
                          	 
                                 
                          <div class="single_line spacing_single">
                            <span>Fecha de Publicacion 
(Desde):</span> <input class="fheight bg_ico_date ieField" type="text" name="FechaInicio" id="FechaInicio" autocomplete="off" style=" margin-right: 3px; width: 90px;" />          
                            (Hasta): <input class="fheight bg_ico_date ieField" type="text" autocomplete="off" name="FechaFin" id="FechaFin" style=" margin-right: 3px; width: 90px;" />                    
                  		  </div>                
                    </div>
                    
                    <!-- more options of Jurisprudencia -->
                    <div id="submore_jurisp">
                    	              <div class="single_line spacing_single">
                            <span>Expediente:</span> <input class="fheight ieField" type="text"  name="norma_id" id="norma_id"  style="margin-right: 3px" />                    
                             <a href="#" id="jexpediente"> <img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /></a>
                              <!-- Begin ToolTip -->
                            	<div id="capaHelp_jexpediente">
                               <div class="capHel_left"></div>
                                <div class="capHel_center" style="width: 480px;">
                                	<strong>Número completo</strong>  <br /><em>Busque aqui solo si conoce el Identificador exacto de la resolucion  compuesto<br /> por la abreviatura, número,  </em> etc. ordenados y separados por guiones o espacios.
                                </div>
                                <div class="capHel_right"></div>  
								</div>
                             <!-- End TOolTip -->    
                  		  </div>
                          <div class="single_line spacing_single">
                            <span>Área:</span> <input class="fheight ieField" type="text"  name="area" id="area"  style=" margin-right: 3px" />                    
                             <a href="#" id="jareas"> <img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /></a>
                              <!-- Begin ToolTip -->
                            	<div id="capaHelp_jareas">
                               <div class="capHel_left"></div>
                                <div class="capHel_center" style="width: 330px;">
                                	<strong>Área ( Rama del Derecho )</strong>  <br /><em>Especifique el área en forma general<br />Ejemplo: PENAL, CIVIL, AMBIENTAL, COMERCIAL, etc.  </em>
                                </div>
                                <div class="capHel_right"></div>  
								</div>
                             <!-- End TOolTip -->    
                  		  </div>
                          <div class="single_line spacing_single">
                            <span>Materias:</span> <input class="fheight ieField" type="text"  name="materias" id="materias"  style=" margin-right: 3px" />                    
                             <a href="#" id="jmaterias"> <img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /></a>
                              <!-- Begin ToolTip -->
                            	<div id="capaHelp_jmaterias">
                               <div class="capHel_left"></div>
                                <div class="capHel_center" style="width: 300px;">
                                	<strong>Busqueda por Materia / Submateria</strong>  <br /><em>Puede buscar Jurisprudencia catalogada <br />por Materias / SubMaterias (ingrese solo una)  </em>
                                </div>
                                <div class="capHel_right"></div>  
								</div>
                             <!-- End TOolTip -->    
                  		  </div>
                          <div class="single_line spacing_single">
                            <span>Tema:</span> <input class="fheight ieField" type="text"  name="Sumilla" id="Sumilla"  style=" margin-right: 3px" />                    
                             <a href="#" id="horgaemiso" style="display: none;"> <img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /></a>
                              <!-- Begin ToolTip -->
                            	<div id="capaHelp_horgaemiso">
                               <div class="capHel_left"></div>
                                <div class="capHel_center" style="width: 440px;">
                                	<strong>Órgano emisor</strong>  <br /><em>Coloque abreviaturas o siglas o cliquee <strong>"Mostrar Filtro"</strong><br />para obtener lista de organismos emisores y cliquee para seleccionarlos </em>
                                </div>
                                <div class="capHel_right"></div>  
								</div>
                             <!-- End TOolTip -->    
                  		  </div>
                          
                          
                    </div>
                            
                    <!-- more options of Doctrina -->
                    <div id="submore_doctrina">
                    							<div class="single_line spacing_single">
                            <span>Autor:</span> <input class="fheight ieField" type="text"  name="autor" id="autor"  style="margin-right: 3px" />                    
                           <!--  <a href="#" id="jexpediente"> <img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /></a> -->
                              <!-- Begin ToolTip -->
                            	<div id="capaHelp_jexpediente">
                               <div class="capHel_left"></div>
                                <div class="capHel_center" style="width: 480px;">
                                	<strong>Número completo</strong>  <br /><em>Busque aqui solo si conoce el Identificador exacto de la resolucion  compuesto<br /> por la abreviatura, número,  </em> etc. ordenados y separados por guiones o espacios.
                                </div>
                                <div class="capHel_right"></div>  
								</div>
                             <!-- End TOolTip -->    
                  		  </div>
                          <div class="single_line spacing_single">
                            <span>Titulo:</span> <input class="fheight ieField" type="text"  name="titulo" id="titulo"  style="margin-right: 3px" />                    
                            <!-- <a href="#" id="jexpediente"> <img src="#!-- #IMAGES:ico_help.png --#" width="15"  height="15" border="0" alt="ico help" /></a>	-->
                              <!-- Begin ToolTip -->
                            	<div id="capaHelp_jexpediente">
                               <div class="capHel_left"></div>
                                <div class="capHel_center" style="width: 480px;">
                                	<strong>Número completo</strong>  <br /><em>Busque aqui solo si conoce el Identificador exacto de la resolucion  compuesto<br /> por la abreviatura, número,  </em> etc. ordenados y separados por guiones o espacios.
                                </div>
                                <div class="capHel_right"></div>  
								</div>
                             <!-- End TOolTip -->    
                  		  </div>
                    </div>
                    <!-- Boton para Limpiar -->
                          <div class="single_line spacing_single" style="text-align: right; margin-bottom: 0px;">
                          	<input type="reset" value="Limpiar" class="iesClear" style="width: 80px" />
                            
                  		  </div>                                           
                    
          </div>
                    <!-- End More Options -->
             
            
            </form>
            <!--  List Results -->
            
               
    </div>
    <div id="content_results">
            	<div id="c_results_header"> 
                	<div id="left_rheaders">               	                
                        <ul>
                            <li><a href="#" class="selecti">Mostrar Aciertos</a></li>
                            <li><a href="#" class="" onclick="javascript:showerContent();">Mostrar Contenidos</a></li>
                            <li><a href="#" title="Imprimir Resultado" class="selecti ico_print" onClick="javascript:doPrintXitlist_();">Imprimir:  <img style="margin-top:2px;" src="#!-- #IMAGES:b_print.png --#" align="absmiddle" border="0" /></a></li>
                        </ul>
                    </div>
                    <div id="right_rheaders" style="margin-left: 20px;">               	                
                        <ul>
	                        <li>
                        	<xsl:call-template name="WriteContexto">
								<xsl:with-param name="prev_type" select="/list-section/hit-context-param" />
							</xsl:call-template>
                            </li>
	                        <li><a href="#" class="ico_note" onclick="javascript:toggleSearchInfo()">Termino de Busqueda</a></li>
                            <li><a href="#" class="ico_save save_from_tmp" onclick="javascript:doSaveSearch();">Guardar Busqueda</a></li>
                            <li>                              
                                
                                <select onchange="fnc_ordenar(this)" syle="width: 50px;">
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
                            </li>
                        </ul>
                    </div>
                    
                </div>     
                

              <!-- Begin Pagination	--> 
              <div style="margin-top: 8px;">
              	<xsl:call-template name="hitlist_navigate_tools"></xsl:call-template>
              </div>
              <!-- End PAgination-->
              
                              
                <div id="zone_cont_content">
				
                	
				<form name="ordenar" id="ordenar" method="get" target="_self">
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
					<input type="hidden" size="0" name="xhitlist_d" id="xhitlist_d"	  value="">
						<xsl:attribute name="value"><xsl:value-of select="list-section/domain"/></xsl:attribute>
					</input>
					<input type="hidden" size="0" name="xhitlist_q" id="xhitlist_q"	  value="">
						<xsl:attribute name="value"><xsl:value-of select="list-section/escaped-query"/></xsl:attribute>
					</input>
					<input type="hidden" size="0" name="xhitlist_hc"  value="[XML][Kwic,10]" />
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
							<table id="item_table" cellspacing="0" border="0" cellpadding="5"><xsl:apply-templates/></table>
						</form>
						
						<br/>
						<xsl:call-template name="hitlist_tools_bar">
							<xsl:with-param name="show_buttons" select="'no'"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
		
                
               </div>     
               <!-- Begin Mostrar COntenidos -->
              <!-- </h1> <div id="zone_cont_content_2">          
               		
			   </div> 	-->                   
               <!-- End Mostrar Contenidos -->
              <!-- Begin Pagination	--> 
              	<xsl:call-template name="hitlist_navigate_tools"></xsl:call-template>
              <!-- End PAgination-->
			<!--	<div id="date_update_msg" style="color:#555; font-weight: 600;">		-->
          	   <!--  	Se actualizó por última vez el: 03-07-2012 a las 7:26:33.25	-->
               
				<!--    <iframe src="#!-- #TEMPLATES:actualizacion.html --#" width="400" marginheight="0" frameborder="0" height="50" marginwidth="0"></iframe>	-->
               
               <!-- End Show Frame -->
      <!--     </div>	-->
            </div>
</div>
</div>
           </div> 
            <div id="resultados"></div>

<!-- Begin Sreen Black -->
	<div id="screen_black">
    </div>
<!--  End Sreen Black -->
<!-- 	Preloder		-->
<script>
	//	QueryLoader.selectorPreload = "body";
	//	QueryLoader.init();
</script>

<!--	End Preloader	-->
            
			</body>
		</html>
	</xsl:template>

	<xsl:template match="list-section"><xsl:apply-templates/></xsl:template>
	
		<!--  <xsl:template match="home-title">
        <span style="color:#ff0000">
	           <xsl:value-of select="."/>
        </span>
         <br />
	</xsl:template> -->

	<xsl:template name="hitlist_navigate_tools">
		<td>
        <div  class="pagination">
			<xsl:if test="list-section/query-syntax[.='Simple' or .='simple']">
				<td>Resultados para <b><xsl:value-of select="list-section/query" /></b></td>
			</xsl:if>            
			<xsl:if test="list-section/view-is-begin[.='no']">
            <div class="all_left">
				<a class="arrow_left_all" id="first" href="#" onclick="moveViewport('first');return false;"></a>
				<a class="arrow_left_single" id="prev"  href="#" onclick="moveViewport('prev'); return false;"></a>
            </div>                
			</xsl:if>

            <div class="all_center">
			<xsl:value-of select="list-section/view-begin-index" />
			a
			<xsl:value-of select="list-section/view-end-index" />
            de
           <!-- <xsl:value-of select="list-section/max-hits" /> -->
           <xsl:value-of select="list-section/hit-count"/>
            </div>           
			<xsl:if test="list-section/view-is-end[.='no']">
             <div class="all_right">
				<a class="arrow_right_single" id="next" href="#" onclick="moveViewport('next');return false;"></a>
				<a class="arrow_right_all" id="last" href="#" onclick="moveViewport('last');return false;"></a>
            </div>			                
			</xsl:if>
			<xsl:variable name="actual_hc" select="sum(list-section/max-hits[number(.)=number(.)])"/>
<!--			<select onchange="fnc_hitcount(this)">
				<option value="50" ><xsl:if test="$actual_hc &gt; 0 and $actual_hc &lt; 51" ><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>50</option>
				<option value="100"><xsl:if test="$actual_hc &gt; 50 and $actual_hc &lt; 101"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>100</option>
				<option value="200"><xsl:if test="$actual_hc &gt; 100 and $actual_hc &lt; 201"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>200</option>
				<option value="300"><xsl:if test="$actual_hc &gt; 200 and $actual_hc &lt; 301"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>300</option>
				<option value="400"><xsl:if test="$actual_hc &gt; 300 and $actual_hc &lt; 401"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>400</option>
				<option value="500"><xsl:if test="$actual_hc &gt; 400 and $actual_hc &lt; 501"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>500</option>
				<option value="10000"><xsl:if test="$actual_hc &gt; 500"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>&gt;500</option>
			</select>
            aciertos
-->			<!-- xsl:value-of select="list-section/hit-count"/ -->			
           </div> 
		</td>
	</xsl:template>
    <!-- Begin Magic -->

    	
    <!-- End Magic-->
	<xsl:template name="hitlist_tools_bar">
		<xsl:param name="show_buttons" select="'yes'"/>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#FFFFFF">
			<tr style="background-color: lightgrey; height: 25px;">
				<!--<xsl:call-template name="hitlist_navigate_tools"></xsl:call-template>-->
				<xsl:if test="$show_buttons='yes'">
				<xsl:if test="list-section[not(concept-query) or concept-query[. != 'yes']]">


				</xsl:if>
					
				</xsl:if>
			</tr>
		</table>
	</xsl:template>

	<xsl:template name="WriteContexto">
		<xsl:param name="prev_type" select="none"/>
		<a href="#" title="Cambiar Contexto" class="ico_book">
		<xsl:choose>
			<xsl:when test="$prev_type='[XML][Kwic,0]'" ><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(10);</xsl:text></xsl:attribute></xsl:when>
			<xsl:when test="$prev_type='[XML][Kwic,10]'"><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(25);</xsl:text></xsl:attribute></xsl:when>
			<xsl:when test="$prev_type='[XML][Kwic,25]'"><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(0);</xsl:text></xsl:attribute></xsl:when>
			<xsl:otherwise><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(25);</xsl:text></xsl:attribute></xsl:otherwise>            
		</xsl:choose>
        <xsl:text>Cambiar Contexto</xsl:text>
		<!-- <img src="#!-- #IMAGES:update-checkout.gif --#" alt="Cambiar Contexto" title="Cambiar Contexto" border="0"/>-->
        </a>
	</xsl:template>
			
	<!-- Node (hit list entry) templates -->
	<xsl:template match="item">
		<xsl:variable name="current-item"><xsl:number/></xsl:variable>
		<xsl:variable name="relevance-weight"><xsl:value-of select="relevance-weight"/></xsl:variable>
		<xsl:element name="tr">
        <xsl:attribute name="class">yesrow</xsl:attribute>
<!--    <xsl:attribute name="id">rowfil_<xsl:number value="$current-item + $view-begin-index - 1"/></xsl:attribute>							-->
<!--    <xsl:attribute name="onmouseover">onColorRow(this,rowfil_<xsl:number value="$current-item + $view-begin-index - 1"/>);</xsl:attribute>	-->
<!--	<xsl:attribute name="onmouseout">onColorRowOut(this,rowfil_<xsl:number value="$current-item + $view-begin-index - 1"/>);</xsl:attribute>-->
			<!-- xsl:choose>
				<xsl:when test="position() mod 2 = 0">
					<xsl:attribute name="style">background-color:#FFFFFF;</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="style">background-color:#AB5312;</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose -->

			<td valign="top" class="item_count">  <!-- class="hit-count" -->
				 <xsl:number value="$current-item + $view-begin-index - 1"/>. 	<!-- Aqui enumeramos en el Listado -->
			</td>
			
			<xsl:element name="td">
				<xsl:attribute name="class">item_name</xsl:attribute>
				<xsl:attribute name="id"><xsl:number value="$current-item + $view-begin-index - 1"/></xsl:attribute>
				<xsl:variable name="id_norma_title"><xsl:call-template name="WriteTituloNorma"><xsl:with-param name="string" select="title/text()" /></xsl:call-template></xsl:variable>				
				<a>
					<xsl:attribute name="href"><!-- #EXECUTIVE:SCRIPT_NAME -->/<xsl:value-of select="path"/></xsl:attribute>
					<xsl:attribute name="id">a<xsl:number value="$current-item + $view-begin-index - 1"/></xsl:attribute>

					<xsl:attribute name="onclick">return onLinkClicked("<xsl:value-of select="path"/>", "<xsl:value-of select="content-type"/>", "1", "<xsl:number value="$current-item + $view-begin-index - 1"/>")</xsl:attribute>
					<img border="0" align="bottom" style="margin-right: 10px;">
						<xsl:attribute name="src"><!-- #IMAGES:ico_list_book.jpg --></xsl:attribute>
					</img>

					<xsl:choose>
						<!-- <xsl:when test="home-title='Jurisprudencia'"></xsl:when>
						<xsl:when test="home-title='Doctrina'"></xsl:when> -->

						<xsl:when test="home-title='Jurisprudencia'">
						
							<xsl:variable name="sumilla"><xsl:value-of select="field[@name='sumilla']"/></xsl:variable>
					
						<!--	<xsl:value-of select="title"/>		-->
							<script type="text/javascript">	
								var title_text =  "<xsl:value-of select="title"/>";
								document.write(title_text.replace(/Vista original/gi, ""));
							
							</script>        
							<!-- xsl:if test="$sumilla!=''">
							<xsl:text>(</xsl:text><xsl:value-of select="field[@name='sumilla']"/><xsl:text>)</xsl:text>
							</xsl:if -->
							<xsl:text> - </xsl:text><span style="font-weight:bold;text-decoration:underline;color: #FF9F00;font-size: 13px;"><xsl:value-of select="home-title"/></span> 
						
						</xsl:when>
												
						<xsl:when test="home-title='Doctrina'">
						
							<xsl:variable name="sumilla"><xsl:value-of select="field[@name='sumilla']"/></xsl:variable>
					
						<!--	<xsl:value-of select="title"/>		-->
							<script type="text/javascript">	
								var title_text =  "<xsl:value-of select="title"/>";
								document.write(title_text.replace(/Vista original/gi, ""));
							
							</script>                        
							<!-- xsl:if test="$sumilla!=''">
							<xsl:text>(</xsl:text><xsl:value-of select="field[@name='sumilla']"/><xsl:text>)</xsl:text>
							</xsl:if -->
							<xsl:text> -- </xsl:text><span style="font-weight:bold;text-decoration:underline;color: #008000;font-size: 13px;"><xsl:value-of select="home-title"/></span> 
												
						</xsl:when>
						<xsl:otherwise> <!-- Legislacion -->
						<!--		<xsl:value-of select="$id_norma_title"/>	-->
							<script type="text/javascript">		
								var title_text =  "<xsl:value-of select="$id_norma_title"/>";
								document.write(title_text.replace(/\- Vista original/gi, "").toUpperCase());
							
							</script>							
							<xsl:variable name="fecha_publicacion"><xsl:value-of select="field[@name='fecha_publicacion']"/></xsl:variable>
                            (<xsl:if test="$fecha_publicacion!=''">
								<xsl:value-of select="$fecha_publicacion"/>
							</xsl:if>)
                            <xsl:if test="field[@name='estado']!=''">
							                            
							<!--<xsl:if test="$fecha_publicacion!='' and field[@name='estado']">-->
                            (<xsl:value-of select="field[@name='estado']"/>) 
							<!--	<xsl:if test="$fecha_publicacion!='' and field[@name='estado']">		-->
							<script type="text/javascript">	
								var estado_text =  "<xsl:value-of select="title"/>";
								//document.write(estado_text.substr(0,1).toUpperCase() + estado_text.substr(2));
							
							</script>   
                                  
							</xsl:if>
							
							<xsl:text> - </xsl:text><span style="font-weight:bold;text-decoration:underline;color: #CC0000;font-size: 13px;"><xsl:value-of select="home-title"/></span> 
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
			<td class="zon_text_content">...<xsl:apply-templates mode="quitarjs"/>...</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="lp-hit" mode="quitarjs">
		<a class="text-resalt">
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
