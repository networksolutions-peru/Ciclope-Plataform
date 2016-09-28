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
<meta name="viewport" content="width=device-width, minimum-scale=1.0, maximum-scale=1.0" />			
			<!-- <link rel="stylesheet" type="text/css"><xsl:attribute name="href"><!-- #STYLESHEETS:xhitlist.css --></xsl:attribute></link> -->
			<link rel="stylesheet" type="text/css"><xsl:attribute name="href">https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css</xsl:attribute></link>        
   			<link rel="stylesheet" type="text/css"><xsl:attribute name="href"><!-- #STYLESHEETS:style2.css --></xsl:attribute></link>
   			          
            
   			<link rel="stylesheet" type="text/css"><xsl:attribute name="href"><!-- #STYLESHEETS:preloader/css/queryLoader.css --></xsl:attribute></link>        
			
            <!-- Liker -->
			
			<script type="text/javascript">
				<xsl:attribute name="src"><!-- #TEMPLATES:jquery.min3.js --></xsl:attribute>
				<xsl:comment>not empty</xsl:comment>
			</script>     

			<script type="text/javascript">
				<xsl:attribute name="src"><!-- #TEMPLATES:bootstrap.min.js --></xsl:attribute>
				<xsl:comment>not empty</xsl:comment>
			</script>     			

			<script type="text/javascript">
				<xsl:attribute name="src"><!-- #TEMPLATES:tri-state-check.js --></xsl:attribute>
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
			// globals
			var query = "<xsl:value-of select="list-section/escaped-query"/>";
			var syntax = "<xsl:value-of select="list-section/query-syntax"/>";
			var select = "<xsl:value-of select="list-section/select"/>";
			var is_concept_query = "<xsl:value-of select="list-section/concept-query"/>";
			var hit_count = "<xsl:value-of select="list-section/hit-count"/>";
			var que_dominio_two = "<xsl:value-of select="list-section/item/home-title" />";			

			var orden;
			var firstClicked = {};
			var classHitSelected = "hit_selected";
			<![CDATA[
			<!-- -->
				var hit_selected = null;
				$(document).ready(function()
				{
				/*	if (hit_count<=0)
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
					}*/
//					top.countEnd();

					scrollWin();

				});




				function scrollWin() {
				    $('html,body').animate({
				        scrollTop: $("#zone_cont_content").offset().top
				    }, 2000);
				}


				
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
//					top.toogleLayout_document();
					// get the correct target window for the document
					
/*					var current_tab;
					if (top.getMainTab != null)
					{
						current_tab = top.getMainTab();
					}
*/
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

//					mSetAcert(hit_number);
			//		if (top.frames[top.DOC_INFO_FRAME].setHitNumber)
			//			top.frames[top.DOC_INFO_FRAME].setHitNumber(hit_number);
					//top.frames['view_doc'].location = 'about:blank';
/*					var pos = url.indexOf('?f=templates');
					var org = url.substring(0, pos);
					if (_shit == org){
						top.frames['view_doc'].location.reload();
					}else{
						_shit = org; // asigno la cipia de la uRL clave
						top.frames['view_doc'].location = url;
					}
*/					
					window.location = url;						
				//	_shit = url;
				//	no_cache = "$nc=" + Math.round(Math.random() * 10000);
				//	alert(url+no_cache);			//ESTO 2 LINEAS STAN X USTOS	 ---- XD
				///	top.frames['view_doc'].location = url+no_cache;
					//top.frames['view_doc'].location.reload();
				//	top.frames['view_doc'].location.reload();
					var separator = escape("</b> > <b>");
					var document_path = escape(getCurrentDocument(true));
//					top.frames[top.DOC_INFO_FRAME].location = "<!-- #TEMPLATES:reference.htm -->$p=" + path;

			/*	alert(document_path.toString());
					return false;					*/ 		//Debugge
//					top.showReference();
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
		document.ordenar.xhitlist_hc.value = '[XML][Kwic,0]';
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
//				saveSearch(TMP_SEARCH_NAME, HITLISTX_FRAME_OBJ);
				
				//$("#xhitlist_d").val('Legislacion');	
//				$("#xhitlist_d").val(top.NAME_CLASS_MENU.substring(1));
				
					var definedDomin  = null;
					 if ( que_dominio_two == 'Legislacion'){		// old mData_del_Contador
						definedDomin  = 'Legislacion';
					 }else  if ( que_dominio_two == 'Jurisprudencia'){	// old mJurisprudencia_data_contadores
						definedDomin  = 'Jurisprudencia';					
					 }else  if ( que_dominio_two == 'Doctrina'){ // eje. alias doctrina  -->		// old mConsultas-data_contadores						
						definedDomin  = 'Doctrina';					
					 }else {
					
					 }	
	
				$("#xhitlist_d").val(definedDomin);						
				
				$("#xhitlist_q").val(q);
//				top.countStart(); //Tiempo en MS que tarda la busqueda
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
//	top.NAME_CLASS_MENU = obj.id ;
	fnc_filtrar_dominio(obj)
	//alert(top.NAME_CLASS_MENU);
}

function goToPreloader(){
	$("#preloader").css('display', 'block');
}

$(document).ready(function() {
//	alert(que_dominio_two); return;
  $("#preloader").delay(700).fadeOut("slow");	
  // Handler for .ready() called.
 // alert('EcoMas');
 
 //$('#'+top.NAME_CLASS_MENU).addClass('selectMenu');
 	//alert(top.NAME_CLASS_MENU);
 if ( que_dominio_two == 'Legislacion' ){
	/* $('#moreOptionShow').css('display', 'none');	*/
	$('#submore_jurisp').css('display', 'none');
	$('#submore_doctrina').css('display', 'none');
	// Los tipos
	$('#sub_tipo_jurisp').css('display', 'none');
	// Texto a Mostrar
	$("#text_domino").html("BÚSQUEDA AVANZADA  DE LEGISLACIÓN");
	
	// asigno el menu seleccionado
	$("#mLegislacion").addClass("item_select");
	
 }else  if ( que_dominio_two == 'Jurisprudencia' ){
	/* $('#moreOptionShow').css('display', 'none');	*/
	$('#submore_legis').css('display', 'none');
	$('#submore_doctrina').css('display', 'none');
	// Los tipos
	$('#sub_tipo_legis').css('display', 'none');	
	// Texto a Mostrar
	$("#text_domino").html("BÚSQUEDA AVANZADA DE JURISPRUDENCIA");	
	// asigno el menu seleccionado
	$("#mJurisprudencia").addClass("item_select");	
	
 }else  if ( que_dominio_two == 'Doctrina' ){
	/* $('#moreOptionShow').css('display', 'none');	*/
	$('#submore_legis').css('display', 'none');
	$('#submore_jurisp').css('display', 'none');		
	// Oculto x q este dominio no tiene tipo de norma
	$('#clickiTN').css('display', 'none');
	// Texto a Mostrar
	$("#text_domino").html("BÚSQUEDA AVANZADA DE DOCTRINA");	
	// asigno el menu seleccionado
	$("#mDoctrina").addClass("item_select");		
	
 }else {
	/* 	$('#clickiTN').css('display', 'none');
		$('#clicki').css('display', 'none');	*/
	$('#submore_jurisp').css('display', 'none');
	$('#submore_doctrina').css('display', 'none');
	// Los tipos
	$('#sub_tipo_jurisp').css('display', 'none');
	// Texto a Mostrar
	$("#text_domino").html("BÚSQUEDA AVANZADA  DE LEGISLACIÓN");
	
	// asigno el menu seleccionado
	$("#mLegislacion").addClass("item_select");		
 }	
});

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
		document.ordenar.xhitlist_hc.value = '[XML][Kwic,0]';
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

			// script for iPhone 
			var native = window.webkit.messageHandlers.native;	

			// script for call 
			var clicks = 0;	
				// iphone
				function showIphoneToast(pin){
					
					var message = {"cmd":"increment","pin": pin,"close":"cerrar", "count":clicks,"callbackFunc":function(responseAsJSON){
						var response = JSON.parse(responseAsJSON);
						clicks = response['count']; /// la mac
	
						pin = response['pin'];

					}.toString()}
					native.postMessage(message)
					}
		

// comunicacion con la APP
function cerrarApp(){
		var ua = navigator.userAgent.toLowerCase();
		var isAndroid = ua.indexOf("android") > -1; //&& ua.indexOf("mobile");
		if(isAndroid) {
		  Android.closeApp();
		}else{
		  showIphoneToast("");
		}

	//	Android.closeApp();
	
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

#content{
	overflow-y: scroll;
	-webkit-overflow-scrolling:touch;
	height:640px;
}
			</style>

         
		</head>
			<body>
            
<div id="preloader" class="my_style_preloader">
 
    <div id="preloaderWrapper" style="width:150px;margin:20% auto;text-align:center;background:none">     
        <img src="#!-- #IMAGES:loading7.gif --#" width="150" /><br />     
  
    </div>
 
</div>            
            
            <div id="main">
	   	
          <header style="height: 140px;">
            <div class="container clearfix">
              <h1 id="logo" style="margin-left: -5px;margin-top: 0px;">
               <img  src="#!-- #IMAGES:LOGO-ET.png --#"  alt="logo" />
              </h1>
              <nav id="toper">
                <a href="#!-- #TEMPLATES:default.htm --#" class="btn btn-sq-sm btn-danger linki">
                  <i class="glyphicon glyphicon-home"></i><br/>
                  Inicio
                </a>
                <a href="#" onclick="cerrarApp();" class="btn btn-sq-sm btn-danger linki">
                  <i class="glyphicon glyphicon-log-out"></i><br/>
                  Salir
                </a>         

              </nav>
            </div>
            <div class="clearfix">
              <nav id="menus" >
                <a href="#!-- #TEMPLATES:default.htm --#" class="btn btn-sq-sm btn-danger">
                  <i class="glyphicon glyphicon-chevron-left"></i><br/>
                  Volver
                </a>
               <!-- <a href="#" class="btn btn-sq-sm btn-danger">
                  <i class="glyphicon glyphicon-chevron-right"></i><br/>
                  Acierto
                </a> 
                <a href="#" class="btn btn-sq-sm btn-danger">
                  <i class="glyphicon glyphicon-remove-sign"></i><br/>
                  Borrar
                </a> 
                <a href="#" class="btn btn-sq-sm btn-danger">
                  <i class="glyphicon glyphicon-circle-arrow-down"></i><br/>
                  Descarga
                </a> -->


              </nav>
            </div>
          </header>
        <div id="container"> 
        <div id="content">
		
		
        	<div id="content_forms">
            <form name="ui_form" onsubmit="makeQuery(); return false;" target="_self">



                    <!-- End More Options -->             
            
            </form>
            <!--  List Results -->
            
               
    </div>
    <div id="content_results">
            	<div id="c_results_header" style="display:none;"> 
                	<div id="left_rheaders" style="display: none;">               	                
                        <ul>
                            <li><a href="#" class="selecti">Mostrar Aciertos</a></li>
                           <!-- <li><a href="#" class="" onclick="javascript:showerContent();">Mostrar Contenidos</a></li> -->
                            <!-- <li><a href="#" title="Imprimir Resultado" class="selecti ico_print" onClick="javascript:doPrintXitlist_();">Imprimir:  <img style="margin-top:2px;" src="#!-- #IMAGES:b_print.png --#" align="absmiddle" border="0" /></a></li> -->
                        </ul>
                    </div>
                    <div id="right_rheaders" style="margin-left: 20px;">               	                
                        <ul>
	                        <li>
                        	<xsl:call-template name="WriteContexto">
								<xsl:with-param name="prev_type" select="/list-section/hit-context-param" />
							</xsl:call-template>
                            </li>
	                        <!-- <li><a href="#" class="ico_note" onclick="javascript:toggleSearchInfo()">Termino de Busqueda</a></li> -->
                            <!-- <li><a href="#" class="ico_save save_from_tmp" onclick="javascript:doSaveSearch();">Guardar Busqueda</a></li> -->
                            <!--<li>                              
                                
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
                            </li> -->
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
					<input type="hidden" size="0" name="xhitlist_hc"  value="[XML][Kwic,0]" />
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
							          <hgroup class="mb20">
                <!-- <h1>Resultados de la búsqueda</h1> -->
                <h2 class="lead">Se han encontrado <strong class="text-danger"><xsl:value-of select="list-section/hit-count"/></strong> documentos.</h2>                
              </hgroup>
							
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
        <nav style="text-align: center; font-size: 0.78em;">
		<ul class="pagination">
			<xsl:if test="list-section/query-syntax[.='Simple' or .='simple']">
				<td>Resultados para <b><xsl:value-of select="list-section/query" /></b></td>
			</xsl:if>            
			<xsl:if test="list-section/view-is-begin[.='no']">
            <li>
			  <a href="#" aria-label="Previous" onclick="moveViewport('first');return false;">
				<span aria-hidden="true"> ◄ ◄ </span>
			  </a>
			</li>
            <li>
			  <a href="#" aria-label="Previous">
				<span aria-hidden="true" onclick="moveViewport('prev'); return false;"> ◄ </span>
			  </a>
			</li>			


			</xsl:if>

            <li><a href="#">
			<xsl:value-of select="list-section/view-begin-index" />
			a
			<xsl:value-of select="list-section/view-end-index" />
            de
           <!-- <xsl:value-of select="list-section/max-hits" /> -->		
			<xsl:value-of select="list-section/hit-count"/>
			</a></li>			

        
			<xsl:if test="list-section/view-is-end[.='no']">
			
			<li>
			  <a href="#" aria-label="Next" onclick="moveViewport('next');return false;">
				<span aria-hidden="true">►</span>
			  </a>
			</li>
			<li>
			  <a href="#" aria-label="Next" onclick="moveViewport('last');return false;">
				<span aria-hidden="true">►►</span>
			  </a>
			</li>				
		                
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
            </ul>
		</nav>
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
		<!-- <a href="#" title="Cambiar Contexto" class="ico_book">
		<xsl:choose>
			<xsl:when test="$prev_type='[XML][Kwic,0]'" ><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(10);</xsl:text></xsl:attribute></xsl:when>
			<xsl:when test="$prev_type='[XML][Kwic,10]'"><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(25);</xsl:text></xsl:attribute></xsl:when>
			<xsl:when test="$prev_type='[XML][Kwic,25]'"><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(0);</xsl:text></xsl:attribute></xsl:when>
			<xsl:otherwise><xsl:attribute name="onclick"><xsl:text>showDocumentExcerpts(25);</xsl:text></xsl:attribute></xsl:otherwise>            
		</xsl:choose>
        <xsl:text>Cambiar Contexto</xsl:text>
		
        </a> -->
        <!--<img src="#!-- #IMAGES:update-checkout.gif --#" alt="Cambiar Contexto" title="Cambiar Contexto" border="0"/>-->
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
<!--					<img border="0" align="bottom" style="margin-right: 10px;">
						<xsl:attribute name="src"><!-- #IMAGES:ico_list_book.jpg --></xsl:attribute>
					</img>
-->
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
			<td class="zon_text_content_null">...<xsl:apply-templates mode="quitarjs"/>...</td>
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
