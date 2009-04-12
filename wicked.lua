---------------------------------------------------------------------------
-- Wicked widgets for the awesome window manager
---------------------------------------------------------------------------
-- Lucas de Vries <lucas@glacicle.com>
-- Licensed under the WTFPL
-- Version: v1.0pre-awe3.0rc4
---------------------------------------------------------------------------

-- Require libs
require("awful")

---- {{{ Grab environment
local ipairs = ipairs
local pairs = pairs
local print = print
local type = type
local tonumber = tonumber
local tostring = tostring
local math = math
local table = table
local awful = awful
local os = os
local io = io
local string = string

-- Grab C API
local capi =
{
    awesome = awesome,
    screen = screen,
    client = client,
    mouse = mouse,
    button = button,
    titlebar = titlebar,
    widget = widget,
    hooks = hooks,
    keygrabber = keygrabber
}

-- }}}

-- Wicked: Widgets for the awesome window manager
module("wicked")

---- {{{ Initialise variables
local registered = {}
local widget_cache = {}

-- Initialise function tables
widgets = {}
helper = {}

local nets = {}
local cpu_total = {}
local cpu_active = {}
local cpu_usage = {}

-- }}}

---- {{{ Helper functions

----{{{ Max width
function helper.max_width(str, width)
    l = str:len()
    
    if l > width then
        r = math.floor(width/2)
        a = str:sub(1,r)
        b = str:sub(l-r, l)
        str = a .. "..." .. b
    end

    return str
end
----}}}

----{{{ Force a fixed width on a string with spaces
function helper.fixed_width(str, width)
    l = str:len()
    n = width-l
    if n >= 0 then
        for i = 1, n do
            str = str.." "
        end
    else
        str = str:sub(0, l+n)
    end
    return str
end
----}}}

---- {{{ Format a string with args
function helper.format(format, args)
    -- TODO: Find a more efficient way to do this

    -- Format a string
    for var,val in pairs(args) do
        format = string.gsub(format, '$'..var, val)
    end

    -- Return formatted string
    return format
end
-- }}}

---- {{{ Padd a number to a minimum amount of digits
function helper.padd(number, padding)
    s = tostring(number)

    if padding == nil then
        return s
    end

    for i=1,padding do
        if math.floor(number/math.pow(10,(i-1))) == 0 then
            s = "0"..s
        end
    end

    if number == 0 then
        s = s:sub(2)
    end

    return s
end
-- }}}

---- {{{ Convert amount of bytes to string
function helper.bytes_to_string(bytes, sec, padding)
    if bytes == nil or tonumber(bytes) == nil then
        return ''
    end

    bytes = tonumber(bytes)

    signs = {}
    signs[1] = '  b'
    signs[2] = 'KiB'
    signs[3] = 'MiB'
    signs[4] = 'GiB'
    signs[5] = 'TiB'

    sign = 1

    while bytes/1024 > 1 and signs[sign+1] ~= nil do
        bytes = bytes/1024
        sign = sign+1
    end

    bytes = bytes*10
    bytes = math.floor(bytes)/10

    if padding then
        bytes = helper.padd(bytes*10, padding+1)
        bytes = bytes:sub(1, bytes:len()-1).."."..bytes:sub(bytes:len())
    end

    if sec then
        return tostring(bytes)..signs[sign]..'ps'
    else
        return tostring(bytes)..signs[sign]
    end
end
-- }}}

---- {{{ Split by whitespace
function helper.splitbywhitespace(str)
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
-- }}}

--{{{ Escape a string
function helper.escape(text)
    if text then
        text = text:gsub("&", "&amp;")
        text = text:gsub("<", "&lt;")
        text = text:gsub(">", "&gt;")
        text = text:gsub("'", "&apos;")
        text = text:gsub("\"", "&quot;")
    end
    return text
end

-- }}}

-- }}}

