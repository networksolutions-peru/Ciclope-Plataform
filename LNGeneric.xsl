<?xml version='1.0'?>
<!--xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl"-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<!--
      This stylesheet will work with any XML document produced by the Lotus Notes Content Adapter.
      It will display all the fields in the XML in a table.
-->



<!--  Rich text processing  -->


<xsl:template match='richtext'>
	<span><xsl:apply-templates/></span>
</xsl:template>


<!-- Paragraphs and Paragraph Styles -->

<xsl:template match='par'>
	<!-- A par may inherit its "def" attribute from a previous sibling. -->
	<xsl:variable name='pardef-id'>
		<xsl:choose>
			<xsl:when test='@def'><xsl:value-of select='@def'/></xsl:when>
			<xsl:otherwise><xsl:value-of select='preceding-sibling::par[@def][1]/@def'/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:call-template name='parcontent'>
		<xsl:with-param name='pardef-id' select='$pardef-id'/>
	</xsl:call-template>
</xsl:template>


<xsl:template name='parcontent'>
	<xsl:param name='pardef-id' select='1'/>
	<p class="id{$pardef-id}">
		<xsl:apply-templates/>
		<!-- If the paragraph is totally empty, put in nbsp. -->
		<xsl:if test='not(*|text())'>&#160;</xsl:if>
	</p>
</xsl:template>


<xsl:template name="pardef-to-css">
	p.id<xsl:value-of select='@id'/> {
	<xsl:if test='@align'>text-align: <xsl:value-of select='@align'/>; </xsl:if>
	<xsl:if test='@leftmargin and not(contains(string(@leftmargin), "%"))'>margin-left: <xsl:value-of select='@leftmargin'/>; </xsl:if>
	<xsl:if test='@firstlineleftmargin'>text-indent: <xsl:value-of select='@firstlineleftmargin'/>; </xsl:if>
	<!-- PDB:disabled xsl:if test='@rightmargin'>margin-right: <xsl:value-of select='@rightmargin'/>; </xsl:if -->
	<xsl:if test='@linespacing'>line-height: <xsl:value-of select='@linespacing'/>em; </xsl:if>
	<xsl:if test='@spacebefore'>margin-top: <xsl:value-of select='number(@spacebefore)-1'/>em; </xsl:if>
	<xsl:if test='@spaceafter'>margin-bottom: <xsl:value-of select='number(@spaceafter)-1'/>em; </xsl:if>
	}
</xsl:template>


<xsl:template match="break">
	<br/>
</xsl:template>



<!-- Tables -->

<xsl:template match="table">
	<table style="border:solid 1px black" border="1">
		<xsl:if test='@fit="margins"'><xsl:attribute name='WIDTH'>100%</xsl:attribute></xsl:if>
		<xsl:apply-templates/>
	</table>
</xsl:template>


<xsl:template match="tablecolumn">
	<COL>
		<xsl:attribute name='STYLE'>
			<xsl:if test='@width'>width: <xsl:value-of select='@width'/></xsl:if>
		</xsl:attribute>
	</COL>
</xsl:template>


<xsl:template match="tablerow">
	<TR><xsl:apply-templates/></TR>
</xsl:template>


<xsl:template match="tablecell">
	<TD VALIGN="TOP">
		<xsl:if test='@columnspan != "1"'>
			<xsl:attribute name='COLSPAN'>
				<xsl:value-of select='@columnspan'/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test='@rowspan != "1"'>
			<xsl:attribute name='ROWSPAN'>
				<xsl:value-of select='@rowspan'/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test='@bgcolor'>
			<xsl:attribute name='BGCOLOR'>
				<xsl:apply-templates select='@bgcolor' mode='color-to-css'/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test='@borderwidth'>
			<xsl:attribute name='STYLE'>
				<xsl:text>border-width: </xsl:text>
				<xsl:value-of select='@borderwidth'/>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
		<!-- If the cell is totally empty, put in nbsp. -->
		<xsl:if test='not(*|text())'>&#160;</xsl:if>
	</TD>
</xsl:template>


<xsl:template match="run">
	<span>
		<xsl:attribute name="style">
			<xsl:apply-templates select='font' mode='font-to-css'/>
			<xsl:if test='@highlight="yellow"'>background-color: #FFFFC0; </xsl:if>
			<xsl:if test='@highlight="pink"'  >background-color: #FFCFCF; </xsl:if>
			<xsl:if test='@highlight="blue"'  >background-color: #CFCFFF; </xsl:if>
			<xsl:if test='@html="true"'>background-color: #DFDFDF; </xsl:if>
		</xsl:attribute>
		<xsl:apply-templates/>
	</span>
