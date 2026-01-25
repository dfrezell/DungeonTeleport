-- Acorn-Bloodhoof
-- Dungeon Teleport Addon
-- Adds clickable teleport functionality to Mythic+ dungeon icons in the Challenges UI

local ADDON_NAME = "DungeonTeleport"
local DungeonTeleport = {}

-- Initialize saved variables
DungeonTeleportDB = DungeonTeleportDB or {}

-----------------------------------------------------------
-- GCD Tracking
-----------------------------------------------------------

DungeonTeleport.gcdDuration = 0
DungeonTeleport.gcdStart = 0
DungeonTeleport.gcdSpellID = 61304 -- Global Cooldown spell ID

-- Track GCD changes
local gcdFrame = CreateFrame("Frame")
gcdFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
gcdFrame:SetScript("OnEvent", function()
    local cooldownInfo = C_Spell.GetSpellCooldown(DungeonTeleport.gcdSpellID)
    if cooldownInfo and cooldownInfo.duration then
        DungeonTeleport.gcdDuration = cooldownInfo.duration
        DungeonTeleport.gcdStart = cooldownInfo.startTime
    end
end)

-- Get current GCD duration
function DungeonTeleport:GetGCDDuration()
    return self.gcdDuration or 1.5
end

-----------------------------------------------------------
-- Dungeon Data
-----------------------------------------------------------

-- Map IDs can be found at: https://wago.tools/db2/MapChallengeMode
-- Current season map IDs can be retrieved with the following macro:
-- /run for i,v in ipairs(ChallengesFrame.DungeonIcons)do if v.mapID then n=C_ChallengeMode.GetMapUIInfo(v.mapID)print(i,n or"?",v.mapID)end end

-- Base spell IDs for dungeons (before faction-specific modifications)
DungeonTeleport.MAP_ID_TO_SPELL_IDS = {
    -- Dragonflight Season 1
    [2]   = {131204}, -- Temple of the Jade Serpent
    [165] = {159899}, -- Shadowmoon Burial Grounds
    [200] = {393764}, -- Halls of Valor
    [210] = {393766}, -- Court of Stars
    [399] = {393256}, -- Ruby Life Pools
    [400] = {393262}, -- The Nokhud Offensive
    [401] = {393279}, -- The Azure Vault
    [402] = {393273}, -- Algeth'ar Academy

    -- Dragonflight Season 2
    [206] = {410078}, -- Neltharion's Lair
    [245] = {410071}, -- Freehold
    [251] = {410074}, -- The Underrot
    [403] = {393222}, -- Uldaman: Legacy of Tyr
    [404] = {393276}, -- Neltharus
    [405] = {393267}, -- Brackenhide Hollow
    [406] = {393283}, -- Halls of Infusion
    [438] = {410080}, -- The Vortex Pinnacle

    -- Dragonflight Season 3
    [168] = {159901}, -- Everbloom
    [198] = {424163}, -- Darkheart Thicket
    [199] = {424153}, -- Black Rook Hold
    [244] = {424187}, -- Atal'Dazar
    [248] = {424167}, -- Waycrest
    [456] = {424142}, -- Throne of the Tides
    [463] = {424197}, -- Dawn of the Infinite: Galakrond's Fall
    [464] = {424197}, -- Dawn of the Infinite: Murozond's Rise

    -- The War Within Season 1
    [501] = {445269}, -- The Stonevault
    [376] = {354462}, -- The Necrotic Wake
    [505] = {445414}, -- The Dawnbreaker
    [353] = {464256}, -- Siege of Boralus (base - will be faction-adjusted)
    [375] = {354464}, -- Mists of Tirna Scithe
    [507] = {445424}, -- Grim Batol
    [502] = {445416}, -- City of Threads
    [503] = {445417}, -- Ara-Kara, City of Echoes

    -- The War Within Season 2
    [525] = {1216786}, -- Operation: Floodgate
    [500] = {445443}, -- The Rookery
    [247] = {467555}, -- The MOTHERLODE!! (base - will be faction-adjusted)
    [370] = {373274}, -- Operation: Mechagon - Workshop
    [382] = {354467}, -- Theater of Pain
    [499] = {445444}, -- Priory of the Sacred Flame
    [504] = {445441}, -- Darkflame Cleft
    [506] = {445440}, -- Cinderbrew Meadery

    -- The War Within Season 3
    [378] = {354465}, -- Halls of Atonement
    [391] = {367416}, -- Tazavesh: Streets of Wonder
    [392] = {367416}, -- Tazavesh: So'leah's Gambit
    [542] = {1237215}, -- Eco-Dome Al'dani

    -----------------------------------------------------------
    -- Midnight Expansion - Season 1
    -----------------------------------------------------------
    [557] = {1254400}, -- Windrunner Spire
    [161] = {159898}, -- Skyreach
    [239] = {1254551}, -- Seat of the Triumvirate
    [556] = {1254555}, -- Pit of Saron
    [559] = {1254563}, -- Nexus-Point Xenas
    [560] = {1254559}, -- Maisara Caverns
    [558] = {1254572}, -- Magisters' Terrace

    -----------------------------------------------------------
    -- Midnight Expansion - Season 2
    -----------------------------------------------------------
    -- TODO: Add Midnight Season 2 dungeon teleport spell IDs

    -----------------------------------------------------------
    -- Midnight Expansion - Season 3
    -----------------------------------------------------------
    -- TODO: Add Midnight Season 3 dungeon teleport spell IDs
}

