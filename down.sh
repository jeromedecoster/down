#!/usr/bin/env bash

file=~/urls.txt
rars=""
nl=$'\n'



opn() {
  [[ ! -f "$file" ]] && touch "$file"
  [[ -n `which open` ]] && open "$file" || xdg-open "$file"
}

[[ $# -gt 0 || ! -f "$file" || `grep -c ^http "$file"` -eq 0 ]] && opn && exit 0


list() {
  find ~ -mindepth 1 -maxdepth 1 -type d | grep -v -F /.
}

dir=`list | grep chargements$ || list | grep ownloads$`


while read url; do
  echo "url:$url"
  txt=`awk -v url="$url" '{ if ($0 == url) { printf "-" } print $0 }' < "$file"`
  echo "$txt" > "$file"

  name=`curl -L -I -n -s "$url" | grep ^Content-Disposition`
  name=${name#*\"}
  name=${name%\"*}

  if [[ -n "$name" ]]; then
    echo "name:$name"
    if [[ ! -f "$dir/$name" ]]; then
      start=`date +'%s'`
      curl -L -n -# "$url" -o "$dir/$name"
      echo "duration:$((`date +'%s'` - $start)) seconds"
      rars="${rars}${name}${nl}"
    else
      echo "already downloaded, skip"
    fi
  else
    echo "no filename, skip"
  fi
  echo

done < <(grep ^http "$file")



filter() {
  cat - | awk "{ if ($1 /rar$/ && ($1 /\.part/ == 0 || $1 /\.part0*1\./)) { print } }"
}

extract() {
  echo "unrar:$1"
  start=`date +'%s'`
  unrar e -c- -y -n*.mkv -n*.mp4 -n*.avi -n*.pdf "$rar" |
  grep -v ^All |
  grep "OK\s*$" |
  sed "s/\.\.\.       /Extracting/"
  echo "duration:$((`date +'%s'` - $start)) seconds"
  echo
}

cd "$dir"

echo "$rars" | filter | while read rar; do
  extract "$rar"
done
