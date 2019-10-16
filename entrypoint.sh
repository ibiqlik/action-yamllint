#!/bin/sh -l

if [ ! -z "$INPUT_STRICT" ]; then
    STRICT="-s"
fi

if [ ! -z "$INPUT_CONFIG_FILE" ]; then
    CONFIG_FILE="-c $INPUT_CONFIG_FILE"
fi

if [ ! -z "$INPUT_CONFIG_DATA" ]; then
    CONFIG_DATA="-d $INPUT_CONFIG_DATA"
fi

yamllint $CONFIG_FILE $CONFIG_DATA $INPUT_FORMAT $STRICT $INPUT_FILE_OR_DIR 
