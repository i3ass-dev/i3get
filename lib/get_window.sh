#!/bin/bash

get_window() {

  local json
  json=${__o[json]:-$(i3-msg -t get_tree)}

  awk -f <(
    echo "
    BEGIN {
      ${__o[instance]:+
        arg_target=\"instance\"
        arg_search[arg_target]=\"${__o[instance]}\"
      }
      ${__o[class]:+
        arg_target=\"class\"
        arg_search[arg_target]=\"${__o[class]}\"
      }
      ${__o[conid]:+
        arg_target=\"id\"
        arg_search[arg_target]=\"${__o[conid]}\"
      }
      ${__o[id]:+
        arg_target=\"window\"
        arg_search[arg_target]=\"${__o[id]}\"
      }
      ${__o[mark]:+
        arg_target=\"marks\"
        arg_search[arg_target]=\"${__o[mark]}\"
      }
      ${__o[title]:+
        arg_target=\"name\"
        arg_search[arg_target]=\"${__o[title]}\"
      }
      ${__o[titleformat]:+
        arg_target=\"title_format\"
        arg_search[arg_target]=\"${__o[titleformat]}\"
      }
      arg_print=\"${__o[print]:-n}\"
    }"
    awklib
  ) FS=: RS=, <<< "$json"
}
