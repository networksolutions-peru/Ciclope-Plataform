/**
	Requerido:
		- Jquery (incluido)
		- Browser que acepte cookies
		
	Para que ande, hacer estos cambios en los formularios de busqueda:
		.- En cada elemento INPUT (text, checkbox, radio, etc) encerrarlo con un tag <label value="NOMBRE_DESCRIPTIVO_DEL_CAMPO">.
		.- TODOS los elementos INPUT deben tener ID y NAME con el mismo valor
		.- En cada formulario de busqueda incluir:
				<script type="text/javascript" src="#!-- #TEMPLATES:jquery.js --#"></script>
				<script type="text/javascript" src="#!-- #TEMPLATES:CLPSessionSaveSearchs.js --#"></script>
			y en el javascript poner: $(document).ready(function(){ loadSavedSearch(); });
	ToDo:
		.- Cuando se borra la ultima busqueda guardada poner el mensaje NO_SEARCH_TEXT
		.- Modificar busqueda.
		
	************************** NO TESTEADO EN IE ******************************************
**/
//TEXTOS
var NO_SEARCH_TEXT     = 'No hay busquedas guardadas en esta sesion.';
var SEARCH_SAVED_TEXT  = 'Busqueda guardada correctamente.';
var SEARCH_NAME_PROMPT = 'Ingrese el nombre de la busqueda';
var SEARCH_NO_VALUES   = 'No existe el item o no tiene valores';
var ERROR_CONTAINER_NOT_FOUND = 'No encontro el container para listar las busquedas guardadas.';
var ERROR_NO_SEARCH_FOUND     = 'No se encontro la busqueda.';
var ERROR_NO_SEARCH_TO_SAVE   = 'No hay busqueda para guardar.';

//OPCIONES
var SHOW_NO_VALUES_FIELDS = true; //Muestra (true) o no (false) los campos que NO tienen valor.

//CONFIGURACIONES (REQUERIDO)
var DOC_FRAME_OBJ = top.frames['index_gaceta']; //Cambiar main por el NAME del frame que va a tener los formularios de busqueda

/* 	Aqui pongo los nombres para las referencias.	*/
var LEGIS_FRAME_OBJ = top.frames['lesgilacion']; // HAgo refefrencia ala ventana de Legislacion
var JURISP_FRAME_OBJ = top.frames['jurisp']; // Hago refefrencia ala ventana de Jurisprducencia
var DOCTRI_FRAME_OBJ = top.frames['doctrina']; // Hago refefrencia ala ventana de Doctrina
var HITLISTX_FRAME_OBJ = top.frames['HitList']; // Hago refefrencia ala ventana del HisList de los  Aciertos		-- ESTO ES UNICO, X Q OTRO CON EL MISMO NOMBRE




var UNIQUE_FORM_NAME = false; //Especificar TRUE si TODOS los formularios de busqueda tienen el mismo valor
							  //en el atributo name (<form ... name="VALOR" ..>)
							  //Especificar FALSE si los formularios de busqueda tienen diferentes valores en el atributo name.
							  //En este ultimo caso, se tomara el primer formulario en el documento
							 
var FORM_NAME = 'ui_form';    //Si UNIQUE_FORM_NAME es false ignorar este valor. 
							  //Especificar el valor del atributo name que tienen TODOS los fomularios de busqueda.

var HITLIST_FRAME_OBJ = top.frames[top.HITLIST_FRAME];
							  
//INTERNO - NO TOCAR
var NO_SEARCH_ID = 'no_searchs';
var COOKIE_SEARCH_PREFIX = 'CLPServerSearch_';
var COOKIE_SEARCH_ID_IN_USE = 'search_in_use_id';
var TMP_SEARCH_NAME = 'tmp';

