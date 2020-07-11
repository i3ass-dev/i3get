#!/bin/bash

match() {

  local json=$1 ret=${__o[print]:-n} k

  [[ -z $_expression ]] && makeexpression

  declare -i i
  declare -A ma

  [[ $json =~ $_expression ]] && {
  
    ma=(
      [n]="${BASH_REMATCH[1]}"
      [m]="${BASH_REMATCH[2]}" # mark opt
      [m]="${BASH_REMATCH[3]}"
      [a]="${BASH_REMATCH[4]}"
      [t]="${BASH_REMATCH[5]}"
      [o]="${BASH_REMATCH[6]}" # titleformat opt
      [o]="${BASH_REMATCH[7]}"
      [d]="${BASH_REMATCH[8]}"
      [c]="${BASH_REMATCH[9]}"
      [i]="${BASH_REMATCH[10]}"
      [e]="${BASH_REMATCH[11]}"
      [s]="${BASH_REMATCH[12]}"
      [f]="${BASH_REMATCH[13]}"
    )

    for ((i=0;i<${#ret};i++)); do
      k=${ret:$i:1}
      [[ $k = w ]] && ma[w]=$(getworkspace)
      [[ -n ${ma[$k]} ]] && _op+=("${ma[$k]}")
    done

  }
}
