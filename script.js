
function elim_cookies()
					{
						if (document.cookie != "")
						{
							if (confirm("Desea salir de la aplicacion?"))
							{
								var la_cookie = document.cookie.split("; ");
								var fecha_fin = new Date();
								fecha_fin.setDate(fecha_fin.getDate()-1);

								for (i=0; i<la_cookie.length; i++)
								{
									var mi_cookie = la_cookie[i].split("=")[0];
									var cookie_value = (la_cookie[i].split("=")[1] != null ? la_cookie[i].split("=")[1] : "");
									document.cookie = mi_cookie+"="+cookie_value+";expires=" + fecha_fin.toGMTString()+"; path=/";
								}
								//document.write("Se han eliminado: " + la_cookie.length + " Cookies ")
								top.window.location = "http://dataonline.gacetajuridica.com.pe/clp/movil.asp";
								//window.parent.close();
							}
						}
					}

// JavaScript Document

$(document).ready(function(){
				// Fecha del Calendario
				$.datepicker.setDefaults($.datepicker.regional['es']);
				$( "#FechaInicio" ).datepicker({ dateFormat:'d/m/yy' });
				$( "#FechaFin" ).datepicker({ dateFormat:'d/m/yy' });
				
		$("#FechaFin").focus(function() {
	//		alert("I'm  so happy");
		});
				//loadSavedSearch();
				/*if (top.frames[top.DOC_INFO_FRAME].reset)
					top.frames[top.DOC_INFO_FRAME].reset();*/
				//top.expandDocFrameToggle($('#doc-expand-img'));
				//top.hideReference();
				
	// CLick en para desplecar las demas opciones		
	
	
		
	$("#clicki").click(function () {
		
		if ($("#poption_more").is(":hidden")) {
/*			if ($("#tipo_de_normas").is(":hidden")){
				$("#poption_more").css('margin-left','270px');
			}else{
				$("#poption_more").css('margin-left','50px');	
			}*/
			$("#poption_more").slideDown("slow", function() {
// Animation complete.
//	alert("lalalalal");
//	scrollWin_option();
				    $('html,body').animate({
				        scrollTop: $("#poption_more").offset().top
				    }, 2000);
});
		//	$("#tipo_de_normas").slideDown("slow");
		} else {
		
			$("#poption_more").slideUp();
		//	$("#poption_more").css('margin-left','200');
		//	$("#tipo_de_normas").slideUp();
		}
		//scrollWin_option();
		
		//$("#poption_more").slideDown();
	});
	
	
	$("#clicki").click();
	
	
	
	// Sxrpt TIpo de Normas  para desplegar
	$("#clickiTN").click(function () {
		
		if ($("#tipo_de_normas").is(":hidden")) {
			$("#poption_more").css('margin-left','20px');
			$("#tipo_de_normas").slideDown("slow");
		} else {
			$("#tipo_de_normas").hide();
			$("#poption_more").css('margin-left','270px');
		}

		//$("#poption_more").slideDown();
	});
	
	
		// SScript para mostrar las busqwuedas guardadas

		$(".clickSaved").click(function () {
		
		if ($("#shower_saved_search").is(":hidden")) {
		//	$("#poption_more").css('margin-left','20px');
			$("#screen_black").fadeTo("slow",0.7);
			$("#shower_saved_search").slideDown("slow");
		} else {
			$("#shower_saved_search").hide();
			$("#screen_black").fadeTo("slow",1);
		//	$("#poption_more").css('margin-left','270px');
		}

		//$("#poption_more").slideDown();
	});
	
});
///////////
/*
				function scrollWin_option() {
				    $('html,body').animate({
				        scrollTop: $("#poption_more").offset().top
				    }, 2000);
				}
*/
//////////////
	
function consultaSearchs()
{
	$("#myIframe").attr('src', '#!-- #TEMPLATES:form_busqueda/consulta_busquedas.htm --#');
}	

/*	---------------  */
function goSilverSaved(){
	$('#shower_saved_search').slideUp('slow');
	$("#screen_black").fadeTo("slow", 0, function(){
		$(this).css("display", "none");

	});
}


/////////// =================== Script	

$(document).ready(function(){
	$("#clicki_h").click(function () {
		
		if ($("#poption_more").is(":hidden")) {
			  $('#form_controls').animate({
/*				opacity: 0.25,	*/
				left: '+=50',
				marginTop: '10px'
				/*height: 'toggle'*/
			  }, 500, function() {
				// Animation complete.
				$("#poption_more").slideDown("slow");
			  });
			//$("#poption_more").slideDown("slow");
			document.getElementById('chk1').checked = true;					
		} else {
			$("#poption_more").slideUp(null, function(){
				 $('#form_controls').animate({
/*				opacity: 0.25,	*/
				left: '+=50',
				marginTop: '100px'
				/*height: 'toggle'*/
			  }, 500, function() {
				// Animation complete.					
			  });			  		
				
			});
			 
		
			$("#chk1").checked = true;
			document.getElementById('chk1').checked = false;								
		}


		//$("#poption_more").slideDown();
	});
	
	// Sxrpt TIpo de Normas 
	$("#clickiTN_h").click(function () {
		
		if ($("#tipo_de_normas").is(":hidden")) {
			$("#tipo_de_normas").slideDown("slow");
			document.getElementById('chk1').checked = true;	
		} else {
			$("#tipo_de_normas").slideUp();
			document.getElementById('chk1').checked = false;	
		}

	//	$("#poption_more").slideDown();
	});
	
});


