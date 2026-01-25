# Dungeon Teleport

A World of Warcraft addon that adds clickable teleport functionality to Mythic+ dungeon icons in the Challenges UI (Great Vault screen).

## Features

- Click dungeon icons in the Challenges UI to teleport directly to them
- Tooltips show spell cooldown status with real-time updates
- Supports faction-specific teleports (Alliance/Horde)
- Automatically handles all current and past Mythic+ seasons
- Ready for Midnight expansion dungeons (see below)

## Installation

### CurseForge (Recommended)
1. Install via the [CurseForge app](https://www.curseforge.com/download/app) or [WowUp](https://wowup.io/)
2. Search for "Dungeon Teleport"
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

### Commands

- `/dt` or `/dungeonteleport` - Display addon info
- `/dt help` - Show available commands
- `/dt reload` - Manually refresh the dungeon teleport buttons

## Adding Midnight Expansion Dungeons

When Midnight launches and new dungeons are added, you'll need to update the spell mappings. Here's how:

### Step 1: Find the Map IDs

In-game, use this macro to get the current season's dungeon map IDs:
```
/run for i,v in ipairs(ChallengesFrame.DungeonIcons)do if v.mapID then n=C_ChallengeMode.GetMapUIInfo(v.mapID)print(i,n or"?",v.mapID)end end
```

This will print a list like:
```
1 The Stonevault 501
2 The Necrotic Wake 376
...
```

### Step 2: Find the Teleport Spell IDs

You can find teleport spell IDs in several ways:

1. **Wago Tools Database**: Visit https://wago.tools/db2/Spell and search for the dungeon name
2. **In-game addon**: Use an addon like idTip to see spell IDs when hovering over spells
3. **Wowhead**: Search for the teleport spell on Wowhead and check the URL for the spell ID

### Step 3: Update DungeonTeleport.lua

Edit [DungeonTeleport.lua](DungeonTeleport.lua) and find the Midnight sections (around line 90):

```lua
-----------------------------------------------------------
-- Midnight Expansion - Season 1
-----------------------------------------------------------
-- TODO: Add Midnight Season 1 dungeon teleport spell IDs
-- Example format:
-- [600] = {SPELL_ID}, -- Dungeon Name
```

Replace the TODO comments with actual mappings:

```lua
-----------------------------------------------------------
-- Midnight Expansion - Season 1
-----------------------------------------------------------
[600] = {12345}, -- Example Dungeon Name
[601] = {12346}, -- Another Dungeon
[602] = {12347}, -- Third Dungeon
-- ... etc
```

### Step 4: Faction-Specific Teleports

If any Midnight dungeons have different Alliance/Horde teleport spells, add them to the `FACTION_SPECIFIC_TELEPORTS` table (around line 115):

```lua
DungeonTeleport.FACTION_SPECIFIC_TELEPORTS = {
    [353] = {445418, 464256}, -- Siege of Boralus: Alliance, Horde
    [247] = {467553, 467555}, -- The MOTHERLODE!!: Alliance, Horde

    -- Add Midnight faction-specific teleports
    [600] = {12345, 12346}, -- Example: Alliance spell, Horde spell
}
```

### Step 5: Reload

After making changes:
1. Save the file
2. Type `/reload` in-game
3. Type `/dt reload` to refresh the buttons

## Troubleshooting

### Buttons not appearing
- Make sure the Challenges UI is open (Shift+J)
- Try `/dt reload` to manually refresh
- Check that Blizzard_ChallengesUI addon is loaded

### Teleport not working
- Verify you have learned the teleport spell
- Some teleports require specific achievements or reputation
- Check the tooltip to see the cooldown status

### Combat lockdown errors
- The addon cannot create or modify buttons during combat
- Exit combat and the buttons will be created automatically

## Technical Details

### How It Works

1. The addon hooks into the Blizzard Challenges UI (`ChallengesFrame`)
2. For each dungeon icon, it creates an invisible clickable button overlay
3. The button is configured as a spell cast button using the secure action button template
4. Tooltips are enhanced with real-time cooldown information
5. GCD tracking ensures accurate cooldown status

### File Structure

- `DungeonTeleport.toc` - Addon metadata and interface version
- `DungeonTeleport.lua` - Main addon code and dungeon mappings
- `.pkgmeta` - CurseForge packager configuration
- `.github/workflows/release.yml` - Automated release workflow
- `CHANGELOG.md` - Version history and changes
- `LICENSE` - MIT License
- `README.md` - This file
- `AGENTS.md` - AI agent development guidelines

## Credits

- **Original Author**: Acorn-Bloodhoof
- **Original WeakAura**: Dungeon Teleport Buttons Library
- Converted to standalone addon for Midnight expansion

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## Development

### Branching Workflow

This project uses a feature branch workflow:

**Branch Naming:**
- `TASK-*` - New features or enhancements (e.g., `TASK-add_midnight_season_1`)
- `FIX-*` - Bug fixes (e.g., `FIX-tooltip_memory_leak`)

**Development Process:**

1. Create a feature branch:
   ```bash
   git checkout -b TASK-your-feature-name
   ```

2. Make your changes to the code

3. Update [CHANGELOG.md](CHANGELOG.md) with your changes

4. Commit your changes:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

5. Push your branch:
   ```bash
   git push origin TASK-your-feature-name
   ```

6. Create a Pull Request on GitHub

7. Merge the PR to `main`

### Creating Releases

After merging your changes to `main`:

1. Update version number in [DungeonTeleport.toc](DungeonTeleport.toc):
   ```
   ## Version: 1.1.0
   ```

2. Update [CHANGELOG.md](CHANGELOG.md) with version details:
   ```markdown
   ## [1.1.0] - 2026-XX-XX

   ### Added
   - Your new features

   ### Fixed
   - Your bug fixes
   ```

3. Commit the version bump:
   ```bash
   git add DungeonTeleport.toc CHANGELOG.md
   git commit -m "Release v1.1.0"
   git push origin main
   ```

4. Create and push the release tag:
   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

5. GitHub Actions will automatically:
   - Package the addon
   - Upload to CurseForge
   - Create a GitHub release

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- **Major** (X.0.0): Breaking changes, major rewrites
- **Minor** (1.X.0): New features, new season dungeons
- **Patch** (1.0.X): Bug fixes, minor improvements

### For AI Agents

If you're an AI agent (like Claude Code) working on this project, please see [AGENTS.md](AGENTS.md) for detailed guidelines on the development workflow and coding standards.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Found a bug or want to add features? Issues and pull requests are welcome!

When Midnight launches, please consider submitting a pull request with the new dungeon mappings to help the community.
