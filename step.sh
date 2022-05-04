#!/usr/bin/env bash
# fail if any commands fails
set -e

# Helper functions
function print_configuration() {
    echo "Configuration:"
    echo "PROJECT_DIR: ${PROJECT_DIR}"
    echo "TEST_NAME: ${TEST_NAME}"
    echo "OUTPUT_DIR: ${OUTPUT_DIR}"
    echo "TEST_RESULT: ${TEST_RESULT}"
    echo "CODE_COVERAGE_RESULT: ${CODE_COVERAGE_RESULT}"
}

# Prepare environment
# Creating the sub-directory for the test run within the BITRISE_TEST_RESULT_DIR:
OUTPUT_DIR="${BITRISE_TEST_RESULT_DIR}/SwiftTest"
TEST_RESULT="${OUTPUT_DIR}/${TEST_NAME}.xml"
CODE_COVERAGE_RESULT="${OUTPUT_DIR}/${TEST_NAME}_codecoverage.json"

if [ ! -d "${OUTPUT_DIR}" ]; then
    mkdir "${OUTPUT_DIR}"
fi

print_configuration

# Reseting the package
swift package reset

# Run test
swift test --enable-code-coverage --parallel --xunit-output "${TEST_RESULT}"

# Copy code coverage
cp "$(swift test --show-codecov-path)" "${CODE_COVERAGE_RESULT}"

# Creating the test-info.json file with the name of the test run defined:
echo "{\"test-name\":\"${TEST_NAME}\"}" >> "${OUTPUT_DIR}/test-info.json"

# Exporting result to artefacts
cp "${TEST_RESULT}" "${BITRISE_DEPLOY_DIR}/${TEST_NAME}.xml"
cp "${CODE_COVERAGE_RESULT}" "${BITRISE_DEPLOY_DIR}/${TEST_NAME}_codecoverage.json"

envman add --key "TEST_RESULT" --value "${BITRISE_DEPLOY_DIR}/${TEST_NAME}.xml"
envman add --key "CODE_COVERAGE_RESULT" --value "${BITRISE_DEPLOY_DIR}/${TEST_NAME}_codecoverage.json"