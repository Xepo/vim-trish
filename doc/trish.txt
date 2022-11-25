# vim-trish

*trish.txt* personal knowledge management in vim
*trish* 

================================================================================
#              ______   ______     __     ______     __  __                    #
#             /\__  _\ /\  == \   /\ \   /\  ___\   /\ \_\ \                   #
#             \/_/\ \/ \ \  __<   \ \ \  \ \___  \  \ \  __ \                  #
#                \ \_\  \ \_\ \_\  \ \_\  \/\_____\  \ \_\ \_\                 #
#                 \/_/   \/_/ /_/   \/_/   \/_____/   \/_/\/_/                 #
#                                                                              #
================================================================================
CONTENTS   *trish-contents*

*trish-intro* 
*trish-basic-usage*


================================================================================
INTRO *trish-intro*

Personal knowledge management, like obsidian or logseq, fully within vim.  Very fast for my notes, which has ~1500 files, working on an iPad.

Killer feature: As you're typing your notes, it'll use the preview window to show you related notes.   Anytime you hit space, it'll check if you just typed a tag, and if so, will open that note in the preview window, with backlinks.

Other features: backlinks, fast jumping, block indent/unindent, daily notes, tags are links.

Missing features compared to obsidian:
	- No images, no tables, no formatting.  The "markdown" in the filename is
	  a bit of a lie, but it means you can easily share the same notes between
	  obsidian and trish.
	- No graph view
	- No sync.  I use a combo of iCoud and git.

WARNING: I make no promises that this won't delete your entire world.  Back up everything, use git (or other services) to make sure that you can undo any changes you make through this script.  (That said, I use this script daily myself, and I've tried to use good coding habits so nothing like this will happen.  But I'm just one dev, and your setup being different than mine may make it behave weirdly)

================================================================================
BASIC USAGE *trish-basic-usage*

TODO: check if tab completion works without supertab
Requirements: vim-supertab
Optional: you probably want ctrlp or fzf or another fuzzy file searched
installed to help you jumped between files.

Use this command to get started:
:TrishSetup <dirname>

Then use <leader>t to open up your daily note for today.  Use #tagname
throughout your notes to both add links and references to concepts.  

You should probably put ephemeral information in your daily notes ("this is
what was done this day, this is what was discussed, this is the current
status" with good tags so it shows up int he addendum), and more permanent
information outside your daily notes.


================================================================================
WORKING WITH TAGS *trish-working-with-tags* 

Tags start with '#', followed by 1 or more of [a-z0-9/-].  The slash allows
you to nest tags.  #music/wilco/yankee-hotel-foxtrot is a child-tag of
#music/wilco, which is a child-tag of #music.

Tab-completion should work with existing tags.

Tags can have files associated with them, stored at basedir/tagname.md, e.g. the file for
#books/the-mind-illuminated is stored at trish-basedir/books/the-mind-illuminated.md

*trish-jumping-to-tags* 
You can jump to a tag's file using vim's standard tag navigation.  With your
cursor over the tag, hit <c-]> to jump to its file.  Use <c-t> to return to
your last location.  See vim docs for more info.

*trish-auto-preview*
When you type a tag, then hit space, trish will open up the file for that tag
in the preview window.  This allows you to quickly check what you've recently
written about that tag before you continue.  

*trish-tag-limitations*
Limitations: 
- No spaces -- didn't feel like trying to get the complicated regex working
  for tags with spaces
- no capitalization -- personal preference, since filenames are case-sensitive
  in lots of places and I wouldn't want to end up with two files that differ
  only by case
- Only roman letters.  Lemme know if you're interested in using trish but this
  is holding you back, I imagine the fix wouldn't be too hard for some
  languages at least.  Also, feel free to submit a pull request to fix this.  

*trish-non-backlinking-tags*
Instead of '#', you can use '%' to start a tag.  This will create a
non-backlinking tag.  It won't show up in the addendum, it won't pull up in the
auto-preview.  It's used purely for providing a way of jumping around your
notes (I use some in my daily notes template)

================================================================================
DAILY NOTES *trish-daily-notes*

Trish assumes you store your daily notes in a subdirectory of your notes dir
named daily.   Sorry if you use a different name.   Lemme know if this messes
you up and I can provide a flag.

