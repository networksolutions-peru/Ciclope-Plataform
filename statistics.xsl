<?xml version="1.0"?>

<!-- 

	Statistics template

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" method="html"/>

<!-- #executive:include:date-time.xsl -->
<!-- We'd rather use xsl:include, but the current UNIX XSL processor doesn't support inclusions via HTTP. -->


<xsl:template match="/">

<html>

<head>
	<title>Estadisticas</title>
	
	<link rel="stylesheet" type="text/css">
		<xsl:attribute name="href"><!-- #STYLESHEETS:main.css --></xsl:attribute>
	</link>

	<link rel="stylesheet" type="text/css">
		<xsl:attribute name="href"><!-- #STYLESHEETS:statistics.css --></xsl:attribute>
	</link>
</head>

<body>

<table width="100%" cellspacing="0">

	<tr>
		<td class="title"> 
			<h1><img align="absmiddle"><xsl:attribute name="src"><!-- #IMAGES:logo.gif --></xsl:attribute></img>Registros y estadisticas</h1>
		</td>
		<td class="title" align="right">
			<xsl:call-template name="render-iso8601-date-time">
				<xsl:with-param name="date-time" select="document/current-time"/>
				<xsl:with-param name="format" select="'short'"/>
			</xsl:call-template>
		</td>
	</tr>
	<tr><td class="separator"></td></tr>
</table>

