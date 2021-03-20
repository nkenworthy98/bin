#!/usr/bin/env bash
set -euo pipefail

for file in ./*.xls; do
    in2csv "$file" > "${file%.*}.csv"
done
