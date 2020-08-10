# i3get - prints info about a specific window to stdout 

USAGE
-----

Search for `CRITERIA` in the output of `i3-msg -t
get_tree`, return desired information. If no arguments are
passed, `con_id` of active window is returned. If there is
more then one criterion, all of them must be true to get
results.


OPTIONS
-------

```text
i3get [--class|-c CLASS] [--instance|-i INSTANCE] [--title|-t TITLE] [--conid|-n CON_ID] [--id|-d WIN_ID] [--mark|-m MARK] [--titleformat|-o TITLE_FORMAT] [--active|-a] [--synk|-y] [--print|-r OUTPUT] [--json TREE]      
i3get --help|-h
i3get --version|-v
```


`--class`|`-c` CLASS  
Search for windows with the given class

`--instance`|`-i` INSTANCE  
Search for windows with the given instance

`--title`|`-t` TITLE  
Search for windows with title.

`--conid`|`-n` CON_ID  
Search for windows with the given con_id

`--id`|`-d` WIN_ID  
Search for windows with the given window id

`--mark`|`-m` MARK  
Search for windows with the given mark

`--titleformat`|`-o` TITLE_FORMAT  
Search for windows with the given titleformat

`--active`|`-a`  
Currently active window (default)

`--synk`|`-y`  
Synch on. If this option is included,  script will wait
till target window exist. (*or timeout after 60 seconds*).

`--print`|`-r` OUTPUT  
*OUTPUT* can be one or more of the following  characters:  


|character | print            | return
|:---------|:-----------------|:------
|`t`         | title            | string
|`c`         | class            | string
|`i`         | instance         | string
|`d`         | Window ID        | INT
|`n`         | Con_Id (default) | INT
|`m`         | mark             | JSON list
|`w`         | workspace        | INT
|`a`         | is active        | true or false
|`f`         | floating state   | string
|`o`         | title format     | string
|`e`         | fullscreen       | 1 or 0
|`s`         | sticky           | true or false
|`u`         | urgent           | true or false

Each character in OUTPUT will be tested and the return
value will be printed on a new line. If no value is found,
`--i3get could not find: CHARACTER` will get printed.

In the example below, the target window did not have a
mark:  

```
$ i3get -r tfcmw
/dev/pts/9
user_off
URxvt
--i3get could not find: m
1
```


`--json` TREE  
Use TREE instead of the output of  
`i3-msg -t get_tree`

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit

EXAMPLES
--------

search for window with instance name sublime_text.  Request
workspace, title and floating state.  

``` shell
$ i3get --instance sublime_text --print wtf 
1
~/src/bash/i3ass/i3get (i3ass) - Sublime Text
user_off
```
## updates

### 2020.08.10

Now uses *one* (well, sometimes two ;) single regular
expression test in bash instead of parsing the json with
awk, this made the script twice as fast and also, imo,
easier to maintain and extend. I also added two new
`--print` options, `s` for sticky status, and `e` for
fullscreen status. But the most important change is done to
the `--synk` functionality, which now uses `i3-msg -t
subscribe` instead of a `while true; do sleep 10 ...`, and
it makes everything much more responsive while at the same
time being so much more efficient and nice on system
recourses. Some output is different for example "marks" will
now print the whole *JSON list* (`["mark1","mark2"...]`),
previous behavior was to only show the first mark unqouted.
If no value is found for a requested output (`--print`) a
line looking like:  
`--i3get could not find: m`  
will be printed, previous behavior was to skip the line i
think this new behavior is better especially if one relies
on the order of the output lines.




