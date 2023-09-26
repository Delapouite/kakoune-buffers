# buflist++: names AND modified bool
# debug buffers (like *debug*, *lint*…) are excluded
declare-option -hidden str-to-str-map buffers_info

declare-option int buffers_total

# keys to use for buffer picking
declare-option str buffer_keys "1234567890qwertyuiopasdfghjklzxcvbnm"

# used to handle [+] (modified) symbol in list
define-command -hidden refresh-buffers-info %{
  set-option global buffers_info
  set-option global buffers_total 0
  # iteration over all buffers (except debug ones)
  evaluate-commands -no-hooks -buffer * %{
    set-option -add global buffers_info "%val{bufname}=%val{modified}"
  }
  evaluate-commands %sh{
    total=$(printf '%s\n' "$kak_opt_buffers_info" | tr ' ' '\n' | wc -l)
    printf "set-option global buffers_total $total"
  }
}

# used to handle # (alt) symbol in list
declare-option str alt_bufname
declare-option str current_bufname
# adjust this number to display more buffers in info
declare-option int max_list_buffers 42

hook global WinDisplay .* %{
  set-option global alt_bufname %opt{current_bufname}
  set-option global current_bufname %val{bufname}
}

define-command info-buffers -docstring 'populate an info box with a numbered buffers list' %{
  refresh-buffers-info
  evaluate-commands %sh{
    # info title
    printf "info -title '$kak_opt_buffers_total buffers' -- %%^"

    index=0
    eval "set -- $kak_quoted_opt_buffers_info"
    while [ "$1" ]; do
      # limit lists too big
      index=$((index + 1))
      if [ "$index" -gt "$kak_opt_max_list_buffers" ]; then
        printf '  …'
        break
      fi

      name=${1%=*}
      if [ "$name" = "$kak_bufname" ]; then
        printf '>'
      elif [ "$name" = "$kak_opt_alt_bufname" ]; then
        printf '#'
      else
        printf ' '
      fi

      modified=${1##*=}
      if $modified; then
        printf '+ %.2d - %s\n' "$index" "$name"
      else
        printf '  %.2d - %s\n' "$index" "$name"
      fi

      shift
    done
    printf '^\n'
  }
}

declare-user-mode pick-buffers
define-command pick-buffers -docstring 'enter buffer pick mode' %{
  refresh-buffers-info
  unmap global pick-buffers
  evaluate-commands %sh{
    docstring() {
      if $1; then
        printf "%s+ %s" "$2" "$3"
      else
        printf "%s  %s" "$2" "$3"
      fi
    }
    index=0
    eval "set -- $kak_quoted_opt_buffers_info"
    while [ "$1" ]; do
      # limit lists too big
      index=$((index + 1))
      if [ $index -gt ${#kak_opt_buffer_keys} ]; then
        break
      fi

      key=$(echo ${kak_opt_buffer_keys} | cut -c${index})
      name=${1%=*}
      modified=${1##*=}
      if [ "$name" = "$kak_bufname" ]; then
        printf "map global pick-buffers %s ': buffer-by-index %s<ret>' -docstring '%s'\n" $key $index "$(docstring $modified '>' "$name")"
      elif [ "$name" = "$kak_opt_alt_bufname" ]; then
        printf "map global pick-buffers %s ': buffer-by-index %s<ret>' -docstring '%s'\n" $key $index "$(docstring $modified '#' "$name")"
      else
        printf "map global pick-buffers %s ': buffer-by-index %s<ret>' -docstring '%s'\n" $key $index "$(docstring $modified ':' "$name")"
      fi

      shift
    done
  }
  enter-user-mode pick-buffers
}

define-command buffer-first -docstring 'move to the first buffer in the list' 'buffer-by-index 1'

define-command buffer-last -docstring 'move to the last buffer in the list' %{
  buffer-by-index %opt{buffers_total}
}

define-command -hidden -params 1 buffer-by-index %{
  refresh-buffers-info
  evaluate-commands %sh{
    target=$1
    index=0
    eval "set -- $kak_quoted_opt_buffers_info"
    while [ "$1" ]; do
      index=$((index+1))
      name=${1%=*}
      if [ $index = $target ]; then
        printf "buffer '%s'\n" "$name"
      fi
      shift
    done
  }
}

define-command buffer-first-modified -docstring 'move to the first modified buffer in the list' %{
  refresh-buffers-info
  evaluate-commands %sh{
    eval "set -- $kak_quoted_opt_buffers_info"
    while [ "$1" ]; do
      name=${1%=*}
      modified=${1##*=}
      if $modified; then
        printf "buffer '%s'\n" "$name"
      fi
      shift
    done
  }
}

define-command delete-buffers -docstring 'delete all saved buffers' %{
  evaluate-commands %sh{
    deleted=0
    eval "set -- $kak_quoted_buflist"
    while [ "$1" ]; do
      echo "try %{delete-buffer '$1'}"
      echo "echo -markup '{Information}$deleted buffers deleted'"
      deleted=$((deleted+1))
      shift
    done
  }
}

define-command buffer-only -docstring 'delete all saved buffers except current one' %{
  evaluate-commands %sh{
    deleted=0
    eval "set -- $kak_quoted_buflist"
    while [ "$1" ]; do
      if [ "$1" != "$kak_bufname" ]; then
        echo "try %{delete-buffer '$1'}"
        echo "echo -markup '{Information}$deleted buffers deleted'"
        deleted=$((deleted+1))
      fi
      shift
    done
  }
}

define-command buffer-only-force -docstring 'delete all buffers except current one' %{
  evaluate-commands %sh{
    deleted=0
    eval "set -- $kak_quoted_buflist"
    while [ "$1" ]; do
      if [ "$1" != "$kak_bufname" ]; then
        echo "delete-buffer! '$1'"
        echo "echo -markup '{Information}$deleted buffers deleted'"
        deleted=$((deleted+1))
      fi
      shift
    done
  }
}

define-command buffer-only-directory -docstring 'delete all saved buffers except the ones in the same current buffer directory' %{
  evaluate-commands %sh{
    deleted=0
    current_buffer_dir=$(dirname "$kak_bufname")
    eval "set -- $kak_quoted_buflist"
    while [ "$1" ]; do
      dir=$(dirname "$1")
      if [ $dir != "$current_buffer_dir" ]; then
        echo "try %{delete-buffer '$1'}"
        echo "echo -markup '{Information}$deleted buffers deleted'"
        deleted=$((deleted+1))
      fi
      shift
    done
  }
}

define-command edit-kakrc -docstring 'open kakrc in a new buffer' %{
  evaluate-commands %sh{
    printf "edit $kak_config/kakrc"
  }
}

declare-user-mode buffers

map global buffers a 'ga'                             -docstring 'alternate ↔'
map global buffers b ': info-buffers<ret>'            -docstring 'info'
map global buffers c ': edit-kakrc<ret>'              -docstring 'config'
map global buffers d ': delete-buffer<ret>'           -docstring 'delete'
map global buffers D ': delete-buffers<ret>'          -docstring 'delete all'
map global buffers f ': buffer<space>'                -docstring 'find'
map global buffers h ': buffer-first<ret>'            -docstring 'first ⇐'
map global buffers l ': buffer-last<ret>'             -docstring 'last ⇒'
map global buffers m ': buffer-first-modified<ret>'   -docstring 'modified'
map global buffers n ': buffer-next<ret>'             -docstring 'next →'
map global buffers o ': buffer-only<ret>'             -docstring 'only'
map global buffers p ': buffer-previous<ret>'         -docstring 'previous ←'
map global buffers r ': rename-buffer '               -docstring 'rename'
map global buffers s ': edit -scratch *scratch*<ret>' -docstring '*scratch*'
map global buffers u ': buffer *debug*<ret>'          -docstring '*debug*'

# trick to access count, 3b → display third buffer
define-command -hidden enter-buffers-mode %{
  evaluate-commands %sh{
    if [ "$kak_count" -eq 0 ]; then
      printf 'enter-user-mode buffers'
    else
      printf "buffer-by-index $kak_count"
    fi
  }
}

# Suggested hook

#hook global WinDisplay .* info-buffers

# Suggested mappings

#map global user b ':enter-buffers-mode<ret>'              -docstring 'buffers…'
#map global user B ':enter-user-mode -lock buffers<ret>'   -docstring 'buffers (lock)…'

# Suggested aliases

#alias global bd delete-buffer
#alias global bf buffer-first
#alias global bl buffer-last
#alias global bo buffer-only
#alias global bo! buffer-only-force
