-- fasd.yazi — jump to a frecent file or directory via `fasd` + `fzf`.
--
-- This replaces ranger's `fzf_fasd` command (ranger/commands.py), which was
-- bound to `zz` and ran:
--   fasd | fzf -e -i --tac --no-sort | awk '{print $2}'
-- then `cd`'d into the result if it was a directory, or selected it if a
-- file. This setup already depends on `fasd` (see zsh/fzf.zsh's `z()`), so
-- this plugin keeps using it rather than introducing zoxide as a new tool.
--
-- Structurally adapted from Yazi's builtin zoxide.lua:
-- https://github.com/sxyazi/yazi/blob/main/yazi-plugin/preset/plugins/zoxide.lua
--
-- Bound to `Z` in keymap.toml (overriding the stock `plugin zoxide` binding,
-- since zoxide isn't part of this setup).

local M = {}

function M:entry()
	local permit = ui.hide()
	local kind, target, err = M.run()
	permit:drop()

	if err then
		ya.notify { title = "Fasd", content = tostring(err), timeout = 5, level = "error" }
	elseif kind == "d" then
		ya.emit("cd", { target, raw = true })
	elseif kind == "f" then
		ya.emit("reveal", { target, raw = true })
	end
end

---@return string?, string?, Error?
function M.run()
	-- `fasd` lists frecent files/dirs; `fzf` filters them interactively;
	-- `awk` extracts the path column. Prefix the winner with d:/f: so we
	-- know whether to `cd` or `reveal` it, without a second subprocess.
	local script = [[
		p=$(fasd | fzf -e -i --tac --no-sort | awk '{print $2}')
		[ -n "$p" ] || exit 0
		if [ -d "$p" ]; then printf 'd:%s' "$p"; else printf 'f:%s' "$p"; fi
	]]

	local child, err = Command("sh")
		:arg({ "-c", script })
		:env("CLICOLOR", 1)
		:env("CLICOLOR_FORCE", 1)
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return nil, nil, Err("Failed to start `fasd`/`fzf`, error: %s", err)
	end

	local output, err = child:wait_with_output()
	if not output then
		return nil, nil, Err("Cannot read `fasd`/`fzf` output, error: %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, nil, Err("`fasd`/`fzf` exited with code %s: %s", output.status.code, output.stderr)
	end

	local kind, target = output.stdout:match("^(%a):(.*)$")
	return kind, target, nil
end

return M
