# Git Customizations:

YADR will take over your `~/.gitconfig`, so if you want to store your usernames or anything personal, please put them into `~/.gitconfig.user`. For example:

```
[user]
  name = "Luiz Gonzaga dos Santos Filho"
  email = lfilho@gmail.com
[github]
	user = lfilho
```

It is recommended to use this file to set your user info. Alternately, you can set the appropriate environment variables in your `~/.secrets`.

Some aliases. For the full list, check [the config file](./gitconfig).
Also note that all zsh auto adds `g` as an alias for `git` so any git command could be written in the form of `g <something>` (example: , `g status`, `g s`, `g l`, `g nb`, etc).

  * `g l` or `gl`- a much more usable git log
  * `g b` or `gb`- a list of branches with summary of last commit
  * `g r` - a list of remotes with info
  * `g t` or `gt`- a list of tags with info
  * `g nb` or `gnb`- a (n)ew (b)ranch - like checkout -b
  * `g cp` or `gcp`- cherry-pick -x (showing what was cherrypicked)
  * `g simple` - a clean format for creating changelogs
  * `g recent-branches` - if you forgot what you've been working on
  * `g unstage` / `guns` (remove from index) and `git uncommit` / `gunc` (revert to the time prior to the last commit - dangerous if already pushed) aliases
  * Some sensible default configs, such as improving merge messages, push only pushes the current branch, removing status hints, and using mnemonic prefixes in diff: (i)ndex, (w)ork tree, (c)ommit and (o)bject
  * Slightly improved colors for diff
  * `gdmb` (g)it (d)elete (m)erged (b)ranches - Deletes all branches already merged on current branch

