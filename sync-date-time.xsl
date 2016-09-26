<!--
<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>
-->

<xsl:param name="month-names">Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec </xsl:param>


<!-- render-iso8601-date-time: Display a date and time from an ISO 8601 date/time string. -->

<xsl:template name="render-iso8601-date-time">
	<xsl:param name="date-time"/>
	<xsl:param name="has-separators" select="'yes'"/>
	<xsl:param name="format"/>

	<!-- Offsets to parts of the date/time: -->
	<xsl:variable name="yr-off" select="1"/>
	<xsl:variable name="mo-off">
		<xsl:choose><xsl:when test="$has-separators='yes'">6</xsl:when><xsl:otherwise>5</xsl:otherwise></xsl:choose>
	</xsl:variable>
	<xsl:variable name="da-off">
		<xsl:choose><xsl:when test="$has-separators='yes'">9</xsl:when><xsl:otherwise>7</xsl:otherwise></xsl:choose>
	</xsl:variable>
	<xsl:variable name="ho-off">
		<xsl:choose><xsl:when test="$has-separators='yes'">12</xsl:when><xsl:otherwise>10</xsl:otherwise></xsl:choose>
	</xsl:variable>
	<xsl:variable name="mi-off">
		<xsl:choose><xsl:when test="$has-separators='yes'">15</xsl:when><xsl:otherwise>12</xsl:otherwise></xsl:choose>
	</xsl:variable>
	<xsl:variable name="se-off">
		<xsl:choose><xsl:when test="$has-separators='yes'">18</xsl:when><xsl:otherwise>14</xsl:otherwise></xsl:choose>
	</xsl:variable>

	<xsl:call-template name="render-base">
		<xsl:with-param name="year" 	select="substring($date-time, $yr-off, 4)"/>
		<xsl:with-param name="month" 	select="substring($date-time, $mo-off, 2)"/>
		<xsl:with-param name="day" 		select="substring($date-time, $da-off, 2)"/>
		<xsl:with-param name="hours" 	select="substring($date-time, $ho-off, 2)"/>
		<xsl:with-param name="minutes" 	select="substring($date-time, $mi-off, 2)"/>
		<xsl:with-param name="seconds" 	select="substring($date-time, $se-off, 2)"/>
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

			<xsl:if test="$day &lt; 10">0</xsl:if>
			<xsl:value-of select="$day"/>&#160;
			<xsl:call-template name="get-month-name">
				<xsl:with-param name="month" select="$month"/>
			</xsl:call-template>&#160;
			<xsl:value-of select="$year"/>&#160;
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

<xsl:template name="get-month-name">
	<xsl:param name="month"/>

	<!-- Assuming 3 chars + space per name. -->
	<xsl:value-of select="substring($month-names, $month * 4 - 3, 3)"/>
</xsl:template>


<!--
</xsl:stylesheet>
-->
