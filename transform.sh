#!/usr/bin/env bash
#
# Transforms XML data about antigen covid tests into RDF
#
# Usage:
#   ./tranform.sh path/to/data.xml > path/resulting/data.ttl
#
# Dependencies:
# - Saxon XSLT processor (e.g., brew install saxon)
# - Apache Jena (e.g., brew install jena)

set -eo pipefail
shopt -s failglob

info () {
  echo >&2 "$@"
}

die () {
  info "$@"
  exit 1
}

command_available () {
  COMMAND="${1}"
  command -v "${COMMAND}" >/dev/null 2>&1 ||
  die "Please install ${COMMAND}!"
}

DATA="${1}"

[ -z "${DATA}" ] && die "Please provide a path to the source data as an argument!"
[ -e "${DATA}" ] || die "${DATA} does not exist!"
[ -f "${DATA}" ] || die "${DATA} is not a file!"

command_available riot
command_available saxon
command_available shacl
command_available update

RDFXML=$(mktemp).rdf
RESULT=$(mktemp).ttl

info "Transforming source XML data to RDF/XML"
saxon \
  -s:"${DATA}" \
  -xsl:resources/transformation.xsl > "${RDFXML}"

info "Validating syntax of the produced RDF/XML"
riot \
  --validate \
  "${RDFXML}"

info "Post-processing"
update \
  --data "${RDFXML}" \
  --dump \
  --update resources/postprocess.ru |
tee "${RESULT}"

# Merge the produced data with its vocabulary for SHACL validation
VALIDATION_FILE=$(mktemp).nt
riot \
  --quiet \
  "${RESULT}" \
  resources/vocabulary.ttl > "${VALIDATION_FILE}"

info "Validating the produced data via SHACL"
shacl validate \
  --data "${VALIDATION_FILE}" \
  --shapes resources/model.ttl 1>&2
