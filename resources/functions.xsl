<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="f xsd"
                version="3.0"
                xmlns:f="https://covidtesty.vse.cz/xslt/functions#"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

</xsl:stylesheet>
