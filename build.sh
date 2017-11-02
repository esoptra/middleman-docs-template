#!/usr/bin/env bash
set -xe

WD=$(dirname $(realpath $0))

MDarray=(`ls $WD/*.md`)

for i in "${MDarray[@]}"
do
    if [ $i != "$WD/CHANGES.md" ] && [ $i != "$WD/README.md" ]
    then
        echo $i
        cp -f $i $WD/source
    fi
done

cd $WD/source

rename -f "s/.md/.html.md.erb/" *.md

bundle update
bundle exec middleman build
