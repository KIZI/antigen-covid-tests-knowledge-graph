#!/usr/bin/env bash
#
# Transforms XML data about antigen covid tests into RDF
#
# Usage:
#   ./tranform.sh path/to/data.xml > path/resulting/data.ttl
# 
# Set the environment variable TEST=true to run unit tests for XSLT.
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

if [ ! -z "${TEST}" ]
then
  TEST="test=true"
else
  TEST="test=false"
fi

command_available riot
command_available saxon
command_available shacl
command_available update
command_available arq

RDFXML=$(mktemp).rdf
RESULT=$(mktemp).ttl

info "Transforming source XML data to RDF/XML"
saxon \
  -ea \
  -s:"${DATA}" \
  -xsl:resources/transformation.xsl \
  "${TEST}" > "${RDFXML}"

info "Validating syntax of the produced RDF/XML"
riot \
  --validate \
  "${RDFXML}"

info "Post-processing"
update \
  --data "${RDFXML}" \
  --dump \
  --update resources/postprocess.ru > "${RESULT}"

# Get owl:imports
VOCABULARY=resources/vocabulary.ttl
IMPORTS=resources/imports.ttl # Local cache for owl:imports
# If the local cache for imports doesn't exist or the vocabulary was modified since it was modified.
if [[ ! -e "${IMPORTS}" ]] || [[ $(date -r "${VOCABULARY}" +%s) -gt $(date -r "${IMPORTS}" +%s) ]]
then
  info "Downloading owl:imports"

  GRAPHS=$(arq \
             --data "${VOCABULARY}" \
             --query resources/imports.rq \
             --results CSV |
           tail -n+2 |
           tr -d '\r')

  printf -- "--graph %s\n" ${GRAPHS} |
  xargs arq \
    --query resources/subset_imported.rq \
    --quiet > "${IMPORTS}"
fi

# Merge the produced data with its vocabulary for SHACL validation
VALIDATION_FILE=$(mktemp).nt
riot \
  --quiet \
  "${RESULT}" \
  "${VOCABULARY}" \
  "${IMPORTS}" |
tee "${VALIDATION_FILE}"

info "Validating the produced data via SHACL"
time shacl validate \
  --data "${VALIDATION_FILE}" \
  --shapes resources/model.ttl 1>&2
