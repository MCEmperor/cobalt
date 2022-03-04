#!/bin/bash

paths=$(cat)
IFS=':' lines=($paths)
for item in "${lines[@]}"; do
    echo -n " $(basename $item)"
done
