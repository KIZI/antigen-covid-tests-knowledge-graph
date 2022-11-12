declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

string-join(
  /testy/data/test/euList[@zdroj = "EUlistPositive"]/@id,
  text{"&#10;"}
)
