--{{{ environment 
local type = type
local tostring = tostring
local table = table
local math = math
local pairs = pairs
local ipairs = ipairs
local io = io
local setmetatable = setmetatable
local getmetatable = getmetatable
local string = string
local naughty = require("naughty")
local screen = screen

module("dbg")

quiet = false
colors = {
  header = "#FF004D",
  count  = "#333333",
  index = "#553333",
  name = "#8F8870",
}
--- }}}

--{{{ function / dbg_get
function dbg_get(var, depth, indent)
  local a = ""
  local text = ""
  local name = ""
  local vtype = type(var)
  local vstring = tostring(var)

  if vtype == "table" or vtype == "userdata" then
    if vtype == "userdata" then var = getmetatable(var) end
    -- element count and longest key
    local count = 0
    local longest_key = 3
    for k,v in pairs(var) do
      count = count + 1
      longest_key = math.max(#tostring(k), longest_key)
    end
    text = text .. vstring .. " <span color='"..colors.count.."'>#" .. count .. "</span>"
    -- descend a table
    if depth > 0 then
      -- sort keys FIXME: messes up sorting number
      local sorted = {}
      for k, v in pairs(var) do table.insert(sorted, { k, v }) end
      table.sort(sorted, function(a, b) return tostring(a[1]) < tostring(b[1]) end)
      -- go through elements
      for _, p in ipairs(sorted) do
        local key = p[1]; local value = p[2]
        -- don't descend _M
        local d; if key ~= "_M" then d = depth - 1 else d = 0 end
        -- get content and add to output
        local content = dbg_get(value, d, indent + longest_key + 1)
        text = text .. '\n' .. string.rep(" ", indent) .. 
               string.format("<span color='"..colors.index.."'>%-"..longest_key.."s</span> %s",
                             tostring(key), content)
      end
    end
  elseif vtype == "tag" or vtype == "client" then
    text = text .. vstring .. " [<span color='"..colors.name.."'>" .. var.name:sub(1,10) .. "</span>]"  
  elseif vtype == "widget" and var.text then 
    text = text .. vstring .. " [<span color='"..colors.name.."'>" .. var.text:sub(1,10) .. "</span>]"  
  else
    text = text .. vstring
  end

  return text
end
-- }}}

 --{{{ function / dbg
function dbg(vars)
  if quiet then return end
  local num = table.maxn(vars)
  local text = "<span color='"..colors.header.."'>dbg</span> <span color='"..colors.count.."'>#"..num.."</span>"
  local depth = vars.d or 0

  for i = 1, num do
    local desc = dbg_get(vars[i], depth, 3)
    text = text .. string.format("\n<span color='"..colors.index.."'>%2d</span> %s", i, desc)
  end

  if vars.err then
    text = text:gsub("<.->", "").."\n===\n"
    text = text:gsub("&gt;", ">")
    text = text:gsub("&lt;", "<")
    text = text:gsub("&amp;", "&")
    io.stderr:write(text)
  else
    naughty.notify{ text = text, timeout = 0, hover_timeout = 0.05, screen = screen.count() }
  end
end
--}}}

setmetatable(_M, { __call = function (_, ...) return dbg(...) end })

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80
