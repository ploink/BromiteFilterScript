#!/bin/sh
cd "$(dirname "${BASH_SOURCE[0]}")"

# Download the ruleset converter if we dont have it already
BIN="ruleset_converter"
if [[ ! -x ${BIN} ]]; then
    URL="$(curl -sLI -o /dev/null -w '%{url_effective}' 'https://github.com/bromite/filters/releases/latest/')"
    URL="$(echo "${URL}" | sed 's|/tag/|/download/|' )/${BIN}"
    echo "Downloading ${URL}"
    curl -L "${URL}" -o ${BIN}
    if file ${BIN}|grep -q "ELF 64-bit LSB"; then
	echo "file ok"
	chmod +x ${BIN}
    else
	rm ${BIN}
	echo "Download failed" 1>&2
	exit 1
    fi;														    
fi;

NOW=$(date "+%s")
DOWNLOADED=false
FILES=""

shopt -s lastpipe
sed 's/#.*//' filters.conf | grep -E '\S+*\s+https?://\S+\s*$' | readarray -t CONFIG

for LINE in "${CONFIG[@]}"; do
    ARGS=(${LINE})
    FILE="${ARGS[0]}.txt"
    URL="${ARGS[1]}"
    if [[ -f "${FILE}" ]]; then
	FTIME=$(stat -L --format %Y "$FILE")
	if [[ $(( ($NOW - $FTIME) > 8*3600 )) == 1 ]]; then
    	    echo Updating ${FILE} 
	    curl -Lsf -o "${FILE}" -z "${FILE}" "${URL}" && DOWNLOADED=true
	fi
    else
        echo Downloading "${FILE}"
	curl -Lsf -o "${FILE}" "${URL}" && DOWNLOADED=true
    fi
    [[ -f "${FILE}" ]] && FILES="${FILES},${FILE}"
done

FILES="${FILES:1}"

if [[ "$DOWNLOADED" == "true" || ! -f filters.dat ]]; then 
    echo Creating filters.dat 
    ./ruleset_converter --input_format=filter-list --output_format=unindexed-ruleset \
	--input_files=${FILES} --output_file=filters.dat &> /dev/null
    exit 0
fi

exit 2
