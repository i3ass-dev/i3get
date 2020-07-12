#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
i3get - version: 0.616
updated: 2020-07-12 by budRich
EOB
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


for ___f in "${___dir}/lib"/*; do
  source "$___f"
done

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




