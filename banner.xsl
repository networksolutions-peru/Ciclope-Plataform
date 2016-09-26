<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html" indent="no"/>


<xsl:param name="is-client"><!-- #EXECUTIVE:PARAM:isclient --></xsl:param>



<xsl:template match="/">

<html>
  
<head>
<title>Banner</title>
<link rel="stylesheet" type="text/css" href="#!-- #STYLESHEETS:main.css --#" />
<link rel="stylesheet" type="text/css" href="#!-- #STYLESHEETS:banner.css --#" />

<script type="text/javascript">
	<xsl:attribute name="src"><!-- #TEMPLATES:update.js --></xsl:attribute>
</script>

<script type="text/javascript">

var last_searchform = "";


function isClient()
{
	// Return true if we're acting as a Solo client.
	<xsl:choose>
		<xsl:when test="$is-client='true'">return true;</xsl:when>
		<xsl:otherwise>return false;</xsl:otherwise>
	</xsl:choose>
}


function initPage()
{
	// make sure the tabs are in sync
	var main_tab = parent.getMainTab();
	var contents_tab = parent.getContentsTab();
	parent.resetDocumentObject(document);
	parent.setMainTab(main_tab);
	parent.setContentsTab(contents_tab);
}


function getCurrentDocument()
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
	
	return unescape(current_document);
}


function manageContent()
{
	// get the parent path of the current document, and start the there
	var current_document = unescape(getCurrentDocument());
	var parent_path = current_document.substring(0, current_document.lastIndexOf("/"));
	
	var doc_lib_url = "#!-- #EXECUTIVE:SCRIPT_NAME --#/" +
		escape(parent_path) +
		"?f=udoclist$udoclist_sel=title;path;has-children;name;last-modified;content-type;type;writable;locked;locked-by;hidden$udoclist_lsel=title;type;writable;path$udoclist_xsl=update.xsl$udoclist_sf=update$udoclist_vpc=first$udoclist_upd=yes";

	if (isIE55())
	{
		// Server-side XSL is required for manage content on IE 5.5 because uploading doesn't work
		// if the XSL is done client side.
		doc_lib_url += "$udoclist_fss=yes";
	}

	var new_window = window.open(doc_lib_url, "update", "scrollbars=yes,resizable=yes,menubar=yes");
	new_window.focus();
}


function preserveHTMLContentsSelect()
{
	// keep the correct select mode
	if (parent.getContentsSelectMode())
	{
		parent.frames["contents"].location.search = "?f=templates$fn=contents-frame-h.htm$tf=_self$tt=contents-frame-h.htm$t=contents-frame-h.htm$sel=1";
		return false;
	}
	
	return true;
}


function showSearchForm(search_form_params)
{
	// search_form_params looks like this:
	// frame-type:search-form-id

	if (search_form_params != "#NoSelection")
	{
		var delim_offset = search_form_params.indexOf(":");
		if (delim_offset != -1)
		{
			var frame_type = search_form_params.substring(0, delim_offset);
			var search_form_id = search_form_params.substring(delim_offset+1);
			var function_name;

			switch (frame_type)
			{
				case "contents":
					parent.setContentsSelectMode(true);
					function_name = "?f=templates$fn=searchform.htm";
					break;

				case "no-contents":
					parent.setContentsSelectMode(false);
					function_name = "?f=templates$fn=searchform.htm";
					break;

				default:
					function_name = "?f=searchforms";
					break;
			}
		
			last_searchform = search_form_params;
			parent.frames["main"].location.search = function_name + "$id=" + search_form_id;
		}
	}
}


function showLastSearchForm()
{
	if (last_searchform == "")
	{
		last_searchform = document.main_form.searchform_list[1].value;
	}

	showSearchForm(last_searchform);
}


function simpleSearch()
{
	if (parent.getMainTab() == "document-results")
	{
		document.main_form.target = "results";
	}
	else
	{
		document.main_form.target = "main";
	}
}


