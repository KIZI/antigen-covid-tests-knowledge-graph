declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  for $test in /testy/data/test[euList/performance[@parameter = "Clinical Sensitivity"]],
      $performance in $test/euList/performance[@parameter = "Clinical Sensitivity"] 
  let $test_id := ($test/euList/@id, $test/nazev)[1],
      $manufacturers_sensitivity := $performance/@value
  order by $test_id
  return string-join(($test_id, $manufacturers_sensitivity, $performance/@info), ","),
  text{"&#10;"}
)
