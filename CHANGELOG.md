# Dungeon Teleport - Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/dfrezell/DungeonTeleport/releases/tag/v1.0.0
