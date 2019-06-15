#!/usr/bin/env bash
if [[ "$REPORT_COVERAGE" == "true" ]] && [[ "$TRAVIS_BRANCH" == "master" ]]; then
  echo "Reporting test coverage for 'master' branch."
  curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter;
  chmod +x ./cc-test-reporter;
  ./cc-test-reporter before-build;
fi