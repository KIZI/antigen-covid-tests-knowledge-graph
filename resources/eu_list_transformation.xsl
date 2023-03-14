<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="f xsd"
                version="3.0"
                xmlns:act="https://covidtesty.vse.cz/vocabulary#"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:f="https://covidtesty.vse.cz/xslt/functions#"
                xmlns:ncit="http://purl.obolibrary.org/obo/NCIT_"
                xmlns:qudt="http://qudt.org/schema/qudt/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:reg="http://purl.org/linked-data/registry#"
                xmlns:schema="http://schema.org/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- Global variables -->

  <xsl:variable name="ns">https://covidtesty.vse.cz/data/</xsl:variable>

  <!-- Functions -->
  
  <xsl:import href="functions.xsl"/>

  <!-- Output -->

  <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC"/>
  <xsl:strip-space elements="*"/>

  <!-- Templates -->

  <xsl:template match="/data">
    <rdf:RDF>
      <xsl:apply-templates/>
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="deviceList">
    <xsl:apply-templates mode="device"/>
  </xsl:template>

  <xsl:template match="*[starts-with(name(), 'device_')]" mode="device">
    <act:AntigenCovidTest>
      <xsl:apply-templates/>
    </act:AntigenCovidTest>
  </xsl:template>

  <xsl:template match="element_id_device">
    <xsl:attribute name="rdf:about" select="f:resource-iri('antigen-covid-test', (text()))"/>
  </xsl:template>

  <xsl:template match="element_commercial_name">
    <schema:name><xsl:value-of select="text()"/></schema:name>
  </xsl:template>

  <xsl:template match="manufacturer">
    <schema:manufacturer>
      <schema:Organization>
        <xsl:apply-templates>
          <xsl:with-param name="manufacturer-id" select="element_id_manufacturer/text()"/>
        </xsl:apply-templates>
      </schema:Organization>
    </schema:manufacturer>
  </xsl:template>

  <xsl:template match="element_id_manufacturer">
    <xsl:attribute name="rdf:about" select="f:resource-iri('organization', (text()))"/>
  </xsl:template>

  <xsl:template match="element_name">
    <schema:name><xsl:value-of select="text()"/></schema:name>
  </xsl:template>

  <xsl:template match="element_country">
    <xsl:param name="manufacturer-id" required="yes"/>
    <schema:address>
      <schema:PostalAddress rdf:about="{f:resource-iri('postal-address', ($manufacturer-id))}">
        <schema:addressCountry><xsl:value-of select="text()"/></schema:addressCountry>
      </schema:PostalAddress>
    </schema:address>
  </xsl:template>

  <xsl:template match="element_website">
    <schema:url><xsl:value-of select="text()"/></schema:url>
  </xsl:template>

  <!-- Catch-all empty template -->

  <xsl:template match="text()|@*" mode="#all"/>
</xsl:stylesheet>
