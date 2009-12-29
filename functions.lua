--{{{ functions / psgrep
function psgrep(args)
  local ret = {}
  local f = io.popen("ps ax")
  ret.header = splitbywhitespace(f:read("*l"))
  
  for line in f:lines() do
    local proc = {}
    for i, v in ipairs(splitbywhitespace(line, #ret.header)) do
      proc[ret.header[i]:lower()] = v
    end
    for k, v in pairs(args) do
      if proc[k]:find(v) then
        table.insert(ret, proc)
        break
      end
    end
  end
  if #ret > 0 then return ret end
end
--}}}

--{{{ functions / pad
function pad(var, len, char)
  local slen = #tostring(var)
  if not char then
    if type(var) == "number" then char = "0" else char = " " end
  end
  if slen < len then
    return string.rep(char, len - slen) .. var
  else
    return var
  end
end

--}}}

--{{{ functions / splitbywhitespace
function splitbywhitespace(str,cols)
    values = {}
    start = 1
    splitstart, splitend = string.find(str, ' ', start)


    while splitstart and (not cols or #values < cols - 1) do
        m = string.sub(str, start, splitstart-1)
        if m:gsub(' ','') ~= '' then
            table.insert(values, m)
        end

        start = splitend+1
        splitstart, splitend = string.find(str, ' ', start)
    end

    m = string.sub(str, start)
    if m:gsub(' ','') ~= '' then
        table.insert(values, m)
    end

    return values
end
--}}}

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80
