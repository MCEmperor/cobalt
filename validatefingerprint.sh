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
    if [ $? -ne 0 ]; then
        echo "ERROR: Git is required but not found."
        exit 2
    fi

    if [ ! -z "$(git status --porcelain)" ]; then
        echo "ERROR: Git working tree is not clean! Make sure you commit or stash all untracked or modified files."
        exit 2
    fi
}

main
