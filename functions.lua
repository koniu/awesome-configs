--{{{ tag+client+process manipulation
--{{{ myfocus
function myfocus(idx)
  awful.client.focus.byidx(idx)
  if awful.client.property.get(client.focus, "skip_focus") then
    myfocus(idx)
  else
    client.focus:raise()
  end
end
--}}}
--{{{ psgrep
function psgrep(args)
  local ret = {}
  local f = io.popen("ps -eo pid,uid,tname,nice,start_time,command")
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
--{{{ getclient
function getclient(prop, val)
  for i, c in ipairs(client.get()) do
    if c[prop] == val then
      return c
    end
  end
end
--}}}
--{{{ run_or_raise
function run_or_raise(cmd, prop, val)
  local c = getclient(prop, val)
  if c then
    awful.tag.viewonly(c:tags()[1])
    client.focus = c
    c:raise()
  else
    awful.util.spawn_with_shell(cmd)
  end
end
--}}}
--{{{ scrollclient
-- scrolling clients bigger than workspace
function scrollclient()
  local c = client.focus
  if not c then return end

  local ss = screen[c.screen].geometry
  local ws = screen[c.screen].workarea
  local cc = c:geometry()
  local mc = mouse.coords()
  local step = 0

  -- left edge
  if mc.x < config.scroll_offset and cc.x < 0 then
    step = math.min(config.step, -cc.x)
    awful.client.moveresize(step,0,0,0,c)
  end

  -- right edge
  if mc.x > ws.width - config.scroll_offset and cc.x + cc.width > ws.width + 1 then
    step = math.min(config.step, cc.x + cc.width-ws.width)
    awful.client.moveresize(-step,0,0,0,c)
  end

  -- top edge
  if mc.y < config.scroll_offset and cc.y < ss.height - ws.height then
    step = math.min(config.step, ss.height - ws.height - cc.y - 1) -- FIXME: -1 is for the frame to hide under panels BROKEN
    awful.client.moveresize(0,step,0,0,c)
  end

  -- bottom edge
  if mc.y > ws.height - config.scroll_offset and cc.y + cc.height > ss.height then
    step = math.min(config.step, cc.y + cc.height - ss.height)
    awful.client.moveresize(0,-step,0,0,c)
  end
end
--}}}
--{{{ terminal
-- runs terminal
function terminal(args)
  local args = args or ' -title "ba:~"'
  awful.util.spawn(config.terminal .. ' ' .. args, false)
end
--}}}
--{{{ popterm
function popterm()
  local c = getclient("instance", "popterm")
  if not c then
    terminal("-name popterm -font 6x10")
  elseif c.hidden then
    c.hidden =  false
    client.focus = c
    c:raise()
  else
    c.hidden = true
  end
end
--}}}
--{{{ taginfo
function ti()
  local t = awful.tag.selected()
  local v = ""

  v = v .. "<span font_desc=\"Verdana Bold 20\">" .. t.name .. "</span>\n"
  v = v .. tostring(t) .. "\n\n"
  v = v .. "clients: " .. #t:clients() .. "\n\n"

  local i = 1
  for op, val in pairs(awful.tag.getdata(t)) do
    if op == "layout" then val = awful.layout.getname(val) end
    if op == "keys" then val = '#' .. #val end
    v =  v .. string.format("%2s: %-12s = %s\n", i, op, tostring(val))
    i = i + 1
  end

  naughty.notify{ text = v:sub(1,#v-1), timeout = 0, margin = 10 }
end
--}}}
--{{{ clientinfo
function ci()
  local v = ""

  -- object
  local c = client.focus
  v = v .. tostring(c)

  -- geometry
  local cc = c:geometry()
  local signx = cc.x >= 0 and "+"
  local signy = cc.y >= 0 and "+"
  v = v .. " @ " .. cc.width .. 'x' .. cc.height .. signx .. cc.x .. signy .. cc.y .. "\n\n"

  local inf = {
    "name", "icon_name", "type", "class", "role", "instance", "pid",
    "icon_name", "skip_taskbar", "id", "group_id", "leader_id", "machine",
    "screen", "hide", "minimize", "size_hints_honor", "titlebar", "urgent",
    "focus", "opacity", "ontop", "above", "below", "fullscreen", "transient_for"
   }

  for i = 1, #inf do
    v =  v .. string.format("%2s: %-16s = %s\n", i, inf[i], tostring(c[inf[i]]))
  end

  naughty.notify{ text = v:sub(1,#v-1), timeout = 0, margin = 10 }

end
--}}}
--{{{ cli_toggle
function cli_toggle(cmd, prop, val)
  local c = getclient(prop, val)
  if c then
    if not c:isvisible() then
      c.hidden = false
      shifty.match(c)
      client.focus = c
      c:raise()
    else
      c.hidden = true
    end
  else
    awful.util.spawn_with_shell(cmd)
  end
end
--}}}
--}}}

--{{{ prompt related

--{{{ prompt
prompt = obvious.popup_run_prompt
function prompt.exec(preset)
  prompt.settings = awful.util.table.join(prompt.defaults, prompt.presets.default, preset)
  prompt.run_prompt()
end
--}}}
--{{{ calculator
function calculator(expr)
  val = awful.util.eval("return " .. expr)
  local calc = naughty.notify({
    text = expr .. ' = <span color="white">' .. val .. "</span>",
    timeout = 0,
    run = function(n)
      n.die()
      awful.util.spawn_with_shell("echo ".. n.val .. " | xsel -i")
    end,
  })
  calc.val = val
end
--}}}
--{{{ dictionary
function dictionary(word)
  local fr = awful.util.pread("dict -d wn " .. word .. " 2>&1")
  naughty.notify({ text = '<span font_desc="Sans 7">'..fr..'</span>', timeout = 0 })
end
--}}}
--{{{ lua completion
function lua_completion (line, cur_pos, ncomp)
   -- Only complete at the end of the line, for now
   if cur_pos ~= #line + 1 then
      return line, cur_pos
   end

   -- We're really interested in the part following the last (, [, comma or space
   local lastsep = #line - (line:reverse():find('[[({, ]') or #line)
   local lastidentifier
   if lastsep ~= 0 then
      lastidentifier = line:sub(lastsep + 2)
   else
      lastidentifier = line
   end

   local environment = _G

   -- String up to last dot is our current environment
   local lastdot = #lastidentifier - (lastidentifier:reverse():find('.', 1, true) or #lastidentifier)
   if lastdot ~= 0 then
      -- We have an environment; for each component in it, descend into it
      for env in lastidentifier:sub(1, lastdot):gmatch('([^.]+)') do
         if not environment[env] or type(environment[env]) ~= "table" then
            -- Oops, no such subenvironment, bail out
            return line, cur_pos
         end
         environment = environment[env]
      end
   end

   local tocomplete = lastidentifier:sub(lastdot + 1)
   if tocomplete:sub(1, 1) == '.' then
      tocomplete = tocomplete:sub(2)
   end

   local completions = {}
   for k, v in pairs(environment) do
      if type(k) == "string" and k:sub(1, #tocomplete) == tocomplete then
         table.insert(completions, k)
      end
   end

   if #completions == 0 then
      return line, cur_pos
   end

   table.sort(completions)
   while ncomp > #completions do
      ncomp = ncomp - #completions
   end

   local str = ""
   if lastdot + lastsep ~= 0 then
      str = line:sub(1, lastsep + lastdot + 1)
   end
   str = str .. completions[ncomp]
   cur_pos = #str + 1
   return str, cur_pos
end
--}}}
--{{{ kill
function kill(line)
  local cmd
  local name,pid,sig = line:match("(.+) (%d+).-(.*)")
  if not pid then naughty.notify{ text = "u fail" }; return end
  local proc = psgrep{ pid = pid }
  if proc and proc[1].uid ~= awful.util.pread("id -u") then
    cmd = "gksudo kill "
  else
    cmd = "kill "
  end
  awful.util.spawn(cmd .. (sig or "") .. " " .. pid, false)
end

killp = ""
function kill_completion(cmd, cur_pos, ncomp)
  local matches = psgrep({ command = cmd:sub(1,cur_pos) })

  if not matches then return cmd, cur_pos end
  while ncomp > #matches do ncomp = ncomp - #matches end

  if killp == "" or cmd:sub(cur_pos, cur_pos+#killp) ~= killp then
    killp = cmd:sub(1, cur_pos)
  end

  if #matches == 1 then
    cur_pos = #(matches[ncomp].command) + 1
  else
    cur_pos = matches[ncomp].command:find(killp) + #killp
  end

  -- return match and position
  return matches[ncomp].command..' '..matches[ncomp].pid, cur_pos
end
--}}}
--}}}

--{{{ text manipulation

--{{{ pad
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
--{{{ splitbywhitespace
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
--{{{ widgettext
function widgettext(label, value, labelcolor, valuecolor)
  local lc = labelcolor or beautiful.widget_label
  local vc = valuecolor or beautiful.widget_value
  return   '<span color="' .. lc .. '">' .. label .. ' </span><span color="' .. vc .. '">'  .. value .. '</span>' .. config.widgets.space
end
--}}}

---}}}

--{{{ fake input
--{{{ sendkeys
local fakekeys = {}
function sendkey(codes)
    if type(codes) ~= "table" then codes = { codes } end
    local f = function()
      for i = 1, #codes do root.fake_input("key_press", codes[i]) end
      for i = #codes, 1, -1 do root.fake_input("key_release", codes[i]) end
      fakekeys[1]:stop()
      table.remove(fakekeys, 1)
    end
    local t = timer({ timeout = 0.2 })
    t:add_signal("timeout", f)
    t:start()
    table.insert(fakekeys, t)
end
--}}}
--{{{ remap function
function remap(from_mod, from_key, to, desc)
  return awful.util.table.join(awful.key(from_mod, from_key,
    function(c)
      for i,j in ipairs(to) do
        sendkey(j)
      end
    end, nil, desc))
end
--}}}
--}}}

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80
