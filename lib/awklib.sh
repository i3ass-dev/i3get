#!/usr/bin/env bash

awklib() {
target="${1:-main}"
if [[ -n ${___dir:-} ]]; then #bashbud
  if [[ $target = main ]]; then #bashbud
    find "${___dir}/awklib" -maxdepth 1 -type f -exec cat "{}" \; #bashbud
  fi #bashbud
else #bashbud


  if [[ $target = main ]]; then
cat << 'EOB'
BEGIN {hit=0;start=0;trg=0}

# set crit array
start == 0 {
  if ($0 == "__START__") {
    start = 1
  } else if (/./) {
    crit[$1]=$2
    trg++
  }
}

# "window_properties":{"class":"URxvt"

start == 1 && match($0,/([{]|"nodes":[}][[]|.*_rect":{|"window_properties":{)?"([a-z_]+)":[["]*(.+)$/,ma) {
# start == 1 && match($0,/([{]|"nodes":[}][[]|.*_rect":{)?"([a-z_]+)":[["]*([^]}"]*)[]}"]*$/,ma) {
  key=ma[2]
  if (key == "title") {
    var=gensub(/"$/,"",1,ma[3])
  }
  else {
    var=gensub(/[]}"]/,"",1,ma[3])
  }


  # on every id, check if target is found, if so exit
  # otherwise clear return array (except workspace key)
  if (key == "id") {
    if (hit == trg) exit
    cid=var
    hit=0
    for(k in r){if(k!="w"){r[k]=""}}
    if(sret ~ /[n]/)
      r["n"]=cid
  }

  if (hit!=trg) {
    for (c in crit) {
      if (key == c && var ~ crit[c]) {
        if (fid==cid) {hit++}
        else {hit=1;fid=cid}
      }
    }
  }

  if (sret ~ /[t]/ && key == "title") {
    r["t"]=gensub($1":","",1,$0)
  }
  
  if (sret ~ /[c]/ && key == "class") {
    r["c"]=var
  }
  
  if (sret ~ /[i]/ && key == "instance") {
    r["i"]=var
  }
  
  if (sret ~ /[d]/ && key == "window") {
    r["d"]=var
  }
  
  if (sret ~ /[m]/ && key == "marks") {
    r["m"]=var
  }
  
  if (sret ~ /[a]/ && key == "focused") {
    r["a"]=var
  }
  
  if (sret ~ /[o]/ && key == "title_format") {
    r["o"]=var
  }
  
  if (sret ~ /[w]/ && key == "num") {
    r["w"]=var
  }
  
  if (sret ~ /[f]/ && key == "floating") {
    r["f"]=var
  }

}

END{
  if (hit==0) exit
  split(sret, aret, "")
  for (i=1; i <= length(sret); i++) {
    op=r[aret[i]]
    gsub(/^["]|["]$/,"",op)
    if(op!="")
      printf("%s\n", op)
  }
}
EOB
  fi
fi #bashbud
}
