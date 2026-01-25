# AI Agent Development Guide

This document provides guidelines for AI agents (like Claude Code) working on this project.

## Project Overview

**DungeonTeleport** is a World of Warcraft addon that adds clickable teleport functionality to Mythic+ dungeon icons in the Challenges UI. It's designed to be updated each expansion as new dungeons are added.

## Development Workflow

### Branching Strategy

This project uses a feature branch workflow with descriptive prefixes:

- `TASK-*` - For new features or enhancements
- `FIX-*` - For bug fixes

**Examples:**
- `TASK-add_midnight_season_1_dungeons`
- `FIX-tooltip_memory_leak`
- `TASK-add_wago_support`

### Important: User Handles Git Operations

**DO NOT** execute git commands like `git add`, `git commit`, `git push`, or `git tag` directly.

**INSTEAD:**
1. Make code changes using Edit/Write tools
2. Show the user the git commands they should run
3. Let the user execute the commands themselves

**Example:**
```markdown
I've updated DungeonTeleport.lua with the new spell IDs. To commit these changes:

git add DungeonTeleport.lua CHANGELOG.md
git commit -m "Add Midnight Season 1 dungeon teleports"
git push origin TASK-add_midnight_season_1_dungeons
```

### Release Process

1. **Create feature branch** (user creates)
2. **Make changes** (agent can edit files)
3. **Update files:**
   - Code files (DungeonTeleport.lua, etc.)
   - [CHANGELOG.md](CHANGELOG.md) - Add entry for changes
   - [DungeonTeleport.toc](DungeonTeleport.toc) - Update version number
