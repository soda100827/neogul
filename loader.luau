-- Loader Script
-- Replace the URL below with the raw link to your src/Main.luau on GitHub

local owner = "soda100827"
local repo = "neogul"
local branch = "main"
local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/src/Main.luau", owner, repo, branch)

loadstring(game:HttpGet(url))()
