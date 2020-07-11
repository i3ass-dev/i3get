#!/usr/bin/env bash

main(){

  declare -a _op      # output, populated in match()
  declare _expression # makeexpression() via match()

  [[ -f ${__o[json]} ]] && _json=$(< "${__o[json]}")
  : "${_json:=$(i3-msg -t get_tree)}"

  match "$_json"

  ((__o[synk])) && {
    # unset _json will force getworkspace()
    # to get a fresh tree if 'w' is in --print
    unset _json
    while [[ -z "${_op[*]}" ]]; do
      i3-msg -qt subscribe '["window","tick"]'
      match "$(i3-msg -t get_tree)"
    done
  }

  [[ -n ${_op[*]} ]] && {
    printf '%s\n' "${_op[@]}"
    exit
  }

  ERX "no matching window."
}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "$@"                                       #bashbud
