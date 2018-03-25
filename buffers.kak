# buflist++: names AND modified bool
# debug buffers (like *debug*, *lint*…) are excluded
decl -hidden str-list buffers_info

decl int buffers_total

# used to handle [+] (modified) symbol in list
def -hidden refresh-buffers-info %{
  set global buffers_info ''
  # iteration over all buffers
  eval -no-hooks -buffer * %{
    set -add global buffers_info "%val{bufname}_%val{modified}"
  }
  %sh{
    total=$(printf '%s\n' "$kak_opt_buffers_info" | tr ':' '\n' | wc -l)
    printf '%s\n' "set global buffers_total $total"
  }
}

# used to handle # (alt) symbol in list
decl str alt_bufname
decl str current_bufname
# adjust this number to display more buffers in info
decl int max_list_buffers 42

hook global WinDisplay .* %{
  set global alt_bufname %opt{current_bufname}
  set global current_bufname %val{bufname}
}

def list-buffers -docstring 'populate an info box with a numbered buffers list' %{
  refresh-buffers-info
  %sh{
    # info title
    index=0
    printf "info -title '$kak_opt_buffers_total buffers' -- %%^"
    printf '%s\n' "$kak_opt_buffers_info" | tr ':' '\n' |
    while read info; do
      # limit lists too big
      index=$(($index + 1))
      if [ "$index" -gt "$kak_opt_max_list_buffers" ]; then
        printf '  …'
        break
      fi

      name=${info%_*}
      if [ "$name" = "$kak_bufname" ]; then
        printf "> %s" "$index - $name"
      elif [ "$name" = "$kak_opt_alt_bufname" ]; then
        printf "# %s" "$index - $name"
      else
        printf "  %s" "$index - $name"
      fi

      modified=${info##*_}
      if [ "$modified" = true ]; then
        printf " [+]"
      fi
      echo
    done
    printf ^\\n
  }
}

def buffer-first -docstring 'move to the first buffer in the list' 'buffer-by-index 1'

def buffer-last -docstring 'move to the last buffer in the list' %{
  refresh-buffers-info
  buffer-by-index %opt{buffers_total}
}

def -hidden -params 1 buffer-by-index %{ %sh{
  index=0

  printf '%s\n' "$kak_buflist" | tr ':' '\n' |
  while read buf; do
    index=$(($index+1))
    if [ $index = $1 ]; then
      echo "b $buf"
    fi
  done
}}

def buffer-only -docstring 'delete all saved buffers except current one' %{ %sh{
  deleted=0

  printf '%s\n' "$kak_buflist" | tr ':' '\n' |
  while read buf; do
    if [ "$buf" != "$kak_bufname" ]; then
      echo "try 'db $buf'"
      echo "echo -markup '{Information}$deleted buffers deleted'"
      deleted=$((deleted+1))
    fi
  done
}}

def buffer-only-force -docstring 'delete all buffers except current one' %{ %sh{
  deleted=0

  printf '%s\n' "$kak_buflist" | tr ':' '\n' |
  while read buf; do
    if [ "$buf" != "$kak_bufname" ]; then
      echo "db! $buf"
      echo "echo -markup '{Information}$deleted buffers deleted'"
      deleted=$((deleted+1))
    fi
  done
}}

def buffer-only-directory -docstring 'delete all saved buffers except the ones in the same current buffer directory' %{ %sh{
  deleted=0
  current_buffer_dir=$(dirname "$kak_bufname")

  printf '%s\n' "$kak_buflist" | tr ':' '\n' |
  while read buf; do
    dir=$(dirname "$buf")
    if [ $dir != "$current_buffer_dir" ]; then
      echo "try 'db $buf'"
      echo "echo -markup '{Information}$deleted buffers deleted'"
      deleted=$((deleted+1))
    fi
  done
}}

declare-user-mode buffers

map global buffers a ga                                     -docstring 'alternate'
map global buffers b :list-buffers<ret>                     -docstring 'list'
map global buffers c ':edit<space>~/.config/kak/kakrc<ret>' -docstring 'config'
map global buffers d :delete-buffer<ret>                    -docstring 'delete'
map global buffers f :buffer<space>                         -docstring 'find'
map global buffers h :buffer-first<ret>                     -docstring 'first'
map global buffers l :buffer-last<ret>                      -docstring 'last'
map global buffers n :buffer-next<ret>                      -docstring 'next'
map global buffers o :buffer-only<ret>                      -docstring 'only'
map global buffers p :buffer-previous<ret>                  -docstring 'previous'
map global buffers s ':edit -scratch *scratch*<ret>'        -docstring '*scratch*'
map global buffers u ':buffer *debug*<ret>'                 -docstring '*debug*'

# trick to access count, 3b → display third buffer
define-command -hidden enter-buffers-mode %{ %sh{
  if [ "$kak_count" -eq 0 ]; then
    echo 'enter-user-mode buffers'
  else
    echo "buffer-by-index $kak_count"
  fi
}}

# Suggested hook

#hook global WinDisplay .* list-buffers

# Suggested mappings

#map global user b ':enter-buffers-mode<ret>'              -docstring 'buffers…'
#map global user B ':enter-user-mode -lock buffers<ret>'   -docstring 'buffers (lock)…'

# Suggested aliases

#alias global bd delete-buffer
#alias global bf buffer-first
#alias global bl buffer-last
#alias global bo buffer-only
#alias global bo! buffer-only-force
