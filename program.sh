#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
i3get - version: 0.622
updated: 2020-07-12 by budRich
EOB
}



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
after 60 seconds).


--print|-r OUTPUT  
OUTPUT can be one or more of the following 
characters:  


|character | print            | return
|:---------|:-----------------|:------
|t         | title            | string
|c         | class            | string
|i         | instance         | string
|d         | Window ID        | INT
|n         | Con_Id (default) | INT
|m         | mark             | JSON list
|w         | workspace        | INT
|a         | is active        | true|false
|f         | floating state   | string
|o         | title format     | string
|e         | fullscreen       | 1|0
|s         | sticky           | true|false
|u         | urgent           | true|false

--json TREE  
Use TREE instead of the output of  
i3-msg -t get_tree


--help|-h  
Show help and exit.


--version|-v  
Show version and exit

EOB
}


set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

ERX() { echo  "[ERROR] $*" >&2 ; exit 77 ;}
ERR() { echo  "[WARNING] $*" >&2 ;}
ERM() { echo  "$*" >&2 ;}
makeexpression() {

local mark o re crit format

declare -A _c

for o in "${!__o[@]}"; do
  [[ $o =~ synk|active|print ]] && continue

  crit=${__o[$o]}

  # allow ^ and $ re in criteria
  if [[ $crit =~ [$]$ ]]; then
    crit='[^"]*'"${crit%$}"
  elif [[ $crit =~ ^[^] ]]; then
    crit=${crit#^}'[^"]*'
  elif [[ $crit =~ ^[^](.+)[$]$ ]]; then
    crit=${BASH_REMATCH[1]}
  fi

  _c[$o]=$crit
done

# no criteria specified, search active window
((__o[active] || !${#_c[@]})) && _c[active]=true
: "${_c[active]:=true|false}"

mark='("marks":(\[[^]]*\]),)?'
format='("title_format":"([^"]+)",)?'

[[ -n ${_c[titleformat]} ]] \
  && format="(\"title_format\":(\"${_c[titleformat]}\"),)"

[[ -n ${_c[mark]} ]] \
  && mark="(\"marks\":(\[[^]]*\"${_c[mark]}\"[^]]*\]),)"

if [[ ${__o[print]} =~ w || -n ${_c[workspace]} ]]; then
  re="\"num$_special\":(${_c[workspace]:-[0-9-]+})"
  re+=",[^$_special]+"
else
  re="(\{)"
fi

re+=$(cat << EOB
"id":(${_c[conid]:-[0-9]+}),
"type":"[^"]+",
"orientation":"[^"]+",
"scratchpad_state":"[^"]+",
"percent":[0-9.]+,
"urgent":(false|true),
${mark}
"focused":(${_c[active]}),
"output":"[^"]+",
"layout":"[^"]+",
"workspace_layout":"[^"]+",
"last_split_layout":"[^"]+",
"border":"[^"]+",
"current_border_width":[0-9-]+,
"rect":[^}]+},
"deco_rect":[^}]+},
"window_rect":[^}]+},
"geometry":[^}]+},
"name":"?(${_c[title]:-[^\"]+})"?,
${format}
("window":(${_c[winid]:-[0-9]+}),
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
"floating":"([^"]+)",)
EOB
)

# if criteria is mark || conid, window properties
# are optional
[[ -n ${_c[mark]}${_c[conid]}${_c[titleformat]} ]] && re+='?'

# ERM "$re"
_expression="${re//$'\n'/}"
}

# example node, this is formated with 'jq' the
# output we parse have NO WHITESPACE other then
# within strings.
# 
# "title_format" and "marks" entries are only present
# if they contain a value.
#
# "name": can be null (not enclosed in quotes)

# {
#   "id": 94203263545520,
#   "type": "con",
#   "orientation": "none",
#   "scratchpad_state": "none",
#   "percent": 1,
#   "urgent": false,
#   "focused": false,
#   "output": "__i3",
#   "layout": "splith",
#   "workspace_layout": "default",
#   "last_split_layout": "splith",
#   "border": "normal",
#   "current_border_width": 2,
#   "rect": {
#     "x": 596,
#     "y": 355,
#     "width": 728,
#     "height": 350
#   },
#   "deco_rect": {
#     "x": 0,
#     "y": 0,
#     "width": 728,
#     "height": 20
#   },
#   "window_rect": {
#     "x": 2,
#     "y": 0,
#     "width": 724,
#     "height": 348
#   },
#   "geometry": {
#     "x": 0,
#     "y": 0,
#     "width": 724,
#     "height": 348
#   },
#   "name": "/dev/pts/12",
#   "title_format": "typiskt",
#   "window": 8393677,
#   "window_type": "unknown",
#   "window_properties": {
#     "class": "URxvt",
#     "instance": "typiskt",
#     "title": "/dev/pts/12",
#     "transient_for": null
#   },
#   "nodes": [],
#   "floating_nodes": [],
#   "focus": [],
#   "fullscreen_mode": 0,
#   "sticky": false,
#   "floating": "user_on",
#   "swallows": []
# }
# ],
# "floating_nodes": [],
# "focus": [
# 94203263545520
# ],
# "fullscreen_mode": 0,
# "sticky": false,
# "floating": "auto_off",
# "swallows": []
# }

match() {

  local json=$1 ret=${__o[print]:-n} k

  [[ -z $_expression ]] && makeexpression

  declare -i i
  declare -A ma

  [[ ${__o[print]} =~ w || -n ${__o[workspace]} ]] \
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


declare -A __o
options="$(
  getopt --name "[ERROR]:i3get" \
    --options "c:i:t:n:d:m:o:ayr:hv" \
    --longoptions "class:,instance:,title:,conid:,winid:,mark:,titleformat:,active,synk,print:,json:,help,version," \
    -- "$@" || exit 77
)"

eval set -- "$options"
unset options

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
    --help       | -h ) ___printhelp && exit ;;
    --version    | -v ) ___printversion && exit ;;
    -- ) shift ; break ;;
    *  ) break ;;
  esac
  shift
done

[[ ${__lastarg:="${!#:-}"} =~ ^--$|${0}$ ]] \
  && __lastarg="" 


main "${@}"


