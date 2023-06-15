## AWK cheatsheet

Enumerate lines. NR is a line number. There is also an FNR variable, which is a line number within a file (while NR is a
global line number)
```shell
awk '{print NR "\t" $0}'
```

Skip the first line. AWK accepts sequences of pattern-actions. Here, NR > 1 is a pattern, and $0 is the current line
```shell
awk 'NR > 1 {print $0}'
```

If there's no action, then {print} action is the default. This is the same as the previous recipe
```shell
awk 'NR > 1'
```

printf is available
```shell
awk '{printf("%s\n", $0)}'
```

Regular expressions are available. This prints the number of lines matching the /ab/ pattern
```shell
awk '/ab/ {x++}; END {print x}'
```

Print the number of lines not matching the /ab/ pattern
```shell
awk '!/ab/ {x++}; END {print x}'
```

Regexes support | and (.*) etc
```shell
awk '/ab|cd/ {x++}; END {print x}'
```

You can assign values to fields. Here's how to remove the second field from each line
```shell
awk '{$2 = ""; print}'
```

Print lines that have a length greater than 4
```shell
awk 'length > 4'
```

You can set a field separator and print only lines that have a number of fields greater than 1
```shell
awk -F ':' 'NF > 1'
```

Patterns support the 'or' statement via ||
```shell
awk 'NR==1 || NR==2'
```

You can match any field on a regular expression
```shell
awk '$2 ~ /ab/''
```

… or don't match
```shell
awk '$2 !~ /ab/'
```