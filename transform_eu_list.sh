#!/usr/bin/env bash

set -eo pipefail

die () {
  info "$@"
  exit 1
}

info () {
  echo >&2 "$@"
}

command_available () {
  COMMAND="${1}"
  command -v "${COMMAND}" >/dev/null 2>&1 ||
  die "Please install ${COMMAND}!"
}

command_available riot
command_available saxon
command_available xmllint

FILENAME=covid-19-diagnostics.jrc.ec.europa.eu
INPUT="${FILENAME}.xml"
RDFXML="${FILENAME}.rdf"

case "$(uname -sr)" in
  Darwin*) DAY_AGO=$(date -j -v-1d +%s)
  ;;

  Linux*) DAY_AGO=$(date --date="1 days ago" +%s)
  ;;
esac

# If-Modified-Since HTTP header is not supported, so we download the data
# if the local file doesn't exist or is older than a day.
if [[ ! -f "${INPUT}" || $DAY_AGO -ge $(date -r "${INPUT}" +%s) ]]
then
  info "Downloading an export."

  curl \
    --data-urlencode rapid_diag=1 \
    --data-urlencode search_method=AND \
    --data-urlencode target_type=6 \
    --get https://covid-19-diagnostics.jrc.ec.europa.eu/devices/export/xml |
  xmllint \
    --format `# Pretty-print XML for readability` \
    - > "${INPUT}"
else
  info "Using a previously downloaded export."
fi

info "Transforming source XML data to RDF/XML."
saxon \
  -s:"${INPUT}" \
  -xsl:resources/eu_list_transformation.xsl > "${RDFXML}"

info "Validating syntax of the produced RDF/XML."
riot \
  --validate \
  "${RDFXML}"
