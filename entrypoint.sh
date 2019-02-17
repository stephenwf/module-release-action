#!/bin/bash

set -e

if [[ -z "$GITHUB_EVENT_NAME" ]]; then
  echo "Set the GITHUB_EVENT_NAME env variable."
  exit 1
fi

if [[ -z "$NPM_AUTH" ]]; then
  echo "Set the NPM_AUTH env variable."
  exit 1
fi

GH_ACTION=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
GH_PR_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

if [[ "$IS_DEBUG_MODE_ENABLED" != false ]]; then
    echo "Github action is: $GH_ACTION";
fi;

if [[ ${GH_ACTION} != "synchronize" ]]; then
    echo "Not required unless there is new code.";
    exit 0;
fi;

# First we need to run yarn, to get the workspaces installed.
# Maybe this can be behind configuration later.
yarn install

IS_DEBUG_MODE_ENABLED=${MODULE_RELEASE_DEBUG:-false}  # If variable not set or null, use default.


if [[ "$IS_DEBUG_MODE_ENABLED" != false ]]; then
    debugEventPath=$(jq "." "$GITHUB_EVENT_PATH")

    echo " DEBUG: Pull request number $GH_PR_NUMBER";
    echo " DEBUG: Github event path $debugEventPath"
fi;

echo "//registry.npmjs.org/:_authToken=${NPM_AUTH}" >> ~/.npmrc

if [[ "$GITHUB_REF" = "refs/heads/master" ]] && [[ "$GH_PR_NUMBER" = "null" ]]; then
    echo "======================================================";
    echo "  Deploying a canary release";
    echo "======================================================";
    if [[ "$IS_DEBUG_MODE_ENABLED" = false ]]; then
        fesk-release --next --yes
    fi;
fi;

#if [[ "${TRAVIS_TAG}" != "" ]]; then
#    echo "DEPLOYING A LATEST RELEASE $TRAVIS_TAG";
#    if [[ "$IS_DEBUG_MODE_ENABLED" = false ]]; then
#        fesk-release --latest --yes
#    fi;
#fi;


if [[ "$GH_PR_NUMBER" != "null" ]]; then
    echo "======================================================";
    echo "  Deploying pull request number: $GH_PR_NUMBER";
    echo "======================================================";
    if [[ "$IS_DEBUG_MODE_ENABLED" = false ]]; then
        fesk-release --pull-request=${GH_PR_NUMBER} --yes
    fi;
fi;
