# Run Swift Test [![Build Status](https://app.bitrise.io/app/6db4b5a23df77ef3/status.svg?token=sh49ITq9wR-JvHYPuepTMA&branch=main)](https://app.bitrise.io/app/6db4b5a23df77ef3)

This step uses xcodebuild & xcpretty to run the macOS tests for the Swift Package Manager. The final files are output in a structure compatible with the "Test Report" plugin and can be configured to be JUnit or HTML as output, so the generated files are compatible with tools like Dagger.

The Code coverage is always exported as a JSON file.

## How to use this Step

```yml
- git::https://github.com/igorcferreira/bitrise-step-run-spm-test-with-coverage.git@main:
   title: Run Swift Package Manager Tests
   inputs:
   - TEST_NAME: BitriseTest
   - PROJECT_DIR: $BITRISE_SOURCE_DIR
   - SKIP_BUILD: 'NO'
   - REPORTER: junit
```

This step will run the package tests and expose the test result and code coverage on:

- TEST_RESULT: XML file with the result of the tests
- CODE_COVERAGE_RESULT: JSON file with the result of the code coverage report
