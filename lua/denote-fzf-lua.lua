local M = {}

local config = require("denote-fzf-lua.config")
local fzflua = require('fzf-lua')
local builtin = require("fzf-lua.previewer.builtin")

--- fzf-lua custom previewer (recombines search result fields into a filename)
M.recombine_previewer = builtin.buffer_or_file:extend()

function M.recombine_previewer:new(o, opts, fzf_win)
  M.recombine_previewer.super.new(self, o, opts, fzf_win)
  setmetatable(self, M.recombine_previewer)
  return self
end

function M.recombine_previewer:parse_entry(entry_str)
  local path = entry_str:match("([^:]+:%d%d:[^:]+):?")
  return {
    path = M.recombine_filename(path),
    line = 1,
    col = 1,
  }
end

function M.copy_table(table)
  local new_table = {}
  for k, v in pairs(table) do
    new_table[k] = v
  end
  return new_table
end

---@param force_slow bool - If true, act as if we don't have dependencies
---Check for dependencies and optional dependencies
function M.has_prereqs(force_slow)
  if vim.fn.executable('fzf') ~= 1 then return "no" end
  if force_slow                    then return "partial" end
  if vim.fn.executable('fd')  ~= 1 then return "partial" end
  if vim.fn.executable('sd')  ~= 1 then return "partial" end
  if vim.fn.executable('qsv') ~= 1 then return "partial" end
  return "yes"
end

---@param force_slow bool - If true, act as if we don't have dependencies
---Sets the full path of the appropriate search script (regular or fallback)
function M.set_script_path(force_slow)
  local lua_file_path = debug.getinfo(1, "S").source:sub(2)
  local lua_file_dir = vim.fn.fnamemodify(lua_file_path, ":h")
  local script_path = lua_file_dir .. "/denote-fzf-lua/scripts/"
  local dependencies = M.has_prereqs(force_slow)
  if dependencies == "yes" then
    script_path = script_path .. "search_files.sh"
  elseif dependencies == "partial" then
    script_path = script_path .. "fallback_search_files.sh"
  else
    error("Missing dependency: fzf")
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
      if options.search_fields[v] then
          fzf_with_nth = fzf_with_nth .. i .. ','
      end
  end
  return fzf_with_nth:sub(1, -2)
end

---@param f string - Field from search result
---@param delim delimiter character
---Puts a field from the search results back into Denote format (e.g. two words to --two-words)
function M.repopulate_field(f, delim)
  if f == "." then 
    return ""
  else
    return delim .. delim .. f:gsub("%s",delim)
  end
end

---@param filename chopped up string with fields separated by multiple spaces
function M.recombine_filename(filename)
  vim.print(filename)
  local t = {}
  filename = filename:gsub("%s%s+", "|")
  t.path, t.year, t.month, t.day, t.hour, t.min, t.sec, t.sig, t.title, t.tags, t.ext =
    filename:match("^(.*/)|(%d%d%d%d)%-(%d%d)%-(%d%d)|(%d%d):(%d%d):(%d%d)|([^|]+)|([^|]+)|([^|]+)|(%..+)")
  t.sig   = M.repopulate_field(t.sig,"=")
  t.title = M.repopulate_field(t.title,"-")
  t.tags  = M.repopulate_field(t.tags,"_")
  return t.path .. t.year .. t.month .. t.day .. "T" .. t.hour .. t.min .. t.sec .. t.sig .. t.title .. t.tags .. t.ext
end

---@param options table of user options
---Opens a window to search filenames
function M.search_files(options)
  script_path = M.set_script_path(options.force_slow_mode)
  if not script_path then return end
  local opts = {}
  opts.previewer = M.recombine_previewer
  opts.fzf_opts = M.copy_table(options.fzf_lua_opts.fzf_opts)
  opts.fzf_opts["--with-nth"] = M.format_fzf_with_nth(options)
  opts.fzf_opts['--header-lines'] = 1
  opts.fzf_opts['--delimiter'] = "\\s{2,}"
  opts.actions = {
    ['default'] = function(selected, opts)
        local filename = M.recombine_filename(selected[1])
        vim.api.nvim_command('edit ' .. filename)
      end }
  fzflua.fzf_exec(script_path .. " " .. options.dir, opts)
end

--- Performs a standard rg search
function M.search_contents(options)
  local opts = {}
  opts.cwd       = options.dir
  opts.previewer = "builtin"
  opts.fzf_opts  = options.fzf_lua_opts.fzf_opts
  opts.actions   = fzflua.defaults.actions.files
  return fzflua.fzf_live(function(q)
    return "rg --column --color=always -i -- " .. vim.fn.shellescape(q or '')
  end, opts)
end

---@param options table of user options
---Creates Neovim command :DenoteSearch
function M.load_cmd(options)
  vim.api.nvim_create_user_command("DenoteSearch", function(opts)
    if opts.fargs[1] == "files" then
      M.search_files(options)
    elseif opts.fargs[1] == "contents" then
      M.search_contents(options)
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
  options = vim.tbl_deep_extend("force", config.defaults, options or {})
  fzflua.setup(options.fzf_lua_opts)
  M.load_cmd(options)
end

return M
