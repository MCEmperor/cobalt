#!/bin/bash

fingerprintSupplier=$1

function main {
    case "${fingerprintSupplier}" in

        "git-commit-hash")
            byGitCommitHash
            ;;
    esac
}

function byGitCommitHash {
    command -v git &>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Git is required but not found."
        exit 2
    fi

    local dirty=0
    local uncommittedFiles=$(tr '\0' '\n' < <(git status -z))
    IFS=$'\n'; for gitLine in ${uncommittedFiles}; do
        local f=${gitLine:3}
        if [[ $f == src/* ]]; then
            dirty=1
            break
        fi
    done

    if [[ $dirty -eq 1 ]]; then
        echo "ERROR: Applying Git commit hash failed - the src directory contains uncommitted files."
        exit 2
    fi
}

main
