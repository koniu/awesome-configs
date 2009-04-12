-- Standard awesome library
require("awful")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

--{{{ dbg function
function dbg(vars)
    local a = nil
    local text = "<span color = \"#FF004D\">dbg </span>"
    for i,j in pairs(vars) do
        a = "<span color='#333333'>" .. i .. " </span>"
        if type(j) == "string" or type(j) == "number" then a = a .. j 
        elseif type(j) == "boolean" then 
            if j then a = a .. "true" else a = a.. " false" end
        elseif type(j) == "table" then a = a .. "table #" .. #j
        else a = a .. tostring(j) or "nil"
        end
        text = text .. " \n" .. a
    end
    naughty.notify{ text = text, timeout = 0, hover_timeout = 0.2 }
end
--}}}

require("shifty")
require("wicked")

--{{{ vars 

--{{{ vars / common
theme_path = "/home/koniu/.config/awesome/theme.dark.master"
beautiful.init(theme_path)
modkey = "Mod4"
if screen.count() == 2 then LCD = 2 else LCD = 1 end

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
--    awful.layout.suit.fair,
awful.layout.suit.floating,
--    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier,
}

--custom
config = {}
config.terminal = "urxvtc"

-- step for scrolling
config.step = 15

-- screen offset it scrolls within
config.scroll_offset = 2

--}}}

--{{{ vars / shifty
shifty.config.tags = {

["sys"]     = { position = 1, exclusive = true, mwfact = 0.75307, screen = LCD,
                layout = awful.layout.suit.tile.bottom,                				                          },
["jack"]    = { position = 1, exclusive = true, mwfact = 0.25307, nmaster = 2, screen = LCD,
                layout = awful.layout.suit.floating,              				                              },
["term"]    = { position = 2, exclusive = true,  screen = LCD, 					                                },
["www"]     = { position = 3, exclusive = true,  screen = LCD, 					                                },
["fb"]      = { position = 9, exclusive = true, 							                                          },
["dir"]     = { rel_index = 1, exclusive = false, 							                                        },
["gqview"]  = { position = 5, spawn = 'gqview',                                                         },
["gimp"]    = { spawn = "gimp", mwfact = 0.18, icon = "/usr/share/icons/hicolor/16x16/apps/gimp.png",
                layout = awful.layout.suit.tile,                                                        },
["xev"]     = { position = 0, spawn = "urxvtc -name xev -e xev", layout = awful.layout.suit.tile,	      },
["live"]    = { icon = "/home/koniu/live.png", layout = awful.layout.suit.floating,                     },

}

shifty.config.apps = {

    -- tag matches
    { match = { "tail", "^top", "fping", "mtr", "htop", "iwconfig", "Wicd", "apt" 
                                                    },  tag = "sys",	nopopup = nil                   },
    { match = { "Informat.*CK Audio Connection Kit" }, 	kill = true, 					                        },
    { match = { "jackctl"	 		                      },	tag = "jack",		                              },
    { match = { "Iceweasel.*", "Firefox.*"	        },	tag = "www",		                              },
    { match = { "urxvt"                             },	tag = "term",                                 },
    { match = { "mc"				                        },	tag = "dir",                   
    	                                                  keys = { key({ modkey, }, "F4", 
                                                                  function (c) 
                                                                    dbg{'aaa'}
                                                                    c:kill() 
                                                                  end) },                             }, 
    { match = { "Wine"				                      },	tag = "wine",                                 },
    { match = { "Ardour.*", "Jamin",                },	tag = "ardour",					                      },

    { match = { "Live",                             }, 	tag = "live", nopopup = true, 
    							                                      geometry = { 0, 34, 1400, 1000 },		          },

    { match = { "foobar2000.exe",	                  },  tag = "fb", nopopup = true,                   },
    { match = { "Deluge", "nicotine"                },	tag = "dl",					                          },
    { match = { "Gimp",                             },	tag = "gimp",					                        },
    { match = { "Mplayer",                          },	tag = "mplayer",				                      },

    -- slaves
    { match = { "gimp-image-window","xmag","^Download$", "ufraw", "qjackctl",
							                                      },  slave = true,			                            },
    -- floats
    { match = { "recordMyDesktop", "Skype", "QQQjackctl", "dupa", "MPlayer", "xmag", "gcolor2"
                                                    },  float = true,                                 },
    -- intruders
    { match = { "^dialog$", "xmag", "gcolor2", "dupa", "^Download$", 
                                                    },  intrusive = true, 				                    },
    -- all
    { match = { "",                                 },  honorsizehints = false,  
    							                                      buttons = {
    								                                        button({ }, 1, function (c) client.focus = c; c:raise() end),
                                            								button({ "Mod1" }, 1, function (c) awful.mouse.client.move() end),
                                            								button({ "Mod1" }, 3, awful.mouse.client.resize ),
                                                        },                                            },

}

shifty.config.defaults = { 
    layout = awful.layout.suit.max,
    leave_kills = false,
    --run = function(tag) naughty.notify({ text = tag.name }) end,
    --run = function(tag) naughty.notify({ text = "Shifty Created: "    ..(awful.tag.getproperty(tag,"position") or shifty.tag2index(mouse.screen,tag)).. " : "..tag.name }) end
    
}

shifty.init()
--}}}

--{{{ vars / naughty

--  naughty settings
naughty.config.border_color = 'black'
naughty.config.font = 'Monospace 7.5'
naughty.config.icon_size = 32
naughty.config.width = 300
naughty.config.position = "top_right"
naughty.config.spacing = 3
naughty.config.padding = 5
naughty.config.margin = 5
naughty.config.presets.normal.height = 16
--naughty.config.timeout = 0
--naughty.config.hover_timeout = 0.2
naughty.config.screen = LCD
--}}}

--{{{ vars / widgets
config.widgets = {}
config.widgets.watchmount = { "/dev/sda2", "/media/", "/mnt/" }
config.widgets.space = "   "
config.widgets.wifi = "wlan1"
--}}}

--}}}