4. **Show commit commands** (don't execute)
5. **User commits and pushes**
6. **User creates PR and merges to main**
7. **User creates and pushes tag** to trigger release

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- **Major** (X.0.0): Breaking changes, major rewrites
- **Minor** (1.X.0): New features, new season dungeons
- **Patch** (1.0.X): Bug fixes, minor improvements

## File Structure

### Core Addon Files
- `DungeonTeleport.toc` - Addon metadata (version, interface, etc.)
- `DungeonTeleport.lua` - Main addon code and dungeon mappings

### Development Files
- `.pkgmeta` - CurseForge packaging configuration
- `.github/workflows/release.yml` - Automated release workflow
- `CHANGELOG.md` - Version history (required for releases)
- `LICENSE` - MIT License
- `README.md` - User documentation
- `AGENTS.md` - This file (AI agent guidelines)

### Excluded from Releases
Via `.pkgmeta`:
- `README.md` - GitHub documentation only
- `.gitignore` - Git configuration
- `.github/` - GitHub Actions workflows
- `images/` - Screenshots and documentation images
- `AGENTS.md` - Development documentation

## Adding New Dungeons

When a new expansion or season launches:

### 1. Gather Information

**Map IDs:**
In-game macro:
```lua
/run for i,v in ipairs(ChallengesFrame.DungeonIcons)do if v.mapID then n=C_ChallengeMode.GetMapUIInfo(v.mapID)print(i,n or"?",v.mapID)end end
```

**Spell IDs:**
- Wago Tools: https://wago.tools/db2/Spell
- Wowhead: Search for teleport spell
- In-game: Use idTip addon

### 2. Update DungeonTeleport.lua

Add to `MAP_ID_TO_SPELL_IDS` table:

```lua
-----------------------------------------------------------
-- Midnight Expansion - Season 1
-----------------------------------------------------------
[600] = {445500}, -- Example Dungeon Name
[601] = {445501}, -- Another Dungeon
-- ... etc
```

For faction-specific teleports, also update `FACTION_SPECIFIC_TELEPORTS`:

```lua
[600] = {445500, 445501}, -- Example: Alliance spell, Horde spell
```

### 3. Update Version and Changelog

**DungeonTeleport.toc:**
```
## Version: 1.1.0
```

**CHANGELOG.md:**
```markdown
## [1.1.0] - 2026-XX-XX

### Added
- Midnight Season 1 dungeon teleport support
- 8 new dungeon teleports: [list dungeons]

[1.1.0]: https://github.com/dfrezell/DungeonTeleport/releases/tag/v1.1.0
```

### 4. Show Git Commands

```bash
# The user should run:
git add DungeonTeleport.lua DungeonTeleport.toc CHANGELOG.md
git commit -m "Add Midnight Season 1 dungeon teleports"
git push origin TASK-add_midnight_season_1_dungeons
```

## Code Style Guidelines

### Lua Conventions
- Use 4-space indentation
- Use descriptive variable names
- Add comments for complex logic
- Follow existing code patterns

### Comments
- Use `---` for function documentation
- Use `--` for inline comments
- Add section headers with dashes:
  ```lua
  -----------------------------------------------------------
  -- Section Name
  -----------------------------------------------------------
  ```

### Table Organization
- Group related items together
- Add comments for each expansion/season
- Keep chronological order (oldest to newest)

## Testing Guidelines

### Before Committing
1. **Syntax Check:** Ensure Lua code has no syntax errors
2. **Spell ID Validation:** Verify spell IDs exist and are correct
3. **Map ID Validation:** Confirm map IDs match current season
4. **Faction Support:** Check if dungeons need faction-specific teleports

### In-Game Testing
Recommend the user test:
1. Open Challenges UI (Shift+J)
2. Verify buttons appear on dungeon icons
3. Check tooltips show correct spell names and cooldowns
4. Test clicking icons (must have learned teleport spell)
5. Verify `/dt reload` command works

## Common Tasks

### Update Interface Version
When a new WoW patch releases:

**DungeonTeleport.toc:**
```
## Interface: 110207, 120000, 120100
```

Add new interface version to the comma-separated list.

### Fix a Bug

1. Create FIX branch (user creates)
2. Make code changes
3. Update CHANGELOG.md with patch version
4. Update version in .toc
5. Show commit commands

### Add New Feature

1. Create TASK branch (user creates)
2. Implement feature
3. Update CHANGELOG.md with minor version
4. Update version in .toc
5. Show commit commands

### TODO Tracking

1. Add follow-up items to `TODO.md`
2. As TODOs are completed, remove them from `TODO.md`
3. When adding or removing features, update `CHANGELOG.md` and `README.md`

## CurseForge Integration

### Automated Releases
- Triggered by pushing tags matching `v*` pattern
- Uploads to CurseForge project 1440396
- Creates GitHub release with changelog
- Supports Wago.io (if token configured)

### Manual CurseForge Updates
Not recommended - use automated workflow instead.

## Troubleshooting

### Release Failed
**Symptom:** GitHub Actions fails during release
**Solution:**
1. Check workflow permissions (needs `contents: write`)
2. Verify CF_API_KEY secret is set
3. Confirm tag format is `vX.X.X`

### TOC Errors
**Symptom:** Addon doesn't load in-game
**Solution:**
1. Check interface version matches game version
2. Verify .toc file syntax
3. Ensure file encoding is UTF-8

## Resources

- [WoW AddOn Documentation](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API)
- [Wago Tools Database](https://wago.tools/)
- [CurseForge Packager](https://github.com/BigWigsMods/packager)
- [Semantic Versioning](https://semver.org/)

## Questions?

When uncertain about:
- **Spell IDs:** Ask user to verify in-game or provide source
- **Feature direction:** Present options and let user decide
- **Breaking changes:** Warn about compatibility concerns
- **Version bump:** Suggest based on change type, let user confirm

## Remember

1. ✅ Make code changes
2. ✅ Update documentation
3. ✅ Update CHANGELOG.md
4. ✅ Show git commands
5. ❌ Don't execute git operations
6. ❌ Don't create commits
7. ❌ Don't push changes
8. ❌ Don't create tags

Let the user maintain control of their repository!
