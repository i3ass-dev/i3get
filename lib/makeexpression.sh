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
