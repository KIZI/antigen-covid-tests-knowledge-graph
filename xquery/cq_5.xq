declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  for $test in /testy/data/test[typTestu = "ze slin"]
  return ($test/euList/@id, $test/nazev)[1],
  text{"&#10;"}
)
