#!/usr/bin/env bash

JUMPMOD_NAME='zzz_jumpmod'
JUMPMOD_PATH="$(pwd)"
JUMPMOD_FILES=('callback.gsc' 'maps' 'jumpmod')
J2G_SUBMODULE='3f8e7d5'

if [[ "$J2G_SUBMODULE" != "$(git submodule status | cut -c '2-8')" ]]; then
    echo 'json2gsc: submodule has changed. "'"$(basename "$0")"'" need to be updated'
    exit 1
fi

REQ_COMMANDS=('zip' 'g++' 'cmake')
for CMD in "${REQ_COMMANDS[@]}"; do
    if [[ ! -x "$(command -v "$CMD")" ]]; then
        echo 'Missing executable:' "$CMD"
        exit 1
    fi
done

if [[ -d "$JUMPMOD_PATH" && "$(basename "$JUMPMOD_PATH")" == "$JUMPMOD_NAME" ]]; then
    if [[ "$1" == 'j2g' || "$1" == 'json2gsc' ]]; then
        if [[ ! -d "$JUMPMOD_PATH/json2gsc/Build" ]]; then
            (
                cd 'json2gsc' || { echo 'json2gsc: Missing "json2gsc/" folder'; exit 1; }; mkdir 'Build'
                cmake . -B 'Build'
                cmake --build 'Build'
            )
        else
            echo 'json2gsc: "Build/" folder already exists. Skipping build'
        fi

        if [[ -x "$JUMPMOD_PATH/json2gsc/Build/Staged/json2gsc" ]]; then
            echo -n 'json2gsc: '

            if ! "$JUMPMOD_PATH/json2gsc/Build/Staged/json2gsc" "$JUMPMOD_PATH/json2gsc/Build/Staged/mapconfigs" "$JUMPMOD_PATH/src/jumpmod/settings.gsc"; then
                exit 1
            fi
        else
            echo 'json2gsc: executable not found'
            exit 1
        fi

        echo
    fi

    if [[ ! -f "$JUMPMOD_PATH/src/jumpmod/settings.gsc" ]]; then
        echo 'Missing "settings.gsc", run:' "$(basename "$0")" 'json2gsc'
        exit 1
    fi

    if [[ -f "$JUMPMOD_NAME.pk3" ]]; then
        echo 'Updating "'"$JUMPMOD_NAME.pk3"'":'
    else
        echo 'Creating "'"$JUMPMOD_NAME.pk3"'":'
    fi

    (
        cd 'src' || { echo 'Missing "src/" folder'; exit 1; }
        zip -r "$JUMPMOD_PATH/$JUMPMOD_NAME.pk3" "${JUMPMOD_FILES[@]}"
    )
fi