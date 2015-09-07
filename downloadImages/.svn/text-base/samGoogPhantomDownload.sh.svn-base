#!/bin/bash
# requires phantomjs from http://phantomjs.org/download.html
# and google-images.js

[ $# = 0 ] && { prog=`basename "$0"`;

echo >&2 "usage: $prog query count parallel safe opts timeout tries agent1 agent2
e.g. : $prog ostrich
       $prog outdir horse 100 20 on isz:l,itp:photo,ic:color, 5 10
       $prog outdir horse 100 20 on itp:photo,ic:color, 5 10"; exit 2; }       

scriptdir="$(readlink -f "`dirname "$0"`")"
dir=$1
query=$2 
count=${3:-20} 
parallel=${4:-10} 
safe=$5 
opts=$6 
timeout=${7:-10} 
tries=${8:-2}
agent1=${9:-Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.117 Safari/537.36} 
agent2=${10:-Googlebot-Image/1.0}

export PATH=$PATH:/projects/grail/santosh/softs/phantomjs-1.9.7-linux-x86_64/bin

query_esc=`perl -e 'use URI::Escape; print uri_escape($ARGV[0]);' "$query"`

#dir=`echo "$query_esc" | sed 's/%20/-/g'`-`date +%s`; mkdir "$dir" || exit 2; cd "$dir"
mkdir "$dir" ; cd "$dir"

url="http://www.google.com/search?tbm=isch&safe=$safe&tbs=$opts&q=$query_esc" procs=0
echo >.URL "$url" ; for A; do echo >>.args "$A"; done

htmlsplit() { tr '\n\r \t' ' ' | sed 's/</\n</g; s/>/>\n/g; s/\n *\n/\n/g; s/^ *\n//; s/ $//;'; }

n_scrolls=$[($count+99)/100 + 1] 
delay=1000

phantomjs "$scriptdir/google-images.js" "$url" .images.html $n_scrolls $delay
<.images.html htmlsplit |
perl -ne 'use HTML::Entities; /^<a .*?href="(.*?)"/ and print decode_entities($1), "\n";' | grep '/imgres?' |
perl -ne 'use URI::Escape; ($img, $ref) = map { uri_unescape($_) } /imgurl=(.*?)&imgrefurl=(.*?)&/;
$ext = $img; for ($ext) { s,.*[/.],,; s/[^a-z0-9].*//i; $_ ||= "img"; }
$save = sprintf("%04d.$ext", ++$i); print join("\t", $save, $img, $ref), "\n";' |
head -n "$count" |
tee -a .images.tsv |
while IFS=$'\t' read -r save img ref; do
wget -U"$agent2" -T"$timeout" --tries="$tries" --referer="$ref" -O "$save" "$img" || rm "$save" &
procs=$[$procs + 1]; [ $procs = $parallel ] && { wait; procs=0; }
done ; wait

