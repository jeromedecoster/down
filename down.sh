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



extract() {
  echo "unrar:$1"
  start=`date +'%s'`
  unrar e -c- -y "$1" | sed '/^$/d' | grep -v -i ^unrar
  echo "duration:$((`date +'%s'` - $start)) seconds"
  echo
}

cd "$dir"

rars=`echo "$rars" | grep rar$ | grep -Fv ".part" && echo "$rars" | grep rar$ | grep "\.part0*1\.rar"`
echo "$rars" | while read rar; do
  extract "$rar"
done
