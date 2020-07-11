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
