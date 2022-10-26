<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY ncit   "http://purl.obolibrary.org/obo/NCIT_">
    <!ENTITY status "https://covidtesty.vse.cz/data/concept/registration-statuses/">
    <!ENTITY xsd    "http://www.w3.org/2001/XMLSchema#">
]>
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
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xpath-default-namespace="https://covidtesty.vse.cz/testy/">
  
  <!-- Parameters -->

  <xsl:param name="test" as="xsd:boolean"/> 

  <!-- Global variables -->

  <xsl:variable name="ns">https://covidtesty.vse.cz/data/</xsl:variable>
  <xsl:variable name="dataset" select="concat($ns, 'evaluations')"/>

  <!-- Functions -->

  <xsl:function name="f:clean-category" as="xsd:string">
    <xsl:param name="category" as="xsd:string"/>
    <xsl:sequence select="replace($category, '2$', '')"/>
  </xsl:function>

  <!-- Converts camelCase $text into kebab-case. -->
  <xsl:function name="f:kebab-case" as="xsd:string">
    <xsl:param name="text" as="xsd:string"/>
    <xsl:value-of select="f:slugify(replace($text, '(\p{Ll})(\p{Lu})', '$1-$2'))"/>
  </xsl:function>

  <!-- Mints a new URI in namespace $ns for instance of $class identified with $key. -->
  <xsl:function name="f:resource-iri" as="xsd:anyURI">
    <xsl:param name="iri-path" as="xsd:string"/>
    <xsl:param name="key" as="xsd:string+"/>
    <xsl:sequence select="concat($ns, $iri-path, '/', string-join(for $k in $key[string-length() != 0] return f:slugify(f:kebab-case($k)), '/')) cast as xsd:anyURI"/>
  </xsl:function>

  <!-- Converts $text into an IRI-safe slug. -->
  <xsl:function name="f:slugify" as="xsd:string">
    <xsl:param name="text" as="xsd:string"/>
    <xsl:sequence select="encode-for-uri(translate(replace(lower-case(normalize-unicode($text, 'NFKD')), '\P{IsBasicLatin}', ''), ' ', '-'))" />
  </xsl:function>

  <!-- Output -->

  <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC"/>
  <xsl:strip-space elements="*"/>

  <!-- Templates -->

  <xsl:template match="/testy">
    <xsl:if test="$test">
       <xsl:call-template name="tests"/>
    </xsl:if>

    <rdf:RDF>
      <xsl:apply-templates/>
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="ciselniky">
    <xsl:apply-templates select="*" mode="codelist"/>
  </xsl:template>

  <xsl:template match="*" mode="codelist">
    <xsl:variable name="codelist-iri" select="f:resource-iri('concept-scheme', (name()))"/>
    <skos:ConceptScheme rdf:about="{$codelist-iri}"/>
    <xsl:apply-templates mode="codelist-item">
      <xsl:with-param name="codelist" select="name()" tunnel="yes"/>
      <xsl:with-param name="codelist-iri" select="$codelist-iri" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*[@hodnota]" mode="codelist-item">
    <xsl:param name="codelist" required="yes" tunnel="yes"/>
    <skos:Concept rdf:about="{f:resource-iri('concept', ($codelist, name(), @hodnota))}">
      <skos:inScheme>
        <skos:ConceptScheme rdf:about="{f:resource-iri('concept-scheme', ($codelist, name()))}"/>
      </skos:inScheme>
      <xsl:apply-templates mode="codelist-item-property" select="*|@*"/>
    </skos:Concept>
  </xsl:template>

  <xsl:template match="varianta" mode="codelist-item">
    <xsl:param name="codelist" required="yes" tunnel="yes"/>
    <skos:Concept rdf:about="{f:resource-iri('concept', ($codelist, name(), text()))}">
      <skos:inScheme>
        <skos:ConceptScheme rdf:about="{f:resource-iri('concept-scheme', ($codelist, name()))}"/>
      </skos:inScheme>
      <skos:notation><xsl:value-of select="text()"/></skos:notation>
    </skos:Concept>
  </xsl:template>

  <xsl:template match="zdroj" mode="codelist-item">
    <xsl:param name="codelist" required="yes" tunnel="yes"/>
    <xsl:param name="codelist-iri" required="yes" tunnel="yes"/>
    <skos:Concept rdf:about="{f:resource-iri('concept', ($codelist, text()))}">
      <skos:inScheme rdf:resource="{$codelist-iri}"/>
      <skos:notation><xsl:value-of select="text()"/></skos:notation>
    </skos:Concept>
  </xsl:template>

  <xsl:template match="@hodnota" mode="codelist-item-property">
    <skos:notation><xsl:value-of select="."/></skos:notation>
  </xsl:template>

  <xsl:template match="nazev" mode="codelist-item-property">
    <skos:prefLabel xml:lang="{@jazyk}"><xsl:value-of select="text()"/></skos:prefLabel>
  </xsl:template>

  <xsl:template match="sloupecNazev" mode="codelist-item-property">
    <skos:altLabel xml:lang="{@jazyk}"><xsl:value-of select="text()"/></skos:altLabel>
  </xsl:template>

  <xsl:template match="vychoziText" mode="codelist-item-property">
    <skos:definition xml:lang="{@jazyk}"><xsl:value-of select="text()"/></skos:definition>
  </xsl:template>

  <xsl:template match="euListSpecimen" mode="codelist-item-property">
    <skos:altLabel xml:lang="en"><xsl:value-of select="text()"/></skos:altLabel>
  </xsl:template>

  <xsl:template match="kratkyNazev" mode="codelist-item-property">
    <skos:altLabel xml:lang="{@jazyk}"><xsl:value-of select="text()"/></skos:altLabel>
  </xsl:template>

  <xsl:template match="data">
    <xsl:apply-templates select="*|@*"/>
  </xsl:template>

  <xsl:template match="@aktualizace">
    <dcat:Dataset rdf:about="">
      <dcterms:modified rdf:datatype="&xsd;date"><xsl:value-of select="."/></dcterms:modified>
    </dcat:Dataset>
  </xsl:template>

  <xsl:template match="test">
    <!-- No ID is available for all tests, therefore we generate a synthetic ID. -->
    <xsl:variable name="covid-test" select="f:resource-iri('antigen-covid-test', (generate-id()))"/>
    <!-- Manufacturer IDs are available only for tests on EU lists, so we fall back on a synthetic ID. -->
    <xsl:variable name="manufacturer-id" select="(euList/manufacturer/@id, generate-id())[1]"/>
    <xsl:variable name="manufacturer" select="f:resource-iri('organization', ($manufacturer-id))"/>
    <act:AntigenCovidTest rdf:about="{$covid-test}">
      <xsl:apply-templates mode="covid-test">
        <xsl:with-param name="manufacturer" select="$manufacturer" tunnel="yes"/>
      </xsl:apply-templates>
    </act:AntigenCovidTest>
    <xsl:apply-templates>
      <xsl:with-param name="covid-test" select="$covid-test" tunnel="yes"/>
      <xsl:with-param name="manufacturer" select="$manufacturer" tunnel="yes"/>
      <xsl:with-param name="manufacturer-id" select="$manufacturer-id" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="nazev">
    <xsl:param name="covid-test" required="yes" tunnel="yes"/>
    <!-- Some registers, such as the one from ÚZIS, don't provide IDs. -->
    <xsl:variable name="id" select="if (@id) then f:slugify(@id) else generate-id()"/>
    <reg:RegisterItem rdf:about="{f:resource-iri('register-item', (@zdroj, $id))}">
      <rdfs:label><xsl:value-of select="text()"/></rdfs:label>
      <reg:representationOf rdf:resource="{$covid-test}"/>
      <xsl:apply-templates select="@*" mode="register-item"/>
    </reg:RegisterItem>
  </xsl:template>

  <xsl:template match="@id" mode="register-item">
    <reg:notation><xsl:value-of select="."/></reg:notation>
  </xsl:template>

  <xsl:template match="@kategorie|@zdroj" mode="register-item">
    <xsl:variable name="register-name" select="f:clean-category(.)"/>
    <reg:register>
      <reg:Register rdf:about="{f:resource-iri('register', ($register-name))}">
        <dcterms:identifier><xsl:value-of select="$register-name"/></dcterms:identifier>
      </reg:Register>
    </reg:register>

    <!-- Infer registration status based on known register names. -->
    <xsl:if test="name() = 'zdroj'">
      <xsl:choose>
        <xsl:when test=". = 'EUlistPositive'">
          <reg:status rdf:resource="&status;status-approved"/>
        </xsl:when>
        <xsl:when test=". = 'EUlistNegative2'">
          <reg:status rdf:resource="&status;status-not-approved"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="vyrobce" mode="covid-test">
    <xsl:param name="manufacturer" required="yes" tunnel="yes"/>
    <xsl:variable name="eu-list-name" select="../euList/manufacturer/name"/>
    <schema:manufacturer>
      <schema:Organization rdf:about="{$manufacturer}">
        <xsl:choose>
          <!-- Prefer manufacturer names from the COVID-19 In Vitro Diagnostic Devices and Test Methods Database. -->
          <xsl:when test="not($eu-list-name)">
            <schema:name><xsl:value-of select="text()"/></schema:name>
          </xsl:when>
          <xsl:when test="$eu-list-name and text() != $eu-list-name">
            <schema:alternateName><xsl:value-of select="text()"/></schema:alternateName>
          </xsl:when>
        </xsl:choose>
      </schema:Organization>
    </schema:manufacturer>
  </xsl:template>

  <xsl:template match="typTestu" mode="covid-test">
    <act:biospecimenCollectionMethod rdf:resource="{f:resource-iri('concept', ('typy-testu', name(), text()))}"/>
  </xsl:template>

  <xsl:template match="hodnoceni">
    <xsl:param name="covid-test" required="yes" tunnel="yes"/>
    <reg:RegisterItem rdf:about="{f:resource-iri('register-item', (f:clean-category(@kategorie), generate-id()))}">
      <reg:representationOf rdf:resource="{$covid-test}"/>
      <xsl:apply-templates select="@*|*" mode="register-item"/>
    </reg:RegisterItem>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="@ikona" mode="register-item">
    <xsl:choose>
      <xsl:when test=". = ('OK', 'star')">
        <reg:status rdf:resource="&status;status-approved"/>
      </xsl:when>
      <xsl:when test=". = ('cross')">
        <reg:status rdf:resource="&status;status-not-approved"/>
      </xsl:when>
      <xsl:when test=". = ('warn', 'half-star')">
        <reg:status rdf:resource="&status;status-warning"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text" mode="register-item">
    <dcterms:description xml:lang="{@jazyk}"><xsl:value-of select="."/></dcterms:description>
  </xsl:template>

  <xsl:template match="citlivostPei/hodnoceni">
    <xsl:param name="covid-test" required="yes" tunnel="yes"/>
    <ncit:C41394> <!-- C41394 = Diagnostic sensitivity -->
      <dcterms:subject rdf:resource="{$covid-test}"/>
      <dcterms:creator rdf:resource="https://www.pei.de"/>
      <rdf:value rdf:datatype="&xsd;decimal"><xsl:value-of select="text()"/></rdf:value>
      <act:peiSensitivityCategory rdf:resource="{f:resource-iri('concept', ('citlivost-pei', 'kategorie', @kategorie))}"/>
      <!-- TODO: This duplicates the degree for each sensitivity category. -->
      <act:peiSensitivityDegree rdf:resource="{f:resource-iri('concept', ('citlivost-pei', 'stupen', ../stupen))}"/>
    </ncit:C41394>
  </xsl:template>

  <xsl:template match="citlivostSsi/hodnoceni">
    <xsl:param name="covid-test" required="yes" tunnel="yes"/>
    <ncit:C41394>
      <dcterms:subject rdf:resource="{$covid-test}"/>
      <dcterms:creator rdf:resource="https://ssi.dk"/>
      <act:coronavirusVariant rdf:resource="{f:resource-iri('concept', ('citlivost-ssi', 'varianta', @varianta))}"/>
      <act:ssiSensitivityCategory rdf:resource="{f:resource-iri('concept', ('citlivost-ssi', 'kategorie', @kategorie))}"/>
      <!-- TODO: SSI sensitivity degree is not defined in the code lists. -->
      <act:ssiSensitivityDegree rdf:resource="{f:resource-iri('concept', ('stupen-citlivosti-ssi', @ikona))}"/>
    </ncit:C41394>
  </xsl:template>

  <xsl:template match="euList">
    <xsl:param name="covid-test" required="yes" tunnel="yes"/>
    <rdf:Description rdf:about="{$covid-test}">
      <schema:url rdf:resource="{concat('https://covid-19-diagnostics.jrc.ec.europa.eu/devices/detail/', @id)}"/>
    </rdf:Description>
    <reg:RegisterItem rdf:about="{f:resource-iri('register-item', (@zdroj, @id))}">
    </reg:RegisterItem>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="manufacturer">
    <xsl:param name="manufacturer" required="yes" tunnel="yes"/>
    <schema:Organization rdf:about="{$manufacturer}">
      <xsl:apply-templates mode="manufacturer"/>
    </schema:Organization>
  </xsl:template>

  <xsl:template match="country" mode="manufacturer">
    <xsl:param name="manufacturer-id" required="yes" tunnel="yes"/>
    <schema:address>
      <schema:PostalAddress rdf:about="{f:resource-iri('postal-address', ($manufacturer-id))}">
        <schema:addressCountry><xsl:value-of select="text()"/></schema:addressCountry>
      </schema:PostalAddress>
    </schema:address>
  </xsl:template>
  
  <xsl:template match="name" mode="manufacturer">
    <schema:name><xsl:value-of select="text()"/></schema:name>
  </xsl:template>

  <xsl:template match="website" mode="manufacturer">
    <schema:url><xsl:value-of select="text()"/></schema:url>
  </xsl:template>

  <!-- Support clinical sensitivity and clinical specificity only (for now). -->
  <xsl:template match="performance[@parameter = ('Clinical Sensitivity', 'Clinical Specificity')]">
    <xsl:param name="covid-test" required="yes" tunnel="yes"/>
    <xsl:param name="manufacturer" required="yes" tunnel="yes"/>
    <rdf:Description>
      <dcterms:subject rdf:resource="{$covid-test}"/>
      <dcterms:creator rdf:resource="{$manufacturer}"/>
      <xsl:apply-templates mode="performance" select="@*"/>
    </rdf:Description>
  </xsl:template>

  <xsl:template match="@parameter" mode="performance">
    <rdf:type>
      <xsl:attribute name="rdf:resource">
        <xsl:choose>
          <xsl:when test=". = 'Clinical Sensitivity'">&ncit;C41394</xsl:when>
          <xsl:when test=". = 'Clinical Specificity'">&ncit;C41395</xsl:when>
        </xsl:choose>
      </xsl:attribute>
    </rdf:type>
  </xsl:template>

  <xsl:template match="@info" mode="performance">
    <rdfs:comment><xsl:value-of select="."/></rdfs:comment>
  </xsl:template>

  <xsl:template match="@value" mode="performance">
    <rdf:value rdf:datatype="&xsd;decimal"><xsl:value-of select="."/></rdf:value>
  </xsl:template>
  
  <xsl:template match="@unit" mode="performance">
    <qudt:unit>
      <xsl:attribute name="rdf:resource">
        <xsl:choose>
          <xsl:when test=". = '%'">http://qudt.org/vocab/unit/PERCENT</xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">Unmapped unit <xsl:value-of select="."/>!</xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </qudt:unit>
  </xsl:template>

  <!-- Catch-all empty template -->

  <xsl:template match="text()|@*" mode="#all"/>

  <!-- Tests -->

  <xsl:template name="tests">
    <xsl:message>Running tests</xsl:message>

    <xsl:call-template name="test">
      <xsl:with-param name="actual" select="f:clean-category('Indie2')"/>
      <xsl:with-param name="expected">Indie</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="test">
      <xsl:with-param name="actual" select="f:kebab-case('ConceptScheme')"/>
      <xsl:with-param name="expected">concept-scheme</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="test">
      <xsl:with-param name="actual" select="f:resource-iri('concept', ('kategorie', 'ABC123'))"/>
      <xsl:with-param name="expected">https://covidtesty.vse.cz/data/concept/kategorie/abc123</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="test">
      <xsl:with-param name="actual" select="f:slugify('Příliš žluťoučký kůň')"/>
      <xsl:with-param name="expected">prilis-zlutoucky-kun</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="test">
    <xsl:param name="actual" required="yes"/>
    <xsl:param name="expected" required="yes"/>
    <xsl:assert test="$actual = $expected">
    Failed test!
    Expected: <xsl:value-of select="$expected"/>
    Actual: <xsl:value-of select="$actual"/>
    </xsl:assert>
  </xsl:template>
</xsl:stylesheet>
