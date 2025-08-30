# DarghosTFS04_v4
Darghos baseado no TFS 0.4 usado durante a versão 8.6

Este repositorio contem todas as alterações do Darghos após a sua volta em 2013 até por volta de 2017, antes da implementação do cliente proprio.

## Development Environment Setup (Updated 2025)

This project has been updated to compile with modern Docker environments. The original recommendation of Debian 7 was outdated due to the codebase using C++11 features that require newer compilers.

### Current Status
- ✅ **Docker Environment**: Updated to Debian 9 (Stretch) with GCC 6.3 for full C++11 support
- ✅ **Build System**: CMake configuration working with all required dependencies
- ✅ **Dependencies Resolved**: Boost 1.62, LibXML2, MySQL/MariaDB, OpenSSL, Lua 5.1, ZLIB
- ✅ **C++11 Compatibility**: Fixed access control issues in `protocolgame.h` 
- ✅ **Code Fixes**: Added missing `BotScriptAction_t` enum definition in `spoof.h`
- 🔧 **Current Build**: ~95% compilation success, final linking pending

### Quick Start
```bash
# Build the Docker environment
./build.sh

# Run the server (after successful compilation)
./run.sh

# Access development shell
./shell.sh
```

### Recent Fixes Applied
1. **Moved private methods to public in `protocolgame.h`**: Fixed access control issues where Player class methods were calling private ProtocolGame methods
2. **Added missing enum in `spoof.h`**: Defined `BotScriptAction_t` enum with BSA_MOVE, BSA_MOVE_DIR, etc.
3. **Docker modernization**: Updated from Debian 7 to Debian 9 for proper C++11 compiler support
4. **Package updates**: Updated library package names for current Debian repositories

### Architecture Overview
- **Language**: C++ with C++11 features (std::atomic, std::thread, std::chrono, etc.)
- **Build System**: CMake with custom Darghos definitions
- **Database**: MySQL/MariaDB support
- **Scripting**: Lua 5.1 for game logic
- **Network**: Custom protocol implementation
- **Platform**: Originally designed for Linux, now containerized for cross-platform development

### Key Darghos Features
- Custom PvP system (`__DARGHOS_PVP_SYSTEM__`)
- Anti-DDoS measures (`__DARGHOS_EMERGENCY_DDOS__`)
- War system (`__WAR_SYSTEM__`)
- Custom spells and mechanics
- Bot/anti-bot systems (spoof.h, spoofbot.cpp)
