#!/bin/sh
# Runs tests and collects code coverage to ./cov.info file


PWD=$(pwd -P)

COVERAGE_FILE="$(PWD)/cov.info"
COVERAGE_DIR="$(PWD)/lcov"

# Cleanup & preparation
rm -rf ./src-cov "$COVERAGE_DIR" "$COVERAGE_FILE"
mkdir ./src-cov "$COVERAGE_DIR"

# Creating directory with instrumented JS code
./node_modules/.bin/coffeeCoverage --exclude=node_modules,.git,test,scripts --path=relative . ./src-cov 1>&2
cp ./package.json ./src-cov
cp -r ./bin ./src-cov/bin
chmod +x ./src-cov/bin/*
cp -r ./scripts ./src-cov/scripts
cp -r ./docs ./src-cov/docs
cp -r ./test ./src-cov/test

# Testing
export COVERAGE_DIR
cd ./src-cov && npm test
cd ..

# Merging LCOV reports
./node_modules/.bin/lcov-result-merger "$COVERAGE_DIR/*.info" "$COVERAGE_FILE"

# Output & cleanup
rm -rf ./src-cov ./lcov
