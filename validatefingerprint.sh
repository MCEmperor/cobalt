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
    if [ ! -z "$(git status --porcelain)" ]; then
        echo "ERROR: Git working tree is not clean! Make sure you commit or stash all untracked or modified files."
        exit 2
    fi
}

main
