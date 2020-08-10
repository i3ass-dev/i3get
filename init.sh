#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
i3get - version: 0.63
updated: 2020-08-10 by budRich
EOB
}




___printhelp(){
  
cat << 'EOB' >&2
i3get - prints info about a specific window to stdout


SYNOPSIS
--------
i3get [--class|-c CLASS] [--instance|-i INSTANCE] [--title|-t TITLE] [--conid|-n CON_ID] [--id|-d WIN_ID] [--mark|-m MARK] [--titleformat|-o TITLE_FORMAT] [--active|-a] [--synk|-y] [--print|-r OUTPUT] [--json TREE]      
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


--id|-d WIN_ID  
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
|a         | is active        | true or false
|f         | floating state   | string
|o         | title format     | string
|e         | fullscreen       | 1 or 0
|s         | sticky           | true or false
|u         | urgent           | true or false

Each character in OUTPUT will be tested and the
return value will be printed on a new line. If no
value is found, --i3get could not find: CHARACTER
will get printed.

In the example below, the target window did not
have a mark:  


   $ i3get -r tfcmw
   /dev/pts/9
   user_off
   URxvt
   --i3get could not find: m
   1




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
    --longoptions "class:,instance:,title:,conid:,id:,mark:,titleformat:,active,synk,print:,json:,help,version," \
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
    --id         | -d ) __o[id]="${2:-}" ; shift ;;
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




