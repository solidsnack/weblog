#!/bin/bash
set -o errexit -o nounset -o pipefail
function -h {
cat <<USAGE
 USAGE: lcube-local <root> <start time> <end time> <host> <app>

  Scan a local log repository, layed out for use by LCube. Files should be
  stored this way:

    <host>/<date>/<hour>:<minute>Z

  With messages in this format:

    2011-04-09T11:31:21.222222+00 a.server user.err apache[678]: webs active

  Hostnames can be given as wildcards:

    *.abc.net

USAGE
}; function --help { -h ;}

function main {
}

function lcube {
  local root="$1"
  local start="$2"
  local end="$3"
  local host="${4#.}"
  local app="$5"
  ( cd "$1"
    find . -mindepth 1 -maxdepth 1 -type d -name "$host" | while read -r dir
    do
    ( cd "$dir"
      find . -type f -mindepth 2 -maxdepth 2 |
      egrep '^[.]/....-..-../..:..Z$' |
      while read -r file
      do
        IFS=/
        set -- $file
        t="$2T$3"
        if [[ $t = $start || ($t > $start && $t < $end) || $t = $end ]]
        then cat "$file"
        fi
      done | awk -F ' ' -v prefix="$app" \
                 '{ if ( substr($4, 1, '"${#app}"') == prefix ) print }' )
    done )
}

function msg { out "$*" >&2 ;}
function err { local x=$? ; msg "$*" ; return $(( $x == 0 ? 1 : $x )) ;}
function out { printf '%s\n' "$*" ;}

if [[ ${1:-} ]] && declare -F | cut -d' ' -f3 | fgrep -qx -- "${1:-}"
then "$@"
else main "$@"
fi

