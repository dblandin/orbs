#!/bin/bash
set -euo pipefail

. ./scripts/orb_utils.sh

ORB="$1"
echo "Validating artsy/$1 orb"

ORB_PATH=$(get_orb_path $ORB)

if [ ! -f "$ORB_PATH" ]; then
  echo "No orb exists at $ORB_PATH"
  exit 1
fi

VERSION=$(get_orb_version $ORB)
VERSION_COMMENT=$(head -n 1 $ORB_PATH)
PUBLISHED_VERSION=$(get_published_orb_version $ORB)

# Ensure the version is defined and that the version comment actually is a comment...
if [ -z $VERSION ] || [ ! "${VERSION_COMMENT:0:1}" == "#" ]; then
  echo ""
  echo "Orb at $ORB_PATH does not have a version comment"
  echo "Add something like '# Orb Version 1.0.0' at the top of the file"
  echo "That version will be used as the published version"
  return
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "master" ]; then

  CHANGED_FILES=$(git diff --name-only HEAD..master)
  UPDATED_FILES=$(git status -s | cut -c4-)
  ALL_CHANGES=("${CHANGED_FILES[@]}" "${UPDATED_FILES[@]}")
  for file in ${ALL_CHANGES[@]}; do
    if [[ "$ORB_PATH" == *"$file" ]] && [[ "$VERSION" == "$PUBLISHED_VERSION" ]]; then
      echo ""
      echo "artsy/$ORB has been updated since master but hasn't had its version bumped."
      echo "Update its version in $ORB_PATH"
      exit 1
    fi
  done

fi 

circleci orb validate $ORB_PATH