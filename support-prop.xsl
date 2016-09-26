<?xml version="1.0"?>

<!-- 
================================================================
This style sheet depends on the following select string for
the DocList component in order to build the navigation UI. 

sel=title;path;has-children;content-type
lsel=title

Other properties may be added as well, and they will be 
displayed in the table. This is no small feat since the number
of properties on given node is variable, but each node needs
to output a table cell regardless of whether the property is
actually present, or the table will not line up correctly.
================================================================
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>


<xsl:variable name="title">NXT Support: Site Properties</xsl:variable>


<!-- These are properties used to build the UI that probably don't need to be
displayed in their own column. Either they are already displayed, or they can
be inferred from what is displayed. -->
<xsl:variable name="ui-properties" select="'title path has-children'"/>


<!-- This comes from the default NXT template set. -->
<!-- #executive:include:date-time.xsl -->


<!-- Suppress any unmatched text. -->
<xsl:template match="text()"/>


<xsl:template match="/">

<html>

<head>
<title><xsl:value-of select="$title"/></title>

<link rel="stylesheet" type="text/css" href="#!-- #stylesheets:support.css --#"/>

<script type="text/javascript">
<![CDATA[

	function openFolder(path)
	{
		var new_url = "#!-- #executive:script_name --#/" +
			escape(path) + 
			"?f=sdoclist";
	
		window.location.href = new_url;
	}

	function openDocument(path)
	{
		var new_url = "#!-- #executive:script_name --#/" +
			escape(path);
	
		window.location.href = new_url;
	}

]]>
</script>

</head>

<body>

	<!-- Header -->
	<div class="header">
		<table width="100%" border="0">
			<tr>
				<td valign="top" colspan="2">
					<b><script type="text/javascript">document.write(window.location.host + "#!-- #executive:script_name --#");</script></b>
				</td>
				<td align="right">
					<h1><xsl:value-of select="$title"/></h1>
				</td>
			</tr>
			<tr>
				<td valign="bottom">
					<xsl:if test="list-section/parent-path">
						<a href="javascript:openFolder('{list-section/parent-path}')"><img src="#!-- #images:support-fld-u.gif --#" border="0" align="middle" alt="Up One Level" width="15" height="14"/>
						Up One Level</a>
					</xsl:if>
					<xsl:if test="not(list-section/parent-path)"><span class="disabled"><img src="#!-- #images:support-fld-u.gif --#" border="0" align="middle" width="15" height="14"/> Up One Level</span></xsl:if>
				</td>
				<td valign="bottom">
					<img src="#!-- #images:support-fld-o.gif --#" border="0" align="middle" alt="Current Folder" width="15" height="14"/>&#160;
					<b><xsl:value-of select="list-section/title"/>&#160;</b>
				</td>
				<td align="right">
					<a href="?f=templates$fn=support.htm">Return to NXT Support Console</a>
				</td>
			</tr>
		</table>
	</div>
	
	<!-- Main Body -->
	<table width="100%" border="0" cellspacing="0">
		
		<th>title</th>
		<xsl:call-template name="output-generic-headings">
			<xsl:with-param name="select" select="list-section/select"/>
		</xsl:call-template>
		
		<xsl:apply-templates/>
		
	</table>
	

</body>

</html>

</xsl:template>



<xsl:template match="item">
	<tr>
		<!-- First build the UI for navigation. -->
		<td>
			<xsl:call-template name="output-icon"><xsl:with-param name="node" select="."/></xsl:call-template>&#160;
			<xsl:call-template name="output-title"><xsl:with-param name="node" select="."/></xsl:call-template>
		</td>

		<!-- Now display any other properties. -->
		<xsl:call-template name="output-generic-properties">
			<xsl:with-param name="select" select="../select"/>
			<xsl:with-param name="node" select="."/>
		</xsl:call-template>

	</tr>
</xsl:template>




