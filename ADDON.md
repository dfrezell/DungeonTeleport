# Dungeon Teleport

A World of Warcraft addon that adds clickable teleport functionality to Mythic+ dungeon icons in the Challenges UI (Great Vault screen) and raid entries in the Encounter Journal.  Based on Mend's Dungeon Teleport Buttons Weak Aura.

## Features

- Click dungeon icons in the Challenges UI to teleport directly to them
- Tooltips show spell cooldown status with real-time updates
- Raid list and raid journal teleport buttons in the Encounter Journal
- Supports faction-specific teleports (Alliance/Horde)
- Automatically handles all current and past Mythic+ seasons
- Ready for Midnight expansion dungeons (see below)

## Installation

### Addon Managers
1. Install via the [CurseForge app](https://www.curseforge.com/download/app) or [WowUp](https://wowup.io/)
2. Search for "DungeonTeleport"
3. Click Install

### Manual Installation
1. Download the latest release from [Releases](https://github.com/dfrezell/DungeonTeleport/releases)
2. Extract the zip file
3. Copy the `DungeonTeleport` folder to your WoW AddOns directory:
   - Windows: `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
   - Mac: `/Applications/World of Warcraft/_retail_/Interface/AddOns/`
4. Restart WoW or reload your UI (`/reload`)

## Usage

Once installed, the addon works automatically:

1. Open the Great Vault / Challenges UI (default: Shift+J)
2. Hover over any dungeon icon at the bottom to see the teleport tooltip
3. Click any dungeon icon to cast the teleport spell (if you know it)
4. Open the Encounter Journal and select a raid to see teleport buttons

### Commands

- `/dt` or `/dungeonteleport` - Display addon info
- `/dt help` - Show available commands
- `/dt reload` - Manually refresh the dungeon and raid teleport buttons
- `/dt raids` - List raids that have teleport spells configured
- `/dt taco` - Toggle the taco panda animation preview
