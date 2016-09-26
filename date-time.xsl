<!--
<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>
-->

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
		<xsl:with-param name="month" 	select="substring($date-time, 6, 2)"/>
		<xsl:with-param name="day" 		select="substring($date-time, 9, 2)"/>
		<xsl:with-param name="hours" 	select="substring($date-time, 12, 2)"/>
		<xsl:with-param name="minutes" 	select="substring($date-time, 15, 2)"/>
		<xsl:with-param name="seconds" 	select="substring($date-time, 18, 2)"/>
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


<!--
</xsl:stylesheet>
-->
