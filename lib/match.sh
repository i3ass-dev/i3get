#!/bin/bash

match() {

  local json=$1 ret=${__o[print]:-n} k

  [[ -z $_expression ]] && makeexpression

  declare -i i
  declare -A ma

  [[ ${__o[print]} =~ w ]] \
    && json=${_json//\"num\":/\"num${_special}\":}

  [[ $json =~ $_expression ]] && {
    ma=(
      [w]="${BASH_REMATCH[$((++i))]}"
      [n]="${BASH_REMATCH[$((++i))]}"
      [u]="${BASH_REMATCH[$((++i))]}"
      [O]="${BASH_REMATCH[$((++i))]}" # mark opt
      [m]="${BASH_REMATCH[$((++i))]}"
      [a]="${BASH_REMATCH[$((++i))]}"
      [t]="${BASH_REMATCH[$((++i))]}"
      [O]="${BASH_REMATCH[$((++i))]}" # titleformat opt
      [o]="${BASH_REMATCH[$((++i))]}"
      [O]="${BASH_REMATCH[$((++i))]}" # window opt (mark|conid)
      [d]="${BASH_REMATCH[$((++i))]}"
      [c]="${BASH_REMATCH[$((++i))]}"
      [i]="${BASH_REMATCH[$((++i))]}"
      [e]="${BASH_REMATCH[$((++i))]}"
      [s]="${BASH_REMATCH[$((++i))]}"
      [f]="${BASH_REMATCH[$((++i))]}"
    )

    for ((i=0;i<${#ret};i++)); do
      k=${ret:$i:1}
      _op+=("${ma[$k]:-$k: NA}")
    done

  }
}