-- Faction-specific teleport overrides
-- Maps dungeon map ID to {Alliance_SpellID, Horde_SpellID}
DungeonTeleport.FACTION_SPECIFIC_TELEPORTS = {
    [353] = {445418, 464256}, -- Siege of Boralus: Alliance, Horde
    [247] = {467553, 467555}, -- The MOTHERLODE!!: Alliance, Horde

    -- TODO: Add Midnight faction-specific teleports if any
}

-----------------------------------------------------------
-- Raid Teleport Data
-----------------------------------------------------------

-- Raid instance IDs mapped to teleport spell IDs
DungeonTeleport.RAID_INSTANCE_TO_SPELL_IDS = {
    -- War Within Raids
    -- [1273] = {1239155}, -- Nerub-ar Palace (War Within Season 1)
    [1296] = {1226482}, -- Liberation of Undermine (War Within Season 2)
    [1302] = {1239155}, -- Manaforge Omega (War Within Season 3)

    -- Dragonflight Raids (Placeholders - TODO: Research)
    [1200] = {432254}, -- Vault of the Incarnates
    [1207] = {432257}, -- Aberrus, the Shadowed Crucible
    [1208] = {432258}, -- Amirdrassil, the Dream's Hope

    -- Shadowlands Raids (Placeholders)
    [1190] = {373190}, -- Castle Nathria
    [1193] = {373191}, -- Sanctum of Domination
    [1195] = {373192}, -- Sepulcher of the First Ones

    -- TODO: Continue with BFA, Legion, older expansions
}

-- Faction-specific raid teleports (if needed)
DungeonTeleport.RAID_FACTION_SPECIFIC_TELEPORTS = {
    -- Example: [instanceID] = {Alliance_SpellID, Horde_SpellID}
}

-- Cache for created raid buttons
DungeonTeleport.createdRaidButtons = {}
DungeonTeleport.raidJournalButton = nil

-- Cache for active tooltip updates to prevent duplicate timers
DungeonTeleport.activeTooltipTimers = {}

-- Cache for created buttons to avoid recreation
DungeonTeleport.createdButtons = {}

-----------------------------------------------------------
-- Core Functions
-----------------------------------------------------------

--- Apply faction-specific teleport spell IDs based on player's faction
--- This handles dungeons that have different teleport spells for Alliance and Horde
function DungeonTeleport:ApplyFactionSpecificTeleports()
    local playerFaction = UnitFactionGroup("player")
    local isAlliance = (playerFaction == "Alliance")

    -- Apply faction-specific overrides
    for mapID, factionSpells in pairs(self.FACTION_SPECIFIC_TELEPORTS) do
        if #factionSpells >= 2 then
            -- factionSpells = {Alliance_SpellID, Horde_SpellID}
            local spellID = isAlliance and factionSpells[1] or factionSpells[2]

            if spellID and C_Spell.GetSpellInfo(spellID) then
                self.MAP_ID_TO_SPELL_IDS[mapID] = {spellID}
            else
                -- Fallback to original spell ID if faction-specific one is invalid
                print(string.format("[%s] Warning: Invalid faction-specific spell ID %s for map %d, using fallback",
                    ADDON_NAME, tostring(spellID), mapID))
            end
        end
    end
end