<!-- output-generic-headings: Output headings for all existing properties except for those in $ui-properties. 
This template recursively parses the 'select' parameter to determine all the properties that
were requested.	
-->
<xsl:template name="output-generic-headings">
	<xsl:param name="select"/>
	
	<!-- Get the name of the current property we want to output a heading for. -->
	<xsl:variable name="property">
		<xsl:choose>
			<xsl:when test="contains($select, ';')">
 				<xsl:value-of select="substring-before($select, ';')"/>
 			</xsl:when>
 			<xsl:otherwise>
 				<xsl:value-of select="$select"/>
 			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- Do we have a property? If not, stop recursion. -->
	<xsl:if test="$property != ''">
	
		<!-- Is this a UI property? If not, output a heading for it. -->
		<xsl:if test="not(contains($ui-properties, $property))">
			<th><xsl:value-of select="$property"/></th>
		</xsl:if>

		<!-- Call recursively to output the next property in the select string. -->
		<xsl:call-template name="output-generic-headings">
			<xsl:with-param name="select" select="substring-after($select, ';')"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>




<!-- output-generic-properties: Output a property table cell for each heading. 
This template recursively parses the 'select' parameter to determine all the properties that
were requested.	
-->
<xsl:template name="output-generic-properties">
	<xsl:param name="select"/>
	<xsl:param name="node"/>
	
	<!-- Get the name of the current property we want to output. -->
	<xsl:variable name="property">
		<xsl:choose>
			<xsl:when test="contains($select, ';')">
 				<xsl:value-of select="substring-before($select, ';')"/>
 			</xsl:when>
 			<xsl:otherwise>
 				<xsl:value-of select="$select"/>
 			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	
	<!-- Do we have a property? If not, stop recursion. -->
	<xsl:if test="$property != ''">
		
		<!-- Is this a UI property? If not, output it. -->
		<xsl:if test="not(contains($ui-properties, $property))">
		
			<!-- Does this node even have the property we need? -->
			<xsl:variable name="has-property">
				<xsl:call-template name="node-has-property">
					<xsl:with-param name="node" select="$node"/>
					<xsl:with-param name="property" select="$property"/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test="$has-property = 'yes'">
					<td>
						<!-- Write out the property. -->
						<xsl:call-template name="output-property">
							<xsl:with-param name="node" select="$node"/>
							<xsl:with-param name="property" select="$property"/>
						</xsl:call-template>
					</td>
				</xsl:when>
				<xsl:otherwise><td>&#160;</td></xsl:otherwise>
			</xsl:choose>
		
		</xsl:if>
		
		<!-- Call recursively to output the next property in the select string. -->
		<xsl:call-template name="output-generic-properties">
			<xsl:with-param name="select" select="substring-after($select, ';')"/>
			<xsl:with-param name="node" select="$node"/>
		</xsl:call-template>
		
	</xsl:if>
</xsl:template>



<!-- node-has-property: Output 'yes' if the given node has a child element whose name matches the given property, empty string otherwise. -->
<xsl:template name="node-has-property">
	<xsl:param name="node"/>
	<xsl:param name="property"/>

	<xsl:for-each select="$node/*">
		<xsl:if test="local-name() = $property">yes</xsl:if>
	</xsl:for-each>
</xsl:template>



<!-- output-property: Output the property value from the given node. -->
<xsl:template name="output-property">
	<xsl:param name="node"/>
	<xsl:param name="property"/>

	<xsl:for-each select="$node/*">
		<xsl:if test="local-name() = $property">
			<xsl:choose>
				<xsl:when test="local-name() = 'last-modified'">
					<xsl:call-template name="render-date-time">
						<xsl:with-param name="date-time" select="."/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>	
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:for-each>
</xsl:template>



<!-- output-icon: Output an appropriate icon for the node. -->
<xsl:template name="output-icon">
	<xsl:param name="node"/>

	<xsl:choose>
		<xsl:when test="$node/has-children='yes'">
			<a href="javascript:openFolder('{$node/path}')">
				<img src="#!-- #images:support-fld.gif --#" border="0" align="middle" alt="Open Folder" width="15" height="14"/>
			</a>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$node/content-type">
					<a href="javascript:openDocument('{$node/path}')"><img src="#!-- #images:support-doc.gif --#" border="0" align="middle" alt="Open Document" width="15" height="14"/></a>
				</xsl:when>
				<xsl:otherwise><img src="#!-- #images:support-fld-e.gif --#" border="0" align="middle" alt="Empty" width="15" height="14"/></xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<!-- output-title: Output an appropriate title and link for the node. -->
<xsl:template name="output-title">
	<xsl:param name="node"/>

	<xsl:choose>
		<xsl:when test="$node/content-type">
			<a href="javascript:openDocument('{$node/path}')"><xsl:value-of select="$node/title"/></a>
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="title"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>




</xsl:stylesheet>

