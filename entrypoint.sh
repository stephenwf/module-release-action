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

number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")


IS_DEBUG_MODE_ENABLED=${MODULE_RELEASE_DEBUG:-false}  # If variable not set or null, use default.


if [[ "$IS_DEBUG_MODE_ENABLED" != false ]]; then
    debugEventPath=$(jq "." "$GITHUB_EVENT_PATH")

    echo " DEBUG: Pull request number $number";
    echo " DEBUG: Github event path $debugEventPath"
fi;

echo "//registry.npmjs.org/:_authToken=${NPM_AUTH}" >> ~/.npmrc

if [[ "$GITHUB_REF" = "refs/heads/master" ]] && [[ "$number" = "null" ]]; then
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


if [[ "$number" != "null" ]]; then
    echo "======================================================";
    echo "  Deploying pull request number: $number";
    echo "======================================================";
    if [[ "$IS_DEBUG_MODE_ENABLED" = false ]]; then
        fesk-release --pull-request=${number} --yes
    fi;
fi;
