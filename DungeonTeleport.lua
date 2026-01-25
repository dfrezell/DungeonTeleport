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

-- Cache for active tooltip updates to prevent memory leaks
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
function DungeonTeleport:SelectBestSpellID(spellIDs)
    if not spellIDs or #spellIDs == 0 then return nil end

    -- If multiple options, prefer known spells
    if #spellIDs > 1 then
        for _, spellID in ipairs(spellIDs) do
            if IsSpellKnown(spellID) and C_Spell.GetSpellInfo(spellID) then
                return spellID
            end
        end
    end

    -- Validate the first spell ID exists before returning it
    local firstSpellID = spellIDs[1]
    if firstSpellID and C_Spell.GetSpellInfo(firstSpellID) then
        return firstSpellID
    end

    return nil
end

--- Update the GameTooltip with spell information and cooldown status
--- @param parent Frame The parent frame that owns the tooltip
--- @param spellID number The spell ID to display information for
--- @param initialize boolean Whether this is the initial tooltip setup
function DungeonTeleport:UpdateGameTooltip(parent, spellID, initialize)
    -- Only proceed if this is initialization or tooltip is owned by our parent
    if not initialize and not GameTooltip:IsOwned(parent) then return end

    -- Ensure parent has an OnEnter script before proceeding
    local Button_OnEnter = parent:GetScript("OnEnter")
    if not Button_OnEnter then return end

    -- Validate spell ID exists
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if not spellInfo then return end

    local spellName = spellInfo.name

    -- Trigger the original OnEnter behavior
    Button_OnEnter(parent)

    -- Add teleport-specific information to the tooltip
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(spellName or TELEPORT_TO_DUNGEON)

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

    GameTooltip:Show()

    -- Schedule next update only if tooltip is still visible and owned by our parent
    if GameTooltip:IsOwned(parent) and GameTooltip:IsVisible() then
        -- Cancel any existing timer for this parent to prevent duplicates
        if self.activeTooltipTimers[parent] then
            self.activeTooltipTimers[parent]:Cancel()
        end

        -- Schedule the next update
        self.activeTooltipTimers[parent] = C_Timer.After(1, function()
            self.activeTooltipTimers[parent] = nil
            self:UpdateGameTooltip(parent, spellID)
        end)
    end
end

--- Create a clickable teleport button for a dungeon icon
--- @param parent Frame The dungeon icon frame to attach the button to
--- @param spellIDs table Array of spell IDs for this dungeon
function DungeonTeleport:CreateDungeonButton(parent, spellIDs)
    if not spellIDs or #spellIDs == 0 then return end

    -- Select the best available spell ID for this player
    local spellID = self:SelectBestSpellID(spellIDs)
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
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", spellID)

    -- Set up tooltip handlers
    button:SetScript("OnEnter", function()
        self:UpdateGameTooltip(parent, spellID, true)
    end)

    button:SetScript("OnLeave", function()
        -- Cancel any active tooltip timer for this parent
        if self.activeTooltipTimers[parent] then
            self.activeTooltipTimers[parent]:Cancel()
            self.activeTooltipTimers[parent] = nil
        end

        -- Hide tooltip if owned by this parent
        if GameTooltip:IsOwned(parent) then
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

    print(string.format("|cff00ff00%s|r loaded successfully!", ADDON_NAME))
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
    elseif event == "PLAYER_LOGIN" then
        -- Try to initialize on login (in case Blizzard_ChallengesUI is already loaded)
        if C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI") then
            DungeonTeleport:Initialize()
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
        print(string.format("|cff00ff00%s|r: Buttons refreshed", ADDON_NAME))
    elseif msg == "help" then
        print(string.format("|cff00ff00%s|r Commands:", ADDON_NAME))
        print("  /dt reload - Refresh dungeon teleport buttons")
        print("  /dt help - Show this help message")
    else
        print(string.format("|cff00ff00%s|r v1.0.0 - Adds teleport buttons to dungeon icons", ADDON_NAME))
        print("Type /dt help for commands")
    end
end
