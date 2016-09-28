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

//OPCIONES
var SHOW_NO_VALUES_FIELDS = true; //Muestra (true) o no (false) los campos que NO tienen valor.

//CONFIGURACIONES (REQUERIDO)
var DOC_FRAME_OBJ = top.frames['main']; //Cambiar main por el NAME del frame que va a tener los formularios de busqueda

var UNIQUE_FORM_NAME = false; //Especificar TRUE si TODOS los formularios de busqueda tienen el mismo valor
							  //en el atributo name (<form ... name="VALOR" ..>)
							  //Especificar FALSE si los formularios de busqueda tienen diferentes valores en el atributo name.
							  //En este ultimo caso, se tomara el primer formulario en el documento
							 
var FORM_NAME = 'ui_form';    //Si UNIQUE_FORM_NAME es false ignorar este valor. 
							  //Especificar el valor del atributo name que tienen TODOS los fomularios de busqueda.

var NO_SEARCH_ID='no_searchs';var COOKIE_SEARCH_PREFIX='CLPServerSearch_';var COOKIE_SEARCH_ID_IN_USE='search_in_use_id';function savedSearchsToHTML(c){var d=$('#'+c);if(d.val()==null){alert(ERROR_CONTAINER_NOT_FOUND);return}var e=document.cookie.split(";");var f=0;for(var i=0;i<e.length;++i){var g=e[i];if(g.indexOf(COOKIE_SEARCH_PREFIX)==-1)continue;var h=/CLPServerSearch_(.*)=(.*)/;var j=h.exec(g);var k=getSearch(j[1]);var l=k.getHTMLValuesTable();$('<a/>',{id:k.id,href:'#'}).html(unescape(k.label)+'<br/>').bind('click',function(){$('#'+$(this).attr('id')+'_values').slideToggle();return false}).appendTo(d);$('<div/>',{id:k.id+'_values'}).hide().html('<blockquote>'+l+'</blockquote>').appendTo(d);$('<input/>',{id:'showSearch',name:'showSearch',type:'button',value:'Usar Busqueda',item_id:k.id,item_url:k.form_url}).bind('click',function(){var a="#!-- #TEMPLATES:URL --#";var b=a.replace("URL",unescape($(this).attr('item_url')));setCookie("search_in_use_id",$(this).attr('item_id'));DOC_FRAME_OBJ.document.location.href=b;return false}).appendTo('#'+k.id+'_values > blockquote');$('<input/>',{id:'deleteSearch',name:'deleteSearch',type:'button',value:'Borrar Busqueda',item_id:k.id}).bind('click',function(){DeleteCookie(COOKIE_SEARCH_PREFIX+$(this).attr('item_id'));$('#'+$(this).attr('item_id')).remove();$('#'+$(this).attr('item_id')+'_values').remove();return false}).appendTo('#'+k.id+'_values > blockquote');++f}if(f==0){$('<div/>',{id:NO_SEARCH_ID}).html(NO_SEARCH_TEXT).appendTo(d)}else $('#'+NO_SEARCH_ID).remove()}function loadSavedSearch(){var a=/search_in_use_id=(.*);.*;.*/;var b=a.exec(document.cookie);if(b==null)return;var c=getSearch(b[1]);if(c==null){alert(ERROR_NO_SEARCH_FOUND);return}c.mapToForm();DeleteCookie(COOKIE_SEARCH_ID_IN_USE)}function saveSearch(e,f){name=e;if(name==null||name==''||name=='undefined'){e=prompt(SEARCH_NAME_PROMPT,"");if(e==null)return;name=e.replace(/\s+/g,"_")}var g='CLPServerSearch_'+name;DeleteCookie(g);var h=DOC_FRAME_OBJ.document.location.href;var i=/^.*\$fn=(.*)$/;var j=i.exec(h);var k="label:"+e+";"+"form_url:"+j[1]+";";var l=null;if(UNIQUE_FORM_NAME)l=eval('DOC_FRAME_OBJ.document.'+FORM_NAME+';');else l=$('form',DOC_FRAME_OBJ.document)[0];$("input, select",l).not("[type=button],[type=submit]").each(function(){var a=$(this).parent("label");var b=(a.val()!=null&&a.attr("value")!=null?a.attr("value"):"");var c=$(this).attr("name");var d=$(this).val();if(SHOW_NO_VALUES_FIELDS&&d!="")k+=b+"="+c+":"+d+";"});setCookie(g,k);alert(SEARCH_SAVED_TEXT)}var searchItem=function(e){this.id=e;this.label="";this.form_url="";this.values=new Array();this.toString=function(){if(this.values==null||this.values.length<=0)return SEARCH_NO_VALUES;var a="";for(var i=0;i<this.values.length;++i){var b=this.values[i];a+="\n"+b.label+"(id:"+b.id+")="+b.value}return"Search ID: "+this.id+"\nSearch Label: "+this.label+"\nSearch Formulario: "+this.form_url+"\nSearch values: "+a}this.getHTMLValuesTable=function(){var a="";for(var b=0;b<this.values.length;++b){var c=this.values[b];var d=(c.label==null||c.label==""?c.id:c.label);if(SHOW_NO_VALUES_FIELDS&&c.value!=""){a+="<tr>"+"<td><strong>"+d+":</strong></td>"+"<td>"+unescape(c.value)+"</td>"+"</tr>"}}return"<table>"+a+"</table>"}this.mapToForm=function(){for(var a=0;a<this.values.length;++a){$('#'+this.values[a].id).val(unescape(this.values[a].value))}}}function getSearch(a){var b=document.cookie.split(";");for(var i=0;i<b.length;++i){var c=b[i];if(c.indexOf(COOKIE_SEARCH_PREFIX)==-1||c.indexOf(COOKIE_SEARCH_PREFIX+a)==-1)continue;var d=new searchItem(a);var e=unescape(c.replace(COOKIE_SEARCH_PREFIX+a+"=",""));var f=e.split(";");for(var g=0;g<f.length;++g){var h=/^(.*)=(.*):(.*)$/;var j=h.exec(f[g]);if(j==null){var k=/^(.*):(.*)$/;var l=k.exec(f[g]);if(l!=null){if(trim(l[1])=="label")d.label=l[2];else if(trim(l[1])=="form_url")d.form_url=l[2]}continue}var m=j[1];var n=j[2];var o=j[3];d.values.push({id:n,value:o,label:m})}return d}return null}
function getCookieVal(a){var b=document.cookie.indexOf(";",a);if(b==-1)b=document.cookie.length;return unescape(document.cookie.substring(a,b))}function GetCookie(a){var b=a+"=";var c=b.length;var d=document.cookie.length;var i=0;while(i<d){var j=i+c;if(document.cookie.substring(i,j)==b)return getCookieVal(j);i=document.cookie.indexOf(" ",i)+1;if(i==0)break}return null}function DeleteCookie(a){var b=new Date();b.setTime(b.getTime()-1);var c=GetCookie(a);document.cookie=a+"="+c+"; expires="+b.toGMTString()}function setCookie(a,b,c,d,e,f){var g=new Date();g.setTime(g.getTime());if(c)c=c*1000*60*60*24;var h=new Date(g.getTime()+(c));document.cookie=a+"="+escape(b)+((c)?";expires="+h.toGMTString():"")+((d)?";path="+d:"")+((e)?";domain="+e:"")+((f)?";secure":"")}function trim(a){return a.replace(/^\s*|\s*$/g,"")}
