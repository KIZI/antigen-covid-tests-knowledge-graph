declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  for $test in /testy/data/test[citlivostPei]
  let $test_id := ($test/euList/@id, $test/nazev)[1],
      $degree := $test/citlivostPei/stupen,
      $definition := /testy/ciselniky/citlivostPei/stupen[@hodnota = $degree]/nazev[@jazyk = "en"]
  return string-join(($test_id, $degree, $definition), ","),
  text{"&#10;"}
)