function executeSavedSearch(name)
{
	if (name != "#NoSelection")
	{
		if (parent.getMainTab() == "document-results")
		{
			eval("document." + name + ".target = 'results'");
		}
		else
		{
			eval("document." + name + ".target = 'main'");
		}
		eval("document." + name + ".submit()");
	}
}

</script>

</head>

<body leftmargin="0" topmargin="0" onload="initPage()">
<form name="main_form" action="#!-- #EXECUTIVE:SCRIPT_NAME --#" target="main" method="get" onsubmit="simpleSearch()">
	<table width="2000" border="0" cellpadding="0" cellspacing="0" nowrap="nowrap">
		<tr nowrap="nowrap">
			<td nowrap="nowrap" width="217" height="90" rowspan="2" valign="top" style="background-color: #e7e7e7">
				<img border="0" src="#!-- #IMAGES:logo.gif --#" width="217" height="57" /><br />
				
				<!-- No whitespace is allowed between the following tags, or the alignment will be off. -->
				<img border="0" src="#!-- #IMAGES:ui-tab-bkgnd0.gif --#" width="10" height="19" 
				/><a href="#!-- #TEMPLATES:contents-frame-h.htm --#" target="contents" onclick="return preserveHTMLContentsSelect()"
				><img border="0" name="html" src="#!-- #IMAGES:tab-html-on.gif --#" 
				/></a><a href="#!-- #TEMPLATES:contents-frame-j.htm --#" target="contents"
				><img border="0" name="java" src="#!-- #IMAGES:tab-java-off.gif --#"
				/></a><img border="0" src="#!-- #IMAGES:ui-tab-bkgnd0.gif --#" width="111" height="19" />
			</td>
			<td class="banner-top">
 				<img border="0" src="#!-- #IMAGES:ui-spacer.gif --#" width="5" height="1" />

				<!-- XML Hit List search form. Each input causes an extra space on IE, so we'll avoid whitespace here. -->
				<input type="text" size="15" name="xhitlist_q"/>
				<xsl:text> </xsl:text> 
 				<input type="submit" class="button" value="Search"/>
				<xsl:text> </xsl:text>
				<input type="hidden" size="0" name="f" value="xhitlist" 
				/><input type="hidden" size="0" name="xhitlist_x"	value="Simple" 
				/><input type="hidden" size="0" name="xhitlist_s"	value="relevance-weight"
				/><input type="hidden" size="0" name="xhitlist_d"	value=""
				/><input type="hidden" size="0" name="xhitlist_hc"	value=""
				/><input type="hidden" size="0" name="xhitlist_xsl" value="xhitlist.xsl"
				/><input type="hidden" size="0" name="xhitlist_vpc" value="first"
				/><input type="hidden" size="0" name="xhitlist_sel" value="title;path;relevance-weight;content-type;home-title" />

 				<img border="0" src="#!-- #IMAGES:ui-spacer.gif --#" width="2" height="1" />
				
				<select name="searchform_list" onchange="showSearchForm(this.options[this.selectedIndex].value); this.selectedIndex = 0" >
					<option value="#NoSelection">Choose search form</option>
					<!-- #SEARCHFORMS:select -->
				</select> 
				<img border="0" src="#!-- #IMAGES:ui-spacer.gif --#" width="5" height="1" />

				<xsl:if test="saved-search/item">
					<select name="savedsearch_list" onchange="executeSavedSearch(this.options[this.selectedIndex].value);  this.selectedIndex = 0">
						<option value="#NoSelection">Choose saved search</option>
						<xsl:for-each select="saved-search/item">
							<option>
								<xsl:attribute name="value">saved_search_form_<xsl:number/></xsl:attribute>
								<xsl:value-of select="@name"/>
							</option>
						</xsl:for-each>
					</select>
				</xsl:if>

				<img border="0" src="#!-- #IMAGES:ui-spacer.gif --#" width="5" height="1" />
				
				<!-- Manage Content or Synchronize button depending on whether we're running on the client or server. -->
				<xsl:choose>
					<xsl:when test="$is-client='true'"><a href="#!-- #EXECUTIVE:SCRIPT_NAME --#?f=sync$sync_c=getstate$sync_xsl=sync-getstate.xsl" class="bannerbutton" target="_top"><img border="0" src="#!-- #IMAGES:sync-icon-g.gif --#" align="middle"/>Synchronize</a></xsl:when>
					<xsl:otherwise><a href="javascript:manageContent()" class="bannerbutton"><img border="0" src="#!-- #IMAGES:ui-update-g.gif --#" align="middle"/>Manage Content</a></xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
		<tr nowrap="nowrap">
			<td valign="top" nowrap="nowrap">
			
				<!-- No whitespace is allowed between the following tags, or the alignment will be off. -->
				<img border="0" src="#!-- #IMAGES:ui-tab-bkgnd1.gif --#" align="bottom" width="4" height="27"
				/><a href="#!-- #TEMPLATES:document-frameset.htm --#" target="main"
				><img name="document" border="0" src="#!-- #IMAGES:tab-document-on.gif --#" align="bottom" width="97" height="27"
				/></a><a href="#!-- #EXECUTIVE:SCRIPT_NAME --#?f=xhitlist$xhitlist_xsld=xhitlist.xsl" target="main"
				><img name="results" border="0" src="#!-- #IMAGES:tab-results-off.gif --#" align="bottom" width="97" height="27"
				/></a><a href="#!-- #TEMPLATES:doc-results.htm --#" target="main"
				><img name="document-results" border="0" src="#!-- #IMAGES:tab-docresults-off.gif --#" align="bottom" width="97" height="27"
				/></a><a href="javascript:showLastSearchForm()"
				><img name="searchform" border="0" src="#!-- #IMAGES:tab-searchform-off.gif --#" align="bottom" width="97" height="27"
				/></a><img border="0" src="#!-- #IMAGES:ui-tab-bkgnd1.gif --#" align="bottom" width="1500" height="27" />
			</td>
		</tr>
	</table>
