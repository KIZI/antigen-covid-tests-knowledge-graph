PREFIX act:    <https://covidtesty.vse.cz/vocabulary#>
PREFIX ncit:   <http://purl.obolibrary.org/obo/NCIT_>
PREFIX rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
PREFIX schema: <http://schema.org/>
PREFIX skos:   <http://www.w3.org/2004/02/skos/core#>

###################################
# Delete duplicate skos:altLabels #
###################################

DELETE {
  ?concept skos:altLabel ?label .
}
WHERE {
  ?concept skos:prefLabel ?label ;
    skos:altLabel ?label .
}

;

##########################################
# Extract biospecimen collection methods #
##########################################

DELETE {
  ?parameter rdfs:comment ?comment .
}
INSERT {
  ?parameter act:biospecimenCollectionMethod ?biospecimenCollectionMethod .
}
WHERE {
  VALUES ?parameter {
    ncit:C41394
    ncit:C41395
  }

  ?parameter rdfs:comment ?comment .

  ?biospecimenCollectionMethod skos:inScheme <https://covidtesty.vse.cz/data/concept-scheme/typy-testu> ;
    skos:prefLabel|skos:altLabel ?biospecimenCollectionMethodLabel .

  FILTER (lang(?biospecimenCollectionMethodLabel) = "en"
          &&
          contains(lcase(replace(replace(?comment, "NP", "nasopharyngeal"), "OP", "oropharyngeal")),
                   lcase(?biospecimenCollectionMethodLabel)))
}

;

###############################################
# Remap properties of PEI sensitivity degrees #
###############################################

DELETE {
  ?concept ?source ?o .
}
INSERT {
  ?concept ?target ?o .
}
WHERE {
  VALUES (?source        ?target) {
         (skos:prefLabel skos:definition)
         (skos:altLabel  skos:prefLabel)
  }
  ?concept skos:inScheme <https://covidtesty.vse.cz/data/concept-scheme/citlivost-pei/stupen> ;
    ?source ?o .
}

;

##################
# Normalize Ltd. #
##################

DELETE {
  ?manufacturer schema:name ?name2 .
}
WHERE {
  [] schema:manufacturer ?manufacturer .

  ?manufacturer schema:name ?name1, ?name2 .

  FILTER (!sameTerm(?name1, ?name2)
          &&
          ?name1 = concat(?name2, "."))
}

;

######################################
# Merge manufacturers via schema:url #
######################################

DELETE {
  ?inS ?inP ?manufacturer .
  ?manufacturer ?outP ?outO .
}
INSERT {
  ?inS ?inP ?chosen_manufacturer .
  ?chosen_manufacturer ?outP ?outO .
}
WHERE {
  {
    SELECT ?url (SAMPLE(?manufacturer) AS ?chosen_manufacturer)
    WHERE {
      ?manufacturer schema:url ?url .
    }
    GROUP BY ?url
    HAVING (COUNT(DISTINCT ?manufacturer) > 1)
  }

  ?manufacturer schema:url ?url .

  FILTER (!sameTerm(?manufacturer, ?chosen_manufacturer))

  {
    ?inS ?inP ?manufacturer .
  } UNION {
    ?manufacturer ?outP ?outO .
  }
}

;

##########################
# Merge postal addresses #
##########################

DELETE {
  ?inS ?inP ?postal_address .
  ?postal_address ?outP ?outO .
}
INSERT {
  ?inS ?inP ?chosen_postal_address .
  ?chosen_postal_address ?outP ?outO .
}
WHERE {
  {
    SELECT ?manufacturer ?country (SAMPLE(?postal_address) AS ?chosen_postal_address)
    WHERE {
      ?postal_address a schema:PostalAddress ;
        schema:addressCountry ?country .

      ?manufacturer schema:address ?postal_address .
    }
    GROUP BY ?manufacturer ?country
    HAVING (COUNT(?postal_address) > 1)
  }

  ?manufacturer schema:address ?postal_address .
  ?postal_address schema:addressCountry ?country .

  FILTER (!sameTerm(?postal_address, ?chosen_postal_address))

  {
    ?inS ?inP ?postal_address .
  } UNION {
    ?postal_address ?outP ?outO .
  }
}

;

###############################
# Normalize manufacturer's name
###############################

DELETE {
  ?s schema:name ?oldName .
}
INSERT {
  ?s schema:name ?newName .
}
WHERE {
  ?s a schema:Organization .
  ?s schema:name ?oldName .
  BIND(REPLACE(?oldName, "co\\.,?\\s*ltd\\.*$", "Co\\. Ltd\\.", "i") AS ?newName)
}
;

##### Normalized name to start with the first letter in uppercase and the rest in lowercase #####
DELETE{
  ?oldManuf schema:name ?oldName .
}
INSERT {
  ?oldManuf schema:name ?newName .
}
WHERE {
    SELECT (?name1 AS ?newName) (?name2 as ?oldName) (?manufacturer2 AS ?oldManuf)
    WHERE {
      ?manufacturer1 a schema:Organization ;
        schema:name ?name1 .

      ?manufacturer2 a schema:Organization ;
        schema:name ?name2 .

      FILTER (!sameTerm(?manufacturer1, ?manufacturer2)
              &&
              lcase(?name1) = lcase(?name2)
              &&
              regex(?name1, "^\\p{Lu}\\p{Ll}+.*$"))
    }
}
;

######################################
# Merge manufacturers via schema:name #
######################################

DELETE {
  ?inS ?inP ?manufacturer .
  ?manufacturer ?outP ?outO .
}
INSERT {
  ?inS ?inP ?chosen_manufacturer .
  ?chosen_manufacturer ?outP ?outO .
}
WHERE {
  {
    SELECT ?name (SAMPLE(?manufacturer) AS ?chosen_manufacturer)
    WHERE {
      ?manufacturer schema:name ?name .
    }
    GROUP BY ?name
    HAVING (COUNT(DISTINCT ?manufacturer) > 1)
  }

  ?manufacturer schema:name ?name .

  FILTER (!sameTerm(?manufacturer, ?chosen_manufacturer))

  {
    ?inS ?inP ?manufacturer .
  } UNION {
    ?manufacturer ?outP ?outO .
  }
}
;
