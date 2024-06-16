#/usr/bin/sh
fd '^\d{8}T\d{6}(==[a-z0-9=]+)?(\-\-[a-z0-9-]+)?(__[a-z0-9_]+)?\.\w+$' $1 |\
sd '(?P<path>\/.*\/)?(?P<datetime>\d{8}T\d{6})(==(?P<sig>[a-z0-9=]+))?(--(?P<title>[a-z0-9-]+))(__(?P<tags>[a-z0-9_]+))?(?P<ext>\.\w+)' '$path,$datetime,$sig,$title,$tags,$ext' |\
tr '\=\-_' ' ' |\
sd '(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})' '$1-$2-$3,$4:$5:$6' |\
sd ',,' ',.,' |\
column -t -s "," -N Path,Date,Time,Sig,Title,Tags,Ext
# fzf --delimiter='\s{2,}' --header-lines=1 -i $2 --preview='\
# sig={4};   sig=$(echo   $sig   | sd "\W" "" | sd " " "="); if [ ! -z ${sig} ]   ; then sig="==${sig}";     fi; \
# title={5}; title=$(echo $title |              sd " " "-"); if [ ! -z ${title} ] ; then title="--${title}"; fi; \
# tags={6};  tags=$(echo  $tags  | sd "\." "" | sd " " "_"); if [ ! -z ${tags} ]  ; then tags="__${tags}";   fi; \
# ext={7}; \
# echo {1}\|{2}\|{3}\|{4}\|{5}\|{6}\|{7} | \
# sd "(?P<path>\/.*\/)?\|(?P<d1>\d\d\d\d)-(?P<d2>\d\d)-(?P<d3>\d\d)\|(?P<t1>\d\d):(?P<t2>\d\d):(?P<t3>\d\d)\|.*" "\$path\$d1\$d2\${d3}T\$t1\$t2\$t3$sig$title$tags$ext" |\
# xargs cat' \
# --bind='enter:become(\
# sig={4};   sig=$(echo   $sig   | sd "\W" "" | sd " " "="); if [ ! -z ${sig} ]   ; then sig="==${sig}";     fi; \
# title={5}; title=$(echo $title |              sd " " "-"); if [ ! -z ${title} ] ; then title="--${title}"; fi; \
# tags={6};  tags=$(echo  $tags  | sd "\." "" | sd " " "_"); if [ ! -z ${tags} ]  ; then tags="__${tags}";   fi; \
# ext={7}; \
# echo {1}\|{2}\|{3}\|{4}\|{5}\|{6}\|{7} | \
# sd "(?P<prefix>\/.*\/)?\|(?P<d1>\d\d\d\d)-(?P<d2>\d\d)-(?P<d3>\d\d)\|(?P<t1>\d\d):(?P<t2>\d\d):(?P<t3>\d\d)\|.*" "\$prefix\$d1\$d2\${d3}T\$t1\$t2\$t3$sig$title$tags$ext")+abort'
#
# I am sorry for this. If I learn an equally fast, more readable way to implement this in Lua I will.
# 1. echo table headers (for xsv)
# 2. fd all Denote files in $1 directory
# 3. sd chops the Denote filename fields into a CSV
# 4. tr replaces special characters in sig, title, and tags with spaces
# 5. sd formats the date and time as YYYY-MM-DD HH:MM:SS
# 6. sd replaces blank fields with . (ensures fzf can count fields correctly)
# 7. xsv to print the fields in tabular format
# 8. fzf the resulting table including $2 args list
# 9 fzf --delimiter breaks the table up into fields on 2+ space
#   fzf --nth and --with-nth (args passed in $2) determine which fields are shown
#   fzf --preview takes all the fzf fields {1}..{7} and recombines them into a filename, passed to cat
#   fzf --bind recombines the filename and just outputs it
