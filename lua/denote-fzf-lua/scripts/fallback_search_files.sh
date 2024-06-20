#!/usr/bin/sh
find $1 |\
sed -E "/^(.*\/)?([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9])(==[^=_\.\-]+)?(--[^_\.\-]+)?(__[^\.]+)?(\.[a-z0-9]+)$/!d" |\
sed -E "s/^(.*\/)?([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9])(==([^=_\.\-]+))?(--([^_\.\-]+))?(__([^\.]+))?(\.[a-z0-9]+)$/\1,\2,\4,\6,\8,\9/" |\
tr '\=\-_' ' ' |\
sed -E 's/([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9])T([0-9][0-9])([0-9][0-9])([0-9][0-9])/\1-\2-\3,\4:\5:\6/' |\
sed 's/,,/,.,/g' |\
column -t -s "," -N Path,Date,Time,Sig,Title,Keywords,Ext

# 1. find everything in directory
# 2. sed deletes every line that isn't a Denote note (can't do this with find alone because -regex can't match optional capture groups)
# 3. sed splits the Denote filename into , delimited fields (pa
# 4. tr replaces sig, title, keywords special characters with spaces
# 5. sed splits the date and time nicely
# 6. sed replaces blank fields with a period
# 7. column pretty prints the filenames in a table
