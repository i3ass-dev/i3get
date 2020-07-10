#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
i3get - version: 0.383
updated: 2020-07-10 by budRich
EOB
}



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

  getworkspace() {
    local re

    re="\"num@\":(${_c[workspace]:-"[0-9-]+"}),[^@]+"
    re+="$_re"

    [[ ${_json//\"num\":/\"num@\":} =~ ${re//$'\n'/} ]] \
      && echo "${BASH_REMATCH[1]}"
  }

  _json=${__o[json]:-$(i3-msg -t get_tree)}

  [[ $_json =~ ${_re//$'\n'/} ]] && {

    declare -A ma
    ma=(
      [n]="${BASH_REMATCH[1]}"
      [o]="${BASH_REMATCH[2]}"
      [d]="${BASH_REMATCH[3]}"
      [c]="${BASH_REMATCH[4]}"
      [i]="${BASH_REMATCH[5]}"
      [t]="${BASH_REMATCH[6]}"
      [e]="${BASH_REMATCH[7]}"
      [s]="${BASH_REMATCH[8]}"
      [f]="${BASH_REMATCH[9]}"
    )

    for ((i=0;i<${#ret};i++)); do
      [[ ${ret:$i:1} = w ]] && ma[w]=$(getworkspace)
      op+=("${ma[${ret:$i:1}]}")
    done

    # printf '%s\n' "${op[@]}"
    
  }

  ((__o[synk])) && {
    # timeout after 10 seconds
    for ((i=0;i<100;i++)); do 
      sleep 0.1
      result=$(getwindow)
      [ -n "$result" ] && break
    done
  }

  if [ -n "${op[*]}" ]; then
    printf '%s\n' "${op[@]}"
  else
    ERX "no matching window."
  fi
  
}

___printhelp(){
  
cat << 'EOB' >&2
i3get - prints info about a specific window to stdout


SYNOPSIS
--------
i3get [--class|-c CLASS] [--instance|-i INSTANCE] [--title|-t TITLE] [--conid|-n CON_ID] [--winid|-d WIN_ID] [--mark|-m MARK] [--titleformat|-o TITLE_FORMAT] [--active|-a] [--synk|-y] [--print|-r OUTPUT]      
i3get --help|-h
i3get --version|-v

OPTIONS
-------

--class|-c CLASS  
Search for windows with the given class


--instance|-i INSTANCE  
Search for windows with the given instance


--title|-t TITLE  
Search for windows with title.


--conid|-n CON_ID  
Search for windows with the given con_id


--winid|-d WIN_ID  
Search for windows with the given window id


--mark|-m MARK  
Search for windows with the given mark


--titleformat|-o TITLE_FORMAT  
Search for windows with the given titleformat


--active|-a  
Currently active window (default)


--synk|-y  
Synch on. If this option is included,  script
will wait till target window exist. (or timeout
after 10 seconds).


--print|-r OUTPUT  
OUTPUT can be one or more of the following 
characters:  


|character | print
|:---------|:-----
|t       | title  
|c       | class  
|i       | instance  
|d       | Window ID  
|n       | Con_Id (default)  
|m       | mark  
|w       | workspace  
|a       | is active  
|f       | floating state  
|o       | title format  
|v       | visible state  

--help|-h  
Show help and exit.


--version|-v  
Show version and exit

EOB
}


ERM(){ >&2 echo "$*"; }
ERR(){ >&2 echo "[WARNING]" "$*"; }
ERX(){ >&2 echo "[ERROR]" "$*" && exit 1 ; }


_re=$(cat << EOB
"id":(${_c[conid]:-"[0-9]+"}),
[^{]+
"focused":${_c[active]},
[^}]+},
[^}]+},
[^}]+},
[^}]+},
[^,]+,
"title_format":"(${_c[format]:-"[^\"]+"})",
"window":(${_c[winid]:-"[0-9]+"}),
[^,]+,
"window_properties":\{"class":"(${_c[class]:-"[^\"]+"})",
"instance":"(${_c[instance]:-"[^\"]+"})",
"title":"(${_c[title]:-"[^\"]+"})",
"transient_for":[^,]+,
[^{}]+,
"fullscreen_mode":([0-9]),
"sticky":(false|true),
"floating":"([^\"]+)",
EOB
)
declare -A __o
eval set -- "$(getopt --name "i3get" \
  --options "c:i:t:n:d:m:o:ayr:hv" \
  --longoptions "class:,instance:,title:,conid:,winid:,mark:,titleformat:,active,synk,print:,help,version," \
  -- "$@"
)"

while true; do
  case "$1" in
    --class      | -c ) __o[class]="${2:-}" ; shift ;;
    --instance   | -i ) __o[instance]="${2:-}" ; shift ;;
    --title      | -t ) __o[title]="${2:-}" ; shift ;;
    --conid      | -n ) __o[conid]="${2:-}" ; shift ;;
    --winid      | -d ) __o[winid]="${2:-}" ; shift ;;
    --mark       | -m ) __o[mark]="${2:-}" ; shift ;;
    --titleformat | -o ) __o[titleformat]="${2:-}" ; shift ;;
    --active     | -a ) __o[active]=1 ;; 
    --synk       | -y ) __o[synk]=1 ;; 
    --print      | -r ) __o[print]="${2:-}" ; shift ;;
    --help       | -h ) __o[help]=1 ;; 
    --version    | -v ) __o[version]=1 ;; 
    -- ) shift ; break ;;
    *  ) break ;;
  esac
  shift
done

if [[ ${__o[help]:-} = 1 ]]; then
  ___printhelp
  exit
elif [[ ${__o[version]:-} = 1 ]]; then
  ___printversion
  exit
fi

[[ ${__lastarg:="${!#:-}"} =~ ^--$|${0}$ ]] \
  && __lastarg="" 


main "${@:-}"