/* ============================	SSNIPETS ====================*/
 /* ======================================================== */
  function toggleType(id, obj)
{
	$('#'+id).toggle();
	var html = $(obj).html();
	html = html.replace(/\+/g, "#menos#");
	html = html.replace(/-/g, "#mas#");
	html = html.replace(/#menos#/g, "-");
	html = html.replace(/#mas#/g, "+");
	$(obj).html(html);
	return false;
} 


/* CODE JS	*/
function open_popup(val)
			{
				var file_help = "";
				switch(val)
				{
				case 'libre':
				file_help="Ayuda_Libre.html";break;

				case 'anio':
				file_help="Ayuda_Anio.html";break;

				case 'entidad_emisora':
				file_help="Ayuda_Emisor.html";break;

				case 'Identificador':
				file_help="Ayuda_Identificador.html";break;

				case 'numero':
				file_help="Ayuda_Numero.html";break;

				case 'norma':
				file_help="Ayuda_Norma.html";break;


				}
				var TEMPLATES_INIT = "#!-- #TEMPLATES:URL --#";
				var url_form = TEMPLATES_INIT.replace("URL",unescape(file_help));


				switch(val)
				{
				case 'libre':
				window.open (url_form, 'ayuda','scrollbars=yes,toolbar=no,menubar=0,status=0,width=550,height=500');break;

				case 'anio':
				window.open (url_form, 'ayuda','menubar=0,resizable=0,status=0,width=300,height=150');break;

				case 'entidad_emisora':
				window.open (url_form, 'ayuda','menubar=0,resizable=0,status=0,width=300,height=550');break;

				case 'Identificador':
				window.open (url_form, 'ayuda','scrollbars=yes,menubar=0,resizable=0,status=0,width=700,height=500');break;

				case 'numero':
				window.open (url_form, 'ayuda','menubar=0,resizable=0,status=0,width=300,height=150');break;

				case 'norma':
				window.open (url_form, 'ayuda','menubar=0,resizable=0,status=0,width=300,height=150');break;


				}



				




				}


/*  Efecft toolTIp 10.08.2012 */
$(function() {
    $("div#poption_more a").mouseover(function(event) {
		//alert(event.pageY);
//		alert($(this).attr('id'))
	//$("#capaHelp-"+ $(this).attr('id')).css("top", parseInt(event.pageY)-15+'px');	
	//alert( $(this).css("top",event.pageY)+'px');
//alert(String($("#capaHelp-"+ $(this).attr('id')).css("top")));
        $("#capaHelp_"+ $(this).attr('id')).show();
    });
    $("div#poption_more a").mouseout(function(event) {
     	//   $("#capaHelp-bole_empresa").slideToggle();
			
		   $("#capaHelp_"+ $(this).attr('id')).hide();
    });
});


////////////////	SNIPPITES

			function toggleFiltroEmisores(id)
			{
				$('#'+id).toggle();
/*				var html = $(obj).html();
				html = html.replace(/Mostrar Filtro/, "#ocultar#");
				html = html.replace(/Ocultar Filtro/, "#mostrar#");
				html = html.replace(/#ocultar#/, "Ocultar Filtro");
				html = html.replace(/#mostrar#/, "Mostrar Filtro");
				$(obj).html(html);*/
	//			emisores_exacto = (emisores_exacto == true ? false : true); //lo contrario
				return false;
			}
			
			function toggleFiltroEmisoresXD(id, obj)
			{
				$('#'+id).toggle();
				var html = $(obj).html();
				html = html.replace(/Mostrar Filtro/, "#ocultar#");
				html = html.replace(/Ocultar Filtro/, "#mostrar#");
				html = html.replace(/#ocultar#/, "Ocultar Filtro");
				html = html.replace(/#mostrar#/, "Mostrar Filtro");
				$(obj).html(html);
				//emisores_exacto = (emisores_exacto == true ? false : true); //lo contrario
				return false;
			}			
			
		    function actualizar(s)
			{
	        document.getElementById('norma_id').value = s.options[s.selectedIndex].value;
			document.getElementById('norma_id').focus();
			}			
			
			function emisoresWWHook(val)
			{
				var emisor_val = $("#emisor").val();
				$("#emisor").val( emisor_val+(emisor_val==''? '': ',') + val);
			}			
			
//******		//
// Scrippt Resumen del  MEs	
/***/
function ShowResumenMonth(cad)
{
	$("#myIframe").attr('src', cad);
}				