#!/usr/bin/env bash
# Convert all the *.xls files in the
# current directory to csv files.
# For xlsx files, change
# *.xls below to *.xlsx
set -euo pipefail

for file in ./*.xls; do
    in2csv "$file" > "${file%.*}.csv"
done
