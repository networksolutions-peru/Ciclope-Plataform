<!--
Standard templates for the Sync UI.
This is included using a server-side include instead of an
xsl:include, hence the missing top-level element.
-->


<xsl:template name="std-html-redirect">
	<xsl:param name="title"/>
	<xsl:param name="product"/>
	<xsl:param name="icon"/>
	<xsl:param name="caption"/>
	<xsl:param name="text"/>
	<xsl:param name="form"/>
	<xsl:param name="form-action"/>

	<html>
	
		<head>
			<xsl:call-template name="std-head-content">
				<xsl:with-param name="title" select="$title"/>
			</xsl:call-template>
		</head>
		
		<body onload="document.redirect.submit()">

			<xsl:call-template name="std-banner">
				<xsl:with-param name="product" select="$product"/>
			</xsl:call-template>	

			<xsl:call-template name="std-message">
				<xsl:with-param name="icon" select="$icon"/>
				<xsl:with-param name="caption" select="$caption"/>
				<xsl:with-param name="text" select="$text"/>
			</xsl:call-template>
			
			<form name="redirect" action="{$form-action}">
				<xsl:copy-of select="$form"/>
			</form>
			
		</body>
	</html>

</xsl:template>



<xsl:template name="std-html-error">
	<xsl:param name="title"/>
	<xsl:param name="product"/>
	<xsl:param name="icon"/>
	<xsl:param name="caption"/>
	<xsl:param name="text"/>
	<xsl:param name="err-code"/>
	<xsl:param name="retry-script" select="'window.location.reload()'"/>
	<xsl:param name="strings"/>

	<html>
	
		<head>
			<xsl:call-template name="std-head-content">
				<xsl:with-param name="title" select="$title"/>
			</xsl:call-template>
		</head>
		
		<body>

			<xsl:call-template name="std-banner">
				<xsl:with-param name="product" select="$product"/>
			</xsl:call-template>	

			<xsl:call-template name="std-error-message">
				<xsl:with-param name="icon" select="$icon"/>
				<xsl:with-param name="caption" select="$caption"/>
				<xsl:with-param name="text" select="$text"/>
				<xsl:with-param name="err-code" select="$err-code"/>
				<xsl:with-param name="retry-script" select="$retry-script"/>
				<xsl:with-param name="strings" select="$strings"/>
			</xsl:call-template>
			
		</body>
	</html>

</xsl:template>



<xsl:template name="std-head">
	<xsl:param name="title"/>

	<head>
		<xsl:call-template name="std-head-content">
			<xsl:with-param name="title" select="$title"/>
		</xsl:call-template>
	</head>
</xsl:template>



<xsl:template name="std-head-content">
	<xsl:param name="title"/>

	<title><xsl:value-of select="$title"/></title>
	<link rel="stylesheet" type="text/css" href="#!-- #STYLESHEETS:main.css --#"/>
	<link rel="stylesheet" type="text/css" href="#!-- #STYLESHEETS:sync.css --#"/>
	<script type="text/javascript" src="#!-- #TEMPLATES:escape.js --#"/>
</xsl:template>



<xsl:template name="std-banner">
	<xsl:param name="product"/>

	<table width="100%" cellspacing="0">
		<tr>
			<td class="title"> 
				<h1><img align="absmiddle" src="#!-- #IMAGES:logo.gif --#"/><xsl:value-of select="$product"/></h1>
			</td>
		</tr>
	</table>
</xsl:template>



<xsl:template name="std-message">
	<xsl:param name="icon"/>
	<xsl:param name="caption"/>
	<xsl:param name="text"/>

	<table border="0">
		<tr><td height="10">&#160;</td></tr>
		<tr>
			<td valign="top">
				<img src="#!-- #EXECUTIVE:SCRIPT_NAME --#?f=images$fn={$icon}"/>
			</td>
			<td>
				<h2><xsl:copy-of select="$caption"/></h2>
				<p><xsl:copy-of select="$text"/></p>
			</td>
		</tr>
	</table>
</xsl:template>



<xsl:template name="std-error-message">
	<xsl:param name="icon"/>
	<xsl:param name="caption"/>
	<xsl:param name="text"/>
	<xsl:param name="err-code"/>
	<xsl:param name="retry-script" select="'window.location.reload()'"/>
	<xsl:param name="strings"/>

	<table border="0">
		<tr><td height="10">&#160;</td></tr>
		<tr>
			<td valign="top">
				<img src="#!-- #EXECUTIVE:SCRIPT_NAME --#?f=images$fn={$icon}"/>
			</td>
			<td>
				<h2><xsl:copy-of select="$caption"/></h2>
				<p>
					<xsl:copy-of select="$text"/><br/>
		
					<xsl:choose>
						<xsl:when test="$strings/ld:str[@id=$err-code]">
							<xsl:copy-of select="$strings/ld:str[@id=$err-code]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="$strings/ld:str[@id='error-unknown']"/>
						</xsl:otherwise>
					</xsl:choose>
					<br/>
					<xsl:copy-of select="$strings/ld:str[@id='error-label']"/>
					<xsl:value-of select="$err-code"/>
					<br/><br/>
					<form>
						<input type="button" class="button" value="{$strings/ld:str[@id='retry']}" onclick="{$retry-script}"/> &#160;
						<input type="button" class="button" value="{$strings/ld:str[@id='cancel']}" onclick="window.location.search='f=templates$fn=default.htm$isclient=true'"/>
					</form>
				</p>
			</td>
		</tr>
	</table>
</xsl:template>



<xsl:template name="escape-js-string">
	<xsl:param name="string"/>
	
	<xsl:variable name="quot" select="'&#34;'"/>
	<xsl:variable name="apos" select='"&#39;"'/>
	<xsl:variable name="bkslash" select="'\'"/>
	
	<xsl:choose>
		<xsl:when test="$string=''"></xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="starts-with($string, $quot)">\"</xsl:when>
				<xsl:when test="starts-with($string, $apos)">\'</xsl:when>
				<xsl:when test="starts-with($string, $bkslash)">\\</xsl:when>
				<xsl:otherwise><xsl:value-of select="substring($string, 1, 1)"/></xsl:otherwise>
			</xsl:choose>
	
			<xsl:call-template name="escape-js-string">
				<xsl:with-param name="string" select="substring($string, 2)"/>
			</xsl:call-template>
		
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


