# kakoune-buffers

[kakoune](http://kakoune.org) plugin to ease navigation between opened buffers.

## Install

Add `buffers.kak` to your autoload dir: `~/.config/kak/autoload/`.

## Usage

Run the `list-buffers` command. It will display an info box with a numbered list of opened buffers.

Use `buffer-first` and `buffer-last` to move to the ends of the list.

To delete all buffers except the current one, use `buffer-only` or the more destructive `buffer-only!` version.

```
# Suggested hook

hook global WinDisplay .* list-buffers

# Suggested mappings

map global user 1 ':find-buffer-by-index 1<ret>' -docstring 'buf 1'
map global user 2 ':find-buffer-by-index 2<ret>' -docstring 'buf 2'
map global user 3 ':find-buffer-by-index 3<ret>' -docstring 'buf 3'
map global user 4 ':find-buffer-by-index 4<ret>' -docstring 'buf 4'
map global user 5 ':find-buffer-by-index 5<ret>' -docstring 'buf 5'
map global user 6 ':find-buffer-by-index 6<ret>' -docstring 'buf 6'
map global user 7 ':find-buffer-by-index 7<ret>' -docstring 'buf 7'
map global user 8 ':find-buffer-by-index 8<ret>' -docstring 'buf 8'
map global user 9 ':find-buffer-by-index 9<ret>' -docstring 'buf 9'

# Suggested aliases

alias global bf buffer-first
alias global bl buffer-last
alias global bo buffer-only
alias global bo! buffer-only!

# Suggested menu

map global user b :mode-buffers<ret> -docstring 'buffers…'

def -hidden mode-buffers %{
  info -title 'buffers' \
%{a: alternate
b: list
d: delete
f: find
h: first
l: last
o: only
n: next
p: previous}
  on-key %{ %sh{
    case $kak_key in
      a) echo exec 'ga' ;;
      b) echo list-buffers ;;
      d) echo delete-buffer ;;
      f) echo exec ':buffer<space>' ;;
      h) echo buffer-first ;;
      l) echo buffer-last ;;
      o) echo buffer-only ;;
      n) echo buffer-next ;;
      p) echo buffer-previous ;;
      *) echo nop ;;
    esac
  }}
}

```

## Screenshot

![screenshot](https://raw.githubusercontent.com/delapouite/kakoune-buffers/master/screenshot.jpg)

## See also

- [kakoune-cd](https://github.com/Delapouite/kakoune-cd)
- [kakoune-registers](https://github.com/Delapouite/kakoune-registers)

## Licence

MIT

Thanks a lot to @danr for the original implementation: https://gist.github.com/danr/e69a55129a3fd27f1f098d4e167afccd
