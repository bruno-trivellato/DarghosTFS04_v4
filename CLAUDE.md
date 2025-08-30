# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **DarghosTFS04_v4**, a Tibia game server based on The Forgotten Server (TFS) 0.4, used during version 8.6. This repository contains all changes to the Darghos server from its return in 2013 to around 2017, before implementing their proprietary client.

## Architecture

This is a C++ game server application with the following structure:

- **Main executable**: `tfs` - built from `src/src/otserv.cpp` (contains main function)
- **Core source**: Located in `src/src/` with 170+ C++ files implementing game mechanics
- **Game data**: Located in `data/` containing Lua scripts, XML configurations, and game content:
  - `actions/` - Action scripts
  - `creaturescripts/` - Creature behavior scripts  
  - `globalevents/` - Server-wide event scripts
  - `items/` - Item definitions
  - `lib/` - Lua libraries
  - `monster/` - Monster definitions
  - `movements/` - Movement scripts

## Build System

The project uses **CMake** as its build system:

### Required Dependencies
- libboost (tested with 1.48/1.49)
- libxml2
- libgmp3
- libssl
- liblua5.1-0-dev
- MySQL (optional)
- LuaJIT (optional, falls back to Lua)
- ZLIB
- OpenSSL

### Build Commands
```bash
mkdir build && cd build
cmake ..
make
```

### Custom Build Definitions
The server includes several Darghos-specific compile-time definitions:
- `__DARGHOS_CUSTOM__`
- `__DARGHOS_EMERGENCY_DDOS__`
- `__NO_CRYPTOPP__`
- `__USE_MYSQL__`
- `__WAR_SYSTEM__`
- `__TFS_NEWEST_REVS_FIXIES__`

## Key Components

- **Game Engine**: Core game logic in files like `game.cpp`, `player.cpp`, `creature.cpp`
- **Network Layer**: Protocol handling in `protocol*.cpp` files
- **Database**: MySQL integration via `iologindata.cpp`, `database.cpp`
- **Scripting**: Lua integration for game events and actions
- **Combat System**: Combat mechanics in `combat.cpp`
- **Map System**: World management in `map.cpp`, `tile.cpp`
- **Items & Spells**: Item system and spell mechanics

## Development Notes

- The codebase targets older C++ standards (pre-C++11)
- Uses Boost libraries extensively for threading, filesystem, and networking
- Lua scripting system allows runtime modification of game behavior
- MySQL database backend for player data persistence
- Custom Darghos modifications include PvP systems and anti-DDoS measures