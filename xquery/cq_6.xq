declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  for $test in /testy/data/test/euList
  let $test_id := $test/@id,
      $url := replace(/testy/ciselniky/zdroje/zdroj[text() = $test/@zdroj]/@web, "\{\{ID\}\}", $test_id)
  return string-join(($test_id, $url), ","),
  text{"&#10;"}
)
