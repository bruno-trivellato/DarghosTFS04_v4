local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)
setCombatParam(combat, COMBAT_PARAM_CREATEITEM, 1497)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

local TILE_INTERVAL = 20500 -- miliseconds, 20 to magic wall duration

local _POSITIONS = {

}

local function getTileState(y, x, z)
    if not _POSITIONS[y]  then
        return false
    end

    if not _POSITIONS[y][x]  then
        return false
    end

    if not _POSITIONS[y][x][z]  then
        return false
    end

    return _POSITIONS[y][x][z]
end

local function createTileState(y, x, z)

    if not _POSITIONS[y]  then
        table.insert(_POSITIONS, y, {})
    end

    if not _POSITIONS[y][x]  then
        table.insert(_POSITIONS[y], x, {})
    end

    if not _POSITIONS[y][x][z]  then
        table.insert(_POSITIONS[y][x], z, os.mtime())
	else
		_POSITIONS[y][x][z] = os.mtime()
    end
end

function onCastSpell(cid, var)

    local last = getTileState(var["pos"]["y"], var["pos"]["x"], var["pos"]["z"])

    if(last) then
        local now = os.mtime()

        if last + TILE_INTERVAL > now then
            doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
            return false
        end
    end

    createTileState(var["pos"]["y"], var["pos"]["x"], var["pos"]["z"])
	return doCombat(cid, combat, var)
end