# kakoune-buffers

[kakoune](http://kakoune.org) plugin to ease navigation between opened buffers.

## Install

Add `buffers.kak` to your autoload dir: `~/.config/kak/autoload/`.

## Usage

Run the `list-buffers` command. It will display an info box with a numbered list of opened buffers.

The current buffer is prefixed by a `>`. Modified buffers are suffixed by a `[+]`.

To jump to a specific buffer index use the `buffer-by-index n` command.

Use `buffer-first` and `buffer-last` to move to the ends of the list.

To delete all buffers except the current one, use `buffer-only` or the more destructive `buffer-only!` version.

All this commands are grouped in a dedicated *menu* that can be triggered with `mode-buffers`.

This *menu* has a behavior similar to the one dealing with the view (`v` key), it can be opened
in *lock* mode. When locked, it means that you can press `n` many times to successively see your buffers.
Press `<esc>` to leave this mode.

```
# Suggested hook

hook global WinDisplay .* list-buffers

# Suggested mappings

map global user b :mode-buffers<ret> -docstring 'buffers…'
map global user B ':mode-buffers lock<ret>' -docstring 'buffers (lock)…'

# Suggested aliases

alias global bf buffer-first
alias global bl buffer-last
alias global bo buffer-only
alias global bo! buffer-only!
```

## Screenshots

*info* displayed by the `list-buffers` command:

![list-buffers](https://raw.githubusercontent.com/delapouite/kakoune-buffers/master/list-buffers.jpg)

*info* displayed by the `mode-buffers` command:

![mode-buffers](https://raw.githubusercontent.com/delapouite/kakoune-buffers/master/mode-buffers.jpg)

## See also

- [kakoune-cd](https://github.com/Delapouite/kakoune-cd)
- [kakoune-registers](https://github.com/Delapouite/kakoune-registers)
- [ncurses implementation of a buffer list](https://github.com/mawww/kakoune/pull/1065)

## Licence

MIT

Thanks a lot to [danr](https://github.com/danr) and [occivink](https://github.com/occivink)
for the original implementation: https://github.com/occivink/config/blob/master/.config/kak/buflist.kak
