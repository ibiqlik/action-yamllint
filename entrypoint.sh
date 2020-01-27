#!/bin/sh -l

echo "======================"
echo "= Linting YAML files ="
echo "======================"

# Use the current directory by default
export INPUT_FILE_OR_DIR=${INPUT_FILE_OR_DIR:-.}

STRICT=""
if [ "$INPUT_STRICT" == "true" ]; then
    STRICT="-s"
fi

if [ ! -z "$INPUT_CONFIG_FILE" ]; then
    CONFIG_FILE="-c $INPUT_CONFIG_FILE"
fi

if [ ! -z "$INPUT_CONFIG_DATA" ]; then
    CONFIG_DATA="-d $INPUT_CONFIG_DATA"
fi

yamllint $CONFIG_FILE $CONFIG_DATA -f $INPUT_FORMAT $STRICT $INPUT_FILE_OR_DIR
