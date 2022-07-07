#!/usr/bin/env bash

# shortcut (can run this file from any folder)

MY_PATH="`dirname \"$0\"`"
# echo "$MY_PATH"

export PATH=$PATH:$MY_PATH/src/kubify/tool
export KUBIFY_DEBUG=1
export KUBIFY_VERBOSE=1
kubify $@