--{{{ functions

--{{{ functions / run
function run(command, class)
	for a,b in ipairs(awful.client.visible(1)) do
		print(b)
		if b.class then if b.class:match(class) then
			b.focus()
		else
			awful.util.spawn(command)
		end
		end
	end

end
--}}}

--{{{ functions / run_or_raise
--- wikipaste ---
--- Spawns cmd if no client can be found matching properties
-- If such a client can be found, pop to first tag where it is visible, and give it focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients.  Possible entries: any properties of the client object
function run_or_raise(cmd, properties)
   local clients = client.get()
   for i, c in pairs(clients) do
      if match(properties, c) then
         local ctags = c:tags()
         if table.getn(ctags) == 0 then
            -- ctags is empty, show client on current tag
            local curtag = awful.tag.selected()
            awful.client.movetotag(curtag, c)
         else
            -- Otherwise, pop to first tag client is visible on
            awful.tag.viewonly(ctags[1])
         end
         -- And then focus the client
         client.focus = c
         c:raise()
         return
      end
   end
   awful.util.spawn(cmd)
end
--}}}

--{{{ functions / match
-- Returns true if all pairs in table1 are present in table2
function match (table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v then
         return false
      end
   end
   return true
end
--}}}

--{{{ functions / scrollclient
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

--{{{ functions / lua completion
function lua_completion (line, cur_pos, ncomp)
   -- Only complete at the end of the line, for now
   if cur_pos ~= #line + 1 then
      return line, cur_pos
   end

   -- We're really interested in the part following the last (, [, comma or space
   local lastsep = #line - (line:reverse():find('[[(, ]') or #line)
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
         if not environment[env] then
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

--{{{ functions / terminal
-- runs terminal
function terminal(args)
	if args then
		awful.util.spawn(config.terminal .. ' ' .. args)
	else
		awful.util.spawn(config.terminal .. ' -title "ba:~"')
	end
end
--}}}

--{{{ functions / jointables
-- join two tables 
function jointables(t1,t2)
	local tmp={}
	for i,v in pairs(t1) do	table.insert(tmp,v) end
	for i,v in pairs(t2) do	table.insert(tmp,v) end
	return tmp
end
--}}}

--{{{ functions / splitbywhitespace
function splitbywhitespace(str)
    values = {}
    start = 1
    splitstart, splitend = string.find(str, ' ', start)
    
    while splitstart do
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

--{{{ functions / taginfo
function ti()
	local v = ""
	local t = awful.tag.selected() 
	local i = 1

	  for op, val in pairs(awful.tag.getdata(t)) do
	          v =  v .. "\n" .. i .. ": " .. op .. " = " .. tostring(val)
		  i = i + 1
	end

	naughty.notify{ text = "<span font_desc=\"Verdana Bold 20\">&lt; " .. t.name .. " &gt;</span>\n"..tostring(t).."\nclients: " .. #t:clients() .. "\n" .. v, timeout = 0, width = "230"}
end
--}}}

--{{{ functions / clientinfo
function ci()
	local v = ""
	local c = client.focus
  local inf = {
    "id", "group_id", "leader_id", "name", "icon_name", "skip_taskbar", "type", "class", "role", "instance", "pid", "machine", "icon_name", "screen",
    "hide", "minimize", "size_hints_honor", "titlebar", "urgent", "focus", "opacity", "ontop", "above", "below",
    "fullscreen", "transient_for",
   }

  for i = 1, #inf do
    v =  v .. "\n" .. i .. ": " .. inf[i] .. " = " .. tostring(c[inf[i]])
  end

	naughty.notify{ text = v, timeout = 0, width = 230}
end
--}}}

--{{{ functions / widgettext
-- format widget output
function widgettext(label, value, labelcolor, valuecolor)
	local lc = labelcolor or beautiful.widget_label
	local vc = valuecolor or beautiful.widget_value
	return 	'<span color="' .. lc .. '">' .. label .. ' </span><span color="' .. vc .. '">'  .. value .. '</span>' .. config.widgets.space
end
--}}}

--{{{ functions / islidclosed
function islidclosed()
	local f = io.open("/proc/acpi/button/lid/LID/state")
	state = f:read()
	f:close()
	if state:find("closed") then
		return true
	else
		return false
	end
end
lidclosed = islidclosed()
--}}}

--}}}

--{{{ widgets

--{{{ widgets / wifi
wifiwidget = widget({
	type = 'textbox',
	name = 'wifiwdget'
})
--[[wifiwidget.mouse_enter = function () 
	local f = io.popen("fortune")
	local fr = ""
	for line in f:lines() do
	print(line)
	fr = fr .. line .. '\n'
	end
	f:close()
	naughty.notify({ text = fr, timeout = 0 })
end
]]

wifiwidget:buttons({
	button({}, 1, function ()      run_or_raise("wicd-client -n", { class = "Wicd-client.py" } )  end),
	button({}, 2,  function () naughty.notify({text = get_autoap(), timeout = 2}) end),
	button({}, 3, function () terminal("-name iwconfig -e watch -n1 /sbin/iwconfig "..config.widgets.wifi) end)
})

function dump_autoap()
	os.execute('curl -s http://gw/user/autoap.htm  > /tmp/.awesome.autoap &')
end

last_ap = "none"
function get_autoap()
   local ap = ""
   if info then return end
   local f = io.open('/tmp/.awesome.autoap')
   if not f then return end
   local line = f:read()
   f:close()
   if not line then return end

   local aar, beg = line:find('<title>')
   if not arr or not beg then return end
   if line:sub(beg+32, beg+32) == 'S' then ap = "<span color=\"#FF602E\">searching...</span>" 
   elseif line:sub(beg+32,beg+32) == 'C' then 
	   endd = line:find('</title>', beg) 
	   ap = line:sub(beg+47,endd-2)
   end
   
   if ap ~= last_ap then naughty.notify({title = "AutoAP network", text = ap, timeout = 10}) 
   last_ap = ap end
   return ap
end

local function get_wifi()
	local v = ''
	local a = io.open('/sys/class/net/'..config.widgets.wifi..'/wireless/link')
	v = a:read() 
	a:close()
	if v == "0" then 
		  v = '<span color="#D9544C">down</span>'
		  netup = nil 
	else 
		  v = v .. '%'
	 	  netup = 1 
	end
	return v 
end
--}}}

--{{{ widgets / net
netwidget = widget({
	type = 'textbox',
	name = 'netwidget',

})
netwidget:buttons({
	button({}, 3, function () terminal("-name fping -e fping -le 10.6.6.1 google.com") end),
	button({}, 1, function () terminal("-name mtr -e mtr google.com") end)
})
netwidget.width = 100

function get_net()
	return wicked.widgets.net()
end
--}}}

--{{{ widgets / cpugraph 
cpugraphwidget = widget({
	type = 'graph',
	name = 'cpugraphwidget',
	align = 'left'
})
cpugraphwidget:buttons({
	button({}, 3, function () terminal("-name top -e top") end),
	button({}, 1, function () terminal("-name htop -e htop --sort-key PERCENT_CPU") end)
})

cpugraphwidget.height = 0.85
cpugraphwidget.width = 40
cpugraphwidget.bg = '#000000'
cpugraphwidget.border_color = '#000000'
cpugraphwidget.grow = 'right'

cpugraphwidget:plot_properties_set('cpu', {
--    fg = '#6E6958',
    fg = '#202020',
--    fg_center = '#285577',
--    fg_end = '#634141',
    vertical_gradient = true
})
--}}}

--{{{ widgets / battery 
batterywidget = widget({
	type = 'textbox',
	name = 'batterywidget',
	align = 'right'
})


local function get_bat()
	local color = 'orange'
	local v = ''
	local a = io.open('/sys/class/power_supply/BAT0/status')
	local status = a:read()
	a:close()

	if 	status == "Full" 	then v = ''; 
	else
	
		local a = io.open('/sys/class/power_supply/BAT0/energy_full')
		local full = a:read()
		a:close()
		local a = io.open('/sys/class/power_supply/BAT0/energy_now')
		local now = a:read()
		a:close() 

		bat = math.floor(now*100/full)
		
		if status == "Discharging" then 
			if 	bat < 11 then color="#D9544C"
			elseif 	bat < 31 then color="#D9A24C"
			else 		      color="#D9CD4C"
			end
		elseif status == "Charging" then color="#ABD94C"
		end
		
		v = widgettext('BAT', bat .. '%',nil,color)
	end


	return v 
 
end
--}}}

--{{{ widgets / memgraph
memgraphwidget = widget({
	type = 'graph',
	name = 'memgraphwidget',
	align = 'left'
})
memgraphwidget:buttons({
	button({}, 3, function () terminal("-name top -e top") end),
	button({}, 1, function () terminal("-name htop -e htop --sort-key PERCENT_MEM") end)
})

memgraphwidget.height = 0.85
memgraphwidget.width = 40
memgraphwidget.bg = '#000000'
memgraphwidget.border_color = '#000000'
memgraphwidget.grow = 'right'

memgraphwidget:plot_properties_set('cache', {
--    fg = '#uu6958',
--    fg = '#1F2613',
    fg = '#000000',
--   fg_center = '#285577',
--    fg_end = '#14170B',
    vertical_gradient = false
})


memgraphwidget:plot_properties_set('used', {
--    fg = '#6E6958',
    fg = '#202020',
--    fg_center = '#285577',
--    fg_end = '#285577',
    vertical_gradient = false
})


function get_mem()
    -- Return MEM usage values
    local f = io.open('/proc/meminfo')

    ---- {{ Get data
    for line in f:lines() do
        line = splitbywhitespace(line)

        if line[1] == 'MemTotal:' then
            mem_total = math.floor(line[2]/1024)
        elseif line[1] == 'MemFree:' then
            free = math.floor(line[2]/1024)
        elseif line[1] == 'Buffers:' then
            buffers = math.floor(line[2]/1024)
        elseif line[1] == 'Cached:' then
            cached = math.floor(line[2]/1024)
        end
    end
    f:close()

    ---- {{ Calculate percentage
    mem_free=free+buffers+cached
    mem_inuse=mem_total-mem_free

    mem_usepercent = math.floor(mem_inuse/mem_total*100)
    mem_cache_percent = math.floor((cached+buffers)/mem_total*100)

    return {mem_usepercent, mem_cache_percent, mem_total, mem_free}
end
--}}}

--{{{ widgets / cputemp
cputempwidget = widget({
    type = 'textbox',
    name = 'cputempwidget',
    align = 'left',
})

local function get_cputemp()
	local f = io.open('/sys/class/hwmon/hwmon1/device/temp1_input')
	local v = f:read() / 1000
	f:close()
	return v
end
--}}}

--{{{ widgets / fan
fanwidget = widget({
    type = 'textbox',
    name = 'fanwidget',
    align = 'left',
})


local function get_fan()
	local f = io.open('/sys/class/hwmon/hwmon1/device/fan1_input')
	local v = f:read()
	f:close()
	return v
end
--}}}

--{{{ widgets / mounts 				FIXME: very dirty
function get_mounts()
   local v = {}
   local f = io.open('/tmp/.awesome.df')
   if not f then return end
   local l = f:lines() 
   for line in l do
   	for p,q in pairs(config.widgets.watchmount) do
		if line:find(q) ~= nil then 
			local tmp = {}
   	         	for id in line:gmatch("%S+") do table.insert(tmp,id) end
			if #tmp > 6 then tmp[6]=tmp[6]..' '..tmp[7] end -- hack: space in mountpoint
			table.insert(v,{tmp[6], tmp[4], q})
		end
	end

   end
   f:close()
   return v
end

function dump_mounts()
	os.execute('df -h > /tmp/.awesome.df &')
end

mounts = {}

function mountlist()
    local w = {}
    local function update()
        local mnts = get_mounts()
        if not mnts or #mnts == 0 then return end
        local len = w.len or #w
        -- Add more widgets
        if len < #mnts then
            for i = len, #mnts do
                w[i] = widget({ type = "textbox", align='right' })
            end
        -- Remove widgets
        elseif len > #mnts then
            for i = #mnts + 1, len do
                w[i] = nil
            end
        end
        -- Update widgets text
        for i,mnt in ipairs(mnts) do
            local tmp = {}
            local esc=string.gsub(mnt[1],' ','\\ ')
--	    w[i].text = --'<bg image="/home/koniu/.config/awesome/icons/hdd.png" />'.. 
	    w[i].bg_image = image("/home/koniu/.config/awesome/icons/hdd.png")
	    w[i].text = "   " .. mnt[1]:gsub(mnt[3],''):upper() .. 
                        '<span color="' .. beautiful.widget_value .. '">' .. mnt[2] .. '</span>' .. 
--                        '<span color="#333333">' .. mnt[2] .. '</span>' .. 
                        config.widgets.space --.. "  "
			
                        w[i]:buttons({
                            button({}, 1, function () terminal(" -name mc -geometry 169x55 -bd \\".. beautiful.border_focus .." -e mc " .. esc) end),
                            button({}, 3, function () 
                                awful.util.spawn("eject " .. esc)
                                awful.util.spawn("pumount " .. esc)
                                --awful.util.spawn("pumount -l " .. esc)
			    end),
			})
        end
    end
    awful.hooks.timer.register(1, update)
    update()
    return w
end
local mountwidget = mountlist()
--}}}

--{{{ widgets / mail
mailwidget = widget({ type = "textbox", name = "mailwidget", align = "right"})

mailwidget:buttons({
    button({ }, 1, function () awful.util.spawn('firefox http://gmail.com'); awful.tag.viewonly(shifty.name2tag('www')) end),
})

function get_mail()
   if info then return end
   local f = io.open('/tmp/.awesome.mail')
   if not f then return end
   local count = f:read()
   f:close()
   if not count then return end
--   local inbox, lists = count:match( ("([^".." ".."]*)".." "):rep(2) )
--    dbg{count, inbox, lists}
   local inbox, lists = count:match("(%d+) (%d+)")
--   dbg{count,inbox,lists}
   if not inbox or not lists then return end
   local text = ''
   if tonumber(inbox) > 0 then text = text .. widgettext('MAIL', inbox, nil, "#99C399")  end
   if tonumber(lists) > 0 then text = text .. widgettext('LIST', lists, nil, "#99C399")  end
   mailwidget.text = text
end

function dump_mail()
--	os.execute('python ~/bin/gmail.py > /tmp/.awesome.mail &')
end
--}}}

--{{{ widgets / apt
aptwidget = widget({ type = "textbox", name = "aptwidget", align="right"})

aptwidget:buttons({
    button({ }, 1, function () terminal("-name apt -title aptitude -e sudo aptitude") end),
})

function get_apt()
   if info then return end
   local f = io.open('/tmp/.awesome.apt')
   if not f then return end
   local counts = {}
   for line in f:lines() do
   	table.insert(counts, line)
   end
   f:close()
--   if not counts[1] or not counts[2] then return end
   if not counts[1] then return end
--   if tonumber(counts[1]) > 0 or tonumber(counts[2]) > 0 then
   if tonumber(counts[1]) > 0 then
   	--aptwidget.text  = widgettext('APT', counts[1] .."<span color='#524E41'>/</span><span color='#6B6655'>"..counts[2]..'</span>' , nil, '#99C399' )
   	aptwidget.text  = widgettext('APT', counts[1]  , nil, '#99C399' )
  else 
  	aptwidget.text = ''
  end
end

function dump_apt()
	--os.execute("sudo apt-get upgrade -s | tail -n1 | awk '{ print $1 \"\\n\" $10}' > /tmp/.awesome.apt &")
	os.execute("sudo apt-get upgrade -s | tail -n1 | awk '{ print $1 }' > /tmp/.awesome.apt &")
end
--}}}

--{{{ widgets / clock
clockwidget = widget({ type = "textbox", name = "clockwidget", align = "right" })

calendar = nil
local offset = 0 

function remove_calendar()
        if calendar ~= nil then
            naughty.destroy(calendar)
            calendar = nil
            offset = 0
        end
end

function showcalendar(inc_offset) 
        local save_offset = offset
        remove_calendar()
        if inc_offset == 666 then
                offset = 0
        else 
                offset = save_offset + inc_offset
        end
        local datespec = os.date("*t")
        datespec = datespec.year * 12 + datespec.month - 1 + offset
        datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
        local cal = awful.util.pread("cal -m " .. datespec)
        cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
        calendar = naughty.notify({ 
                    text = os.date("<b><span color=\"white\">%a, %d %B %Y</span></b>\n\n") .. cal, 
                    timeout = 0, hover_timeout = 0.5,
                    width = 150, 
        })
end

clockwidget:buttons({
        button({ }, 1, function () showcalendar(-1) end),
        button({ }, 2, function () showcalendar(666) end),
        button({ }, 3, function () showcalendar(1) end),
        button({ }, 4, function () showcalendar(-1) end),
        button({ }, 5, function () showcalendar(1) end),

})
clockwidget.mouse_enter = function() showcalendar(0) end
clockwidget.mouse_leave = function () remove_calendar() end
--}}}

--{{{ widgets / prompt
mypromptbox = widget({ type = "textbox", name = "mypromptbox", align = "left" })
--}}}

--{{{ widgets / systray
mysystray = widget({ type = "systray", name = "mysystray", align = "right" })
--}}}

--{{{ widgets / layoutbox
mylayoutbox = {}
for s = 1, screen.count() do
    mylayoutbox[s] = widget({ type = "imagebox", align = "left" })
 mylayoutbox[s]:buttons({
        button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        button({ }, 4, function () awful.layout.inc(layouts, 1) end),
        button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    })

--    mylayoutbox[s].text = "<bg image=\"/home/koniu/.config/awesome/icons/layouts/tilew.png\" resize=\"true\"/> "
end
--}}}

--{{{ widgets / initialize separators, widget tables

-- separator widgets
sep_l = widget({
	type = 'textbox',
	name = 'sep_l',
	align = 'left',
})
sep_l.text='<span font_desc="verdana 4"> </span>'

sep_r = widget({
	type = 'textbox',
	name = 'sep_r',
	align = 'right',
})
sep_r.text='	'

-- widget tables
widgets_left={
	sep_l,
	memgraphwidget,
	sep_l,
    	cpugraphwidget,
	sep_l,
	sep_l,
	sep_l,
	sep_l,
	cputempwidget,
	fanwidget,
	wifiwidget,
	netwidget,
        mypromptbox, 
}

widgets_right={
--	sep_r,
	mountwidget,
	sep_r,
	batterywidget,
	aptwidget,
	mailwidget,
        mysystray, 
        clockwidget,
}
--}}}

--{{{ widgets / hook functions
function hook_001s()
  scrollclient()
end

function hook_1s()
	local color,color2=''
	if lidclosed then return end

	cpugraphwidget:plot_data_add('cpu',wicked.widgets.cpu()[1])
	
	local a = get_mem()
	memgraphwidget:plot_data_add('used',a[1])
	memgraphwidget:plot_data_add('cache',a[1]+a[2])

	cputempwidget.text 	= widgettext('CPU', get_cputemp() .. '°C')
	fanwidget.text		= widgettext('FAN', string.format("%-4s",get_fan()))
	wifiwidget.text		= widgettext('WIFI', get_wifi())

	local b = wicked.widgets.net()
	if b['{'..config.widgets.wifi.. ' down_kb}'] > 0 then color = beautiful.widget_value; color = beautiful.widget_value else color = '#333333' end
	if b['{'..config.widgets.wifi.. ' up_kb}'] > 0 then color2 = beautiful.widget_value else color2 = '#333333' end
	if netup then
		netwidget.text = widgettext('NET', string.format('%3s <span color="#333333">/</span> %-3s', b['{'..config.widgets.wifi..' down_kb}'], b['{'..config.widgets.wifi.. ' up_kb}']), nil, color2)
	else 
		netwidget.text = ''
	end
	clockwidget.text = config.widgets.space .. "<span font_desc='' color='#cccccc'>" .. os.date("%H<span color='#999999'>:</span>%M<span color='#999999'>:</span>%S") .. "</span> "
end


function hook_3s ()
--	if lidclosed then return end
	dump_mounts()
	get_mounts()

end

function hook_5s ()
	if lidclosed then return end
	batterywidget.text = get_bat()
	get_mail()
--	get_apt()
	dump_autoap()
	get_autoap()
end

function hook_1m ()
	lidclosed = islidclosed()
	if lidclosed then return end
	dump_mail()
end

function hook_10m ()
	dump_apt()
end
--}}}

--}}}

--{{{ panels 

--{{{ panels / widget
widgetbar = {}
for s = LCD, screen.count() do
    widgetbar[s] = wibox({ position = "top", name = "widgetbar" .. s,
                                 fg = beautiful.fg_normal, bg = beautiful.bg_normal, height = 16 })
    -- Add widgets to the statusbar - order matters
    widgetbar[s].widgets = jointables(widgets_left,widgets_right)
    widgetbar[s].screen = s
--widgetbar[s].ontop = true
end
--}}}

--{{{ panels / separator
separatorbar = {}
for s = 1, screen.count() do
    separatorbar[s] = wibox({ position = "top", name = "separatorbar" .. s, bg = beautiful.bg_normal, height = 3 })
    separatorbar[s].widgets = { widget({type="textbox"}) }
   separatorbar[s].screen = s
--   separatorbar[s].ontop = true
end
--}}}

--{{{ panels / taglist+tasklist
mytaglist = {}
mytaglist.buttons = { button({ }, 1, awful.tag.viewonly),
                      button({ modkey }, 1, awful.client.movetotag),
                      button({ }, 3, function (tag) tag.selected = not tag.selected end),
                      button({ modkey }, 3, awful.client.toggletag),
                      button({ }, 4, awful.tag.viewnext),
                      button({ }, 5, awful.tag.viewprev) }
mytasklist = {}
mytasklist.buttons = { button({ }, 1, function (c)
                                          if not c:isvisible() then
                                              awful.tag.viewonly(c:tags()[1])
                                          end
                                          client.focus = c
                                          c:raise()
                                      end),
--                       button({ }, 3, function () if instance then instance:hide() end instance = awful.menu.clients({ width=250 }) end),
		       button({ }, 3, function () if instance then instance:hide() instance = nil else instance = awful.menu.clients({ width=250 }) end end),
                       button({ }, 4, function ()
                                          awful.client.focus.byidx(1)
                                          if client.focus then client.focus:raise() end
                                      end),
                       button({ }, 5, function ()
                                          awful.client.focus.byidx(-1)
                                          if client.focus then client.focus:raise() end
                                      end) }


for s = 1, screen.count() do
    -- Create a promptbox for each screen
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist.new(function(c)
                                                  return awful.widget.tasklist.label.currenttags(c, s)
                                              end, mytasklist.buttons)

    -- Create the wibox
end
shifty.taglist = mytaglist

tabbar = {}
for s = 1, screen.count() do
    tabbar[s] = wibox({ position = "top", name = "tabbar" .. s,
                                 fg = beautiful.fg_normal, bg = beautiful.bg_normal })
    -- Add widgets to the statusbar - order matters
    tabbar[s].widgets = {
        mytaglist[s],
        mylayoutbox[s],
        mytasklist[s],
	
    }
    tabbar[s].screen = s
--    tabbar[s].ontop = true
end
-- }}}

--}}}

-- {{{ bindings 

-- {{{ bindings / global
globalkeys = {}

-- {{{ bindings / global / spawns
table.insert(globalkeys, key({ modkey 		}, "grave", 		function () terminal() end))
table.insert(globalkeys, key({ modkey }, "x", function () awful.util.spawn("xkill") end))
table.insert(globalkeys, key({ modkey, "Mod1"	}, "grave", 		function () terminal("-name dupa -fg '#1A1914'  -font 6x10 -g 80x24-10-10") end))
table.insert(globalkeys, key({ modkey, "Control"	}, "grave", 		function () terminal("-name tail -title log/awesome -e tail -fn0 ~/log/awesome") end))
table.insert(globalkeys, key({ 			}, "Print", 		function () awful.util.spawn("~/bin/shot") end))
-- }}}

-- {{{ bindings / global / tag manipulation
table.insert(globalkeys, key({                    }, "XF86Back",    awful.tag.viewprev))
table.insert(globalkeys, key({                    }, "XF86Forward", awful.tag.viewnext))

table.insert(globalkeys, key({  modkey 		        }, "XF86Forward", shifty.shift_next))
table.insert(globalkeys, key({  modkey 		        }, "XF86Back", 		shifty.shift_prev))
table.insert(globalkeys, key({  "Shift" 		      }, "XF86Forward", shifty.send_next))
table.insert(globalkeys, key({  "Shift" 		      }, "XF86Back", 		shifty.send_prev))

table.insert(globalkeys, key({ modkey		          }, "t", 		      function() shifty.add({ rel_index = 1 }) end))
table.insert(globalkeys, key({ modkey, "Control"  }, "t", 		      function() shifty.add({ rel_index = 1, nopopup = true }) end))
table.insert(globalkeys, key({ modkey 		        }, "r", 		      shifty.rename))
table.insert(globalkeys, key({ modkey	 	          }, "w", 		      shifty.del))

table.insert(globalkeys, key({modkey}, 'i', ti))
-- }}}

-- {{{ bindings / global / shifty.getpos
for i=1, ( shifty.config.maxtags or 9 ) do
  table.insert(globalkeys, key({ modkey }, i,
  function ()
    local t = awful.tag.viewonly(shifty.getpos(i))
  end))
  table.insert(globalkeys, key({ modkey, "Control" }, i,
  function ()
    local t = shifty.getpos(i)
    t.selected = not t.selected
  end))
  table.insert(globalkeys, key({ modkey, "Control", "Shift" }, i,
  function ()
    if client.focus then
      awful.client.toggletag(shifty.getpos(i))
    end
  end))
  -- move clients to other tags
  table.insert(globalkeys, key({ modkey, "Shift" }, i,
    function ()
      if client.focus then
        t = shifty.getpos(i)
        awful.client.movetotag(t)
        awful.tag.viewonly(t)
      end
    end))
end
-- }}}

-- {{{ bindings / global / client manipulation
table.insert(globalkeys, key({ "Control"		}, "XF86Back", 		function () awful.client.focus.byidx(-1);  if client.focus then client.focus:raise() end end))
table.insert(globalkeys, key({ "Control"		}, "XF86Forward", 	function () awful.client.focus.byidx(1);  if client.focus then client.focus:raise() end end ))
table.insert(globalkeys, key({ modkey, "Shift" }, "XF86Forward", function () awful.client.swap.byidx(1) end))
table.insert(globalkeys, key({ modkey, "Shift" }, "XF86Back", function () awful.client.swap.byidx(-1) end))
-- }}}

-- {{{ bindings / global / mm keys
table.insert(globalkeys, key({ 			}, "XF86AudioPlay", 	function () awful.util.spawn("fb /playpause") end))
table.insert(globalkeys, key({ 			}, "XF86AudioStop",	function () awful.util.spawn("fb /stop") end))
table.insert(globalkeys, key({ 			}, "XF86AudioPrev",	function () awful.util.spawn("fb /prev") end))
table.insert(globalkeys, key({ 			}, "XF86AudioNext",	function () awful.util.spawn("fb /next") end))
-- }}}

-- {{{ bindings / global / prompts

-- {{{ bindings / global / prompts /run
table.insert(globalkeys, key({ "Mod1" 	}, "F2", function ()
		info = true
	awful.prompt.run({ fg_cursor = "orange",bg_cursor=beautiful.bg_normal, ul_cursor = "single", prompt = "<span color='orange'>Run:</span> " }, mypromptbox, awful.util.spawn, awful.completion.shell, os.getenv("HOME") .. "/.cache/awesome/history") 
end))
-- }}}

-- {{{ bindings / global / prompts /lua
table.insert(globalkeys, key({ "Mod1"	}, "F1", function ()
		info = true
                awful.prompt.run({ fg_cursor="#D1FF00", bg_cursor=beautiful.bg_normal, ul_cursor = "single", prompt = "<span color = '#D1FF00'>Lua:</span> " }, mypromptbox, awful.util.eval, lua_completion,
os.getenv("HOME") .. "/.cache/awesome/history_eval") end))
-- }}}

-- {{{ bindings / global / prompts /run
table.insert(globalkeys, key({ modkey}, "c", function ()
    info = true
    awful.prompt.run({  text = val and tostring(val), 
                        selectall = true, 
                        fg_cursor = "#00A5AB",bg_cursor=beautiful.bg_normal, ul_cursor = "single",
                        prompt = "<span color='#00A5AB'>Calc:</span> " }, mypromptbox,
	                function(expr)
                            val = awful.util.eval(expr)
		            naughty.notify({    text = expr .. ' = <span color="white">' .. val .. "</span>", 
                                                timeout = 0,
                                                run = function() io.popen("echo ".. val .. " | xsel -i"):close() end, })
	                end,
	                nil, awful.util.getdir("cache") .. "/calc") 
end))
-- }}}

-- {{{ bindings / global / prompts /dict
table.insert(globalkeys, key({ modkey}, "d", function ()
	info = true
        local g = io.popen("xsel -o")
        local paste = g:read()
        g:close()
        color = '#008DFA'
	awful.prompt.run({ fg_cursor = color, bg_cursor=beautiful.bg_normal, ul_cursor = "single", text = paste, selectall = true, prompt = "<span color='"..color.."'>Dict:</span> " }, mypromptbox,
	function(word)
		local f = io.popen("dict -d wn " .. word .. " 2>&1")
		local fr = ""
		for line in f:lines() do
		fr = fr .. line .. '\n'
		end
		f:close()
		naughty.notify({ text = '<span font_desc="Sans 7">'..fr..'</span>', timeout = 0, width = 400 })
	end,
	nil, awful.util.getdir("cache") .. "/dict") 
end))
-- }}}

-- {{{ bindings / global / prompts /kill
table.insert(globalkeys, key({ modkey}, "k", function ()
	info = true
	awful.prompt.run({ fg_cursor = "#FF4F4F", bg_cursor = beautiful.bg_normal, ul_cursor="single", text = paste, selectall = true, prompt = "<span color='#FF4F4F'>Kill:</span> " }, mypromptbox,
	function(line)
                local name,pid  = line:match("(%a+) (%d+)")
                          awful.util.spawn("kill " .. pid) 
	end,
        function (cmd, cur_pos, ncomp)
        local ps = {}
        local g = io.popen("ps hxuc") -- | awk '{print $11 \" \" $2}'")
        for line in g:lines() do
              local out = splitbywhitespace(line)
--            table.insert(ps, a .. b})
            table.insert(ps, out[11] .. " " .. out[2])

   --             end
        end
        g:close()
    if cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " " then
        return cmd, cur_pos
    end
               local matches = {}
            for i, j in ipairs(ps) do
                if ps[i]:find("^" .. cmd:sub(1, cur_pos)) then
                        table.insert(matches, ps[i])
                end
            end
        if #matches == 0 then return cmd, cur_pos end
 while ncomp > #matches do ncomp = ncomp - #matches end

    -- return match and position
    return matches[ncomp], cur_pos

 
        end
        
        , awful.util.getdir("cache") .. "/kill") 
end))
-- }}}

-- {{{ bindings / global / prompts /client infobox
table.insert(globalkeys, key({ modkey, "Ctrl" }, "i", function ()
	if mypromptbox.text then
		info = nil
		mypromptbox.text = nil
		get_mounts()
		--get_apt()
		get_mail()
	        widgetbar[LCD].widgets = jointables(widgets_left, widgets_right)

	else
		info = true
	        widgetbar[LCD].widgets = {mypromptbox, clockwidget}
		aptwidget.text = ''
		mailwidget.text = ''

		local c = client.focus
		local cc = c:geometry()
		mypromptbox.text = nil
		local tmp = " "
		local format = "<span color='#ffffff'>%s</span> <span color='orange'>%s</span>" .. config.widgets.space
	
		if c.class then
			tmp = tmp .. string.format(format,'class', client.focus.class)
		end
		if c.instance then
			tmp = tmp .. string.format(format,'inst', client.focus.instance)
		end
		if c.role then
			tmp = tmp .. string.format(format,'role', client.focus.role)
		end
		if c.pid then
			tmp = tmp .. string.format(format,'pid', client.focus.pid)
		end
		
		local signx = '+'
		if cc.x < 0 then signx = '' end
		local signy = '+'
		if cc.y < 0 then signy = '' end
		tmp = tmp .. string.format(format,'geom', cc.width .. 'x' .. cc.height .. signx .. cc.x .. signy .. cc.y)
		
		if c.type then
			tmp = tmp .. string.format(format,'type', client.focus.type)
		end

		mypromptbox.text = tmp

	end
end))
-- }}}

-- }}}

-- {{{ bindings / global / default rc.lua keys

table.insert(globalkeys, key({ modkey }, "Escape", awful.tag.history.restore))


table.insert(globalkeys, key({ modkey, "Control" }, "j", function () awful.screen.focus(1) end))
table.insert(globalkeys, key({ modkey, "Control" }, "k", function () awful.screen.focus(-1) end))

table.insert(globalkeys, key({ modkey }, "Tab", function () awful.client.focus.history.previous(); if client.focus then client.focus:raise() end end))

table.insert(globalkeys, key({ modkey }, "u", awful.client.urgent.jumpto))

-- Standard program

table.insert(globalkeys, key({ modkey, "Control" }, "r", function ()
                                                             mypromptbox.text =
                                                                 awful.util.escape(awful.util.restart())
                                                          end))
table.insert(globalkeys, key({ modkey, "Shift" }, "q", awesome.quit))

-- Layout manipulation
table.insert(globalkeys, key({ modkey }, "l", function () awful.tag.incmwfact(0.05) end))
table.insert(globalkeys, key({ modkey }, "h", function () awful.tag.incmwfact(-0.05) end))
table.insert(globalkeys, key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster(1) end))
table.insert(globalkeys, key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1) end))
table.insert(globalkeys, key({ modkey, "Control" }, "h", function () awful.tag.incncol(1) end))
table.insert(globalkeys, key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end))
table.insert(globalkeys, key({ modkey }, "space", function () awful.layout.inc(layouts, 1) end))
table.insert(globalkeys, key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end))
--}}}

-- }}}

--{{{ bindings / client
clientkeys = {}
table.insert(clientkeys, key({ modkey }, "m", function (c) c.maximized_horizontal = not c.maximized_horizontal
                                                           c.maximized_vertical = not c.maximized_vertical end))
table.insert(clientkeys, key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen end))
table.insert(clientkeys, key({ modkey, "Control" }, "space", awful.client.floating.toggle))
table.insert(clientkeys, key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end))
table.insert(clientkeys, key({ modkey }, "o", awful.client.movetoscreen))
table.insert(clientkeys, key({ modkey, "Shift" }, "r", function (c) c:redraw() end))

table.insert(clientkeys, key({ "Mod1", }, "F4", function (c) c:kill() end))
table.insert(clientkeys, key({ "Mod1", "Mod4" }, "i", ci))
table.insert(globalkeys, key({ "Shift", }, "F5", function (c) root.fake_input("key_press",23); end)) --root.fake_input("key_release",23); dbg{'aaa'} end))
--}}}

-- {{{ bindings / set keys and buttons
root.buttons({
    button({ }, 3, function () mymainmenu:toggle() end),
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})
root.keys(globalkeys)
shifty.config.clientkeys = clientkeys
-- }}}

-- }}}

-- {{{ hooks 

-- {{{ hooks / focus
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
end)
-- }}}

-- {{{ hooks / unfocus
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)
-- }}}

-- {{{ hooks / marked
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)
-- }}}

-- {{{ hooks / unmarked 
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)
-- }}}

-- {{{ hooks / mouse_enter
awful.hooks.mouse_enter.register(function (c)
    -- Sloppy focus, but disabled for magnifier layout
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)
-- }}}

-- {{{ hooks / manage DISABLED
awful.hooks.manage.register(function (c, startup)
    -- If we are not managing this application at startup,
    -- move it to the screen where the mouse is.
    -- We only do it for filtered windows (i.e. no dock, etc).
    if true then return end
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end

    if use_titlebar then
        -- Add a titlebar
        awful.titlebar.add(c, { modkey = modkey })
    end
    -- Add mouse bindings
    c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
--        button({ modkey }, 1, awful.mouse.client.move),
--        button({ modkey }, 3, awful.mouse.client.resize)
	button({ "Mod1" }, 1, awful.mouse.client.move),
	button({ "Mod1" }, 3, awful.mouse.client.resize)
    })
    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
    client.focus = c

    -- Set key bindings
    c:keys(clientkeys)

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)
    --
    
--    awful.placement.centered(c, c.transient_for)
--   awful.placement.no_offscreen(c)

    -- Honor size hints: if you want to drop the gaps between windows, set this to false.
    -- c.size_hints_honor = false
--    if c.type== "utility" then awful.client.floating.set( c, false) end
end)
-- }}}

-- {{{ hooks / arrange 
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout and beautiful["layout_" ..layout] then
        mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
    else
        mylayoutbox[screen].image = nil
    end

    -- Give focus to the latest client in history if no window has focus
    -- or if the current window is a desktop or a dock one.
    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end
end)
-- }}}

--{{{ hooks / timers
awful.hooks.timer.register(1, hook_1s)
awful.hooks.timer.register(30, hook_1m)
awful.hooks.timer.register(0.01, hook_001s)
awful.hooks.timer.register(3, hook_3s)
awful.hooks.timer.register(5, hook_5s)
awful.hooks.timer.register(600, hook_10m)
-- }}}

-- }}}

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80
