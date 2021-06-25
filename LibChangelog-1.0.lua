--- LibChangelog-1.0
-- Provides an way to create a simple ingame frame to show a changelog

--[[
LibChangelog-1.0

Very light wrapper library that combines all the LibChangelog subcomponents into one more easily used whole.

]]

local _, Data = ...
local L = Data.L


local MAJOR, MINOR = "LibChangelog-1.0", 0
local LibChangelog = LibStub:NewLibrary(MAJOR, MINOR)

if not LibChangelog then return end


-- Lua APIs
local pcall, error, type, pairs = pcall, error, type, pairs




local NEW_MESSAGE_FONTS = {
    version = GameFontNormalHuge,
    title = GameFontNormal,
    text = GameFontHighlight
}

local VIEWED_MESSAGE_FONTS = {
    version = GameFontDisableHuge,
    title = GameFontDisable,
    text = GameFontDisable
}

-- -------------------------------------------------------------------
-- :RegisterOptionsTable(appName, options, slashcmd, persist)
--
-- - appName - (string) application name
-- - options - table or function ref, see LibChangelogRegistry
-- - slashcmd - slash command (string) or table with commands, or nil to NOT create a slash command

--- Register a option table with the LibChangelog registry.
-- You can supply a slash command (or a table of slash commands) to register with LibChangelogCmd directly.
-- @paramsig appName, options [, slashcmd]
-- @param appName The application name for the config table.
-- @param options The option table (or a function to generate one on demand).  http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
-- @param slashcmd A slash command to register for the option table, or a table of slash commands.
-- @usage
-- local LibChangelog = LibStub("LibChangelog-1.0")
-- LibChangelog:RegisterOptionsTable("MyAddon", myOptions)



function LibChangelog:Register(addonName, changelogTable, lastReadVersion, onlyShowWhenNewVersion)

    if self[addonName] then return error("LibChangelog: '"..addonName.."' already registered", 2) end


    self[addonName] = {
        changelogTable = changelogTable,
        options = options,
        lastReadVersion = lastReadVersion,
        onlyShowWhenNewVersion = onlyShowWhenNewVersion
    }
end

function LibChangelog:CreateString(frame, text, font, offset)
    local entry = frame.scrollChild:CreateFontString(nil, "ARTWORK")
  
    if offset == nil then
      offset = -5
    end
  

    --print("ScrollChild width", frame.scrollChild:GetWidth())
    --print("scrollBar width", frame.scrollBar:GetWidth())
    -- frame.scrollBar:GetWidth() == frame.scrollChild:GetWidth()

    entry:SetFontObject(font or "GameFontNormal")
    entry:SetText(text)
    entry:SetJustifyH("LEFT")
    entry:SetWidth(frame.scrollBar:GetWidth())
  
    if frame.previous then
      entry:SetPoint("TOPLEFT", frame.previous, "BOTTOMLEFT", 0, offset)
    else
      entry:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", -5)
    end
  
    frame.previous = entry

    return entry
end

-- Did this just to get nice alignment on the bulleted entries (otherwise the text wrapped below the bulle

function LibChangelog:CreateBulletedListEntry(frame, text, font, offset)
    local bullet = self:CreateString(frame, "- ", font, offset)

    local bulletWidth = 20

    bullet:SetWidth(bulletWidth)
    bullet:SetJustifyV("TOP")
  
    local entry = self:CreateString(frame, text, font, offset)
    entry:SetPoint("TOPLEFT", bullet, "TOPRIGHT")
    entry:SetWidth(frame.scrollBar:GetWidth() - bulletWidth)
  
    bullet:SetHeight(entry:GetStringHeight())
  
    frame.previous = bullet
    return bullet
end

function LibChangelog:ShowChangelog(addonName)
    local fonts = NEW_MESSAGE_FONTS
  
    local addonData = self[addonName]

    if not addonData then return error("LibChangelog: '"..addonName.. "' was not registered. Please use :Register() first", 2) end

    local lastEntry = addonData.changelogTable[#addonData.changelogTable]

    if addonData.lastReadVersion and lastEntry.Version <= addonData.lastReadVersion and addonData.onlyShowWhenNewVersion then return end

  
    if not addonData.frame then

        local frame = CreateFrame("Frame", nil, UIParent, "ButtonFrameTemplate")
        ButtonFrameTemplate_HidePortrait(frame)
        frame:SetTitle(addonName.. " "..L.News)
        frame.Inset:SetPoint("TOPLEFT", 4, -25)
        
        -- frame:EnableMouse(true)
        
        frame:SetSize(500, 500)
        frame:SetPoint("CENTER")
        -- frame:SetMovable(true)
        -- frame:RegisterForDrag("LeftButton")
        -- frame:SetScript("OnDragStart", frame.StartMoving)
        -- frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        
        frame.scrollBar = CreateFrame("ScrollFrame", nil, frame.Inset, "UIPanelScrollFrameTemplate")
        frame.scrollBar:SetPoint("TOPLEFT", 10, -6)
        frame.scrollBar:SetPoint("BOTTOMRIGHT", -27, 6)
        
        frame.scrollChild = CreateFrame("Frame")
        frame.scrollChild:SetSize(1, 1) -- it doesnt seem to matter how big it is, the only thing that not works is setting the height to really high number, then you can scroll forever
        
        frame.scrollBar:SetScrollChild(frame.scrollChild)

        frame.CheckButton = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        frame.CheckButton:SetChecked(true)
        frame.CheckButton:SetFrameStrata("HIGH")
        frame.CheckButton:SetSize(20, 20)
        frame.CheckButton:SetScript("OnClick", function(self)
            local result = self:GetChecked()
        end)
        frame.CheckButton:SetPoint("LEFT", frame, "BOTTOMLEFT", 10, 13)
        frame.CheckButton.text:SetText(L.OnlyShowAfterUpdate)

        addonData.frame = frame
    end


    for i = 1, #addonData.changelogTable do
        local entry = addonData.changelogTable[i]

        if addonData.lastReadVersion and addonData.lastReadVersion >= entry.Version then
            fonts = VIEWED_MESSAGE_FONTS
        end

        -- Add version string
        current = self:CreateString(addonData.frame, entry.Version, fonts.version, -30) --add a nice spacing between the version header and the previous text

        if entry.General then
            current = self:CreateString(addonData.frame, entry.General, fonts.text)
        end

        if entry.Sections then
            local predefinedSections = {"NewFeatures", "Changes", "Bugfixes"}
            for i = 1, #predefinedSections do
                local sectionName = predefinedSections[i]
                local section = entry.Sections[sectionName]
                if section then
                    current = self:CreateString(addonData.frame, L[sectionName], fonts.title, -8)
                    for j = 1, #section do
                        current = self:CreateBulletedListEntry(addonData.frame, section[j], fonts.text)
                    end
                end
            end
        end
    end
end











