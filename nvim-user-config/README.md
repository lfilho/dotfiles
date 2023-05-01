# What's included, How to learn? etc

Browse the `plugins/*.vim` files to see which plugins we have.

Files in `nvim/settings` are our configurations or customizations.
- `nvim/settings/plugin-*.vim` are configs for a specific plugin.
- `nvim/settings/vim-*.vim` are general vim configs.
- Whatever you **don't** see in the above files (or if a plugin doesn't have a correspondent file in there) means that we use that plugin's (or vim's) defaults.

If you are having an unexpected behavior, wondering why a particular key works the way it does, use: `:map [keycombo]` (e.g. `:map <C-\>`) to see what the key is mapped to. For bonus points, you can see where the mapping was set by using `:verbose map [keycombo]`. If you omit the key combo, you'll get a list of all the maps. You can do the same thing with `nmap`, `imap`, `vmap`, etc.

## How to customize

You can place any number of `*.vim` files inside the folders `before` and `after` in the `settings` dir. They'll be loaded, accordingly, before or after the main installation and configuration steps.
If you think something could benefit everybody, feel free to open a Pull Request.

## Search/Code Navigation

 * <kbd>,</kbd><kbd>f</kbd> - instantly Find definition of class (must have exuberant ctags installed)
 * <kbd>,</kbd><kbd>F</kbd> - same as <kbd>,</kbd><kbd>f</kbd> but in a vertical split
 * <kbd>,</kbd><kbd>g</kbd><kbd>f</kbd> or <kbd>Ctrl</kbd>-<kbd>f</kbd> - same as vim normal gf (go to file), but in a vertical split (works with file.rb:123 line numbers also)
 * <kbd>g</kbd><kbd>F</kbd> - standard vim mapping, here for completeness (go to file at line number)
 * <kbd>K</kbd> - Search the current word under the cursor and show results in quickfix window
 * <kbd>,</kbd><kbd>K</kbd> - Grep the current word up to next exclamation point (useful for ruby foo! methods)
 * <kbd>Cmd</kbd>-<kbd>\*</kbd> - highlight all occurrences of current word (similar to regular <kbd>\*</kbd> except doesn't move)
 * <kbd>,</kbd><kbd>h</kbd><kbd>l</kbd> - toggle search highlight on and off
 * <kbd>,</kbd><kbd>g</kbd><kbd>g</kbd> or <kbd>,</kbd><kbd>r</kbd><kbd>g</kbd> - Grep command line, type between quotes. Uses RipGrep.
 * After searching with <kbd>,</kbd><kbd>g</kbd><kbd>g</kbd> you can navigate the results with <kbd>Ctrl</kbd>-<kbd>x</kbd> <kbd>a</kbd>nd <kbd>Ctrl</kbd>-<kbd>z</kbd> (or standard vim `:cn` and `:cp`)
 * <kbd>,</kbd><kbd>g</kbd><kbd>d</kbd> - Grep def (greps for 'def [function name]') when cursor is over the function name
 * <kbd>,</kbd><kbd>g</kbd><kbd>c</kbd><kbd>f</kbd> - Grep Current File to find references to the current file
 * <kbd>/</kbd><kbd>/</kbd> - clear the search
 * <kbd>,</kbd><kbd>,</kbd><kbd>w</kbd> (alias <kbd>,</kbd><kbd>esc</kbd>) or <kbd>,</kbd><kbd>,</kbd><kbd>b</kbd> (alias <kbd>,</kbd><kbd>shift</kbd><kbd>esc</kbd>) - EasyMotion, a vimium/vimperator style tool that highlights jump-points on the screen and lets you type to get there.
 * <kbd>,</kbd><kbd>m</kbd><kbd>c</kbd> - mark this word for MultiCursor (like sublime). Use Ctrl-n (next), Ctrl-p (prev), Ctrl-x(skip) to add more cursors, then do normal vim things like edit the word.
 * <kbd>g</kbd><kbd>K</kbd> - Opens the documentation for the word under the cursor.
 * <kbd>Space</kbd> - Sneak - type two characters to move there in a line. Kind of like vim's <kbd>f</kbd> <kbd>b</kbd>ut more accurate.
 * `:Gsearch foo` - global search, then do your normal `%s/search/replace/g` and follow up with `:Greplace` to replace across all files. When done use `:wall` to write all the files.

## Better keystrokes for common editing commands

 * <kbd>Tab</kbd> for snipmate snippets.
 * <kbd>,</kbd><kbd>#</kbd>,<kbd>,</kbd><kbd>"</kbd>,<kbd>,</kbd><kbd>'</kbd>,<kbd>,</kbd><kbd>]</kbd>,<kbd>,</kbd><kbd>)</kbd>,<kbd>,</kbd><kbd>}</kbd> to surround a word in these common wrappers. the <kbd>#</kbd> does `#{ruby interpolation}`. works in visual mode (thanks @cj). Normally these are done with something like <kbd>y</kbd><kbd>s</kbd><kbd>w</kbd><kbd>#</kbd>
 * <kbd>Cmd</kbd>-<kbd>'</kbd>, <kbd>Cmd</kbd>-<kbd>"</kbd>, <kbd>Cmd</kbd>-<kbd>]</kbd>, <kbd>Cmd</kbd>-<kbd>)</kbd>, etc to change content inside those surrounding marks. You don't have to be inside them (<kbd>Alt</kbd> in Linux)
 * <kbd>,</kbd><kbd>.</kbd> to go to last edit location (same as <kbd>'</kbd><kbd>.</kbd>) because the apostrophe is hard on the pinky
 * <kbd>,</kbd><kbd>c</kbd><kbd>i</kbd> to change inside any set of quotes/brackets/etc

## Tabs, Windows, Splits

 * Use <kbd>Cmd</kbd>-<kbd>1</kbd> thru <kbd>Cmd</kbd>-<kbd>9</kbd> to switch to a specific tab number (like iTerm and Chrome) - and tabs have been set up to show numbers (<kbd>Alt</kbd> in Linux)
 * <kbd>Ctrl</kbd>-<kbd>h,l,j,k</kbd> - to move left, right, down, up between splits. This also works between vim and tmux splits thanks to `vim-tmux-navigator`.
 * <kbd>Q</kbd> - Intelligent Window Killer. Close window `wincmd c` if there are multiple windows to same buffer, or kill the buffer `bwipeout` if this is the last window into it.
 * <kbd>v</kbd><kbd>v</kbd> - vertical split (<kbd>Ctrl</kbd>-<kbd>w</kbd>,<kbd>v</kbd>)
 * <kbd>s</kbd><kbd>s</kbd> - horizontal split (<kbd>Ctrl</kbd>-<kbd>w</kbd>,<kbd>s</kbd>)
 * <kbd>,</kbd><kbd>q</kbd><kbd>o</kbd> - open quickfix window (this is where output from Grep goes)
 * <kbd>,</kbd><kbd>q</kbd><kbd>c</kbd> - close quickfix

## Utility

 * <kbd>Ctrl</kbd>-<kbd>p</kbd> after pasting - Use <kbd>p</kbd> to paste and <kbd>Ctrl</kbd>-<kbd>p</kbd> to cycle through previous pastes. Provided by YankRing.
 * <kbd>,</kbd><kbd>y</kbd><kbd>r</kbd> - view the yankring - a list of your previous copy commands. also you can paste and hit <kbd>ctrl</kbd>-<kbd>p</kbd> for cycling through previous copy commands
 * <kbd>c</kbd><kbd>r</kbd><kbd>s</kbd>, <kbd>c</kbd><kbd>r</kbd><kbd>c</kbd>, <kbd>c</kbd><kbd>r</kbd><kbd>u</kbd> via abolish.vim, coerce to snake_case, camelCase, and UPPERCASE. There are more `:help abolish`
 * <kbd>,</kbd><kbd>i</kbd><kbd>g</kbd> - toggle visual indentation guides
 * <kbd>,</kbd><kbd>c</kbd><kbd>f</kbd> - Copy Filename of current file (full path) into system (not vi) paste buffer
 * <kbd>,</kbd><kbd>c</kbd><kbd>n</kbd> - Copy Filename of current file (name only, no path)
 * <kbd>,</kbd><kbd>y</kbd><kbd>w</kbd> - yank a word from anywhere within the word (so you don't have to go to the beginning of it)
 * <kbd>,</kbd><kbd>o</kbd><kbd>w</kbd> - overwrite a word with whatever is in your yank buffer - you can be anywhere on the word. saves having to visually select it
 * <kbd>,</kbd><kbd>o</kbd><kbd>c</kbd><kbd>f</kbd> - open changed files (stolen from @garybernhardt). open all files with git changes in splits
 * <kbd>,</kbd><kbd>w</kbd> - strip trailing whitespaces
 * <kbd>s</kbd><kbd>j</kbd> - split a line such as a hash {:foo => {:bar => :baz}} into a multiline hash (j = down)
 * <kbd>s</kbd><kbd>k</kbd> - unsplit a link (k = up)
 * <kbd>,</kbd><kbd>h</kbd><kbd>e</kbd> - Html Escape
 * <kbd>,</kbd><kbd>h</kbd><kbd>u</kbd> - Html Unescape
 * <kbd>,</kbd><kbd>h</kbd><kbd>p</kbd> - Html Preview (open in Safari)
 * <kbd>Cmd</kbd>-<kbd>Shift</kbd>-<kbd>A</kbd> - align things (type a character/expression to align by, works in visual mode or by itself) (<kbd>Alt</kbd> in Linux)
 * `:ColorToggle` - turn on #abc123 color highlighting (useful for css)
 * `:Gitv` - Git log browsers
 * <kbd>,</kbd><kbd>h</kbd><kbd>i</kbd> - show current Highlight group. if you don't like the color of something, use this, then use `hi! link [groupname] [anothergroupname]` in your vimrc.after to remap the color. You can see available colors using `:hi`
 * <kbd>,</kbd><kbd>g</kbd><kbd>t</kbd> - Go Tidy - tidy up your html code (works on a visual selection)
 * `:Wrap` - wrap long lines (e.g. when editing markdown files)
 * <kbd>Cmd</kbd>-<kbd>/</kbd> - toggle comments (usually gcc from tComment) (`Alt` in Linux)
 * <kbd>g</kbd><kbd>c</kbd><kbd>p</kbd> (comment a paragraph)

## Vim Dev

 * <kbd>,</kbd><kbd>v</kbd><kbd>c</kbd> - (Vim Command) copies the command under your cursor and executes it in vim. Great for testing single line changes to vimrc.
 * <kbd>,</kbd><kbd>v</kbd><kbd>r</kbd> - (Vim Reload) source current file as a vim file
