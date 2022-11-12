declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  let $sorted_tests := for $test in /testy/data/test[citlivostPei]
                       let $test_id := ($test/euList/@id, $test/nazev)[1],
                           $total_sensitivity := $test/citlivostPei/prumer
                       order by $total_sensitivity descending
                       return $test_id
  return $sorted_tests[1],
  text{"&#10;"}
)
