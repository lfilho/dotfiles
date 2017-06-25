# ZSH

Think of Zsh as a more awesome bash without having to learn anything new.
Automatic spell correction for your commands, syntax highlighting, and more.
We've also provided lots of enhancements:

* Vim mode and bash style <kbd>Ctrl</kbd>-<kbd>R</kbd> for reverse history finder
* <kbd>Ctrl</kbd>-<kbd>x</kbd>,<kbd>Ctrl</kbd>-<kbd>l</kbd> to insert output of last command
* Fuzzy matching - if you mistype a directory name, tab completion will fix it
* [fasd](https://github.com/clvv/fasd) integration - hit <kbd>z</kbd> and partial match for recently used directory. Tab completion enabled.
* [Prezto - the power behind YADR's zsh](http://github.com/sorin-ionescu/prezto)
* [How to add your own ZSH theme](doc/zsh/themes.md)

## Customizing ZSH with ~/.zsh.after/ and ~/.zsh.before/

If you want to customize your zsh experience, yadr provides two hooks via `~/.zsh.after/` and `~/.zsh.before/` directories.
In these directories, you can place files to customize things that load before and after other zsh customizations that come from `~/.yadr/zsh/*`

## Aliases

Lots of things we do every day are done with two or three character mnemonic aliases. Please feel free to edit them:

```bash
ae # alias edit
ar # alias reload
```

## Adding your own ZSH theme

If you want to add your own zsh theme, you can place it in `~/.zsh.prompts` and it will automatically be picked up by the prompt loader.

Make sure you follow the naming convention of `prompt_[name]_setup`

```
touch ~/.zsh.prompts/prompt_mytheme_setup
```

See also the [Prezto](https://github.com/sorin-ionescu/prezto) project for more info on themes.

## Overriding the theme

To override the theme, you can do something like this:

```
echo "prompt yourprompt" > ~/.zsh.after/prompt.zsh
```

Next time you load your shell, this file will be read and your prompt will be the youprompt prompt. Use `prompt -l` to see the available prompts.
