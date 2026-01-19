#!/bin/bash

REGEX="^\[(patch|minor|major)\] (feat|fix|refactor): .+$"

if [[ ! $INPUT_TITLE =~ $REGEX ]]; then
  echo "::error title=PR Title::Your pull request title does not follow the conventional commit format. Please use the format: [<bump type>] (<type>): <description>"
  echo "::warning title=Available Types:feat,fix,refactor"
  echo "::warning title=Example:[patch] refactor: Refactor mappers"
  exit 1
fi