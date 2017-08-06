#!/usr/bin/env bash

# Copyright (C) 2017 Philipp Hack <philipp.hack@gmail.com>. All Rights Reserved.
# This file is licensed under the GPLv2+. Please see COPYING for more information.

PREFIX="${NOTE_STORE_DIR:-$HOME/note-store}"
SUFFIX="${NOTE_STORE_SUFFIX:-md}"
FZF="${NOTES_VISUAL_FZF_BIN:-fzf}"
NOTES="${NOTES_VISUAL_NOTES_BIN:-notes}"

find_files() {
  (find "$PREFIX" -type f -iname \*.$SUFFIX |
  sed -e "s/\.${SUFFIX}$//" -e "s,$PREFIX/,," -e "s/\(.*\)/\x1b[33;1m\1\x1b[m ->\1/")
}

filter_lines() {
  sed -e "s/.${SUFFIX}:/:/" -e "s,$PREFIX/,," -e "s/\([^:]*\):\(.*\)/\x1b[34;1m\1\x1b[m ->\2/"
}

search_rg() {
  (find_files; rg --no-heading -L -N -v '^$' -g \*.${SUFFIX} "$PREFIX" 2>/dev/null | filter_lines)
}

search_ag() {
  (find_files; ag --nobreak --noheading -f --nonumbers -v -G .${SUFFIX}$ '^$' "$PREFIX" 2>/dev/null | filter_lines)
}

search_grep() {
  (find_files; grep -r -v "^$" "$PREFIX/"*."$SUFFIX" 2>/dev/null | filter_lines)
}

best_search() {
  local have_rg=0 have_ag=0
  command -v 'rg' &>/dev/null && have_rg=1
  command -v 'ag' &>/dev/null && have_ag=1
  if [[ $have_rg -eq 1 ]]; then
    search_rg
  elif [[ $have_ag -eq 1 ]]; then
    search_ag
  else
    search_grep
  fi
}

interactive () {
  local match line
  while read -r -d "" line; do
    match="$line"
  done < <(best_search | fzf --exact -n 2.. --ansi --tiebreak=index --print-query --reverse --no-sort --algo=v1 --no-extended --bind='tab:print-query' --print0)
  [[ ! -z $match ]] && "$NOTES" edit "${match/ ->*/}"
}

cmd_interactive_or_notes() {
  if [[ $# -eq 0  ]]; then
    interactive
  else
    "$NOTES" "$@"
  fi
}

cmd_usage() {
	cmd_version
	echo
	cat <<-_EOF
	Usage:
	    $PROGRAM
	        Search, add or edit a note.
	    $PROGRAM notes-command-args...
	        Call the notes command with the specified notes-args.
	    $PROGRAM help
	        Show this text.
	    $PROGRAM version
	        Show version information.

	More information may be found in the notes(1) man page.
	_EOF
}

cmd_version() {
	echo $PROGRAM v0.0.1
}

command -v "$FZF" &>/dev/null
[[ $? -eq 0 ]] || die "$FZF not found."

command -v "$NOTES" &>/dev/null
[[ $? -eq 0 ]] || die "$NOTES not found."

PROGRAM="${0##*/}"
COMMAND="$1"

case "$1" in
	  help|--help) shift;		cmd_usage "$@" ;;
	  version|--version) shift;	cmd_version "$@" ;;
	  *)				cmd_interactive_or_notes "$@" ;;
esac
exit 0
