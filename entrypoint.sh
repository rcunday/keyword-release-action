#!/bin/bash
set -e

if [ -n "$GITHUB_EVENT_PATH" ];
then
    EVENT_PATH=$GITHUB_EVENT_PATH
elif [ -f ./mock_push_event.json ];
then
    EVENT_PATH='./mock_push_event.json'
    LOCAL_TEST=true
else
    echo "No JSON data to process! :("
    exit 1
fi

env
jq . < $EVENT_PATH

# if keyword is found
if jq '.commits[].message, .head_commit.message' < $EVENT_PATH | grep -i -q "$*";
then
    # Create Tag with Version
    VERSION=$(date +%F.%s)
    # https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28
    DATA="$(printf '{"tag_name":"v%s",' $VERSION)"
    DATA="${DATA} $(printf '"target_commitish":"main",')"
    DATA="${DATA} $(printf '"name":"v%s",' $VERSION)"
    DATA="${DATA} $(printf '"body":"Automated release based on keyword: %s",' "$*")"
    DATA="${DATA} $(printf '"draft":false, "prerelease":false}')"

    URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases"
    TOKEN="Authorization: Bearer ${GITHUB_TOKEN}"

    if [[ "${LOCAL_TEST}" == *"true"* ]];
    then
        echo "## [TESTING] Keyword was found but no release was created."
    else
        # echo $DATA | http POST $URL $TOKEN | jq .
    curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "$(TOKEN)" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -X POST \
    --data "$(DATA)" \
    "$(URL)"
    fi
# otherwise
else
    # exit gracefully
    echo "Nothing to process."
fi