--- Select the best spell ID from available options
--- Prioritizes spells the player knows over unknown spells
--- @param spellIDs table Array of spell IDs to choose from
--- @return number|nil The best spell ID, or nil if none are valid
function DungeonTeleport:GetSpellForTeleport(spellIDs)
    if not spellIDs or #spellIDs == 0 then return nil, false end

    local firstValidSpellID = nil

    for _, spellID in ipairs(spellIDs) do
        if spellID and C_Spell.GetSpellInfo(spellID) then
            if IsSpellKnown(spellID) then
                return spellID, true
            end
            if not firstValidSpellID then
                firstValidSpellID = spellID
            end
        end
    end

    if firstValidSpellID then
        return firstValidSpellID, false
    end

    return nil, false
end

function DungeonTeleport:ApplyButtonState(button, spellID, isKnown)
    button:SetAttribute("type", isKnown and "spell" or nil)
    button:SetAttribute("spell", spellID)
    button:SetAlpha(isKnown and 1 or 0.4)
    button.teleportSpellID = spellID
    button.teleportKnown = isKnown

    if button.SetNormalFontObject then
        button:SetNormalFontObject(isKnown and "GameFontNormal" or "GameFontDisable")
    end
end

function DungeonTeleport:AddCooldownLines(spellID)
    if IsSpellKnown(spellID) then
        local cooldownInfo = C_Spell.GetSpellCooldown(spellID)

        if not cooldownInfo.startTime or not cooldownInfo.duration then
            GameTooltip:AddLine(SPELL_FAILED_NOT_KNOWN, 1, 0, 0)
        elseif cooldownInfo.duration == 0 or cooldownInfo.duration <= self:GetGCDDuration() then
            GameTooltip:AddLine(READY, 0, 1, 0)
        else
            local remainingTime = cooldownInfo.startTime + cooldownInfo.duration - GetTime()
            GameTooltip:AddLine(SecondsToTime(math.ceil(remainingTime)), 1, 0, 0)
        end
    else
        GameTooltip:AddLine(SPELL_FAILED_NOT_KNOWN, 1, 0, 0)
    end
end

function DungeonTeleport:ShowSpellTooltip(button)
    local currentSpellID = button.teleportSpellID
    if not currentSpellID then return end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:SetSpellByID(currentSpellID)
    GameTooltip:AddLine(" ")
    self:AddCooldownLines(currentSpellID)
    GameTooltip:Show()
end

--- Update the GameTooltip with spell information and cooldown status
--- @param parent Frame The parent frame that owns the tooltip
--- @param spellID number The spell ID to display information for
--- @param initialize boolean Whether this is the initial tooltip setup
function DungeonTeleport:UpdateGameTooltip(parent, spellID, initialize, tooltipOwner)
    local owner = tooltipOwner or parent
    if not initialize and not GameTooltip:IsOwned(owner) then return end

    local Button_OnEnter = parent:GetScript("OnEnter")
    if Button_OnEnter then
        Button_OnEnter(parent)
        owner = GameTooltip:GetOwner() or parent
    else
        GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    end

    -- Validate spell ID exists
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if not spellInfo then return end

    local spellName = spellInfo.name

    -- Add teleport-specific information to the tooltip
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(spellName or TELEPORT_TO_DUNGEON)

    self:AddCooldownLines(spellID)

    GameTooltip:Show()

    -- Schedule next update only if tooltip is still visible and owned by our parent
    if GameTooltip:IsOwned(owner) and GameTooltip:IsVisible() then
        if self.activeTooltipTimers[parent] then
            self.activeTooltipTimers[parent]:Cancel()
            self.activeTooltipTimers[parent] = nil
        end

        self.activeTooltipTimers[parent] = C_Timer.NewTicker(1, function()
            if not GameTooltip:IsOwned(owner) or not GameTooltip:IsVisible() then
                if self.activeTooltipTimers[parent] then
                    self.activeTooltipTimers[parent]:Cancel()
                    self.activeTooltipTimers[parent] = nil
                end
                return
            end
            self:UpdateGameTooltip(parent, spellID, false, owner)
        end)
    end
end

