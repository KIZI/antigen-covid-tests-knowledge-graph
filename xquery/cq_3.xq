declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  for $test in /testy/data/test
  let $test_id := ($test/euList/@id, $test/nazev)[1],
      $manufacturer := $test/vyrobce
  order by $manufacturer
  return string-join(($manufacturer, $test_id), ","),
  text{"&#10;"}
)