<table>

	<xsl:for-each select="document/log[starts-with(@class, 'build-') and @class != 'build-urlcrawler']">
		<xsl:variable name="build-class" select="@class"/>
		<xsl:variable name="first-build-name" select="string(../log[@class=$build-class]/@name)"/>

		<!-- Only continue if this is the first log for a build with this class because 
		the following code will output all the build logs for this class. -->
		<xsl:if test="@name[. = $first-build-name]">
			<tr><td class="separator"></td></tr>
			<tr>
				<td class="title">
					<xsl:choose>
						<!-- Known build types can have better titles: -->
						<xsl:when test="@class[. = 'build-filestore']">Construccion de Servicios de File System </xsl:when>
						<xsl:when test="@class[. = 'build-lnotesdocstore']">Lotus Notes Service Builds</xsl:when>
						<xsl:when test="@class[. = 'build-outlookstore']">Outlook Service Builds</xsl:when>
						<xsl:when test="@class[. = 'build-sourcesafestore']">Source Safe Service Builds</xsl:when>
						<xsl:when test="@class[. = 'build-odbcdoc']">Construccion de Servicios de Base de datos ODBC </xsl:when>
						<xsl:when test="@class[. = 'build-oracledoc']">Oracle Database Service Builds</xsl:when>
						<xsl:when test="@class[. = 'build-disconnectedsync']">Construccion de Distribucion y Sincronizacion</xsl:when>
		
						<!-- Otherwise just use the log's name: -->
						<xsl:otherwise><xsl:value-of select="$build-class"/></xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
			<tr><td>
			
				<table cellpadding="3">
					<tr>
						<xsl:call-template name="write-service-build-headings"/>
					</tr>
		
					<xsl:for-each select="../log[@class=$build-class]">
						<tr>
							<xsl:call-template name="report-service-build">
								<xsl:with-param name="log-name" select="@name"/>
								<xsl:with-param name="log-props" select="properties"/>
							</xsl:call-template>
						</tr>
					</xsl:for-each>
				</table>
		
			</td></tr>
		</xsl:if>
	</xsl:for-each>


	<!-- URLCrawler logs -->	
	<xsl:if test="document/log[@class='build-urlcrawler']">

	<tr><td class="separator"></td></tr>
	<tr><td class="title">Construccion de Servicio Web</td></tr>
	<tr><td>
	
		<table cellpadding="3">

			<tr>
				<xsl:call-template name="write-service-build-headings"/>

				<!-- A few extra headings for URLCrawler -->
				<th>Recuperados</th>
				<th>Pendientes</th>
				<th>Nivel actual</th>
				<th>Documento actual</th>
			</tr>

			<xsl:for-each select="document/log[@class='build-urlcrawler']">

				<tr>
					<xsl:call-template name="report-service-build">
						<xsl:with-param name="log-name" select="@name"/>
						<xsl:with-param name="log-props" select="properties"/>
					</xsl:call-template>

					<td align="right"><xsl:value-of select="properties/property[@name='totalretrieveddocs']"/></td>
					<td align="right"><xsl:value-of select="properties/property[@name='totalpendingdocs']"/></td>
					<td align="right"><xsl:value-of select="properties/property[@name='currentleveldepth']"/></td>
					<td>&#160;<xsl:value-of select="properties/property[@name='currentdocument']"/></td>
				</tr>

			</xsl:for-each>
		</table>

	</td></tr>
	
	</xsl:if>

	<!-- Link logs -->	
	<xsl:if test="document/log[@class='link']">

	<tr><td class="separator"></td></tr>
	<tr><td class="title">Vinculos de Estadisticas</td></tr>
	<tr><td>
	
		<table cellpadding="3">

			<tr>
				<th>Nombre</th>
				<th>Estado</th>
				<th>Tiempo de Inicio</th>
				<th>Conexiones Fallidas</th>
				<th>Timeouts</th>
				<th>Documentos</th>
				<th>Segundas Lineas</th>
				<th>Informacion de las Consultas</th>
				<th>Consultas</th>
				<th>Elementos</th>
				<th>Nodos de Busqueda</th>
				<th>Propiedades</th>
				<th>KBytes Enviados</th>
				<th>KBytes Recebidos</th>
				<th>Tiempo de Respuesta Aproximado</th>
			</tr>

			<xsl:for-each select="document/log[@class='link']">

				<tr>
					<td><b><xsl:value-of select="properties/property[@name='name']"/></b></td>
					<td>
						<xsl:element name="a">
							<xsl:attribute name="href">#!-- #EXECUTIVE:SCRIPT_NAME --#?f=statistics$fmt=xsl$ss=message-log.xsl$msg=1$log=<xsl:value-of select="@name"/></xsl:attribute>
							<xsl:choose><xsl:when test="properties/property[@name = 'status' and . = '0']">OK (0x0000000)</xsl:when><xsl:otherwise>Error (0x<xsl:value-of select="properties/property[@name='status']"/>)</xsl:otherwise></xsl:choose>
						</xsl:element>
					</td>
					<td>
						<xsl:call-template name="render-iso8601-date-time">
							<xsl:with-param name="date-time" select="properties/property[@name='start-time']"/>
							<xsl:with-param name="format" select="'short'"/>
						</xsl:call-template>
					</td>
					<td><xsl:value-of select="properties/property[@name='failed-connections']"/></td>
					<td><xsl:value-of select="properties/property[@name='timeout-count']"/></td>
					<td><xsl:value-of select="properties/property[@name='doc-requests']"/></td>
					<td><xsl:value-of select="properties/property[@name='children-requests']"/></td>
					<td><xsl:value-of select="properties/property[@name='query-info-requests']"/></td>
					<td><xsl:value-of select="properties/property[@name='query-requests']"/></td>
					<td><xsl:value-of select="properties/property[@name='element-requests']"/></td>
					<td><xsl:value-of select="properties/property[@name='find-node-requests']"/></td>
					<td><xsl:value-of select="properties/property[@name='properties-requests']"/></td>
					<td><xsl:number value="number(properties/property[@name='bytes-sent']) div 1024" grouping-size="3" grouping-separator=","/></td>
					<td><xsl:number value="number(properties/property[@name='bytes-received']) div 1024" grouping-size="3" grouping-separator=","/></td>
					<td>
						<xsl:call-template name="write-avg-link-time">
							<xsl:with-param name="log-props" select="properties"/>
						</xsl:call-template>
					</td>
				</tr>

			</xsl:for-each>

		</table>
		
	</td></tr>

	</xsl:if>

	<!-- Executive logs -->	
	<xsl:if test="document/log[@class='executive']">

	<tr><td class="separator"></td></tr>
	<tr><td class="title">Estadisticas del Servidor</td></tr>
	<tr><td>
	
		<table cellpadding="3">

			<tr>
				<th>Funcion</th>
				<th>Pedidos Totales</th>
				<th>Actuales Pedidos</th>
				<th>Timed Out Totales</th>
				<th>Fallidos Totales</th>
				<th>Tiempo Maximo (ms)</th>
				<th>Tiempo Total (ms)</th>
				<th>Tiempo de Respuesta Aproximado (ms)</th>
			</tr>
			
			<xsl:for-each select="document/log[@class='executive']">

				<tr>
					<xsl:choose>
						<xsl:when test="properties/property[@name='name']">
							<td><b><xsl:value-of select="properties/property[@name='name']"/></b></td>
						</xsl:when>
						<xsl:otherwise>
							<td><b>Total</b></td>
						</xsl:otherwise>
					</xsl:choose>
					<td align="right">&#160;<xsl:value-of select="properties/property[@name='totalrequests']"/></td>
					<td align="right">&#160;<xsl:value-of select="properties/property[@name='currentrequests']"/></td>
					<td align="right">&#160;<xsl:value-of select="properties/property[@name='totaltimedout']"/></td>
					<td align="right">&#160;<xsl:value-of select="properties/property[@name='totalfailed']"/></td>
					<td align="right">&#160;<xsl:value-of select="properties/property[@name='maxtime']"/></td>
					<td align="right">&#160;<xsl:value-of select="properties/property[@name='totaltime']"/></td>
					<td align="right">&#160;
						<xsl:call-template name="write-avg-request-time">
							<xsl:with-param name="log-props" select="properties"/>
						</xsl:call-template>
					</td>
				</tr>

			</xsl:for-each>

		</table>
		
	</td></tr>

	</xsl:if>

	<!-- SiteView statistics -->	
	<xsl:if test="document/log[@class='siteview']">

	<tr><td class="separator"></td></tr>
	<tr><td class="title">Estadisticas de Recursos de Sistema</td></tr>
	<tr><td>
	
		<table cellpadding="3">

			<tr>
				<td><b>Desde</b></td>
				<td align="right">
					<xsl:call-template name="render-iso8601-date-time">
						<xsl:with-param name="date-time" select="document/log[@class='siteview']/properties/property[@name='starttime']"/>
						<xsl:with-param name="format" select="'short'"/>
					</xsl:call-template>
				</td>
			</tr>
			<xsl:if test="document/log[@class='executive']/properties/property[@name='currentsessions']">
				<tr>
					<td><b>Sesiones Actuales</b></td>
					<td align="right"><xsl:value-of select="document/log[@class='executive']/properties/property[@name='currentsessions']"/></td>
				</tr>
			</xsl:if>
			<xsl:if test="document/log[@class='executive']/properties/property[@name='totalsessions']">
				<tr>
					<td><b>Sesiones Totales</b></td>
					<td align="right"><xsl:value-of select="document/log[@class='executive']/properties/property[@name='totalsessions']"/></td>
				</tr>
			</xsl:if>
			<xsl:if test="document/log[@class='executive']/properties/property[@name='maxsessionsreached']">
				<tr>
					<td><b>Maxima Cantidad de Sesiones Alcanzada</b></td>
					<td align="right"><xsl:value-of select="document/log[@class='executive']/properties/property[@name='maxsessionsreached']"/></td>
				</tr>
			</xsl:if>
			<tr>
				<td><b>Maxima Memoria Usada para las Paginas</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='maxmempagestouse']"/></td>
			</tr>
			<tr>
				<td><b>Minima Memoria Usada para las Paginas</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='minmempagestouse']"/></td>
			</tr>
			<tr>
				<td><b>Minimo de Paginas en Cache de Lectura</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='minpagestoreadcache']"/></td>
			</tr>
			<tr>
				<td><b>Maximo de Paginas en Cache de Lectura</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='maxpagestoreadcache']"/></td>
			</tr>
			<tr>
				<td><b>Minimo de Paginas en Cache de Escritura</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='minpagestowritecache']"/></td>
			</tr>
			<tr>
				<td><b>Maximo de Paginas en Cache de Escritura</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='maxpagestowritecache']"/></td>
			</tr>
			<tr>
				<td><b>Minima Reserva de Paginas</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='minreservepages']"/></td>
			</tr>
			<tr>
				<td><b>Maxima Reserva de Paginas</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='maxreservedpages']"/></td>
			</tr>
			<tr>
				<td><b>Paginas Actuales en Cache de Lectura</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='curreadcachedpages']"/></td>
			</tr>
			<tr>
				<td><b>Paginas Actuales en Cache de Escritura</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='curwritecachedpages']"/></td>
			</tr>
			<tr>
				<td><b>Paginas Descartadas del Cache de Lectura</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='readcachediscards']"/></td>
			</tr>
			<tr>
				<td><b>Paginas alineadas en Cache de Escritura</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='writecacheflushes']"/></td>
			</tr>
			<tr>
				<td><b>Paginas Actuales Alojadas en Memoria</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='curmempagesallocated']"/></td>
			</tr>
			<tr>
				<td><b>Total de Paginas Actuales Alojadas</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='curpagesallocated']"/></td>
			</tr>
			<tr>
				<td><b>Paginas Compaginadas</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='pagedpages']"/></td>
			</tr>
			<tr>
				<td><b>Numero Maximo de Bytes que el Servidor esta usando</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='fcsrvheapusagebytes']"/></td>
			</tr>
			<tr>
				<td><b>Numero Maximo de Bytes usado por Servidor</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='fcsrvhighwaterheapusagebytes']"/></td>
			</tr>
			<tr>
				<td><b>umero Maximo de Bytes que el Administrador esta usando</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='nfomgrheapusagebytes']"/></td>
			</tr>
			<tr>
				<td><b>Numero Maximo de Bytes usado por Administrador</b></td>
				<td align="right"><xsl:value-of select="document/log[@class='siteview']/properties/property[@name='nfomgrhighwaterheapusagebytes']"/></td>
			</tr>

		</table>
		
	</td></tr>

	</xsl:if>
	
