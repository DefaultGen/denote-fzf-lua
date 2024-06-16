local M = {}

local config = require("denote-fzf-lua.config")
local fzflua = require('fzf-lua')


--- Check for dependencies and optional dependencies
function M.has_prereqs()
  if vim.fn.executable('fzf') ~= 1 then return "no" end
  if vim.fn.executable('rg')  ~= 1 then return "no" end
  if vim.fn.executable('fd')  ~= 1 then return "partial" end
  if vim.fn.executable('sd')  ~= 1 then return "partial" end
  if vim.fn.executable('xsv') ~= 1 then return "partial" end
  return "yes"
end

---Returns the full path of the appropriate script
function M.get_script_path()
  local lua_file_path = debug.getinfo(1, "S").source:sub(2)
  local lua_file_dir = vim.fn.fnamemodify(lua_file_path, ":h")
  local script_path = lua_file_dir .. "/denote-fzf-lua/scripts/"
  local dependencies = M.has_prereqs()
  if dependencies == "yes" then
    script_path = script_path .. "search_files.sh"
  elseif dependencies == "partial" then
    script_path = script_path .. "fallback_search_files.sh"
  else
    error("Missing dependencies: fzf and rg")
    return false
  end
  return script_path
end

---@param options table of user options
---Format the --with-nth argument for fzf (which fields are shown)
function M.format_fzf_with_nth(options)
  local fzf_with_nth = ""
  local fields = {"path", "date", "time", "sig", "title", "tags", "ext" }
  for i, v in ipairs(fields) do
      if options.fzf.search_fields[v] then
          fzf_with_nth = fzf_with_nth .. i .. ','
      end
  end
  return fzf_with_nth:sub(1, -2)
end

-- TODO: This is absolutely wrecked
function M.open_file(filename)
  local t = {}
  filename = filename:gsub("%s%s+", "|")
  t.path, t.year, t.month, t.day, t.hour, t.min, t.sec, t.sig, t.title, t.tags, t.ext =
    filename:match("^(.*/)|(%d%d%d%d)%-(%d%d)%-(%d%d)|(%d%d):(%d%d):(%d%d)|([^|]+)|([^|]+)|([^|]+)|(%..+)")
  if t.sig   == "." then
    t.sig   = ""
  else
    t.sig = "==" .. t.sig:gsub("%s", "=")
  end
  if t.title == "." then
    t.title = ""
  else
    t.title = "--" .. t.title:gsub("%s", "-")
  end
  if t.tags  == "." then
    t.tags  = ""
  else
    t.tags = "__" .. t.tags:gsub("%s", "_")
  end
  local file = t.path .. t.year .. t.month .. t.day .. "T" .. t.hour .. t.min .. t.sec .. t.sig .. t.title .. t.tags .. t.ext
  vim.api.nvim_command('edit ' .. file)
end

---@param options table of user options
---Opens a window to search filenames
function M.files(options)
  local script_path = M.get_script_path()
  if not script_path then return end
  options.fzf.opts["--with-nth"] = M.format_fzf_with_nth(options)
  fzflua.fzf_exec(script_path .. " " .. options.dir, 
    {
      preview = options.fzf.preview,
      actions = options.fzf.actions,
      fzf_opts = options.fzf.opts,
    })
  -- local fzf_args = M.format_fzf_with_nth(options) .. " " .. options.fzf.args
  -- vim.api.nvim_command('edit ' .. stdout)
end

---@param options table of user options
function M.load_cmd(options)
  vim.api.nvim_create_user_command("DenoteSearch", function(opts)
    if opts.fargs[1] == "files" then
      M.files(options)
    elseif opts.fargs[1] == "contents" then
      M.conents(options)
    else
      error("Unsupported operation " .. opts.fargs[1])
    end
  end, {
    nargs = 1,
    complete = function()
      return {"files", "contents"}
    end,
  })
end

---@param options? table user configuration
function M.setup(options)
  config.options = vim.tbl_deep_extend("force", config.defaults, options or {})
  M.load_cmd(config.options)
end

return M
