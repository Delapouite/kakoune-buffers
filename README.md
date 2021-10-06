# kakoune-buffers

[kakoune](http://kakoune.org) plugin to ease navigation between opened buffers.

## Install

Add `buffers.kak` to your autoload dir: `~/.config/kak/autoload/`.

Or via [plug.kak](https://github.com/andreyorst/plug.kak):

```
plug 'delapouite/kakoune-buffers' %{
  map global normal ^ q
  map global normal <a-^> Q
  map global normal q b
  map global normal Q B
  map global normal <a-q> <a-b>
  map global normal <a-Q> <a-B>
  map global normal b ': enter-buffers-mode<ret>' -docstring 'buffers'
  map global normal B ': enter-user-mode -lock buffers<ret>' -docstring 'buffers (lock)'
}
```

## Usage

Run the `info-buffers` command. It will display an info box with a numbered list of opened buffers.

- The current buffer is prefixed by a `>`.
- The alt buffer is prefixed by a `#` (use `ga` to reach it).
- Modified buffers are prefixed by a `+`.

If this list gets too big, decrease the `max_list_buffers` option (42 entries by default).

To jump to a specific buffer index use the `buffer-by-index n` command.
Use `buffer-first` and `buffer-last` to move to the ends of the list.
With `buffer-first-modified`, jump to the first modified buffer.

To delete all buffers except the current one, use `buffer-only` or the more destructive `buffer-only-force` version.
You can also delete all buffers except the ones in the same dir as the current buffer with `buffer-only-directory`.
## User mode

All these commands are grouped in a dedicated `buffers` user-mode.

While opened in `lock` mode, it means that you can press `p` or `n` many times to cycle through your buffers.
Press `<esc>` to leave this mode.

```
# Suggested hook

hook global WinDisplay .* info-buffers

# Suggested mappings

map global user b ':enter-buffers-mode<ret>'              -docstring 'buffers…'
map global user B ':enter-user-mode -lock buffers<ret>'   -docstring 'buffers (lock)…'

# Suggested aliases

alias global bd delete-buffer
alias global bf buffer-first
alias global bl buffer-last
alias global bo buffer-only
alias global bo! buffer-only-force
```

## More controversial mappings

Ask yourself: how often do you use macros? If you're like me, not so much thanks to all the cool interactive ways 
to accomplish a task with Kakoune. But they waste a nice spot on the `q` key! Time to free it for something else.

What about moving the `b` actions, (*moving word backward*) here instead? It makes sense on a `qwerty` keyboard.
The `q` is on the left of `w` which goes the opposite direction. The `q`, `w` and `e` actions are now finally together
just under your left hand like the 3 musketeers.

Therefore your `b` key is free and you can now use it for `buffer` actions:

```
# ciao macros
map global normal ^ q
map global normal <a-^> Q

map global normal q b
map global normal Q B
map global normal <a-q> <a-b>
map global normal <a-Q> <a-B>

map global normal b ':enter-buffers-mode<ret>'              -docstring 'buffers…'
map global normal B ':enter-user-mode -lock buffers<ret>'   -docstring 'buffers (lock)…'
```

## Screenshots

*info* displayed by the `info-buffers` command:

![info-buffers](https://raw.githubusercontent.com/delapouite/kakoune-buffers/master/list-buffers.jpg)

*info* displayed by the `buffers` user-mode:

![mode-buffers](https://raw.githubusercontent.com/delapouite/kakoune-buffers/master/mode-buffers.jpg)

## See also

- [kakoune-cd](https://github.com/Delapouite/kakoune-cd)
- [kakoune-registers](https://github.com/Delapouite/kakoune-registers)
- [explore.kak](https://github.com/alexherbo2/explore.kak)
- [ncurses implementation of a buffer list](https://github.com/mawww/kakoune/pull/1065)
- [sidetree](https://github.com/topisani/sidetree)

## Licence

MIT

Thanks a lot to [danr](https://github.com/danr) and [occivink](https://github.com/occivink)
for the original implementation: https://github.com/occivink/config/blob/master/.config/kak/buflist.kak
