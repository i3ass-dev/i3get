#!/bin/bash

main(){

  result=$(get_window)

  timeout=$SECONDS

  ((__o[synk])) && until [[ $result ]]; do
    i3-msg -qt subscribe '["window"]'
    result=$(get_window)
    ((SECONDS-timeout > 60)) && break
  done

  [[ $result ]] || ERX "no matching window"
  echo "$result"
}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "${@}"                                     #bashbud
