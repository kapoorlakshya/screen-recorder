#!/usr/bin/env bash
if [[ "$REPORT_COVERAGE" == "true" ]] && [[ "$TRAVIS_BRANCH" == "master" ]]; then
  ./cc-test-reporter after-build --exit-code $TRAVIS_TEST_RESULT;
    echo "Reported test coverage for 'master' branch."
fi