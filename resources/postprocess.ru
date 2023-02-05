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