--- Create a clickable teleport button for a dungeon icon
--- @param parent Frame The dungeon icon frame to attach the button to
--- @param spellIDs table Array of spell IDs for this dungeon
function DungeonTeleport:CreateDungeonButton(parent, spellIDs)
    if not spellIDs or #spellIDs == 0 then return end

    -- Select the best available spell ID for this player
    local spellID, isKnown = self:GetSpellForTeleport(spellIDs)
    if not spellID then return end

    -- Reuse existing button or create new one
    local button = self.createdButtons[parent]
    if not button then
        button = CreateFrame("Button", nil, parent, "InsecureActionButtonTemplate")
        button:SetAllPoints(parent)
        button:RegisterForClicks("AnyDown", "AnyUp")
        self.createdButtons[parent] = button
    end

    -- Configure the button for spell casting
    self:ApplyButtonState(button, spellID, isKnown)

    -- Set up tooltip handlers
    button:SetScript("OnEnter", function()
        self:UpdateGameTooltip(parent, spellID, true, button)
    end)

    button:SetScript("OnLeave", function()
        -- Cancel any active tooltip timer for this parent
        if self.activeTooltipTimers[parent] then
            self.activeTooltipTimers[parent]:Cancel()
            self.activeTooltipTimers[parent] = nil
        end

        -- Hide tooltip if owned by this parent
        if GameTooltip:IsOwned(button) or GameTooltip:IsOwned(parent) then
            GameTooltip:Hide()
        end
    end)
end

--- Create teleport buttons for all visible dungeon icons
function DungeonTeleport:CreateDungeonButtons()
    -- Don't modify UI during combat
    if InCombatLockdown() then return end

    -- Ensure required frames exist
    if not ChallengesFrame or not ChallengesFrame.DungeonIcons then return end

    -- Create buttons for each dungeon icon
    for _, dungeonIcon in pairs(ChallengesFrame.DungeonIcons) do
        if dungeonIcon.mapID then
            self:CreateDungeonButton(dungeonIcon, self.MAP_ID_TO_SPELL_IDS[dungeonIcon.mapID])
        end
    end
end

--- Initialize the addon
function DungeonTeleport:Initialize()
    if self.initialized then return end
    -- Wait for the Challenges UI to load before proceeding
    if not C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI") then
        return
    end

    -- Apply faction-specific teleport spell IDs
    self:ApplyFactionSpecificTeleports()

    -- Hook into the ChallengesFrame update cycle to maintain buttons
    if ChallengesFrame and type(ChallengesFrame.Update) == "function" then
        hooksecurefunc(ChallengesFrame, "Update", function()
            DungeonTeleport:CreateDungeonButtons()
        end)
    end

    -- Create initial set of dungeon buttons
    self:CreateDungeonButtons()

    -- Initialize raid teleport system
    self:InitializeRaidTeleports()

    self.initialized = true
    print(string.format("|cff00ff00%s|r loaded successfully!", ADDON_NAME))
end

-----------------------------------------------------------
-- Raid Teleport Module
-----------------------------------------------------------

--- Apply faction-specific raid teleport spell IDs based on player's faction
function DungeonTeleport:ApplyFactionSpecificRaidTeleports()
    local playerFaction = UnitFactionGroup("player")
    local isAlliance = (playerFaction == "Alliance")

    for instanceID, factionSpells in pairs(self.RAID_FACTION_SPECIFIC_TELEPORTS) do
        if #factionSpells >= 2 then
            local spellID = isAlliance and factionSpells[1] or factionSpells[2]

            if spellID and C_Spell.GetSpellInfo(spellID) then
                self.RAID_INSTANCE_TO_SPELL_IDS[instanceID] = {spellID}
            end
        end
    end
end

--- Create a clickable teleport button overlay for a raid list entry (Location 1)
--- @param parent Frame The raid list entry frame to attach the button to
--- @param instanceID number The raid instance ID
function DungeonTeleport:CreateRaidListButton(parent, instanceID)
    if not instanceID then return end

    local spellIDs = self.RAID_INSTANCE_TO_SPELL_IDS[instanceID]
    if not spellIDs or #spellIDs == 0 then
        local existingButton = self.createdRaidButtons[parent]
        if existingButton then
            existingButton:Hide()
        end
        return
    end

    local spellID, isKnown = self:GetSpellForTeleport(spellIDs)
    if not spellID then
        local existingButton = self.createdRaidButtons[parent]
        if existingButton then
            existingButton:Hide()
        end
        return
    end

    -- Reuse or create button overlay (same pattern as dungeons)
    local button = self.createdRaidButtons[parent]
    if not button then
        button = CreateFrame("Button", nil, parent, "InsecureActionButtonTemplate, UIPanelButtonTemplate")
        button:SetSize(80, 18)
        button:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -6, 6)
        button:SetText("Teleport")
        button:RegisterForClicks("AnyDown", "AnyUp")
        self.createdRaidButtons[parent] = button
    end

    self:ApplyButtonState(button, spellID, isKnown)
    button:Show()

    -- Reuse existing tooltip system
    button:SetScript("OnEnter", function()
        self:ShowSpellTooltip(button)
    end)

    button:SetScript("OnLeave", function()
        if self.activeTooltipTimers[parent] then
            self.activeTooltipTimers[parent]:Cancel()
            self.activeTooltipTimers[parent] = nil
        end
        if GameTooltip:IsOwned(button) or GameTooltip:IsOwned(parent) then
            GameTooltip:Hide()
        end
    end)
