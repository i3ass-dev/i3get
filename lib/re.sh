makeexpression() {

local mark
mark='("marks":(\[[^]]*\]),)?'
[[ -n ${_c[mark]} ]] \
  && mark="(\"marks\":(\[[^]]*\"${_c[mark]}\"[^]]*\]),)"

cat << EOB
"id":(${_c[conid]:-"[0-9]+"}),
[^{]+
${mark}
"focused":(${_c[active]}),
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
}
