-- init.lua — plugin setup that runs at startup.
-- Replaces ranger's `set vcs_aware true` / `vcs_backend_git enabled`
-- (rc.conf) with the official git status plugin (installed via `ya pkg`,
-- see package.toml). Fetcher registration lives in yazi.toml.
require("git"):setup()