end

--- Create teleport buttons for all visible raid list entries
function DungeonTeleport:CreateRaidListButtons()
    if InCombatLockdown() then return end
    if not EncounterJournal or not EncounterJournal.instanceSelect then return end

    local instanceSelect = EncounterJournal.instanceSelect
    local scrollBox = instanceSelect.ScrollBox

    if not scrollBox and instanceSelect.scroll then
        scrollBox = instanceSelect.scroll.ScrollBox
    end

    if scrollBox and scrollBox.EnumerateFrames then
        for _, frame in scrollBox:EnumerateFrames() do
            if frame and frame.instanceID then
                local name, _, _, _, _, _, _, _, _, _, isRaid = EJ_GetInstanceInfo(frame.instanceID)
                if name and isRaid then
                    self:CreateRaidListButton(frame, frame.instanceID)
                else
                    local existingButton = self.createdRaidButtons[frame]
                    if existingButton then
                        existingButton:Hide()
                    end
                end
            end
        end
        return
    end

    local scroll = instanceSelect.scroll
    if not scroll or not scroll.child then return end

    local scrollChild = scroll.child
    for i = 1, scrollChild:GetNumChildren() do
        local button = select(i, scrollChild:GetChildren())

        if button and button.instanceID then
            local name, _, _, _, _, _, _, _, _, _, isRaid = EJ_GetInstanceInfo(button.instanceID)
            if name and isRaid then
                self:CreateRaidListButton(button, button.instanceID)
            else
                local existingButton = self.createdRaidButtons[button]
                if existingButton then
                    existingButton:Hide()
                end
            end
        end
    end
end

--- Create a standalone teleport button in the raid journal (Location 2)
--- @param instanceID number The raid instance ID
function DungeonTeleport:CreateRaidJournalButton(instanceID)
    if InCombatLockdown() then return end
    if not EncounterJournal then return end
    if not EncounterJournal.encounter then return end
    if not EncounterJournal.encounter.instance then return end

    local spellIDs = self.RAID_INSTANCE_TO_SPELL_IDS[instanceID]

    -- Hide button if no teleport available
    if not spellIDs or #spellIDs == 0 then
        if self.raidJournalButton then
            self.raidJournalButton:Hide()
        end
        return
    end

    local spellID, isKnown = self:GetSpellForTeleport(spellIDs)
    if not spellID then
        if self.raidJournalButton then
            self.raidJournalButton:Hide()
        end
        return
    end

    -- The instanceButton contains the raid image - use it as parent
    local instanceButton = EncounterJournal.encounter.instance
    if not instanceButton then
        print("|cffff0000DungeonTeleport|r: Could not find mapButton frame")
        return
    end

    local button = self.raidJournalButton
    if not button then
        button = CreateFrame("Button", "DungeonTeleportRaidButton",
                                    instanceButton,
                                    "InsecureActionButtonTemplate, UIPanelButtonTemplate")

        button:SetSize(96, 22)
        -- Position on bottom-left of the image, matching Show Maps button style
        button:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -30, 130)
        button:SetText("Teleport")
        button:SetFrameLevel(instanceButton:GetFrameLevel() + 10)

        -- Enable clicking for secure action buttons
        button:RegisterForClicks("AnyDown", "AnyUp")

        -- Tooltip handlers
        button:SetScript("OnEnter", function(self)
            DungeonTeleport:ShowSpellTooltip(self)
        end)

        button:SetScript("OnLeave", function(self)
            if GameTooltip:IsOwned(self) then
                GameTooltip:Hide()
            end
        end)

        self.raidJournalButton = button
    end

    self:ApplyButtonState(button, spellID, isKnown)
    button:Show()
end