function savedSearchsToHTML(id)
{
	var container = $('#'+id);
	if (container.val() == null)
	{
		alert(ERROR_CONTAINER_NOT_FOUND);
		return;
	}
	
	var searchs_list = document.cookie.split(";");
		
	var items_count = 0;
	for (var i=0 ; i<searchs_list.length ; ++i)
	{
		var item = searchs_list[i];
		if (item.indexOf(COOKIE_SEARCH_PREFIX) == -1) continue;
		
		//Regex que machea el nombre y los valores
		var regex = /CLPServerSearch_(.*)=(.*)/;
		var match = regex.exec(item); //Ejecuto la regex sobre la String item
		if (match == null)
			continue;
		//El primer match de la regex es el nombre de la busqueda
		var search_item = getSearch(match[1]);
		
		if (search_item.label == TMP_SEARCH_NAME)
			continue;
		//Creo la tabla con los valores de esta busqueda
		var search_values_str = search_item.getHTMLValuesTable();
		
		//Inserto el nombre de la busqueda.
		$('<a/>', {id:search_item.id, href:'#'})
						.html(unescape(search_item.label)+'<br/>')
						.bind('click', function(){ $('#'+$(this).attr('id')+'_values').slideToggle(); return false;})
				.appendTo(container);
		
		//Inserto una tabla con los valores de la busqueda.
		$('<div/>', {id:search_item.id+'_values'}).hide()
			.html('<blockquote>'+search_values_str+'</blockquote>').appendTo(container);
		$('<input/>',{id:'showSearch',name:'showSearch',type:'button',value:'Usar Busqueda', hitlist_url:search_item.search_url, item_id:search_item.id, item_url:search_item.form_url})
			.bind('click', function()
			{	//alert(top.NAME_CLASS_MENU.toString());
				//return
				DeleteCookie('CLPServerSearch_'+TMP_SEARCH_NAME);
				top.NAME_CLASS_MENU = 'hitlist'; // Eta es
				top.frames['HitList'].document.location.href = unescape($(this).attr('hitlist_url'));
//				$("#ompalompa").html = unescape($(this).attr('hitlist_url'));
				//alert(unescape($(this).attr('hitlist_url')));
				_saveSearch(COOKIE_SEARCH_ID_IN_USE, $(this).attr('item_id'));
				
				if (loadSearchCallback)
					loadSearchCallback();
				/*
				var TEMPLATES_INIT = "#!-- #TEMPLATES:URL --#"; //Seteo la variable de reemplazo con un valor (URL) para que
																//no se mezcle con el javascript.
				var url_form = TEMPLATES_INIT.replace("URL",unescape($(this).attr('item_url'))); //Reemplazo URL por la url verdadera sacada de la cookie
				setCookie("search_in_use_id", $(this).attr('item_id')); //Seteo la cookie que va a leer la funcion loadSavedSearch()
															   //llamada desde el formulario
				DOC_FRAME_OBJ.document.location.href = url_form; //Cambio al formulario
				*/
				return false; //Evito el href=#
			}).appendTo('#'+search_item.id+'_values > blockquote');
		$('<input/>',{id:'deleteSearch',name:'deleteSearch',type:'button',value:'Borrar Busqueda', item_id:search_item.id})
			.bind('click', function()
			{
				DeleteCookie(COOKIE_SEARCH_PREFIX+$(this).attr('item_id')); //Borro la busqueda pidiendo el ID y anteponiendole "CLPServerSearch_"
				$('#'+$(this).attr('item_id')).remove();
				$('#'+$(this).attr('item_id')+'_values').remove();
				document.location.href = document.location.href;
				return false; //Evito el href=#
			}).appendTo('#'+search_item.id+'_values > blockquote');
		++items_count;
	}
	if (items_count == 0)
	{
		$('<div/>', {id:NO_SEARCH_ID})
			.html(NO_SEARCH_TEXT)
			.appendTo(container);
	}else
		$('#'+NO_SEARCH_ID).remove();
}

function getSearchInUse()
{
	var url_regexp = /search_in_use_id=([^;]*);[^;]*;.*/;
	var url_matcher = url_regexp.exec(document.cookie);
	if (url_matcher == null) //NO hay busqueda para mostrar
		return;
	return url_matcher[1];
}

