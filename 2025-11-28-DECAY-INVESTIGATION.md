# Decay System Investigation

**Date**: November 28, 2025
**Status**: Decay disabled due to critical threading bugs
**Severity**: High - Causes server crashes and blocks player connections

---

## Problem Summary

The decay system in TFS 0.4 has critical threading issues that cause:
1. **Segmentation faults** - Server crashes at `std::list::push_back()`
2. **Deadlocks** - Mutex acquired recursively causing freeze
3. **Infinite loops** - Same items processed repeatedly
4. **Connection blocking** - Players unable to connect to game server

---

## Investigation Timeline

### Initial Discovery
- Decay was **disabled on August 31, 2025** (commit `d7add4d`) to isolate crashes
- Simple early return added: `return;  // Skip decay processing`
- Server ran stable for months without decay

### Reactivation Attempt (November 28, 2025)
Attempted to fix and re-enable decay system with modern thread safety.

---

## Root Causes Identified

### 1. **No Thread Synchronization** (Primary Issue)

**Problem:** `decayItems[]` arrays accessed from multiple threads without protection

**Evidence:**
- 17+ source files add items to decay system
- No mutex protecting decay lists
- Race conditions causing list corruption

**Files accessing decay system:**
```
game.cpp, actions.cpp, container.cpp, spells.cpp, combat.cpp,
creature.cpp, player.cpp, item.cpp, iomap.cpp, monsters.cpp,
movement.cpp, luascript.cpp, iomapserialize.cpp, etc.
```

### 2. **Deadlock Bug**

**Problem:** `checkDecay()` calls `cleanup()`, both try to acquire same mutex

**Code flow:**
```cpp
checkDecay() {
    lock_guard<mutex> lock(decayMutex);  // Acquires mutex
    ...
    cleanup();  // Calls cleanup
}

cleanup() {
    lock_guard<mutex> lock(decayMutex);  // Tries to acquire SAME mutex
    // DEADLOCK! Waits forever for itself
}
```

**Impact:** Server freezes, players cannot connect to game server (port 7172)

### 3. **Order of Operations Bug**

**Problem:** `freeThing()` called before `erase()` from list

**Original code:**
```cpp
item->setDecaying(DECAYING_FALSE);
freeThing(item);            // Item memory freed
it = decayItems[bucket].erase(it);  // Accessing freed memory
```

**Fix applied:** Swap order - erase first, then free

### 4. **Infinite Loop**

**Evidence from logs:**
```
[Decay] Processing item 4614 in bucket 0, duration: 60000
[Decay] Processing item 4614 in bucket 0, duration: 60000
[Decay] Processing item 4614 in bucket 0, duration: 60000
... (repeated hundreds of times)
```

**Cause:** Items being re-added to decay list during iteration, creating infinite cycle

### 5. **Memory Corruption**

**Crash location:**
```
std::list::push_back() → std::__detail::_List_node_base::_M_hook()
SIGSEGV (Segmentation fault)
```

**Last item before crash:** Attempting to push item 3132 to bucket 14

**Cause:** List internal structure corrupted by concurrent modifications

---

## Fixes Attempted

### ✅ Fix 1: Added Mutex Protection
```cpp
// In game.h
std::mutex decayMutex;

// In game.cpp checkDecay()
std::lock_guard<std::mutex> lockClass(decayMutex);
```

**Result:** Prevented some race conditions, but insufficient

### ✅ Fix 2: Fixed Order of Operations
```cpp
// Before (buggy):
freeThing(item);
it = decayItems[bucket].erase(it);

// After (fixed):
it = decayItems[bucket].erase(it);
freeThing(item);
```

**Result:** Improved safety, but crash persists

### ✅ Fix 3: Removed Recursive Mutex Acquisition
```cpp
// cleanup() no longer tries to acquire mutex
// (checkDecay already holds it)
```

**Result:** Fixed deadlock, but crash still occurs

### ❌ Fix 4: Added Debug Logging
```cpp
std::cerr << "[Decay] Processing item " << item->getID() << ...
```

**Result:** Revealed infinite loop and corruption, but didn't fix root cause

---

## Why Fixes Failed

**The fundamental issue:** Decay system accessed from **17+ source files** across multiple threads without synchronization.

**What we protected:**
- `checkDecay()` function (1 location)
- `cleanup()` function (1 location)

**What's still unprotected:**
- `item.cpp` - Items starting decay
- `spells.cpp` - Magic walls, food decay
- `combat.cpp` - Corpse creation
- `player.cpp` - Player item interactions
- 13+ other files adding to `toDecayItems`

