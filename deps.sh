#!/usr/bin/bash

for pkg in $(find $1 -name *.zst)
do
    echo '### ' $pkg
    for file in $(find-libdeps $pkg | sed 's/=.*//' | grep -v libwx)
    do
        pacman -Qo /usr/lib/$file | awk '{print $5}'
    done | sort | uniq | xargs
done
