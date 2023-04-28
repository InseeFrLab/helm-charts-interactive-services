#!/bin/sh
shopt -s extglob
cd charts
if [ ! -d "$file" ]; then
      "$@" "$file"
  fi
for d in *  ; do
    echo "$d"
    if [ "$d" != "library-chart" ]; then
        helm dependency update $d
        helm unittest $d -f ../../tests/*.yaml || exit 1;
    fi
done
