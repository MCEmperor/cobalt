#!/bin/bash

fingerprintSupplier=$1

function main {
    case "${fingerprintSupplier}" in

        "git-commit-hash")
            echo $(git rev-parse --verify HEAD)
            ;;
    esac
}

main
