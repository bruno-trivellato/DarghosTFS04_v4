function findMinions(cid) 
	local list = getSpectators({x = 1988, y = 1810, z = 15}, 18, 18, false)

	for k,v in ipairs(list) do
		if(string.lower(getCreatureName(v)) == "king minion") then
			doCreatureSay(v, "My KING! Here's my life for you!", TALKTYPE_MONSTER_YELL)
			local fullHp = getCreatureMaxHealth(v)
			local kingHealth = getCreatureHealth(cid)
			doCreatureAddHealth(v, -getCreatureHealth(v), CONST_ME_HEARTS, COLOR_GREY)
			doCreatureAddHealth(cid, fullHp, CONST_ME_MAGIC_BLUE)
		end
	end
end

local NEXT_PHASE_HEALTH = 90

local SUMMON_BEHEMOTHS_INTERVAL = 1000 * 20

local INTERNAL_TICKS = 0
local TICKSADD = 1000 * 2

function onCastSpell(cid, var)
	INTERNAL_TICKS = INTERNAL_TICKS + TICKSADD

	if(INTERNAL_TICKS >= SUMMON_BEHEMOTHS_INTERVAL) then
		summonMinions(cid)
	end

	local lifePercent = math.floor((getCreatureHealth(cid) * 100) / getCreatureMaxHealth(cid))

	if(lifePercent <= NEXT_PHASE_HEALTH) then
		NEXT_PHASE_HEALTH = NEXT_PHASE_HEALTH - 10
		findMinions(cid)
	end
end

function summonMinions(cid)
	INTERNAL_TICKS = 0

	local pos = getCreaturePosition(cid)

	local list = getSpectators({x = 1988, y = 1810, z = 15}, 18, 18, false)
	local behemoths = 0

	local plist = {}
	for k,v in ipairs(list) do
		if string.lower(getCreatureName(v)) == "king minion" then
			behemoths = behemoths + 1
		end

		if isPlayer(v) then
			table.insert(plist, v)
		end
	end

	if(behemoths <= 16) then
		doCreatureSay(cid, "BEHEMOTHS COME AND SERVE YOUR MASTER!", TALKTYPE_MONSTER_YELL)

		for k,v in ipairs(plist) do
			doPlayerSendTextMessage(v, MESSAGE_STATUS_CONSOLE_BLUE, "Behemoth King invocou alguns Behemoths para ajudar! Mate os para evitar que o boss se cure!")
		end
		
		local behe_positions = {
			{x = 1995, y = 1815, z = 15},
			{x = 1997, y = 1818, z = 15},
			{x = 1995, y = 1821, z = 15},
			{x = 1988, y = 1821, z = 15},
			{x = 1986, y = 1818, z = 15},
			{x = 1988, y = 1815, z = 15},
			{x = 1989, y = 1810, z = 15},
			{x = 1996, y = 1811, z = 15},
			{x = 2001, y = 1811, z = 15},
			{x = 2002, y = 1817, z = 15},
			{x = 2001, y = 1821, z = 15},
			{x = 1999, y = 1825, z = 15},
			{x = 1995, y = 1826, z = 15},
			{x = 1990, y = 1826, z = 15},
			{x = 1985, y = 1825, z = 15},
			{x = 1983, y = 1822, z = 15},
			{x = 1982, y = 1817, z = 15},
			{x = 1984, y = 1811, z = 15}
		}

		local used = table.copy(behe_positions)

		for i=1, 8 do
			local pos = math.random(1, #used)
			
			if not doCreateMonster("King Minion", used[pos], false, false, false) then
				std.clog("[Behemoth King Minions] No place found to summon")
			end

			table.remove(used, pos)
		end
	end
end