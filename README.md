# Run Swift Test [![Build Status](https://app.bitrise.io/app/6db4b5a23df77ef3/status.svg?token=sh49ITq9wR-JvHYPuepTMA&branch=main)](https://app.bitrise.io/app/6db4b5a23df77ef3)

Step that runs "swift test" in the local directory and export the results into Bitrise Test Plugin

## How to use this Step

```yml
- git::https://github.com/igorcferreira/bitrise-step-run-spm-test-with-coverage.git@main:
   title: Run Swift Package Manager Tests
   inputs:
   - TEST_NAME: BitriseTest
   - PROJECT_DIR: $BITRISE_SOURCE_DIR
```

This step will run the package tests and expose the test result and code coverage on:

- TEST_RESULT: XML file with the result of the tests
- CODE_COVERAGE_RESULT: JSON file with the result of the code coverage report
