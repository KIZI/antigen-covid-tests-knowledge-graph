declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  let $lvl := /testy/ciselniky/citlivostPei/kategorie[sloupecNazev[@jazyk = "en"] = "low viral load"]/@hodnota,
      $sorted_tests := for $test in /testy/data/test[citlivostPei/hodnoceni[@kategorie = $lvl]]
                       let $test_id := ($test/euList/@id, $test/nazev)[1],
                           $pei_sensitivity := $test/citlivostPei/hodnoceni[@kategorie = $lvl]
                       order by $pei_sensitivity descending
                       return string-join(($test_id, $pei_sensitivity), ",")
  return subsequence($sorted_tests, 1, 10),
  text{"&#10;"}
)
