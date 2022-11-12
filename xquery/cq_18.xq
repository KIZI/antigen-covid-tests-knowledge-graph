declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  for $test in /testy/data/test
  let $test_id := ($test/euList/@id, $test/nazev)[1]
  where $test/hodnoceni/@ikona = "cross"
  and $test/euList/performance[@parameter = "Clinical Sensitivity"]/@value >= 90
  return $test_id,
  text{"&#10;"}
)
