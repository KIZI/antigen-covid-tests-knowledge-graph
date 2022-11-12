declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  for $manufacturer in /testy/data/test/vyrobce
  let $test_count := count(/testy/data/test[vyrobce = $manufacturer]),
      $degree_over_3_test_count := count(/testy/data/test[vyrobce = $manufacturer and citlivostPei/stupen > 3])
  return string-join(($manufacturer, $degree_over_3_test_count div $test_count * 100), ","),
  text{"&#10;"}
)
