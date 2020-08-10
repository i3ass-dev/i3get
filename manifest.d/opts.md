# options-help-description
Show help and exit.

# options-version-description
Show version and exit

# options-active-description
Currently active window (default)

# options-class-description
Search for windows with the given class

# options-instance-description
Search for windows with the given instance

# options-title-description
Search for windows with title.

# options-conid-description
Search for windows with the given con_id

# options-id-description
Search for windows with the given window id

# options-mark-description
Search for windows with the given mark

# options-titleformat-description
Search for windows with the given titleformat

# options-json-description
Use TREE instead of the output of  
`i3-msg -t get_tree`

# options-synk-description
Synch on. If this option is included, 
script will wait till target window exist. (*or timeout after 60 seconds*).

# options-print-description
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
|`a`         | is active        | true or false
|`f`         | floating state   | string
|`o`         | title format     | string
|`e`         | fullscreen       | 1 or 0
|`s`         | sticky           | true or false
|`u`         | urgent           | true or false

Each character in OUTPUT will be tested and the return value will be printed on a new line. If no value is found, `--i3get could not find: CHARACTER` will get printed.

In the example below, the target window did not have a mark:  

```
$ i3get -r tfcmw
/dev/pts/9
user_off
URxvt
--i3get could not find: m
1
```

