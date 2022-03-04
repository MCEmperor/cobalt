#!/bin/bash

COBALT_BIN_DIR=$(dirname $(test -L "$0" && readlink "$0" || echo "$0"))
PROJECT_ROOT_DIR=$1
if [ "${PROJECT_ROOT_DIR}" == "" ]; then
    PROJECT_ROOT_DIR=$(pwd)
fi
PROJECT_CACHE_DIR=$(${COBALT_BIN_DIR}/getcachedir.sh ${PROJECT_ROOT_DIR})

echo "Writing project cache: ${PROJECT_CACHE_DIR}"
# Make the cache directory, if it not exists
mkdir -p "${PROJECT_CACHE_DIR}"

python3 "${COBALT_BIN_DIR}/genmakefile.py" "${COBALT_BIN_DIR}" "${PROJECT_CACHE_DIR}" "${PROJECT_ROOT_DIR}"
