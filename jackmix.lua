local osc = require("osc.client")
local os = os
local io = io
local setmetatable = setmetatable
local math = math

module("jackmix")

local function gain2vol(gain, min_gain)
    return 100 + (gain / -min_gain) * 100
end

local function vol2gain(vol, min_gain)
    return ((vol / 100) * -min_gain) + min_gain 
end

function new(settings)
    local mixer = setmetatable({}, { __index = JM })

    mixer.default_channel = settings.default_channel or 1
    mixer.min_gain = settings.min_gain or -60
    mixer.max_gain = settings.max_gain or 0
    mixer.step = settings.step or 5
    mixer.state_file = settings.state_file or "/tmp/oscmix"
    mixer.osc = osc.new{ host = settings.host, port = settings.port }
    mixer.state = mixer:volume()

    return mixer
end

JM = {}

function JM:get_gain(ch)
    local channel = ch or self.default_channel
    local gain = self.osc:send{ '#bundle', os.time(), {'/mixer/channel/get_gain', 'i', channel} }
    if gain then return gain[4] end
end

function JM:set_gain(gain, ch)
    local channel = ch or self.default_channel
    local gain = math.max(self.min_gain, math.min(self.max_gain, gain))
    gain = self.osc:send{ '#bundle', os.time(), {'/mixer/channel/set_gain', 'i', channel, 'f', gain} }
    if gain then gain = gain[4] else return end
    self.state = gain2vol(gain, self.min_gain)
    return gain
end

function JM:volume(vol, ch)
    local channel = ch or self.default_channel
    local gain
    if vol then
        gain = self:set_gain( vol2gain(vol, self.min_gain), channel )
    else
        gain = self:get_gain( channel )
    end
    if gain then
        self.state = gain2vol(gain, self.min_gain)
        return self.state
    end
end

function JM:volume_up()     return self:volume(self:volume() + self.step) end
function JM:volume_down()   return self:volume(self:volume() - self.step) end

function JM:mute(ch)
    local channel = ch or self.default_channel
    local gain = self:get_gain(channel)
    if gain == self.min_gain then
        local f = io.open(self.state_file)
        if not f then return end
        local gain = f:read()
        self:set_gain(gain, channel)
        self.state = gain2vol(gain, self.min_gain)
    else
        local f = io.open(self.state_file, "w+")
        if not f then return end
        f:write(gain)
        self:set_gain(self.min_gain, channel)
        self.state = "m"
    end
end
-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80
