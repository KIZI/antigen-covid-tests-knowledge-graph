# Antigen covid tests knowledge graph

A knowledge graph build from the [data on antigen covid tests](https://covidtesty.vse.cz/english/) collected by the Prague University of Economics and Business.

## How to use this

The `transform.sh` script transforms the source XML data into data in the RDF/Turtle syntax:

```sh
./transform.sh path/to/data.xml > path/to/data.ttl
```

While the resulting RDF data is written to the standard output stream, logs and validation messages are written to the standard error stream.

Set the environment variable `TEST=true` to run unit tests for XSLT.

```sh
TEST=true ./transform.sh path/to/data.xml > path/to/data.ttl
```

## Dependencies

- [Apache Jena command-line tools](https://jena.apache.org/documentation/tools/) (e.g., `brew install jena` on OSX)
- [Saxon](https://saxon.sourceforge.io) (e.g., `brew install saxon` on OSX)