--- Update all raid teleport buttons
function DungeonTeleport:UpdateRaidButtons()
    if not EncounterJournal then return end
    self:CreateRaidListButtons()

    -- Update journal button if a raid is selected
    local instanceID = EncounterJournal.instanceID
    if instanceID then
        -- EJ_GetInstanceInfo returns: name, description, bgImage, buttonImage, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, isRaid
        local name, _, _, _, _, _, _, _, _, _, isRaid = EJ_GetInstanceInfo(instanceID)
        if name and isRaid then
            self:CreateRaidJournalButton(instanceID)
        elseif self.raidJournalButton then
            self.raidJournalButton:Hide()
        end
    elseif self.raidJournalButton then
        self.raidJournalButton:Hide()
    end
end

--- Initialize raid teleport system
function DungeonTeleport:InitializeRaidTeleports()
    if self.raidInitialized then return end
    if not C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
        return
    end

    self:ApplyFactionSpecificRaidTeleports()

    -- Hook into journal events
    if EncounterJournal then
        -- Update when journal is shown
        EncounterJournal:HookScript("OnShow", function()
            DungeonTeleport:UpdateRaidButtons()
        end)

        -- Update when instance changes
        hooksecurefunc("EncounterJournal_DisplayInstance", function(instanceID)
            DungeonTeleport:UpdateRaidButtons()
        end)

        -- Update when raid list scrolls/updates
        local instanceSelect = EncounterJournal.instanceSelect
        if instanceSelect then
            local scrollBox = instanceSelect.ScrollBox
            if not scrollBox and instanceSelect.scroll then
                scrollBox = instanceSelect.scroll.ScrollBox
            end

            if scrollBox and scrollBox.RegisterCallback and ScrollBoxListMixin and ScrollBoxListMixin.Event and ScrollBoxListMixin.Event.OnDataRangeChanged then
                scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, function()
                    DungeonTeleport:CreateRaidListButtons()
                end, DungeonTeleport)
            elseif instanceSelect.scroll and instanceSelect.scroll.update then
                hooksecurefunc(instanceSelect.scroll, "update", function()
                    DungeonTeleport:CreateRaidListButtons()
                end)
            end
        end
    end

    -- Initial update if journal already open
    if EncounterJournal and EncounterJournal:IsShown() then
        self:UpdateRaidButtons()
    end

    self.raidInitialized = true
end

-----------------------------------------------------------
-- Event Handling
-----------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Blizzard_ChallengesUI" then
        DungeonTeleport:Initialize()
    elseif event == "ADDON_LOADED" and arg1 == "Blizzard_EncounterJournal" then
        DungeonTeleport:InitializeRaidTeleports()
    elseif event == "PLAYER_LOGIN" then
        -- Try to initialize on login (in case addons are already loaded)
        if C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI") then
            DungeonTeleport:Initialize()
        end
        if C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
            DungeonTeleport:InitializeRaidTeleports()
        end
    end
end)

-----------------------------------------------------------
-- Slash Commands
-----------------------------------------------------------

SLASH_DUNGEONTELEPORT1 = "/dt"
SLASH_DUNGEONTELEPORT2 = "/dungeonteleport"

SlashCmdList["DUNGEONTELEPORT"] = function(msg)
    msg = msg:lower():trim()

    if msg == "reload" or msg == "refresh" then
        DungeonTeleport:CreateDungeonButtons()
        DungeonTeleport:UpdateRaidButtons()
        print(string.format("|cff00ff00%s|r: Buttons refreshed", ADDON_NAME))
    elseif msg == "raids" then
        print(string.format("|cff00ff00%s|r - Raids with teleport spells:", ADDON_NAME))
        for instanceID, spellIDs in pairs(DungeonTeleport.RAID_INSTANCE_TO_SPELL_IDS) do
            -- EJ_GetInstanceInfo returns the name as the first value
            local name = EJ_GetInstanceInfo(instanceID)
            if name and type(name) == "string" then
                print(string.format("  %s (ID: %d)", name, instanceID))
            else
                print(string.format("  [Unknown Raid] (ID: %d)", instanceID))
            end
        end
    elseif msg == "help" then
        print(string.format("|cff00ff00%s|r Commands:", ADDON_NAME))
        print("  /dt reload - Refresh dungeon and raid teleport buttons")
        print("  /dt raids - List all raids with teleport spells")
        print("  /dt help - Show this help message")
    else
        print(string.format("|cff00ff00%s|r v1.2.0 - Adds teleport buttons to dungeon and raid icons", ADDON_NAME))
        print("Type /dt help for commands")
    end
end