function loadSavedSearch()
{
	var search_name = getSearchInUse();
	var item = getSearch(search_name);
	if (item == null)
	{
		alert(ERROR_NO_SEARCH_FOUND);
		return;
	}
	item.mapToForm();
}
function saveSearchFromTMP(search_name, search_url)
{
	var search_item = getSearch(TMP_SEARCH_NAME);
	if (search_item == null)
	{
		alert(ERROR_NO_SEARCH_TO_SAVE);
		return;
	}

	if (search_name == null || search_name == '' || search_name == 'undefined')
	{
		search_name  = prompt(SEARCH_NAME_PROMPT, "");
		if (search_name == null)
			return;
		name = search_name.replace(/\s+/g, "_"); //Reemplazo los espacios por _
	}else
	{
		name = search_name;
	}	

	var full_search_name = 'CLPServerSearch_'+name;
	var cookie_value = "label:"+name+";"+
				   "form_url:"+search_item.form_url+";"+
				   "search_url:"+escape(search_url)+";";
			
	var cookie_fields = "";
	for (var i=0; i<search_item.values.length ; ++i)
	{
		var item = search_item.values[i];
		cookie_fields += item.label+"="+item.id+":"+item.value+";";
	}
	
	cookie_value += cookie_fields;
	DeleteCookie('CLPServerSearch_'+TMP_SEARCH_NAME);
	_saveSearch(full_search_name, cookie_value);
	_saveSearch(COOKIE_SEARCH_ID_IN_USE, name);
}

function saveSearch(search_name, frame_refe) 		//form_relative_url)
{
	name = search_name;
	//	alert(name + ' - ' + name.length);return;
	//Si no me pasaron nombre lo pido ahora
	if (name  == null || name  == '' || name  == 'undefined')
	{
		search_name  = prompt(SEARCH_NAME_PROMPT, "");
		if (search_name == null)
			return;
		name  = search_name.replace(/\s+/g, "_"); //Reemplazo los espacios por _
	}
	
	//Armo el nombre para despues identificarlo entre las cookies
	var full_search_name = 'CLPServerSearch_'+name;

	
	//Busco la URL del formulario de busqueda		
	var url = DOC_FRAME_OBJ.document.location.href;		// Ojo hice un cambio de la variables por el 2 parametro q le paso al funciion
	var url_regexp = /^.*\$fn=(.*)$/;		
	var url_matcher = url_regexp.exec(url);


	
	//Tomo (con jquery) todos los campos del formulario de busqueda y los guardo en cookie_value
	var cookie_value = "label:"+search_name+";"+
					   "form_url:"+url_matcher[1]+";"+
				   "search_url:null;";
		/*===============================*/	
//		alert(cookie_value);

//		return;

	/*=====================================*/				   
		
	var form = null;
	//Si el nombre del form es unico en TODOS los formularios tomo ese, sino busco en el documento el primer formulario.
	if (UNIQUE_FORM_NAME)
		form = eval('DOC_FRAME_OBJ.document.'+FORM_NAME+';');
	else
		form = $('form', frame_refe.document)[0];
		
	$("input, select", form).not("[type=button],[type=submit],[type=hidden],[type=reset]").each(function()
	{
		var parent_label_obj = $(this).parent("label");
		if ($(this).attr("type") == "checkbox" && !$(this).attr("checked"))
			return;
		var field_label = (parent_label_obj.val() != null && parent_label_obj.attr("value") != null ? parent_label_obj.attr("value") : "");
		var field_name  = $(this).attr("name");
		
		var field_value;
		if ($(this).attr("type") == "checkbox")
			field_value = "SI";
		else
			field_value = $(this).val();
		if (SHOW_NO_VALUES_FIELDS && field_value != "")
			cookie_value += field_label+"="+field_name+":"+field_value+";";
	});
	
	_saveSearch(full_search_name, cookie_value);
	_saveSearch(COOKIE_SEARCH_ID_IN_USE, full_search_name);
	if (name != TMP_SEARCH_NAME)
		alert(SEARCH_SAVED_TEXT);//Mensaje de OK
}

