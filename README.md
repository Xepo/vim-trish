# Vim-trish

A highly opinionated personal knowledge management plugin for vim.  Think obsidian or logseq, but within vim.  Very fast for my notes, which has ~1500 files, working on an iPad.

Killer feature: As you're typing your notes, it'll use the preview window to show you related notes.   Anytime you hit space, it'll check if you just typed a tag, and if so, will open that note in the preview window, with backlinks.

Other features: backlinks, fast jumping, block indent/unindent, daily notes, tags are links.

Missing features compared to obsidian:

* No images, no tables, no formatting.  The "markdown" in the filename is a bit of a lie, but it means you can easily share the same notes between obsidian and trish.
* No graph view
* No sync.  I use a combo of iCoud and git.
* probably others

WARNING: I make no promises that this won't delete your entire world.  Back up
everything, use git (or other services) to make sure that you can undo any
changes you make through this script.  (That said, I use this script daily
myself, and I've tried to use good coding habits so nothing like this will
happen.  But I'm just one dev, and your setup being different than mine may
make it behave weirdly)

## Installation
Like any other plugin hosted on git.  

### Manual
```bash
mkdir -p ~/.vim/pack/git-plugins/start
git clone --depth 1 https://github.com/Xepo/vim-trish.git ~/.vim/pack/git-plugins/start/vim-trish
```

### Vim-plug
You can install this plugin using [Vim-Plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Xepo/vim-trish'
```

# More info
See the [vim help docs for trish](https://github.com/Xepo/vim-trish/blob/main/doc/trish.txt).
