declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  for $test in /testy/data/test
  let $manufacturer := $test/vyrobce,
      $country := $test/euList/manufacturer/country
  order by $manufacturer
  return string-join(($manufacturer, $country), ","),
  text{"&#10;"}
)
