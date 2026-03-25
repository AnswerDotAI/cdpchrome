#!/bin/bash
set -e
cur=$(cat VERSION | tr -d '[:space:]')
new=$(echo "$cur" | awk -F. '{print $1"."$2"."$3+1}')
echo "$new" > VERSION
echo "$cur -> $new"
