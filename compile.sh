#!/usr/bin/env bash

JUMPMOD_NAME='zzz_jumpmod'
JUMPMOD_PATH="$(pwd)"
JUMPMOD_FILES=(callback.gsc maps jumpmod)

if [[ -d "$JUMPMOD_PATH" && "$(basename "$JUMPMOD_PATH")" == "$JUMPMOD_NAME" ]]; then
    if [[ ("$1" == 'j2g' || "$1" == 'json2gsc') && -f "$JUMPMOD_PATH/json2gsc/Build/Staged/json2gsc" ]]; then
        "$JUMPMOD_PATH/json2gsc/Build/Staged/json2gsc" "$JUMPMOD_PATH/json2gsc/Build/Staged/mapconfigs" "$JUMPMOD_PATH/jumpmod/settings.gsc"
    fi

    zip -r "$JUMPMOD_NAME.pk3" "${JUMPMOD_FILES[@]}"
fi