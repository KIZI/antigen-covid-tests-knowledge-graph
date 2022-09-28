PREFIX act:  <https://covidtesty.vse.cz/vocabulary#>
PREFIX ncit: <http://purl.obolibrary.org/obo/NCIT_>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

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
