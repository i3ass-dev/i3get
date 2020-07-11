#!/bin/bash

getworkspace() {
  local re

  [[ -z $_json ]] && {
    [[ -f ${__o[json]} ]] && _json=$(< "${__o[json]}")
    : "${_json:=$(i3-msg -t get_tree)}"
  }

  special=@
  re="\"num$special\":(${_c[workspace]:-"[0-9-]+"}),[^$special]+"
  re+="$_expression"

  [[ ${_json//\"num\":/\"num@\":} =~ $re ]] \
    && echo "${BASH_REMATCH[1]}"
}
