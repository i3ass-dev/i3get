#!/bin/bash

match() {

  local json=$1 k

  [[ -z $_expression ]] && makeexpression

  declare -i i
  declare -A ma

  [[ $_toprint =~ w || -n ${__o[workspace]} ]] \
    && json=${_json//\"num\":/\"num${_special}\":}

  # name of the keys in array "ma" match the characters
  # that can be used as arguments to --print (_toprint)
  # optional capture groups are collected in the dummykey O
  [[ $json =~ $_expression ]] && {
    ma=(
      [w]="${BASH_REMATCH[$((++i))]}" # "num:"             - INT
      [n]="${BASH_REMATCH[$((++i))]}" # "id:"              - INT
      [u]="${BASH_REMATCH[$((++i))]}" # "urgent:"          - false|true
      [O]="${BASH_REMATCH[$((++i))]}" # ! optional group
      [m]="${BASH_REMATCH[$((++i))]}" # "marks:"           - ["mark1","mark2"...]
      [a]="${BASH_REMATCH[$((++i))]}" # "focused:"         - false|true
      [t]="${BASH_REMATCH[$((++i))]}" # "name:"            - STRING
      [O]="${BASH_REMATCH[$((++i))]}" # ! optional group
      [o]="${BASH_REMATCH[$((++i))]:-%title}" # "title_format:"    - string
      [O]="${BASH_REMATCH[$((++i))]}" # ! optional group
      [d]="${BASH_REMATCH[$((++i))]}" # "window:"          - INT
      [c]="${BASH_REMATCH[$((++i))]}" # "class:"           - STRING
      [i]="${BASH_REMATCH[$((++i))]}" # "instance:"        - STRING
      [e]="${BASH_REMATCH[$((++i))]}" # "fullscreen_mode:" - 0|1
      [s]="${BASH_REMATCH[$((++i))]}" # "sticky:"          - true|false
      [f]="${BASH_REMATCH[$((++i))]}" # "floating:"        - auto_off|auto_on|user_off|user_on
    )

    for ((i=0;i<${#_toprint};i++)); do
      k=${_toprint:$i:1}
      _op+=("${ma[$k]:---i3get could not find: $k}")
    done

  }
}
