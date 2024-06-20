local M = {}

local config = require("denote-fzf-lua.config")
local fzflua = require('fzf-lua')

---@param options table of user options
--- Check for dependencies and optional dependencies
function M.has_prereqs(options)
  if vim.fn.executable('fzf') ~= 1 then return "no" end
  if options.force_slow_mode       then return "partial" end
  if vim.fn.executable('fd')  ~= 1 then return "partial" end
  if vim.fn.executable('sd')  ~= 1 then return "partial" end
  if vim.fn.executable('qsv') ~= 1 then return "partial" end
  return "yes"
end

---@param options table of user options
--- Sets the full path of the appropriate search script (regular or fallback)
function M.set_script_path(options)
  local lua_file_path = debug.getinfo(1, "S").source:sub(2)
  local lua_file_dir = vim.fn.fnamemodify(lua_file_path, ":h")
  local script_path = lua_file_dir .. "/denote-fzf-lua/scripts/"
  local dependencies = M.has_prereqs(options)
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
      if options.fzf.search_fields[v] then
          fzf_with_nth = fzf_with_nth .. i .. ','
      end
  end
  return fzf_with_nth:sub(1, -2)
end

---@param filename chopped up string with fields separated by |
function M.recombine_filename(filename)
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
  return t.path .. t.year .. t.month .. t.day .. "T" .. t.hour .. t.min .. t.sec .. t.sig .. t.title .. t.tags .. t.ext
end

--- Sets fzf preview to bat or cat depending on program availability
function M.set_preview_program()
  if vim.fn.executable('bat') == 1 then
    return "xargs bat -p --color=always"
  else
    return "xargs cat"
  end
end

-- Sets fzf preview for contents search. $file is the filename, $line is the rg match line.
function M.set_rg_preview()
  if vim.fn.executable('bat') == 1 then
    return "bat $file -p --color=always --highlight-line=$line"
  else
    return "cat $file"
  end
end

---@param options table of user options
---Opens a window to search filenames
function M.search_files(options)
  script_path = M.set_script_path(options)
  if not script_path then return end
  options.fzf.opts["--with-nth"] = M.format_fzf_with_nth(options)
  options.fzf.opts['--header-lines'] = 1
  fzflua.fzf_exec(script_path .. " " .. options.dir, 
    {
      preview = options.fzf.preview .. M.set_preview_program(),
      -- selected[1] is the chopped up filename with 2+ spaces between fields
      actions = { ['default'] = function(selected, opts)
          local filename = M.recombine_filename(selected[1])
          vim.api.nvim_command('edit ' .. filename)
        end},
      fzf_opts = options.fzf.opts,
    })
end

---@param f string returned from rg. "/path/filename:line..."
function M.open_file_at_line(f)
  local filename, line = f:match("^(.-):(%d+)")
  vim.api.nvim_command('edit +' .. line .. " " .. filename)
end

---@param options table
function M.search_contents(options)
  local r = fzflua.fzf_live("rg " .. options.rg.opts .. " -- <query> " .. options.dir .. " 2>/dev/null",
    {
      preview = options.rg.fzf.preview .. M.set_rg_preview(),
      actions = { ['default'] = function(selected, opts)
        local filename_line = selected[1]
        filename_line = filename_line .. ":1" --Default :1 in case no line returned
        M.open_file_at_line(filename_line)
      end},
      fzf_opts = options.rg.fzf.opts,
    })
end

function M.search2(options)
  opts = {}
  opts.prompt = "> "
  opts.actions = fzflua.defaults.actions.files
  opts.previewer = "builtin"
  opts.cwd = options.dir
  opts.fzf_opts = options.rg.fzf.opts
  return fzflua.fzf_live(function(q)
    return "rg --column --color=always -- " .. vim.fn.shellescape(q or '')
  end, opts)
end

---@param options table of user options
---Creates Neovim command :DenoteSearch
function M.load_cmd(options)
  vim.api.nvim_create_user_command("DenoteSearch", function(opts)
    if opts.fargs[1] == "files" then
      M.search_files(options)
    elseif opts.fargs[1] == "contents" then
      M.search2(options)
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
  fzflua.setup({ winopts = options.winopts })
  M.load_cmd(options)
end

return M