</xsl:template>



<!-- Pictures -->

<xsl:template match="picture">
	<xsl:choose>
		<xsl:when test="caption">
			<div style="width:{@width}">
				<xsl:call-template name="picture"/>
				<p style="text-align:center;"><xsl:apply-templates/></p>
			</div>
		</xsl:when>
		<xsl:otherwise><xsl:call-template name="picture"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="picture">
	<img width="{@width}" height="{@height}" alt="{@alttext}">
		<xsl:attribute name="src">
			<xsl:choose>
				<xsl:when test="notesbitmap/@nxtid">?f=id$id=<xsl:value-of select="notesbitmap/@nxtid"/></xsl:when>
				<xsl:when test="jpeg/@nxtid">?f=id$id=<xsl:value-of select="jpeg/@nxtid"/></xsl:when>
				<xsl:when test="gif/@nxtid">?f=id$id=<xsl:value-of select="gif/@nxtid"/></xsl:when>
				<xsl:when test="imageref/@nxtid">?f=id$id=<xsl:value-of select="imageref/@nxtid"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="imageref/@name"/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="border">
			<xsl:attribute name="style">
				<xsl:apply-templates mode="border-to-css"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="imagemap/@name">
			<xsl:attribute name="usemap">#<xsl:value-of select="imagemap/@name"/></xsl:attribute>
		</xsl:if>
	</img>
</xsl:template>

<xsl:template match="imagemap">
	<map>
	<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
	<xsl:apply-templates/>
	</map>
</xsl:template>

<xsl:template match="area">
	<xsl:if test='string-length(@type)>0 and @type!="default"'>
		<xsl:element name="area">
			<xsl:if test="@name"><xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="@name"/></xsl:attribute></xsl:if>
			<xsl:if test="@title"><xsl:attribute name="title"><xsl:value-of select="@title"/></xsl:attribute></xsl:if>
			<xsl:attribute name="shape"><xsl:value-of select="@type"/></xsl:attribute>
			<xsl:attribute name="coords"><xsl:value-of select="@coords"/></xsl:attribute>
			<xsl:attribute name="href">
				<xsl:choose>
					<xsl:when test="urllink"><xsl:value-of select="urllink/@href"/></xsl:when>
					<xsl:when test="doclink">?f=id$id=<xsl:value-of select="doclink/@nxtid"/></xsl:when>
				</xsl:choose>
			</xsl:attribute>
		</xsl:element>
	</xsl:if>
</xsl:template>



<!-- Links and Anchors -->

<xsl:template match="doclink">
	<a href="?f=id$id={@nxtid}"><img border="0" src="#!-- #IMAGES:LNdoclink.gif --#"/></a>
</xsl:template>


<xsl:template match="anchor">
	<a name="{@name}"/>
</xsl:template>


<xsl:template match="urllink">
	<A>
	<xsl:for-each select='@href'><xsl:copy-of select='.'/></xsl:for-each>
	<xsl:for-each select='code[@event="value"]/formula'>
		<xsl:attribute name='onClick'>
			<xsl:text>javascript:alert("This link jumps to a computed URL")</xsl:text>
		</xsl:attribute>
	</xsl:for-each>
	<xsl:apply-templates/>
	</A>
</xsl:template>


<xsl:template match='urllink/code'/>



<!-- Buttons -->

<xsl:template match='button'>
	<INPUT TYPE="BUTTON" VALUE="{text()}">
		<xsl:for-each select='code[@event="onClick"]/javascript'>
			<xsl:attribute name='onClick'>
				<xsl:value-of select='.'/>
			</xsl:attribute>
		</xsl:for-each>
	</INPUT>
</xsl:template>



<!-- Attachments - Added PDB 14 March 2001 -->

<xsl:template match='attachmentref'>
	<a><xsl:attribute name='href'>?f=id$id=<xsl:value-of select='@nxtid'/></xsl:attribute>
		<xsl:apply-templates/>
	</a>
</xsl:template>



<!-- Fonts -->