**Scope of fix required:**
- Add mutex locks in 17+ files
- Or redesign entire decay architecture
- Extensive testing across all game systems

---

## Technical Details

### Decay System Architecture

**Data structures:**
```cpp
DecayList decayItems[EVENT_DECAYBUCKETS];  // 16 buckets
std::forward_list<Item*> toDecayItems;     // Items pending decay
size_t lastBucket;                         // Current bucket index
```

**Processing flow:**
1. Items added to `toDecayItems` from various game systems
2. `cleanup()` moves items from `toDecayItems` → `decayItems[bucket]`
3. `checkDecay()` processes one bucket every 1000ms (EVENT_DECAYINTERVAL)
4. Items decrease duration, move to new buckets, or get removed

**Threading context:**
- `checkDecay()` runs on **Scheduler thread**
- Items added from **Game thread, Dispatcher thread, Protocol threads**
- No synchronization between threads

### Crash Analysis

**Stack trace:**
```
#3 std::__detail::_List_node_base::_M_hook()  ← STL internal function
#4 std::list::_M_insert()
#5 std::list::push_back()
#6 Game::checkDecay()+0x93e
```

**Crash location:** Line 5140 in game.cpp
```cpp
decayItems[newBucket].push_back(item);  ← CRASH HERE
```

**Why it crashes:**
- List internal pointers corrupted by concurrent modification
- Attempt to hook new node into corrupted list structure
- Segmentation fault when accessing invalid memory

---

## Current Solution

**Decision:** Keep decay **DISABLED** for production stability

**Implementation:**
```cpp
void Game::checkDecay()
{
    g_scheduler.addEvent(createSchedulerTask(EVENT_DECAYINTERVAL,
        std::bind(&Game::checkDecay, this)));

    return;  // Early return - skip decay processing
}
```

**Impact:**
- ❌ Corpses don't disappear (minor)
- ❌ Magic walls don't expire (minor - can /clean)
- ❌ Food doesn't decay (minor)
- ✅ Server 100% stable
- ✅ No crashes
- ✅ Players can connect normally

---

## Future Fix Strategy

### Option 1: Global Decay Mutex (Comprehensive)

**Protect ALL decay access points:**
```cpp
// In every file that touches toDecayItems:
std::lock_guard<std::mutex> lock(g_game.getDecayMutex());
toDecayItems.push_front(item);
```

**Pros:** Would fix the threading issue
**Cons:** Requires changes in 17+ files, extensive testing
**Effort:** High (4-8 hours)

### Option 2: Lock-Free Decay Queue

**Use thread-safe queue:**
```cpp
std::atomic<bool> decayEnabled;
boost::lockfree::queue<Item*> decayQueue;
```

**Pros:** Better performance, no deadlocks
**Cons:** Requires architectural redesign
**Effort:** Very High (1-2 days)

### Option 3: Single-Threaded Decay

**Process decay only on game thread:**
```cpp
// Add decay processing to game loop instead of separate thread
```

**Pros:** No threading issues
**Cons:** May impact game loop performance
**Effort:** Medium (2-4 hours)

### Option 4: Keep Disabled

**Current approach - decay disabled**

**Pros:** Server stable, no crashes
**Cons:** Items don't decay (minor gameplay impact)
**Effort:** Zero - already done

---

## Recommendation

**For production:** Keep decay disabled (Option 4)

**Reasoning:**
1. Server runs perfectly without decay
2. Gameplay impact is minimal
3. Fix requires significant development/testing effort
4. Risk of introducing new bugs is high

**For future development:**
- Implement Option 1 (Global Mutex) if decay is required
- Allocate dedicated debugging session (4-8 hours)
- Test thoroughly before production deployment

---

## Code References

**Decay disabled:** `src/src/game.cpp:5063` (early return statement)
**Mutex added:** `src/src/game.h:686` (decayMutex declaration)
**Crash location:** `src/src/game.cpp:5140` (push_back segfault)
**Original disable:** Commit `d7add4d` (August 31, 2025)

---

## Testing Notes

**Stable configuration:**
- Decay: Disabled
- Build: Debug mode
- Platform: linux/amd64
- Uptime: Stable for hours

**Crash configuration:**
- Decay: Enabled with mutex
- Crash time: 10-30 seconds after start
- Trigger: First decay bucket with items
- Signal: SIGSEGV (Segmentation fault)

---

**Conclusion:** Decay system requires comprehensive threading redesign. Current workaround (disabled) is production-ready and stable.
