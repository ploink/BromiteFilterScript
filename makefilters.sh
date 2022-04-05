#!/bin/sh
cd "$(dirname "${BASH_SOURCE[0]}")"

BIN="ruleset_converter"

shopt -s lastpipe

download_ruleset_converter() {
  [[ $(find "ruleset_converter" -mtime -1 2> /dev/null) ]] && return
  URL="https://github.com/bromite/bromite/releases/latest/download/ruleset_converter"
  curl -Lsf -o "${BIN}" -z "${BIN}" "${URL}" || return
  if file ${BIN}|grep -q "ELF 64-bit LSB"; then
    echo "Downloaded ${BIN}"
    chmod +x ${BIN}
    else
    rm ${BIN}
    echo "Download ${BIN} failed" 1>&2
    exit 1
  fi
}

download_filter_list() {
  [[ $(find "$1" -mmin -60 2> /dev/null) ]] && return 0
  local STATUS=$(curl -Lsf -w "%{http_code}\n" -o "$1" -z "$1" "$2") || return 1

  if [[ "$STATUS" == "304" ]]; then
    echo "${FILE}: Not Modified"
  else
    echo "${FILE}: Downloaded ok"
    DOWNLOADED="true" 
  fi
  return 0
}


if [[ ! -f "filters.conf" ]]; then
  echo "Creating filters.conf" 
  cp "filters.conf.dist" "filters.conf" 
  exit
fi


download_ruleset_converter

sed 's/#.*//' filters.conf | grep -E '\S+*\s+https?://\S+\s*$' | readarray -t CONFIG

for LINE in "${CONFIG[@]}"; do
    ARGS=(${LINE})
    FILE="${ARGS[0]}.txt"
    URL="${ARGS[1]}"
    download_filter_list "${FILE}" "${URL}" && FILES="${FILES},${FILE}"
done

FILES="${FILES:1}"

if [[ "$DOWNLOADED" == "true" || ! -f filters.dat ]]; then 
    echo Creating filters.dat 
    ./ruleset_converter --input_format=filter-list --output_format=unindexed-ruleset \
	--input_files=${FILES} --output_file=filters.dat 
    exit 0
fi

exit 2