<xsl:template match='font' mode='font-to-css'>
	<xsl:if test='@color'>color: <xsl:value-of select='@color'/>; </xsl:if>
	<xsl:if test='@size'>font-size: <xsl:value-of select='@size'/>; line-height: 1em; </xsl:if>
	<xsl:if test='@name'>font-family: <xsl:value-of select='@name'/>; </xsl:if>
	<xsl:if test='contains(@style,"bold")'>font-weight: bold; </xsl:if>
	<xsl:if test='contains(@style,"italic")'>font-style: italic; </xsl:if>
	<xsl:if test='contains(@style,"underline")'>text-decoration: underline; </xsl:if>
	<xsl:if test='contains(@style,"strikethrough")'>text-decoration: line-through; </xsl:if>
	<xsl:if test='contains(@style,"subscript")'>vertical-align: sub; </xsl:if>
	<xsl:if test='contains(@style,"superscript")'>vertical-align: super; </xsl:if>
</xsl:template>


<xsl:template match='@*' mode='color-to-css'>
	<xsl:choose>
		<xsl:when test='.="system"'>
			<xsl:text>ThreeDFace</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select='.'/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<!-- Borders -->

<xsl:template match="border" mode="border-to-css">
	<xsl:choose>
		<xsl:when test="not(@style)">border-style: solid;</xsl:when>
		<xsl:when test="@style = 'dot'">border-style: dotted;</xsl:when>
		<xsl:when test="@style = 'dash'">border-style: dashed;</xsl:when>
		<xsl:otherwise>border-style: <xsl:value-of select="@style"/></xsl:otherwise>
	</xsl:choose>
	border-width: <xsl:value-of select="@width"/>;
	<xsl:choose>
		<xsl:when test="not(@color)">border-color: black;</xsl:when>
		<xsl:otherwise>border-color: <xsl:value-of select="@color"/>;</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="@insidewidth">
	padding: <xsl:value-of select="@insidewidth"/>;
	</xsl:if>
</xsl:template>



<!-- NXT hit highlighting and TOC navigation. -->

<xsl:template match="lp-hit">
	<span id="lphit" style="background-color: navy; color: white"><xsl:apply-templates/></span>
</xsl:template>


<xsl:template match="lp-hit-anchor">
	<a name="LPHit{@count}"/>
</xsl:template>


<xsl:template match="lp-toc">
	<a name="LPTOC{@anchor}"/>
</xsl:template>



<!-- Time/Date rendering routines. -->


<xsl:template match="datetime">
	<xsl:call-template name='render-iso8601-date-time'>
		<xsl:with-param name="date-time" select="."/>
		<xsl:with-param name="format" select='"short"'/>
	</xsl:call-template >
</xsl:template>



<!-- render-date-time: Display a date and time from a date/time node set. -->

<xsl:template name="render-date-time">
	<xsl:param name="date-time"/>
	<xsl:param name="format"/>

	<xsl:call-template name="render-base">
		<xsl:with-param name="year" 	select="string($date-time/year)"/>
		<xsl:with-param name="month" 	select="string($date-time/month)"/>
		<xsl:with-param name="day" 		select="string($date-time/day)"/>
		<xsl:with-param name="hours" 	select="string($date-time/hours)"/>
		<xsl:with-param name="minutes" 	select="string($date-time/minutes)"/>
		<xsl:with-param name="seconds" 	select="string($date-time/seconds)"/>
		<xsl:with-param name="format" 	select="$format"/>
	</xsl:call-template>
</xsl:template>



<!-- render-iso8601-date-time: Display a date and time from an ISO 8601 date/time string. -->

<xsl:template name="render-iso8601-date-time">
	<xsl:param name="date-time"/>
	<xsl:param name="format"/>

	<xsl:call-template name="render-base">
		<xsl:with-param name="year" 	select="substring($date-time, 1, 4)"/>
		<xsl:with-param name="month" 	select="substring($date-time, 5, 2)"/>
		<xsl:with-param name="day" 		select="substring($date-time, 7, 2)"/>
		<xsl:with-param name="hours" 	select="substring($date-time, 10, 2)"/>
		<xsl:with-param name="minutes" 	select="substring($date-time, 12, 2)"/>
		<xsl:with-param name="seconds" 	select="substring($date-time, 14, 2)"/>
		<xsl:with-param name="format" 	select="$format"/>
	</xsl:call-template>
</xsl:template>



<!-- render-elapsed-time: Display an elapsed time in seconds as hours:minutes:seconds. -->

