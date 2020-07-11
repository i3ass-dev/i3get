#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
i3get - version: 0.571
updated: 2020-07-11 by budRich
EOB
}



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

___printhelp(){
  
cat << 'EOB' >&2
i3get - prints info about a specific window to stdout


SYNOPSIS
--------
i3get [--class|-c CLASS] [--instance|-i INSTANCE] [--title|-t TITLE] [--conid|-n CON_ID] [--winid|-d WIN_ID] [--mark|-m MARK] [--titleformat|-o TITLE_FORMAT] [--active|-a] [--synk|-y] [--print|-r OUTPUT] [--json TREE]      
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


|character | print            | return
|:---------|:-----------------|:------
|t       | title            | string
|c       | class            | string
|i       | instance         | string
|d       | Window ID        | INT
|n       | Con_Id (default) | INT
|m       | mark             | JSON list
|w       | workspace        | INT
|a       | is active        | true|false
|f       | floating state   | string
|o       | title format     | string
|e       | fullscreen       | 1|0
|s       | sticky           | true|false

--json TREE  
Use TREE instead of the output of i3-msg -t
get_tree


--help|-h  
Show help and exit.


--version|-v  
Show version and exit

EOB
}


ERM(){ >&2 echo "$*"; }
ERR(){ >&2 echo "[WARNING]" "$*"; }
ERX(){ >&2 echo "[ERROR]" "$*" && exit 1 ; }

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
makeexpression() {

local mark o re crit

declare -A _c

for o in "${!__o[@]}"; do
  [[ $o =~ synk|active|print ]] && continue

  crit=${__o[$o]}

  # allow ^ and $ re in criteria
  if [[ $crit =~ [$]$ ]]; then
    crit='[^"]*'"${crit%$}"
  elif [[ $crit =~ ^[^] ]]; then
    crit=${crit%$}'[^"]*'
  elif [[ $crit =~ ^[^](.+)[$]$ ]]; then
    crit=${BASH_REMATCH[1]}
  fi

  _c[$o]=$crit
done

# no criteria specified, search active window
((__o[active] || !${#_c[@]})) && _c[active]=true
: "${_c[active]:=true|false}"

mark='("marks":(\[[^]]*\]),)?'
[[ -n ${_c[mark]} ]] \
  && mark="(\"marks\":(\[[^]]*\"${_c[mark]}\"[^]]*\]),)"

re=$(cat << EOB
"id":(${_c[conid]:-[0-9]+}),
[^{]+
${mark}
"focused":(${_c[active]}),
[^}]+},
[^}]+},
[^}]+},
[^}]+},
"name":"(${_c[title]:-[^\"]+})",
("title_format":"(${_c[format]:-[^\"]+})",)?
"window":(${_c[winid]:-[0-9]+}),
[^,]+,
"window_properties":\{
"class":"(${_c[class]:-[^\"]+})",
"instance":"(${_c[instance]:-[^\"]+})",
[^}]+\},
"nodes":[^,]+,
"floating_nodes":[^,]+,
"focus":[^,]+,
"fullscreen_mode":([0-9]),
"sticky":(false|true),
"floating":"([^\"]+)",
EOB
)

_expression="${re//$'\n'/}"
}

# example node, this is formated with 'jq' the
# output we parse have NO WHITESPACE other then
# within strings.
# 
# "title_format" and "marks" entries are only present
# if they contain a value

# {
#   "id": 94203249782944,
#   "type": "con",
#   "orientation": "none",
#   "scratchpad_state": "none",
#   "percent": 0.25,
#   "urgent": false,
#   "focused": false,
#   "output": "HDMI2",
#   "layout": "splith",
#   "workspace_layout": "default",
#   "last_split_layout": "splith",
#   "border": "normal",
#   "current_border_width": 2,
#   "rect": {
#     "x": 1614,
#     "y": 272,
#     "width": 306,
#     "height": 808
#   },
#   "deco_rect": {
#     "x": 0,
#     "y": 0,
#     "width": 76,
#     "height": 20
#   },
#   "window_rect": {
#     "x": 2,
#     "y": 0,
#     "width": 304,
#     "height": 808
#   },
#   "geometry": {
#     "x": 0,
#     "y": 0,
#     "width": 1920,
#     "height": 808
#   },
#   "name": "/home/bud/snd/y - File Manager",
#   "title_format": "snd/y",
#   "window": 14680068,
#   "window_type": "normal",
#   "window_properties": {
#     "class": "ThunarD",
#     "instance": "thunar-ltd",
#     "window_role": "Thunar-1593373798-3562220418",
#     "title": "/home/bud/snd/y - File Manager",
#     "transient_for": null
#   },
#   "nodes": [],
#   "floating_nodes": [],
#   "focus": [],
#   "fullscreen_mode": 0,
#   "sticky": false,
#   "floating": "user_off",
#   "swallows": []
# },

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
declare -A __o
eval set -- "$(getopt --name "i3get" \
  --options "c:i:t:n:d:m:o:ayr:hv" \
  --longoptions "class:,instance:,title:,conid:,winid:,mark:,titleformat:,active,synk,print:,json:,help,version," \
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
    --json       ) __o[json]="${2:-}" ; shift ;;
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


