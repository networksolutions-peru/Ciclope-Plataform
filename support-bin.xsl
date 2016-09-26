<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>


<xsl:variable name="title">NXT Support: Binaries</xsl:variable>


<!-- This comes from the default NXT template set. -->
<!-- #executive:include:date-time.xsl -->

<xsl:template match="/">

<html>

<head>
<title><xsl:value-of select="$title"/></title>

<link rel="stylesheet" type="text/css" href="#!-- #stylesheets:support.css --#"/>

<script type="text/javascript">
<![CDATA[


]]>
</script>

</head>

<body>

	<!-- Header -->
	<div class="header">
		<table width="100%" border="0">
			<tr>
				<td valign="top">
					<b><script type="text/javascript">document.write(window.location.host + "#!-- #executive:script_name --#");</script></b>
				</td>
				<td align="right">
					<h1><xsl:value-of select="$title"/></h1>
				</td>
			</tr>
			<tr>
				<td valign="bottom">
					<b><xsl:value-of select="directory/path"/>&#160;</b>
				</td>
				<td align="right">
					<a href="?f=templates$fn=support.htm">Return to NXT Support Console</a>
				</td>
			</tr>
		</table>
	</div>
	

	<!-- Main Body -->
	<table width="100%" border="0" cellspacing="0">
		
		<th>name</th>
		<th style="text-align: right">size</th>
		<th>type</th>
		<th>date-time</th>
		
		<xsl:if test="directory/file/file-version">
			<th>file version</th>
		</xsl:if>
		
		<xsl:if test="directory/file/file-description">
			<th>file description</th>
		</xsl:if>
		
		<xsl:if test="not(directory/file)">
			<tr><td>No files found at this path.</td></tr>
		</xsl:if>

		<xsl:for-each select="directory/file">
	
			<xsl:sort select="name"/>
		
			<tr nowrap="nowrap">
				<td nowrap="nowrap" valign="top"><a href="#!-- #executive:script_name --#?f=support$support_c=get$support_fn={path}"><xsl:value-of select="name"/></a></td>
				<td nowrap="nowrap" valign="top" style="text-align: right">
					<xsl:call-template name="format-memory">
						<xsl:with-param name="bytes" select="size"/>
					</xsl:call-template>
				</td>
				<td nowrap="nowrap" valign="top">
					<xsl:call-template name="get-file-type">
						<xsl:with-param name="filename" select="name"/>
					</xsl:call-template>
				</td>
				<td nowrap="nowrap" valign="top">
					<xsl:call-template name="render-iso8601-date-time">
						<xsl:with-param name="date-time" select="date-time"/>
						<xsl:with-param name="format" select="'short'"/>
					</xsl:call-template>
				</td>
				
				<xsl:if test="../file/file-version">
					<td nowrap="nowrap" valign="top"><xsl:value-of select="file-version"/>&#160;</td>
				</xsl:if>
				
				<xsl:if test="../file/file-description">
					<td nowrap="nowrap" valign="top"><xsl:value-of select="file-description"/>&#160;</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
	</table>

</body>
</html>

</xsl:template>


<!-- get-file-type: Outputs a descriptive file type based on the file extension. -->
<xsl:template name="get-file-type">
	<xsl:param name="filename"/>
	
	<xsl:variable name="ext">
		<xsl:call-template name="get-file-extension">
			<xsl:with-param name="filename" select="$filename"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:choose>
		<xsl:when test="$ext='DLL' or $ext='SO'">Application Extension</xsl:when>
		<xsl:when test="$ext='DTD'">Document Type Definition</xsl:when>
		<xsl:when test="$ext='EXE'">Application</xsl:when>
		<xsl:when test="$ext='INI'">Configuration Settings</xsl:when>
		<xsl:when test="$ext='LIB'">Library</xsl:when>
		<xsl:when test="$ext='NFO' or $ext='NXT'">Content Collection</xsl:when>
		<xsl:when test="$ext='SDB'">Site Database</xsl:when>
		<xsl:when test="$ext='SDF'">Site Definition File</xsl:when>
		<xsl:when test="$ext='TXT'">Text Document</xsl:when>
		<xsl:when test="$ext='XIL'">Index Sheet</xsl:when>
		<xsl:otherwise><xsl:value-of select="$ext"/> File</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<!-- get-file-extension: Outputs the (upper case) file extension of a file, even if it has multiple dot (.) characters. -->
<xsl:template name="get-file-extension">
	<xsl:param name="filename"/>
	
	<xsl:variable name="extension" select="substring-after($filename, '.')"/>
	<xsl:choose>
		<xsl:when test="contains($extension, '.')">
			<xsl:call-template name="get-file-extension">
				<xsl:with-param name="filename" select="$extension"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="translate($extension, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<xsl:template name="format-memory">
	<xsl:param name="bytes"/>

	<xsl:choose>
		<xsl:when test="number($bytes) &gt; 10485760">
			<xsl:number value="round(number($bytes) div 1048576)" grouping-size="3" grouping-separator=","/> MB
		</xsl:when>
		<xsl:when test="number($bytes) &gt; 500">
			<xsl:number value="round(number($bytes) div 1024)" grouping-size="3" grouping-separator=","/> KB
		</xsl:when>
		<xsl:otherwise>
			1 KB
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



</xsl:stylesheet>