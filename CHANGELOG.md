# Dungeon Teleport - Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-01-25

### Added
- Raid teleport button support in Encounter Journal (Adventure Guide)
- Two button locations for raid teleports:
  - Location 1: Overlay buttons on raid entries in the Adventure Guide raid list
  - Location 2: Standalone "Teleport" button inside individual raid journals (bottom-right)
- Support for Manaforge Omega raid teleport (spell ID: 1239155)
- Placeholder structure for all expansion raids with teleport spells
- Faction-specific raid teleport handling framework
- New slash command: `/dt raids` - Lists all raids with teleport spells
- Hooks into Blizzard_EncounterJournal addon for raid UI integration

### Changed
- Extended `/dt reload` command to refresh both dungeon and raid buttons
- Updated help text to include raid functionality
- Enhanced addon architecture with modular raid teleport system
- Updated localized descriptions to mention raid support

### Technical
- New module: Raid Teleport System
- New data table: `RAID_INSTANCE_TO_SPELL_IDS`
- New data table: `RAID_FACTION_SPECIFIC_TELEPORTS`
- New functions: `InitializeRaidTeleports()`, `CreateRaidListButton()`, `CreateRaidListButtons()`, `CreateRaidJournalButton()`, `UpdateRaidButtons()`, `ApplyFactionSpecificRaidTeleports()`, `GetSpellForTeleport()`, `ApplyButtonState()`, `ShowSpellTooltip()`
- Reuses existing utilities: `UpdateGameTooltip()`, `GetGCDDuration()`
- Event handler now listens for `Blizzard_EncounterJournal` addon loading
- Raid list integration supports ScrollBox callbacks and disables unknown spell buttons

## [1.1.0] - 2026-01-25

### Added
- Midnight Season 1 dungeon teleport support
- 7 new dungeon teleports:
  - Windrunner Spire
  - Skyreach
  - Seat of the Triumvirate
  - Pit of Saron
  - Nexus-Point Xenas
  - Maisara Caverns
  - Magisters' Terrace
- Localized addon titles and descriptions for all 11 WoW languages
- Wago.io integration for automated releases
- Development documentation (AGENTS.md)

### Changed
- Enhanced README with comprehensive development workflow
- Improved release automation with Wago.io support

## [1.0.1] - 2026-01-21

### Changed
- Updated `.pkgmeta` to exclude `images` directory from CurseForge releases
- Improved packaging configuration to reduce addon download size
- Add TOC metadata

## [1.0.0] - 2026-01-21

### Added
- Initial release of DungeonTeleport addon
- Converted from WeakAura to standalone addon
- Click-to-teleport functionality on dungeon icons in Challenges UI
- Real-time cooldown tooltips with automatic updates
- Support for all Dragonflight seasons (S1, S2, S3)
- Support for all War Within seasons (S1, S2, S3)
- Faction-specific teleport handling (Alliance/Horde)
- Independent GCD tracking (no WeakAuras dependency)
- Slash commands: `/dt`, `/dt reload`, `/dt help`
- Prepared structure for Midnight expansion dungeons
- Multi-interface support (11.0.7, 12.0.0, 12.0.1)

### Technical Details
- Hooks into Blizzard_ChallengesUI for seamless integration
- Uses secure action button templates for combat safety
- Automatic button creation and refresh on UI updates
- Memory-efficient tooltip timer management
- Button caching to prevent unnecessary recreation

### Known Issues
- Midnight expansion dungeon teleport spells need to be added when available
- Buttons cannot be created during combat (Blizzard limitation)

---

[1.2.0]: https://github.com/dfrezell/DungeonTeleport/releases/tag/v1.2.0
[1.1.0]: https://github.com/dfrezell/DungeonTeleport/releases/tag/v1.1.0
[1.0.1]: https://github.com/dfrezell/DungeonTeleport/releases/tag/v1.0.1
[1.0.0]: https://github.com/dfrezell/DungeonTeleport/releases/tag/v1.0.0
