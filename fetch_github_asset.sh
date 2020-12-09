#!/bin/bash

if [[ -z "$INPUT_FILE" ]]; then
  echo "Missing file input in the action"
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Missing GITHUB_REPOSITORY env variable"
  exit 1
fi

REPO=$GITHUB_REPOSITORY
if ! [[ -z ${INPUT_REPO} ]]; then
  REPO=$INPUT_REPO ;
fi
echo INPUT_TOKEN $INPUT_TOKEN

# Optional personal access token for external repository
TOKEN=$GITHUB_TOKEN
if ! [[ -z ${INPUT_TOKEN} ]]; then
  TOKEN=$INPUT_TOKEN
fi
echo TOKEN $TOKEN

API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $TOKEN"
API_URL="https://api.github.com/repos/$REPO"
echo API_URL $API_URL
echo INPUT_VERSION $INPUT_VERSION
RELEASE_DATA=$(curl -i -H "${AUTH_HEADER}" -H "${API_HEADER}" $API_URL/releases/${INPUT_VERSION})
echo RELEASE_DATA
echo $RELEASE_DATA
echo INPUT_FILE $INPUT_FILE
ASSET_ID=$(echo $RELEASE_DATA | jq -r ".assets | map(select(.name == \"${INPUT_FILE}\"))[0].id")
TAG_VERSION=$(echo $RELEASE_DATA | jq -r ".tag_name" | sed -e "s/^v//" | sed -e "s/^v.//")

echo ASSET_ID $ASSET_ID
echo TAG_VERSION $TAG_VERSION

if [[ -z "$ASSET_ID" ]]; then
  echo "Could not find asset id"
  exit 1
fi

curl \
  -J \
  -L \
  -H "Accept: application/octet-stream" \
  "$API_URL/releases/assets/$ASSET_ID" \
  -o ${INPUT_FILE}

echo "::set-output name=version::$TAG_VERSION"
