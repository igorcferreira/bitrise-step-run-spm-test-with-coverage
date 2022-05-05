#!/usr/bin/env bash
# fail if any commands fails
set -e

# Helper functions
function print_configuration() {
    echo "Configuration:"
    echo "PACKAGE_NAME: ${PACKAGE_NAME}"
    echo "PROJECT_DIR: ${PROJECT_DIR}"
    echo "TEST_NAME: ${TEST_NAME}"
    echo "BUILD_PATH: ${BUILD_PATH}"
    echo "SKIP_BUILD: ${SKIP_BUILD}"
    echo "OUTPUT_DIR: ${OUTPUT_DIR}"
    echo "REPORTER: ${REPORTER}"
    echo "SDK: ${SDK}"
    echo "DESTINATION: ${DESTINATION}"
    echo "TEST_RESULT: ${TEST_RESULT}"
    echo "CODE_COVERAGE_RESULT: ${CODE_COVERAGE_RESULT}"
}

# Prepare environment
# Creating the sub-directory for the test run within the BITRISE_TEST_RESULT_DIR:
OUTPUT_DIR="${BITRISE_TEST_RESULT_DIR}/SwiftTest"
CODE_COVERAGE_FILE_NAME="${TEST_NAME}_codecoverage.json"
CODE_COVERAGE_RESULT="${OUTPUT_DIR}/${CODE_COVERAGE_FILE_NAME}"
TEST_ARCHIVE_NAME="${TEST_NAME}_codecoverage.xcresult"
TEST_ARCHIVE="${OUTPUT_DIR}/${TEST_ARCHIVE_NAME}"

if [ ! -d "${OUTPUT_DIR}" ]; then
    mkdir "${OUTPUT_DIR}"
fi

if [ "${REPORTER}" = "junit" ]; then
    TEST_FILE_NAME="${TEST_NAME}.xml"
else
    TEST_FILE_NAME="${TEST_NAME}.html"
fi

TEST_RESULT="${OUTPUT_DIR}/${TEST_FILE_NAME}"

PACKAGE_NAME="$(cd "${PROJECT_DIR}" ; swift package describe --type text | \
grep 'Name: ' | \
head -1 | \
sed -e 's/Name:[[:space:]]*//g')"

print_configuration

echo "Preparing environment"
if [ -d "${TEST_ARCHIVE}" ]; then
    rm -rf "${TEST_ARCHIVE}"
fi
if [ -f "${TEST_RESULT}" ]; then
    rm "${TEST_RESULT}"
fi
if [ -f "${CODE_COVERAGE_RESULT}" ]; then
    rm "${CODE_COVERAGE_RESULT}"
fi

RUN_ACTION=""
if [ "${SKIP_BUILD}" = "YES" ]; then
    RUN_ACTION="test-without-building"
else
    RUN_ACTION="test"
fi

echo "Running tests"
BUILD_COMMAND="xcodebuild ${RUN_ACTION} \
-scheme '${PACKAGE_NAME}' \
-configuration 'Debug' \
-enableCodeCoverage YES \
-sdk '${SDK}' \
-resultBundlePath '${TEST_ARCHIVE}' \
-derivedDataPath '${BUILD_PATH}' \
-destination '${DESTINATION}' | \
xcpretty --color --report '${REPORTER}' --output '${TEST_RESULT}'"
(cd "${PROJECT_DIR}" ; sh -c "${BUILD_COMMAND}")

# Copy code coverage
(cd "${PROJECT_DIR}" ; xcrun xccov view --report --json "${TEST_ARCHIVE}" > "${CODE_COVERAGE_RESULT}")

# Creating the test-info.json file with the name of the test run defined:
echo "{\"test-name\":\"${TEST_NAME}\"}" >> "${OUTPUT_DIR}/test-info.json"

# Exporting result to artefacts
cp -r "${TEST_ARCHIVE}" "${BITRISE_DEPLOY_DIR}/${TEST_ARCHIVE_NAME}"
cp "${TEST_RESULT}" "${BITRISE_DEPLOY_DIR}/${TEST_FILE_NAME}"
cp "${CODE_COVERAGE_RESULT}" "${BITRISE_DEPLOY_DIR}/${CODE_COVERAGE_FILE_NAME}"

envman add --key "TEST_RESULT" --value "${BITRISE_DEPLOY_DIR}/${TEST_FILE_NAME}"
envman add --key "CODE_COVERAGE_RESULT" --value "${BITRISE_DEPLOY_DIR}/${CODE_COVERAGE_FILE_NAME}"