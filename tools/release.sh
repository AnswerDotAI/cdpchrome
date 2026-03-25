#!/bin/bash
set -e
v=$(cat VERSION | tr -d '[:space:]')
git tag "v$v"
git push origin main --tags
echo "Released v$v"
