declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  let $hvl := /testy/ciselniky/citlivostPei/kategorie[sloupecNazev[@jazyk = "en"] = "high viral load"]/@hodnota
  for $test in /testy/data/test[citlivostPei/hodnoceni[@kategorie = $hvl] and euList/performance[@parameter = "Clinical Sensitivity"]],
      $performance in $test/euList/performance[@parameter = "Clinical Sensitivity"]
  let $test_id := ($test/euList/@id, $test/nazev)[1],
      $pei_sensitivity := $test/citlivostPei/hodnoceni[@kategorie = $hvl],
      $manufacturers_sensitivity := $performance/@value
  order by $test_id
  return string-join(($test_id, $pei_sensitivity - $manufacturers_sensitivity, $performance/@info), ","),
  text{"&#10;"}
)