---- {{{ Widget types

---- {{{ MPD widget type
function widgets.mpd()
    ---- Get data from mpc
    local nowplaying_file = io.popen('mpc')
    local nowplaying = nowplaying_file:read()

    -- Check that it's not nil
    if nowplaying == nil then
        return {''}
    end

    -- Close the command
    nowplaying_file:close()
    
    -- Escape
    nowplaying = helper.escape(nowplaying)

    -- Return it
    return {nowplaying}
end

widget_cache[widgets.mpd] = {}
-- }}}

---- {{{ MOCP widget type
function widgets.mocp(format, max_width)
	local playing = ''

    ---- Get data from mocp
    local info = io.popen('mocp -i')
    local state = info:read()
	state = state.gsub(state, 'State: ', '')

	if (state == "PLAY") then
		local file = info:read()
		file = file.gsub(file, 'File: ', '')
		local title = info:read()
		title = title.gsub(title, 'Title: ', '')
		local artist = info:read()
		artist = artist.gsub(artist, 'Artist: ', '')
		local songtitle = info:read()
		songtitle = songtitle.gsub(songtitle, 'SongTitle: ', '')
		local album = info:read()
		album = album.gsub(album, 'Album: ', '')
		
		-- Try artist - (song)title
		if (artist:len() > 0) then
			playing = artist .. ' - ' .. (songtitle ~= '' and songtitle or title)
			
		-- Else try title or songtitle
		elseif (artist:len() == 0 and (title:len() > 0 or songtitle:len() > 0)) then
			playing = (title ~= '' and title or songtitle)

		-- Else use the filename
		else
			file = string.reverse(file)
			i = string.find(file, '/')
			if (i ~= nil) then
				file = string.sub(file, 0, i-1)
			end
			playing = string.reverse(file)
		end
	else
		playing = state
	end

	-- Close file
	info:close()

	-- Apply maximum width
	if (max_width ~= nil) then
		playing = helper.max_width(playing, max_width)
	end

	playing = helper.escape(playing)

    -- Return it
    return {playing}
end

widget_cache[widgets.mocp] = {}
-- }}}

---- {{{ CPU widget type
function widgets.cpu(format, padding)
    -- Calculate CPU usage for all available CPUs / cores and return the
    -- usage

    -- Perform a new measurement
    ---- Get /proc/stat
    local cpu_lines = {}
    local cpu_usage_file = io.open('/proc/stat')
    for line in cpu_usage_file:lines() do
        if string.sub(line, 1, 3) == 'cpu' then
            table.insert(cpu_lines, helper.splitbywhitespace(line))
        end
    end
    cpu_usage_file:close()

    ---- Ensure tables are initialized correctly
    while #cpu_total < #cpu_lines do
        table.insert(cpu_total, 0)
    end
    while #cpu_active < #cpu_lines do
        table.insert(cpu_active, 0)
    end
    while #cpu_usage < #cpu_lines do
        table.insert(cpu_usage, 0)
    end

    ---- Setup tables
    total_new     = {}
    active_new    = {}
    diff_total    = {}
    diff_active   = {}

    for i,v in ipairs(cpu_lines) do
        ---- Calculate totals
        total_new[i]    = v[2] + v[3] + v[4] + v[5]
        active_new[i]   = v[2] + v[3] + v[4]
    
        ---- Calculate percentage
        diff_total[i]   = total_new[i]  - cpu_total[i]
        diff_active[i]  = active_new[i] - cpu_active[i]
        cpu_usage[i]    = math.floor(diff_active[i] / diff_total[i] * 100)

        ---- Store totals
        cpu_total[i]    = total_new[i]
        cpu_active[i]   = active_new[i]
    end

    if padding ~= nil then
        for k,v in pairs(cpu_usage) do
            if type(padding) == "table" then
                p = padding[k]
            else
                p = padding
            end

            cpu_usage[k] = helper.padd(cpu_usage[k], p)
        end
    end

    return cpu_usage
end

widget_cache[widgets.cpu] = {}
-- }}}

---- {{{ Memory widget type
function widgets.mem(format, padding)
    -- Return MEM usage values
    local f = io.open('/proc/meminfo')

    ---- Get data
    for line in f:lines() do
        line = helper.splitbywhitespace(line)

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

    ---- Calculate percentage
    mem_free=free+buffers+cached
    mem_inuse=mem_total-mem_free
    mem_usepercent = math.floor(mem_inuse/mem_total*100)

    if padding then
        if type(padding) == "table" then
            mem_usepercent = helper.padd(mem_usepercent, padding[1])
            mem_inuse = helper.padd(mem_inuse, padding[2])
            mem_total = helper.padd(mem_total, padding[3])
            mem_free = helper.padd(mem_free, padding[4])
        else
            mem_usepercent = helper.padd(mem_usepercent, padding)
            mem_inuse = helper.padd(mem_inuse, padding)
            mem_total = helper.padd(mem_total, padding)
            mem_free = helper.padd(mem_free, padding)
        end
    end

    return {mem_usepercent, mem_inuse, mem_total, mem_free}
end

widget_cache[widgets.mem] = {}
-- }}}

---- {{{ Swap widget type
function widgets.swap(format, padding)
    -- Return SWAP usage values
    local f = io.open('/proc/meminfo')

    ---- Get data
    for line in f:lines() do
        line = helper.splitbywhitespace(line)

        if line[1] == 'SwapTotal:' then
            swap_total = math.floor(line[2]/1024)
        elseif line[1] == 'SwapFree:' then
            free = math.floor(line[2]/1024)
        elseif line[1] == 'SwapCached:' then
            cached = math.floor(line[2]/1024)
        end
    end
    f:close()

    ---- Calculate percentage
    swap_free=free+cached
    swap_inuse=swap_total-swap_free
    swap_usepercent = math.floor(swap_inuse/swap_total*100)

    if padding then
        if type(padding) == "table" then
            swap_usepercent = helper.padd(swap_usepercent, padding[1])
            swap_inuse = helper.padd(swap_inuse, padding[2])
            swap_total = helper.padd(swap_total, padding[3])
            swap_free = helper.padd(swap_free, padding[4])
        else
            swap_usepercent = helper.padd(swap_usepercent, padding)
            swap_inuse = helper.padd(swap_inuse, padding)
            swap_total = helper.padd(swap_total, padding)
            swap_free = helper.padd(swap_free, padding)
        end
    end

    return {swap_usepercent, swap_inuse, swap_total, swap_free}
end

widget_cache[widgets.swap] = {}
-- }}}

---- {{{ Date widget type
function widgets.date(format)
    -- Get format
    if format == nil then
        return os.date()
    else
        return os.date(format)
    end
end
-- }}}

---- {{{ Filesystem widget type
function widgets.fs(format, padding)
    local f = io.popen('df -hP')
    local args = {}

    for line in f:lines() do
        vars = helper.splitbywhitespace(line)
        
        if vars[1] ~= 'Filesystem' and #vars == 6 then
            vars[5] = vars[5]:gsub('%%','')

            if padding then
                if type(padding) == "table" then
                    vars[2] = helper.padd(vars[2], padding[1])
                    vars[3] = helper.padd(vars[3], padding[2])
                    vars[4] = helper.padd(vars[4], padding[3])
                    vars[5] = helper.padd(vars[5], padding[4])
                else
                    vars[2] = helper.padd(vars[2], padding)
                    vars[3] = helper.padd(vars[3], padding)
                    vars[4] = helper.padd(vars[4], padding)
                    vars[5] = helper.padd(vars[5], padding)
                end
            end

            args['{'..vars[6]..' size}'] = vars[2]
            args['{'..vars[6]..' used}'] = vars[3]
            args['{'..vars[6]..' avail}'] = vars[4]
            args['{'..vars[6]..' usep}'] = vars[5]
        end
    end

    f:close()
    return args
end
-- }}}

---- {{{ Net widget type
function widgets.net(format, padding)
    local f = io.open('/proc/net/dev')
    args = {}

    for line in f:lines() do
        line = helper.splitbywhitespace(line)

        local p = line[1]:find(':')
        if p ~= nil then
            name = line[1]:sub(0,p-1)
            line[1] = line[1]:sub(p+1)

            if tonumber(line[1]) == nil then
                line[1] = line[2]
                line[9] = line[10]
            end

            if padding then
                args['{'..name..' rx}'] = helper.bytes_to_string(line[1], nil, padding)
                args['{'..name..' tx}'] = helper.bytes_to_string(line[9], nil, padding)
            else
                args['{'..name..' rx}'] = helper.bytes_to_string(line[1])
                args['{'..name..' tx}'] = helper.bytes_to_string(line[9])
            end

            args['{'..name..' rx_b}'] = math.floor(line[1]*10)/10
            args['{'..name..' tx_b}'] = math.floor(line[9]*10)/10
            
            args['{'..name..' rx_kb}'] = math.floor(line[1]/1024*10)/10
            args['{'..name..' tx_kb}'] = math.floor(line[9]/1024*10)/10

            args['{'..name..' rx_mb}'] = math.floor(line[1]/1024/1024*10)/10
            args['{'..name..' tx_mb}'] = math.floor(line[9]/1024/1024*10)/10

            args['{'..name..' rx_gb}'] = math.floor(line[1]/1024/1024/1024*10)/10
            args['{'..name..' tx_gb}'] = math.floor(line[9]/1024/1024/1024*10)/10

            if nets[name] == nil then 
                nets[name] = {}
                args['{'..name..' down}'] = 'n/a'
                args['{'..name..' up}'] = 'n/a'
                
                args['{'..name..' down_b}'] = 0
                args['{'..name..' up_b}'] = 0

                args['{'..name..' down_kb}'] = 0
                args['{'..name..' up_kb}'] = 0

                args['{'..name..' down_mb}'] = 0
                args['{'..name..' up_mb}'] = 0

                args['{'..name..' down_gb}'] = 0
                args['{'..name..' up_gb}'] = 0

                nets[name].time = os.time()
            else
                interval = os.time()-nets[name].time
                nets[name].time = os.time()

                down = (line[1]-nets[name][1])/interval
                up = (line[9]-nets[name][2])/interval

                if padding then
                    args['{'..name..' down}'] = helper.bytes_to_string(down, true, padding)
                    args['{'..name..' up}'] = helper.bytes_to_string(up, true, padding)
                else
                    args['{'..name..' down}'] = helper.bytes_to_string(down, true)
                    args['{'..name..' up}'] = helper.bytes_to_string(up, true)
                end

                args['{'..name..' down_b}'] = math.floor(down*10)/10
                args['{'..name..' up_b}'] = math.floor(up*10)/10

                args['{'..name..' down_kb}'] = math.floor(down/1024*10)/10
                args['{'..name..' up_kb}'] = math.floor(up/1024*10)/10

                args['{'..name..' down_mb}'] = math.floor(down/1024/1024*10)/10
                args['{'..name..' up_mb}'] = math.floor(up/1024/1024*10)/10

                args['{'..name..' down_gb}'] = math.floor(down/1024/1024/1024*10)/10
                args['{'..name..' up_gb}'] = math.floor(up/1024/1024/1024*10)/10
            end

            nets[name][1] = line[1]
            nets[name][2] = line[9]
        end
    end

    f:close()
    return args
end
widget_cache[widgets.net] = {}
-- }}}

-- For backwards compatibility: custom function
widgets["function"] = function ()
    return {}
end

-- }}}

