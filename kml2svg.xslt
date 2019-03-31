<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"     
    xmlns="http://www.w3.org/2000/svg" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:kml="http://www.opengis.net/kml/2.2"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="math"
>
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>

	<xsl:variable name="mapscale" select="0.0002"/>
	<xsl:variable name="mapshift_x" select="-120"/>
	<xsl:variable name="mapshift_y" select="1350"/>
	
	<xsl:template name="degtometers_lon">
	  <xsl:param name="lon"/>
	  <xsl:variable name="hcir" select="20037508.34"/>
	  <xsl:value-of select="format-number($mapshift_x + $mapscale * ($lon * $hcir div 180), '####0.00000')"/>
	</xsl:template>
	
	<xsl:template name="degtometers_lat">
	  <xsl:param name="lat"/>
	  <xsl:variable name="pi" select="math:pi()"/>
	  <xsl:variable name="hcir" select="20037508.34"/>
	  <xsl:value-of select="format-number($mapshift_y + $mapscale * -1.0 * ((math:log(math:tan((90.0 + $lat) * $pi div 360)) div ($pi div 180)) * $hcir div 180), '####0.00000')"/>
	</xsl:template>

	<xsl:template name="degtometers">
	  <xsl:param name="lon"/>
	  <xsl:param name="lat"/>
	  <xsl:variable name="pi" select="math:pi()"/>
	  <xsl:variable name="hcir" select="20037508.34"/>
	  <xsl:variable name="rx" select="format-number($mapshift_x + $mapscale * ($lon * $hcir div 180), '####0.00000')"/>
	  <xsl:variable name="ry" select="format-number($mapshift_y + $mapscale * -1.0 * ((math:log(math:tan((90.0 + $lat) * $pi div 360)) div ($pi div 180)) * $hcir div 180), '####0.00000')"/>
	  <xsl:value-of select="concat( $rx, ',' , $ry, ' ' )"/>
	</xsl:template>

    <xsl:template match="kml:Document">
        <svg width="210mm" height="297mm" viewBox="0 0 210 297" version="1.1">
            <title><xsl:value-of select="kml:name"/></title>
            <desc><xsl:value-of select="kml:description"/></desc>            
	        <xsl:apply-templates select="kml:Folder"/>
        </svg>
    </xsl:template>

    <!-- Process folder elements -->
    <xsl:template match="kml:Folder">
    	<xsl:if test="kml:Placemark/kml:LineString">
        <g>
            <title><xsl:value-of select="kml:name"/></title>
            <desc><xsl:value-of select="kml:description"/></desc>
           	<xsl:apply-templates select="kml:Placemark"/>
        </g>
        </xsl:if>
    </xsl:template>

    <xsl:template match="kml:Placemark">
        <xsl:variable name="lon" select="number(substring-before(normalize-space(kml:Point/kml:coordinates), ','))"/>
        <xsl:variable name="lat" select="number(substring-before(substring-after(normalize-space(kml:Point/kml:coordinates), ','), ','))"/>

        <xsl:variable name="cx">
			<xsl:call-template name="degtometers_lon">
				<xsl:with-param name="lon" select="$lon"/>
			</xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="cy">
			<xsl:call-template name="degtometers_lat">
				<xsl:with-param name="lat" select="$lat"/>
			</xsl:call-template>        
        </xsl:variable>
		
        <g>
        	<xsl:if test="string(number($cx))!='NaN' and string(number($cy))!='NaN'">
	            <title><xsl:value-of select="kml:name"/></title>
	            <desc><xsl:value-of select="kml:description"/></desc>
	            <circle r="5" fill="white" stroke="blue" stroke-width="0.3">                       
	                <xsl:attribute name="cx">
						<xsl:value-of select="$cx"/>
	                </xsl:attribute>
	                <xsl:attribute name="cy">
						<xsl:value-of select="$cy"/>
	                </xsl:attribute>
	            </circle>
	            <text font-family="Verdana" font-size="4" fill="blue">
	                <xsl:attribute name="x">
	                    <xsl:value-of select="$cx + 5.0 + 1.0"/>
	                </xsl:attribute>
	                <xsl:attribute name="y">
	                    <xsl:value-of select="$cy + 1.5"/>
	                </xsl:attribute>
	                <xsl:value-of select="kml:name"/>
	            </text>
	            <text font-family="Verdana" font-size="3" fill="blue">                 
	                <xsl:attribute name="x">
	                    <xsl:value-of select="$cx + 5.0 + 1.0"/>
	                </xsl:attribute>
	                <xsl:attribute name="y">
	                    <xsl:value-of select="$cy + 4.0"/>
	                </xsl:attribute>
	                <xsl:value-of select="kml:description"/>
	            </text>
	        </xsl:if>
            <xsl:apply-templates select="kml:LineString"/>
        </g>
    </xsl:template>

    <xsl:template match="kml:LineString">
        <xsl:variable name="coords" select="kml:coordinates"/>
        <xsl:variable name="tokenizedCoords" select="tokenize($coords, ',0\n')" />
        <polyline fill="none" stroke="blue" stroke-width="0.3mm">
            <xsl:attribute name="points">
                <xsl:for-each select="$tokenizedCoords">                	
                	<xsl:variable name="lonlat" select="tokenize(normalize-space(.), ',')" />
                	<xsl:if test="$lonlat != ''">
						<xsl:call-template name="degtometers">
							<xsl:with-param name="lon" select="number($lonlat[1])"/>
							<xsl:with-param name="lat" select="number($lonlat[2])"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:for-each>
            </xsl:attribute>        
        </polyline>
            
    </xsl:template>
    <!-- Catch all rule to fire on un-matched elements - ideally should not appear -->
    <xsl:template match="*">
        <xsl:message terminate="no">
        WARNING: Unmatched element: <xsl:value-of select="name()"/>
        </xsl:message>

        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>