declare default element namespace "https://covidtesty.vse.cz/testy/";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";

count(/testy/data/test[nazev[@zdroj = "SUKL"] and citlivostPei/stupen = 5])
