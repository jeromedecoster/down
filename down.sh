#!/usr/bin/env bash

file=~/urls.txt
rars=""
nl=$'\n'



opn() {
  [[ ! -f "$file" ]] && touch "$file"
  open "$file"
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
      curl -L -n -# "$url" -o "$dir/$name"
      rars="${rars}${name}${nl}"
    else
      echo "already downloaded, skip"
    fi
  else
    echo "no filename, skip"
  fi
  echo

done < <(grep ^http "$file")


cd "$dir"
while read rar; do
  echo "unrar:$rar"
  unrar e -c- -y "$rar" *.pdf *.mkv *.avi *.mp4 | sed '/^$/d' | grep -v -i ^UNRAR
  echo
done < <(echo "$rars" | sed '/^$/d')