</form>


<xsl:apply-templates select="saved-search/item"/>


</body>

</html>

</xsl:template>



<xsl:template match="item">

<form method="get">
	<xsl:attribute name="name">saved_search_form_<xsl:number/></xsl:attribute>
	<xsl:attribute name="action"><!-- #EXECUTIVE:SCRIPT_NAME --></xsl:attribute>
	<input type="hidden" size="0" name="f" value="xhitlist" />
	<input type="hidden" size="0" name="xhitlist_q"><xsl:attribute name="value"><xsl:value-of select="query"/></xsl:attribute></input>
	<input type="hidden" size="0" name="xhitlist_s"><xsl:attribute name="value"><xsl:value-of select="sort"/></xsl:attribute></input>
	<input type="hidden" size="0" name="xhitlist_d"><xsl:attribute name="value"><xsl:value-of select="domain"/></xsl:attribute></input>
	<input type="hidden" size="0" name="xhitlist_hc"><xsl:attribute name="value"><xsl:value-of select="hit-context"/></xsl:attribute></input>
	<input type="hidden" size="0" name="xhitlist_xsl"><xsl:attribute name="value"><xsl:value-of select="stylesheet"/></xsl:attribute></input>
	<input type="hidden" size="0" name="xhitlist_sel"><xsl:attribute name="value"><xsl:value-of select="select"/></xsl:attribute></input>
	<input type="hidden" size="0" name="xhitlist_x"><xsl:attribute name="value"><xsl:value-of select="syntax"/></xsl:attribute></input>
	<input type="hidden" size="0" name="xhitlist_vpc" value="first" />
</form> 

</xsl:template>



</xsl:stylesheet>
