#!/usr/bin/env bash

main(){

  declare -a _op         # output, populated in match()
  declare -r _special= # used when searching for ws
  declare -g _expression # makeexpression() via match()
  declare -i timeout

  [[ -f ${__o[json]} ]] && _json=$(< "${__o[json]}")
  : "${_json:=$(i3-msg -t get_tree)}"

  match "$_json"

  ((__o[synk])) && [[ -z "${_op[*]}" ]] && {

    timeout=$SECONDS

    match "$(i3-msg -t get_tree)"

    while [[ -z "${_op[*]}" ]]; do
      ((SECONDS-timeout > 60)) && break
      i3-msg -qt subscribe '["window"]'
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
