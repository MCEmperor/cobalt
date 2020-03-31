#!/bin/bash

fingerprintSupplier=$1

function main {
    case "${fingerprintSupplier}" in

        "git-commit-hash")
            byGitCommitHash
            ;;
        *)
            byNone
            ;;
    esac
}

function byNone {
    echo ""
}

function byGitCommitHash {
    if [ ! -z "$(git status --porcelain)" ]; then
        echo "Git working tree is not clean! Make sure you commit or stash all untracked or modified files."
        exit 2
    fi

    echo $(git rev-parse --verify HEAD)
}

main
