<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>


<xsl:template match="/">

<html>

<head>
	<title>Manage Saved Searches</title>
	
	<link rel="stylesheet" type="text/css">
		<xsl:attribute name="href"><!-- #STYLESHEETS:main.css --></xsl:attribute>
	</link>
	
	<script type="text/javascript">
	
	function initPage()
	{
      refreshBanner()
	}
	
	function refreshBanner()
	{
		document.banner_form.userinfo_xsl.value = "banner.xsl";
		document.banner_form.target = "banner";
	  
		// preserve the client property
		var banner_win = opener.parent.frames["banner"];
		if (banner_win != null)
		{
			if (banner_win.isClient != null &amp;&amp; banner_win.isClient())
			{
				document.banner_form.isclient.value="true";
			}
		}
		
		document.banner_form.submit();
	}
	
	
	function deleteItem(item_name)
	{
		document.request_form.userinfo_c.value = "delete";
		document.request_form.userinfo_n.value = item_name;
		document.request_form.submit();
	}
	
	
	function renameItem(item_name, new_name)
	{
		document.request_form.userinfo_c.value = "rename";
		document.request_form.userinfo_n.value = item_name;
		document.request_form.userinfo_nn.value = new_name;
		document.request_form.submit();
	}
	
	
	function deleteAll()
	{
		if (confirm('Are you sure you want to delete all your saved searches?'))
		{
			document.request_form.userinfo_c.value = "nuke";
			document.request_form.submit();
		}
	}
	
	</script>
</head>

<body onload="initPage()">

	<h1>Saved Searches</h1>
	<form name="ui_form">
		<table border="0">
			<xsl:apply-templates select="saved-search/item"/>
         <tr>
            <td>
               <input type="button" value="Delete All" class="button" onclick="deleteAll()"/>
            </td>
         </tr>
         <tr>
            <td colspan="3">
               <div align="center">
                  <input type="button" value="   Exit   " class="button" onclick="window.close()"/>
               </div>
            </td>
         </tr>
		</table>
	</form>
	
	<form name="request_form" method="post">
		<xsl:attribute name="action"><!-- #EXECUTIVE:SCRIPT_NAME --></xsl:attribute>
		<input type="hidden" name="f"				value="userinfo"/>
		<input type="hidden" name="userinfo_cat"	value="saved-search"/>
		<input type="hidden" name="userinfo_xsl"	value="saved-search.xsl"/>
		<input type="hidden" name="userinfo_c"		value=""/>
		<input type="hidden" name="userinfo_n"		value=""/>
		<input type="hidden" name="userinfo_nn"		value=""/>
	</form>
	<form name="banner_form" method="post">
		<xsl:attribute name="action"><!-- #EXECUTIVE:SCRIPT_NAME --></xsl:attribute>
		<input type="hidden" name="f"				value="userinfo"/>
		<input type="hidden" name="userinfo_cat"	value="saved-search"/>
		<input type="hidden" name="userinfo_xsl"	value="banner.xsl"/>
		<input type="hidden" name="userinfo_c"		value=""/>
		<input type="hidden" name="userinfo_n"		value=""/>
		<input type="hidden" name="userinfo_nn"		value=""/>
		<input type="hidden" name="isclient"		value=""/>
	</form>

</body>

</html>

</xsl:template>


<xsl:template match="item">
	<tr>
		<td>
			<input type="text" size="30" maxlength="25">
				<xsl:attribute name="name">edit<xsl:number/></xsl:attribute>
				<xsl:attribute name="value"><xsl:value-of select="@name"/></xsl:attribute>
			</input>
			<input type="hidden">
				<xsl:attribute name="name">original<xsl:number/></xsl:attribute>
				<xsl:attribute name="value"><xsl:value-of select="@name"/></xsl:attribute>
			</input>
		</td>
		<td>
			<input type="button" value="Rename" class="button" >
				<xsl:attribute name="onclick">renameItem(document.ui_form.original<xsl:number/>.value, document.ui_form.edit<xsl:number/>.value)</xsl:attribute>
			</input>
		</td>
		<td>
			<input type="button" value="Delete" class="button" >
				<xsl:attribute name="onclick">deleteItem(document.ui_form.original<xsl:number/>.value)</xsl:attribute>
			</input>
		</td>
	</tr>
</xsl:template>



</xsl:stylesheet>