</table>

</body>

</html>

</xsl:template>






<!-- write-service-build-headings: Writes common headings for service builds. -->

<xsl:template name="write-service-build-headings">
	<th>Nombre</th>
	<th>Tiempo de Inicio</th>
	<th>Tiempo de Finalizacion</th>
	<th>Tiempo Total (h:m:s)</th>
	<th>Construyendo</th>
	<th>Fase</th>
	<th>Estado</th>
	<th>Errores</th>
	<th>Advertencias</th>
</xsl:template>



<!-- report-service-build: Reports common parts of a service build. -->

<xsl:template name="report-service-build">
	<xsl:param name="log-name"/>
	<xsl:param name="log-props"/>

	<td><b><xsl:value-of select="substring-after($log-name, ':')"/></b></td>
	<td>
		<xsl:call-template name="render-iso8601-date-time">
			<xsl:with-param name="date-time" select="$log-props/property[@name='start-time']"/>
			<xsl:with-param name="format" select="'short'"/>
		</xsl:call-template>
	</td>
	<td>&#160;
		<xsl:call-template name="render-iso8601-date-time">
			<xsl:with-param name="date-time" select="$log-props/property[@name='stop-time']"/>
			<xsl:with-param name="format" select="'short'"/>
		</xsl:call-template>
	</td>
	<td align="right">&#160;
		<xsl:call-template name="render-elapsed-time">
			<xsl:with-param name="seconds" select="$log-props/property[@name='elapsed-time']"/>
		</xsl:call-template>
	</td>
	<td><xsl:choose><xsl:when test="$log-props/property[@name = 'building' and . = '1']">Yes</xsl:when><xsl:otherwise>No</xsl:otherwise></xsl:choose></td>
	<td><xsl:value-of select="$log-props/property[@name = 'phase']"/></td>
	<td>
		<xsl:element name="a">
			<xsl:attribute name="href"><!-- #EXECUTIVE:SCRIPT_NAME -->?f=statistics$fmt=xsl$ss=message-log.xsl$msg=1$log=<xsl:value-of select="$log-name"/></xsl:attribute>
			<xsl:choose><xsl:when test="$log-props/property[@name = 'status' and . = '0']">OK (0x0000000)</xsl:when><xsl:otherwise>Error (0x<xsl:value-of select="properties/property[@name='status']"/>)</xsl:otherwise></xsl:choose>
		</xsl:element>
	</td>
	<td><xsl:value-of select="$log-props/property[@name='error-count']"/></td>
	<td><xsl:value-of select="$log-props/property[@name='warning-count']"/></td>
</xsl:template>



<!-- write-avg-request-time: Calculates and writes the average request time for a set of log properties. -->

<xsl:template name="write-avg-request-time">
	<xsl:param name="log-props"/>

	<xsl:choose>
		<xsl:when test="not($log-props/property[@name='totalrequests'])"/>
		<xsl:otherwise>
			<xsl:value-of select="round($log-props/property[@name='totaltime'] div $log-props/property[@name='totalrequests'])"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<!-- write-avg-link-time: Calculates and writes the average link response time for a set of log properties. -->

<xsl:template name="write-avg-link-time">
	<xsl:param name="log-props"/>

	<xsl:choose>
		<xsl:when test="not($log-props/property[@name='total-requests'])"/>
		<xsl:otherwise>
			<xsl:value-of select="round($log-props/property[@name='response-time'] div $log-props/property[@name='total-requests'])"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



</xsl:stylesheet>