function _saveSearch(name, cookie)
{
	//Borro esta misma busqueda por si es que existia
	DeleteCookie(name);
	
	//Seteo la cookie
	setCookie(name, cookie);
}
var searchItem = function(id)
{
	this.id = id;
	this.label = "";
	this.form_url = "";
	this.search_url = "";
	this.values = new Array();
	this.toString = function()
	{
		if (this.values == null || this.values.length <= 0)
			return SEARCH_NO_VALUES;
		
		var values = "";
		for (var i=0 ; i<this.values.length ; ++i)
		{
			var item = this.values[i];
			values += "\n"+item.label+"(id:"+item.id + ")=" + item.value;
		}
		return  "Search ID: "       + this.id + "<br/>" +
				"\nSearch Label: "  + this.label + "<br/>" +
				"\nSearch Formulario: "  + this.form_url + "<br/>" +
				"\nSearch URL: "    + this.search_url + "<br/>" +
				"\nSearch values: " + values;
	}
	this.getHTMLValuesTable = function()
	{
		var search_values_str = "";
		for (var i_values=0 ; i_values<this.values.length ; ++i_values)
		{
			var item = this.values[i_values];
			var label = (item.label == null || item.label == "" ? item.id : item.label);
			
			if (SHOW_NO_VALUES_FIELDS && item.value != "")
			{
				search_values_str += "<tr>"+
										"<td><strong>"+label+":</strong></td>"+
										"<td>"+unescape(item.value)+"</td>"+
									 "</tr>";
			}
		}
		return "<table>"+search_values_str+"</table>";
	}
	this.mapToForm = function()
	{
		for (var i_values=0 ; i_values<this.values.length ; ++i_values)
		{
			if (this.values[i_values].id == "")
				continue;
				
			var item = $('#'+this.values[i_values].id);
			if (item.attr("type") == "checkbox")
				item.attr("checked", true);
			else
				item.val(unescape(this.values[i_values].value));
		}
	}
}

function getSearch(str)
{
	//alert("getSearch(1):"+document.cookie);
	str=str.replace(COOKIE_SEARCH_PREFIX, "");
	//alert("getSearch(2):"+str);
	var searchs_list = document.cookie.split(";");
	for (var i=0 ; i<searchs_list.length ; ++i)
	{
		var item = searchs_list[i];
		//alert("getSearch(3): " + item);
	
		//Busco si tiene el COOKIE_SEARCH_PREFIX y si es la busqueda pasada por parametro
		if (item.indexOf(COOKIE_SEARCH_PREFIX) == -1 || item.indexOf(COOKIE_SEARCH_PREFIX+str) == -1)
			continue;
			
		//El primer match de la regex es el nombre de la busqueda
		var s_item = new searchItem(str);
		var values = unescape(item.replace(COOKIE_SEARCH_PREFIX+str+"=", ""));
		
		//alert("Values:" + values);
		var search_values_list = values.split(";"); //%3B == ;
		for (var i_values=0 ; i_values<search_values_list.length ; ++i_values)
		{
			var regex_values = /^([^=]*)=([^:]*):(.*)$/; //Tipo: "label=id:valor"
			var match_values = regex_values.exec(search_values_list[i_values]); //Ejecuto la regex sobre la String item

			//Si no es del formato "label=id:valor" compruebo que sea del tipo "id:valor"
			if (match_values == null)
			{
				var regex_values_gral = /^(.*):(.*)$/; //Tipo: "id:valor"
				var match_values_gral = regex_values_gral.exec(search_values_list[i_values]); //Ejecuto la regex sobre la String item
				if (match_values_gral != null)
				{
					if (trim(match_values_gral[1])== "label")
						s_item.label = match_values_gral[2];
					else if (trim(match_values_gral[1]) == "form_url")
						s_item.form_url = match_values_gral[2];
					else if (trim(match_values_gral[1]) == "search_url")
						s_item.search_url = match_values_gral[2];
				}
				continue;
			}
			var field_label = match_values[1];
			var field_name  = match_values[2];
			var field_value = match_values[3];
			
			s_item.values.push( {id:field_name, value:field_value, label:field_label} );
		}
		return s_item;
	}
	return null;
}

function getCookieVal(a){var b=document.cookie.indexOf(";",a);if(b==-1)b=document.cookie.length;return unescape(document.cookie.substring(a,b))}function GetCookie(a){var b=a+"=";var c=b.length;var d=document.cookie.length;var i=0;while(i<d){var j=i+c;if(document.cookie.substring(i,j)==b)return getCookieVal(j);i=document.cookie.indexOf(" ",i)+1;if(i==0)break}return null}function DeleteCookie(a){var b=new Date();b.setTime(b.getTime()-1);var c=GetCookie(a);document.cookie=a+"="+c+"; expires="+b.toGMTString()}function setCookie(a,b,c,d,e,f){var g=new Date();g.setTime(g.getTime());if(c)c=c*1000*60*60*24;var h=new Date(g.getTime()+(c));document.cookie=a+"="+escape(b)+((c)?";expires="+h.toGMTString():"")+((d)?";path="+d:"")+((e)?";domain="+e:"")+((f)?";secure":"")}function trim(a){return a.replace(/^\s*|\s*$/g,"")}