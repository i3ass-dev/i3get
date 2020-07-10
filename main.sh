#!/usr/bin/env bash

main(){

  declare -A _c

  for o in "${!__o[@]}"; do
    [[ $o =~ synk|active|print ]] && continue
    _c[$o]="${__o[$o]}"
  done
  
  ((__o[active])) && _c[active]=true

  # if no search is given, search for active window
  ((${#_c[@]})) || _c[active]=true
  : "${_c[active]:=true|false}"
  ret=${__o[print]:-n}

  _re=$(makeexpression)
  _json=${__o[json]:-$(i3-msg -t get_tree)}

  [[ $_json =~ ${_re//$'\n'/} ]] && {

    declare -A ma
    ma=(
      [n]="${BASH_REMATCH[1]}"
      [m]="${BASH_REMATCH[2]}"
      [m]="${BASH_REMATCH[3]}"
      [a]="${BASH_REMATCH[4]}"
      [o]="${BASH_REMATCH[5]}"
      [d]="${BASH_REMATCH[6]}"
      [c]="${BASH_REMATCH[7]}"
      [i]="${BASH_REMATCH[8]}"
      [t]="${BASH_REMATCH[9]}"
      [e]="${BASH_REMATCH[10]}"
      [s]="${BASH_REMATCH[11]}"
      [f]="${BASH_REMATCH[12]}"
    )

    for ((i=0;i<${#ret};i++)); do
      [[ ${ret:$i:1} = w ]] && ma[w]=$(getworkspace)
      op+=("${ma[${ret:$i:1}]}")
    done
    
  }

  ((__o[synk])) \
    && while read -r line < <(i3-msg -mt subscribe '["window"]'); do

      [[ $line =~ ${_re//$'\n'/} ]] && {

        declare -A ma
        ma=(
          [n]="${BASH_REMATCH[1]}"
          [m]="${BASH_REMATCH[2]}"
          [m]="${BASH_REMATCH[3]}"
          [a]="${BASH_REMATCH[4]}"
          [o]="${BASH_REMATCH[5]}"
          [d]="${BASH_REMATCH[6]}"
          [c]="${BASH_REMATCH[7]}"
          [i]="${BASH_REMATCH[8]}"
          [t]="${BASH_REMATCH[9]}"
          [e]="${BASH_REMATCH[10]}"
          [s]="${BASH_REMATCH[11]}"
          [f]="${BASH_REMATCH[12]}"
        )

        for ((i=0;i<${#ret};i++)); do
          [[ ${ret:$i:1} = w ]] && ma[w]=$(getworkspace)
          op+=("${ma[${ret:$i:1}]}")
        done

        break
      }
    done

  # ((__o[synk])) && {
  #   # timeout after 10 seconds
  #   for ((i=0;i<100;i++)); do 
  #     sleep 0.1
  #     result=$(getwindow)
  #     [ -n "$result" ] && break
  #   done
  # }

  if [ -n "${op[*]}" ]; then
    printf '%s\n' "${op[@]}"
  else
    ERX "no matching window."
  fi
  
}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "$@"                                       #bashbud
