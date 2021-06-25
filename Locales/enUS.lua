local addonName, Data = ...
local defaultLocale = {}


local gameLocale = GetLocale()
if gameLocale == "enGB" then
	gameLocale = "enUS"
end

local errorReported, missingReported = false, false

Data.L = setmetatable({}, { --key set by all non english clients, Table gets accessed to read translations
    __index = function(t, k)  -- t is the normal table (no metatable)
        if defaultLocale[k] then
            return defaultLocale[k]
        else
            return k
        end
    end
})

local L = defaultLocale --set to L for curseforges system

--@localization(locale="enUS", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@