<leader>t -- Today's file.  If the file doesn't exist, it'll use your daily template (see below).
<leader>p -- Go to previous file. If you're not currently in a daily file, take you to yesterday's.
<leader>n -- Go to next file. If you're not currently in a daily file, take you to tomorrow's.
#tdt expands to the tag for the current daily file.

TODO: get rid of the space in this file.
*trish-daily-template*
When trish creates a new daily file for today, it'll default to using the contents from "templates/daily template.md". If you wish to embed the current date, include the string: {{date:YYY-MM-DD}}

LIMITATIONS: templates is a barely implemented feature, but suffices for my
needs:
- The only supported template is the daily one
- You can't actually use a different date format. The replacement text it's replacing is taken from obsidian.

================================================================================
ADDENDUMS *trish-working-with-tags* 

Any time you open a markdown file in trish, it adds an addendum to the end of
the file.  This also works in auto preview (see [[trish-auto-preview]]). This addendum contains:

- Backlinks, with your daily notes backlinks sorted first
- Parent and child tags
- If on iOS, any conflicting files, see [[trish-ios-conflicts]]

This addendum is not saved with the file.  The addendum is removed before the
file is saved.

================================================================================
TAG ALIASES *trish-tag-aliases* *tag-aliases.cfg*

Trish allows you to specify aliases for tags, which will be auto-rewritten as
you type them. You can use this to make sure you always use the same tag name
for the same concept.  

Store the aliases you want in the file 'tag-aliases.cfg' in your notes directory.  trish
will read it on start-up, and reload it if you edit it within a session. The format of the file is:
#desttag #alias1 #alias2 ...

For example:
#space/jwst #space/james-webb #james-webb #jwst
#space/iss #iss #international-space-station #space/international-space-station 

Will rewrite all of those listed tags into either #space/jwst or #space/iss.

================================================================================
OUTLINING *trish-outlining*

Outliners use nested lists.  It's a decent way of organizing your
thoughts.  Trish is not a full outliner like logseq, but provides some helpers
towards it:

Indenting *trish-indenting*
Trish treats the current line, plus all subsequent lines that are indented
further, as part of the current block, and gives you a quick way of indenting
and unindenting the block. 

These work in normal mode, and in insert mode when there's whitespace before
the cursor (to prevent from interfering with tab-completion for tags):
	<Tab> - Indent current line and children lines
	<S-Tab> - Unindent current line and children lines

AUTODASH *trish-autodash* *g:trish_autodash*

Trish will add a dash for you at at the beginning of new lines, since a dash starts a list and I mostly use nested lists.  You can turn it off by setting g:trish_autodash to anything other than 'y'.

================================================================================
IOS NOTES *trish-ios-notes*

I use an iPad as my daily driver for notes, which means everything in here is
compatible with iVim. This means I didn't take advantage of some vim features
that aren't compatible with iVim. 

STORAGE *trish-ios-notes-storage*
Consider using [iexdir] to add an iCloud directory to be accessible from iVim.
Also consider using that to store your .vim elsewhere.  
I use working copy to keep history and sync my notes to other systems outside
of apple.  I have a daily shortcut that commits the entire directory.

JUMPING TO OBSIDIAN *trish-ios-jumping-to-obsidian*
In case you'd find it useful, the below mapping will let you open the current
file up in obsidian. You'll have to replace nameofvault with the name of the
vault in obsidian

:nnoremap <D-o> :exe 'iopenurl obsidian://vault/nameofvault/' . expand('%')<CR>

IOS CONFLICTS *trish-ios-conflicts*
If you store your docs on iCloud, you get sync with your phone for free, which
is pretty great.  The problem is that iCloud syncs lazily, so sometimes you'll
get conflicts if you open the file on two devices.  This causes iCloud to
put the conflicted file as 'filename 2.md', with the number increasing as it
finds more conflicts or the existing one doesn't get resolved.  This can be
super annoying.

Trish will look for these conflicts, and report it in the addendum.  Put your cursor over one of the conflicts and hit <leader>df to diff the conflicted file with your current one.

I've heard that opening the directory in the files app will force a sync.  Use
command-U to make that happen for the current file.

(If anyone knows a reliable way of making these less frequent from vim, let me
know)

================================================================================
NOTE FROM DEV *trish-note-from-dev*

I made this for me, and my particular needs.  There are some very opinionated
choices in here, and I've only really tested this on iOS and a little on
ubuntu.  I hope this all works for you.  I'm happy to do a little work to get
it to fit your particular needs, but I do have a full-time job and don't wanna
overpromise.
