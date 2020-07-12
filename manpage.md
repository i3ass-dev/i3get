`i3get` - prints info about a specific window to stdout

SYNOPSIS
--------
```text
i3get [--class|-c CLASS] [--instance|-i INSTANCE] [--title|-t TITLE] [--conid|-n CON_ID] [--winid|-d WIN_ID] [--mark|-m MARK] [--titleformat|-o TITLE_FORMAT] [--active|-a] [--synk|-y] [--print|-r OUTPUT] [--json TREE]      
i3get --help|-h
i3get --version|-v
```

DESCRIPTION
-----------
Search for `CRITERIA` in the output of `i3-msg -t
get_tree`, return desired information. If no
arguments are passed. `con_id` of acitve window is
returned. If there is more then one criterion, all
of them must be true to get results.


OPTIONS
-------

`--class`|`-c` CLASS  
Search for windows with the given class

`--instance`|`-i` INSTANCE  
Search for windows with the given instance

`--title`|`-t` TITLE  
Search for windows with title.

`--conid`|`-n` CON_ID  
Search for windows with the given con_id

`--winid`|`-d` WIN_ID  
Search for windows with the given window id

`--mark`|`-m` MARK  
Search for windows with the given mark

`--titleformat`|`-o` TITLE_FORMAT  
Search for windows with the given titleformat

`--active`|`-a`  
Currently active window (default)

`--synk`|`-y`  
Synch on. If this option is included,  script
will wait till target window exist. (*or timeout
after 60 seconds*).

`--print`|`-r` OUTPUT  
*OUTPUT* can be one or more of the following 
characters:  


|character | print            | return
|:---------|:-----------------|:------
|`t`         | title            | string
|`c`         | class            | string
|`i`         | instance         | string
|`d`         | Window ID        | INT
|`n`         | Con_Id (default) | INT
|`m`         | mark             | JSON list
|`w`         | workspace        | INT
|`a`         | is active        | true|false
|`f`         | floating state   | string
|`o`         | title format     | string
|`e`         | fullscreen       | 1|0
|`s`         | sticky           | true|false
|`u`         | urgent           | true|false

`--json` TREE  
Use TREE instead of the output of  
`i3-msg -t get_tree`

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit


EXAMPLES
--------
search for window with instance name
sublime_text.  Request workspace, title and
floating state.  

``` shell
$ i3get --instance sublime_text -r wtf 
1
~/src/bash/i3ass/i3get (i3ass) - Sublime Text
user_off
```

DEPENDENCIES
------------
`bash`
`gawk`
`i3`



