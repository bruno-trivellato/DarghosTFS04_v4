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
	
	local COOLDOWN = 8
	
	if(doPlayerIsInBattleground(cid)) then
		local v = getPlayerStorageValue(cid, sid.BATTLEGROUND_LAST_MAGIC_WALL)
		local inCooldown = (v ~= -1 and v + COOLDOWN > os.time()) and true or false
		if(inCooldown) then
			local cooldownLeft = (v + COOLDOWN) - os.time()
			doPlayerSendCancel(cid, "Você está exausto para usar novamente esta runa, aguarde mais " .. cooldownLeft .. " segundos.")
			doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
			return false
		end
		
		setPlayerStorageValue(cid, sid.BATTLEGROUND_LAST_MAGIC_WALL, os.time())
	end

  local last = getTileState(var["pos"]["y"], var["pos"]["x"], var["pos"]["z"])

  if(last) then
      local now = os.mtime()

      if last + TILE_INTERVAL > now then
          doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
          return false
      end
  end

  createTileState(var["pos"]["y"], var["pos"]["x"], var["pos"]["z"])

	if getPlayerStorageValue(cid, sid.ENT_INSIDE) == 1 then
		doPlayerSendCancel(cid, "Runa não permitida dentro do evento.")
		doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)		
		return false
	end
	
	return doCombat(cid, combat, var)
end
