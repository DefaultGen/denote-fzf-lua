#!/usr/bin/sh
find $1 |\
sed -E "/^(.*\/)?([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9])(==[^=\-_\.]+)?(--[^\-_\.]+)?(__[^\.]+)?(\.[a-z0-9]+)$/!d" |\
sed -E "s/^(.*\/)?([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9])(==([^=\-_\.]+))?(--([^\-_\.]+))?(__([^\.]+))?(\.[a-z0-9]+)$/\1|\2|\4|\6|\8|\9/" |\
tr '\=\-_' ' ' |\
sed -E 's/([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9])T([0-9][0-9])([0-9][0-9])([0-9][0-9])/\1-\2-\3|\4:\5:\6/' |\
sed 's/||/|.|/g' |\
column -t -s "|" -N Path,Date,Time,Sig,Title,Tags,Ext |\
fzf --delimiter='\s{2,}' --header-lines=1 -i $2 --preview='\
sig={4};   sig=$(echo   $sig   | tr -d . | tr " " =); if [ ! -z ${sig} ]   ; then sig="==${sig}";     fi; \
title={5}; title=$(echo $title | tr -d . | tr " " -); if [ ! -z ${title} ] ; then title="--${title}"; fi; \
tags={6};  tags=$(echo  $tags  | tr -d . | tr " " _); if [ ! -z ${tags} ]  ; then tags="__${tags}";   fi; \
ext={7}; \
echo {1}\|{2}\|{3}\|{4}\|{5}\|{6}\|{7} |\
sed -E "s/^(.*\/)?\|([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9])\|([0-9][0-9]):([0-9][0-9]):([0-9][0-9])\|.*/\1\2\3\4T\5\6\7$sig$title$tags$ext/" |\
xargs cat' \
--bind='enter:become(\
sig={4};   sig=$(echo   $sig   | tr -d . | tr " " =); if [ ! -z ${sig} ]   ; then sig="==${sig}";     fi; \
title={5}; title=$(echo $title | tr -d . | tr " " -); if [ ! -z ${title} ] ; then title="--${title}"; fi; \
tags={6};  tags=$(echo  $tags  | tr -d . | tr " " _); if [ ! -z ${tags} ]  ; then tags="__${tags}";   fi; \
ext={7}; \
echo {1}\|{2}\|{3}\|{4}\|{5}\|{6}\|{7} | \
sed -E "s/^(.*\/)?\|([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9])\|([0-9][0-9]):([0-9][0-9]):([0-9][0-9])\|.*/\1\2\3\4T\5\6\7$sig$title$tags$ext/")+abort'

# I am sorry for this. If I learn an equally fast, more readable way to implement this in Lua I will.
# 1. find everything in directory
# 2. sed deletes every line that isn't a Denote note (can't do this with find alone because -regex can't match optional capture groups)
# 3. sed splits the Denote filename into | delimited fields
# 4. tr replaces sig, title, tags special characters with spaces
# 5. sed splits the date and time nicely
# 6. sed replaces blank fields with a period (column doesn't work with null fields)
# 7. column pretty prints the filenames in a table
# 8. fzf --delimiter breaks the table up into fields on 2+ space
#    fzf --nth and --with-nth (args passed in $2) determine which fields are shown
#    fzf --preview takes all the fzf fields {1}..{7} and recombines them into a filename, passed to cat
#    fzf --bind recombines the filename and just outputs it
