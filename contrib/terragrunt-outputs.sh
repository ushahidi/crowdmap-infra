#!/bin/bash

# requires jq installed and findable in PATH

# environment variables (all are optional)
# TERRAOUT_CACHE_TTL : how long to keep a cache file alive
# TERRAOUT_CACHE_OVERRIDE : ignore present cache file and overwrite with new results
# TERRAOUT_CACHE_DISABLE : do not use the cache in this run
# TERRAOUT_CACHE_FILE : file location to use for cache
#   (note that if you use this variable, it's up to you to ensure that different
#    cache files are provided for different environments)

set -e

if [ -z "$1" ]; then
  echo "ERROR: it is required to provide the path to a folder with terragrunt "
  echo "       environment definitions, i.e. tg/live/harbinger"
  exit 1;
fi

if [ -z "$(which jq)" ]; then
  echo "ERROR: this script requires jq to be installed"
  exit 1;
fi

# Determine location of cache file
TERRAOUT_CACHE_FILE=${TERRAOUT_CACHE_FILE:-`dirname $0`/../tmp/terragrunt_outputs_cache.`echo $1 | tr /. _`}
TERRAOUT_CACHE_TTL=${TERRAOUT_CACHE_TTL:-3600}

gen_single_output() {
  set +e
  local component=$1
  local tmpfile=$(mktemp)
  local ret=0
  local n=0
  until [ $n -ge 5 ]; do
    ( cd "$component" && terragrunt output -json > $tmpfile; )
    ret=$?
    if [ $ret -eq 0 ]; then
      # transforms terraform output from
      # {
      #   "output1": {
      #     "type": ...,
      #     "value": <value1>
      #   },
      #   "output2": {
      #     "type": ...,
      #     "value": <value2>
      #   }
      # }
      # to:
      # {
      #   <component_name>: {
      #     "output1": <value1>,
      #     "output2": <value2>
      #   }
      # }
      cat $tmpfile | jq -M  "with_entries(.value |= .value) | { \"`basename $component | tr - _`\": . }";
      break
    fi
    n=$[$n+1]
    sleep 5
  done
  rm -f $tmpfile
  return $ret
}

# given a base folder to work from extract list of terragrunt outputs
gen_outputs() {
  find $1 -mindepth 1 -maxdepth 1 -type d -a -print0 | \
  while read -d '' -r component; do
    if [ -f "$component/terraform.tfvars" ]; then
      gen_single_output $component || exit 1
    fi
  done
}


if [[ -z "$TERRAOUT_CACHE_DISABLE" && -z "$TERRAOUT_CACHE_OVERRIDE" && -f "$TERRAOUT_CACHE_FILE" && "$((`date +%s` - `date -r $TERRAOUT_CACHE_FILE +%s`))" -le $TERRAOUT_CACHE_TTL ]]; then
  >&2 echo "* Using cache file at $TERRAOUT_CACHE_FILE"
  cat $TERRAOUT_CACHE_FILE
elif [ -z "$TERRAOUT_CACHE_DISABLE" ]; then
  { gen_outputs $1 | jq -M -S -s add ; } > $TERRAOUT_CACHE_FILE.tmp
  if [ $? -eq 0 ]; then
    mv $TERRAOUT_CACHE_FILE.tmp $TERRAOUT_CACHE_FILE
    cat $TERRAOUT_CACHE_FILE
  else
    exit 1
  fi
else
  gen_outputs $1 | jq -M -S -s add ;
fi
