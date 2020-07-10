#!/bin/bash

getworkspace() {
  local re

  special=@
  re="\"num$special\":(${_c[workspace]:-"[0-9-]+"}),[^$special]+"
  re+="$_re"

  [[ ${_json//\"num\":/\"num@\":} =~ ${re//$'\n'/} ]] \
    && echo "${BASH_REMATCH[1]}"
}