---- {{{ Main functions
---- {{{ Register widget
function register(widget, wtype, format, timer, field, padd)
    local reg = {}
    local widget = widget

    -- Set properties
    reg.type = wtype
    reg.format = format
    reg.timer = timer
    reg.field = field
    reg.padd = padd
    reg.widget = widget

    -- Update function
    reg.update = function ()
        update(widget, reg)
    end

    -- Default to timer=1
    if reg.timer == nil then
        reg.timer = 1
    end

    -- Allow using a string widget type
    if type(reg.type) == "string" then
        reg.type = widgets[reg.type]
    end

    -- Register reg object
    regregister(reg)

    -- Return reg object for reuse
    return reg
end
-- }}}

-- {{{ Register from reg object
function regregister(reg)
    if not reg.running then
        -- Put widget in table
        if registered[reg.widget] == nil then
            registered[reg.widget] = {}
            table.insert(registered[reg.widget], reg)
        else
            already = false

            for w, i in pairs(registered) do
                if w == reg.widget then
                    for k,v in pairs(i) do
                        if v == reg then
                            already = true
                            break
                        end
                    end

                    if already then
                        break
                    end
                end
            end

            if not already then
                table.insert(registered[reg.widget], reg)
            end
        end

        -- Start timer
        awful.hooks.timer.register(reg.timer, reg.update)

        -- Initial update
        reg.update()

        -- Set running
        reg.running = true
    end
end
-- }}}

-- {{{ Unregister widget
function unregister(widget, keep, reg)
    if reg == nil then
        for w, i in pairs(registered) do
            if w == widget then
                for k,v in pairs(i) do
                    reg = unregister(w, keep, v)
                end
            end
        end

        return reg
    end

    if not keep then
        for w, i in pairs(registered) do
            if w == widget then
                for k,v in pairs(i) do
                    if v == reg then
                        table.remove(registered[w], k)
                    end
                end
            end
        end
    end

    awful.hooks.timer.unregister(reg.update)

    reg.running = false
    return reg
end
-- }}}

-- {{{ Suspend wicked, halt all widget updates
function suspend()
    for w, i in pairs(registered) do
        for k,v in pairs(i) do
            unregister(w, true, v)
        end
    end
end
-- }}}

-- {{{ Activate wicked, restart all widget updates
function activate(widget)
    for w, i in pairs(registered) do
        if widget == nil or w == widget then
            for k,v in pairs(i) do
                regregister(v)
            end
        end
    end
end
-- }}}

---- {{{ Update widget
function update(widget, reg)
    -- Check if there are any equal widgets
    if reg == nil then
        for w, i in pairs(registered) do
            if w == widget then
                for k,v in pairs(i) do
                    update(w, v)
                end
            end
        end

        return
    end

    local t = os.time()
    local data = {}

    -- Check if we have output chached for this widget,
    -- newer than last widget update.
    if widget_cache[reg.type] ~= nil then
        local c = widget_cache[reg.type]

        if c.time == nil or c.time <= t-reg.timer then
            c.time = t
            c.data = reg.type(reg.format, reg.padd)
        end
        
        data = c.data
    else
        data = reg.type(reg.format, reg.padd)
    end

    if type(data) == "table" then
        if type(reg.format) == "string" then
            data = helper.format(reg.format, data)
        elseif type(reg.format) == "function" then
            data = reg.format(widget, data)
        end
    end
    
    if reg.field == nil then
        widget.text = data
    elseif widget.plot_data_add ~= nil then
        widget:plot_data_add(reg.field, tonumber(data))
    elseif widget.bar_data_add ~= nil then
        widget:bar_data_add(reg.field, tonumber(data))
    end
    return data
end

-- }}}

-- }}}

-- vim: set filetype=lua fdm=marker tabstop=4 shiftwidth=4 nu:
