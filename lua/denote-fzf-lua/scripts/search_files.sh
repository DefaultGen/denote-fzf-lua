#/usr/bin/sh
(echo "Path,Date,Time,Sig,Title,Keywords,Ext";
fd '^\d{8}T\d{6}(==[a-z0-9=]+)?(\-\-[a-z0-9-]+)?(__[a-z0-9_]+)?\.\w+$' $1 |\
sd '(?P<path>\/.*\/)?(?P<datetime>\d{8}T\d{6})(==(?P<sig>[a-z0-9=]+))?(--(?P<title>[a-z0-9-]+))(__(?P<keywords>[a-z0-9_]+))?(?P<ext>\.\w+)' '$path,$datetime,$sig,$title,$keywords,$ext' |\
tr '\=\-_' ' ' |\
sd '(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})' '$1-$2-$3,$4:$5:$6') |\
sd ',,' ',.,' |\
qsv table

# 1. echo the table headers
# 2. fd only Denote files in $1 directory (and subdirectories)
# 3. sd chops the Denote filename fields into a CSV
# 4. tr replaces special characters in sig, title, and keywords with spaces
# 5. sd formats the date and time as YYYY-MM-DD HH:MM:SS
# 6. sd replaces blank fields with . (fzf can't handle blank fields)
# 7. qsv to print the fields in tabular format