<xsl:template name="render-elapsed-time">
	<xsl:param name="seconds"/>

	<xsl:choose>
		<xsl:when test="string($seconds) = ''"/>
		<xsl:otherwise>
			<xsl:variable name="hours" select="floor($seconds div 3600)"/>
			<xsl:variable name="secs-less-hours" select="$seconds mod 3600"/>
			<xsl:variable name="minutes" select="floor($secs-less-hours div 60)"/>
			<xsl:variable name="secs-less-minutes" select="$secs-less-hours mod 60"/>
			
			<xsl:if test="$hours &lt; 10">0</xsl:if>
			<xsl:value-of select="$hours"/>:<xsl:if test="$minutes &lt; 10">0</xsl:if>
			<xsl:value-of select="$minutes"/>:<xsl:if test="$secs-less-minutes &lt; 10">0</xsl:if>
			<xsl:value-of select="$secs-less-minutes"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<!-- Internal Templates =================================================== -->



<!-- render-base: Base template for rendering date/time. All parameters must be strings. -->

<xsl:template name="render-base">
	<xsl:param name="year"/>
	<xsl:param name="month" select="0"/>
	<xsl:param name="day"/>
	<xsl:param name="hours"/>
	<xsl:param name="minutes"/>
	<xsl:param name="seconds"/>
	<xsl:param name="format"/>

	<xsl:choose>
		<!-- Invalid date - leave blank -->
		<xsl:when test="$month = '' or $month &lt; 1 or $month &gt; 12"/>

		<!-- Short format -->
		<xsl:when test="$format = 'short'">
			<xsl:value-of select="$month"/>/<xsl:value-of select="$day"/>/<xsl:value-of select="$year"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="$hours"/>:<xsl:value-of select="$minutes"/>:<xsl:value-of select="$seconds"/>
		</xsl:when>

		<!-- Default format -->
		<xsl:otherwise>

			<xsl:variable name="am-pm-hours">
				<xsl:choose>
					<xsl:when test="$hours = 0">12</xsl:when>
					<xsl:when test="$hours &lt; 12"><xsl:value-of select="$hours"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$hours - 12"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:call-template name="get-month-name">
				<xsl:with-param name="month" select="$month"/>
			</xsl:call-template>
			<xsl:text> </xsl:text>
			<xsl:if test="$day &lt; 10">0</xsl:if>
			<xsl:value-of select="$day"/>, <xsl:value-of select="$year"/>
			<xsl:text> </xsl:text>
			<xsl:if test="$am-pm-hours &lt; 10">0</xsl:if>
			<xsl:value-of select="$am-pm-hours"/>:<xsl:value-of select="$minutes"/>
			<xsl:choose>
				<xsl:when test="$hours &lt; 12"><xsl:text> </xsl:text>AM</xsl:when>
				<xsl:otherwise><xsl:text> </xsl:text>PM</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<!-- get-month-names: Return a string representation of a month given a one-based month number. -->

<xsl:variable name="month-names">Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec </xsl:variable>

<xsl:template name="get-month-name">
	<xsl:param name="month"/>

	<!-- Assuming 3 chars + space per name. -->
	<xsl:value-of select="substring($month-names, $month * 4 - 3, 3)"/>
</xsl:template>


<!--  End Rich Text processing  -->






<xsl:template match="/">
	<html><body>
	<table border="1" cellpadding="1" cellspacing="0">
	<tr><td><b>Type</b></td><td><b>Name</b></td><td><b>Value</b></td></tr>
	
	<xsl:apply-templates select="/document/*"/>

	</table>
	</body>
	</html>
</xsl:template>


<xsl:template match="item">
	<xsl:apply-templates/>
</xsl:template>


<xsl:template match="text">
	<tr>
		<td>text</td>
		<td><xsl:value-of select="../@name"/></td>
		<td><xsl:apply-templates/></td>
	</tr>
</xsl:template>

<xsl:template match="richtext">
	<tr>
		<td>richtext</td>
		<td><xsl:value-of select="../@name"/></td>
		<td><xsl:apply-templates/></td>
	</tr>
</xsl:template>

<xsl:template match="datetime">
	<tr>
		<td>datetime</td>
		<td><xsl:value-of select="../@name"/></td>
		<td>
		<xsl:call-template name='render-iso8601-date-time'>
			<xsl:with-param name="date-time" select="."/>
			<xsl:with-param name="format" select='"short"'/>
		</xsl:call-template >
		</td>
	</tr>
</xsl:template>


<xsl:template match="*">
</xsl:template>










</xsl:stylesheet>
