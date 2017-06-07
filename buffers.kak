def list-buffers -docstring 'populate an info box with a numbered buffers list' %{ %sh{
  bs=${kak_buflist//[^:]}
  title="${#bs} buffers"

  echo -n info -title "'" $title "'" -- %^
  index=0
  (while read -d : buf; do
    index=$(($index+1))
    if [[ "$buf" == "$kak_bufname" ]]; then
      echo "> $index - $buf"
    else
      echo "  $index - $buf"
    fi
  done) <<< "$kak_buflist"
  echo ^
} }

def -hidden -params 1 find-buffer-by-index %{ %sh{
  index=0
  (while read -d : buf; do
    index=$(($index+1))
    if [[ $index == $1 ]]; then
      echo "b $buf"
    fi
  done) <<< "$kak_buflist"
} }

# Suggested hook

#hook global WinDisplay .* list-buffers

# Suggested mappings

#map global user 1 ':find-buffer-by-index 1<ret>' -docstring 'buf 1'
#map global user 2 ':find-buffer-by-index 2<ret>' -docstring 'buf 2'
#map global user 3 ':find-buffer-by-index 3<ret>' -docstring 'buf 3'
#map global user 4 ':find-buffer-by-index 4<ret>' -docstring 'buf 4'
#map global user 5 ':find-buffer-by-index 5<ret>' -docstring 'buf 5'
#map global user 6 ':find-buffer-by-index 6<ret>' -docstring 'buf 6'
#map global user 7 ':find-buffer-by-index 7<ret>' -docstring 'buf 7'
#map global user 8 ':find-buffer-by-index 8<ret>' -docstring 'buf 8'
#map global user 9 ':find-buffer-by-index 9<ret>' -docstring 'buf 9'

