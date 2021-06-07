# add x to list to grab geometry
$(NF-1) ~ /"(id|window|name|urgent|num|floating|sticky|title_format|fullscreen_mode|marks|focused|instance|class|focus)"$/ {
  
  key=gensub(/.*"([^"]+)"$/,"\\1","g",$(NF-1))
    
  switch (key) {

    
    case "fullscreen_mode":
    case "sticky":
    case "urgent":
      ac[cid][key]=$NF
    break

    case "class":
    case "instance":
    case "title_format":
      ac[cid][key]=$NF
      if ( key == arg_target && $NF == "\"" arg_search[key] "\"" )
        suspect_targets[cid]=1
    break

    # if $NF doesnt end with ", 
    # its a comma in the name
    # use getline in that case
    case "name":
      title=gensub(/\\"/,"@@_DQ_@@","g",$NF)
      while (title ~ /[^"]$/ && title != "null") {
        getline
        title = title "," gensub(/\\"/,"@@_DQ_@@","g",$0)
      }
      title=gensub("@@_DQ_@@","\"","g",title)
      ac[cid][key]=title
      if ( key == arg_target && match(title, arg_search[key]) )
        suspect_targets[cid]=1
    break

    case "id":
      # when "nodes": (or "floating_nodes":) and "id":
      # is on the same record.
      #   example -> "nodes":[{"id":94446734049888 
      # it is the start of a branch in the tree.
      # save the last container_id as current_parent_id
      if ($1 ~ /nodes"$/) {
        current_parent_id=cid
      } else if (NR == 1) {
        root_id=$NF
      }


      # cid, "current id" is the last seen container_id
      cid=$NF
      ac[cid][key]=$NF

      if ( key == arg_target && match($NF, arg_search[key]) )
        suspect_targets[cid]=1
    break

    case "x":

      if ($1 ~ /"(deco_)?rect"/) {
        # this will add values to:
        #   ac[cid]["x"] , ["y"] , ["w"] , ["h"]
        #   ac[cid]["deco_x"] , ["deco_y"] , ["deco_w"] , ["deco_h"]
        keyprefix=($1 ~ /"deco_rect"/ ? "deco_" : "")
        while (1) {

          match($0,/"([^"])[^"]*":([0-9]+)([}])?$/,ma)
          ac[cid][keyprefix ma[1]]=ma[2]
          if (ma[3] ~ "}")
            break
          # break before getline, otherwise we will
          # miss the "deco_rect" line..
          getline
        }
      }

    break

    case "num":
      ac[cid][key]=$NF
      cwsid=cid # current workspace id
    break

    case "focused":
      ac[cid][key]=$NF
      if ($NF == "true") {
        active_container_id=cid
        active_workspace_id=cwsid
      }
      ac[cid]["workspace"]=ac[cwsid]["num"]
      ac[cid]["parent"]=current_parent_id
    break

    case "window":
      if ($NF != "null") {
        ac[cid]["window"]=$NF
        if ( key == arg_target && $NF == arg_search[key] )
          suspect_targets[cid]=1
      }
    break

    case "floating":
      ac[cid]["floating"]=$NF
    break

    case "focus":
      if ($2 != "[]") {
        # a not empty focus list is the first thing
        # we encounter after a branch. The first
        # item of the list is the focused container
        # which is of interest if the container is
        # tabbed or stacked, where only the focused container
        # is visible.
        first_id=gensub(/[^0-9]/,"","g",$2)
        parent_id=ac[first_id]["parent"]
        ac[parent_id]["focused"]=first_id

        # this restores current_parent_id  and cid 
        # to what it was before this branch.
        cid=parent_id
        current_parent_id=ac[parent_id]["parent"]
      }
    break

    case "marks":

      if ($NF == "[]") {
        ac[cid][key] = $NF
        break
      }

      if ( key == arg_target && match($NF, "\"" arg_search[key] "\"") )
        suspect_targets[cid]=1

      # ac[cid][key]="["
      while (1) {
        match($0,/"([^"]+)"([]])?$/,ma)
        ac[cid][key] = ( ac[cid][key] ? ac[cid][key] "," : "[" ) "\"" ma[1] "\""
        if (ma[2] ~ "]")
          break

        getline
      }

      ac[cid][key] = ac[cid][key] "]"

    break
  }
}
