local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)

local AREA = {
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
}

local area = createCombatArea(AREA)
setCombatArea(combat, area)

local foundTiles = {}

function onTargetTile(cid, pos)
	table.insert(foundTiles, pos)
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETTILE, "onTargetTile")

local toSummon = 4

function onCastSpell(cid, var)

	local list = getSpectators(getCreaturePosition(cid), 18, 18, false)

	toSummon = 4
	if #list > 0 then
		for k,v in ipairs(list) do
			if string.lower(getCreatureName(v)) == "dark priestess" then
				toSummon = toSummon - 1
			end
		end
	end

	if(toSummon > 0) then
		addEvent(summonPriestess, 1000 * 3, cid)
		return doCombat(cid, combat, var)
	end

	return true	
end

function summonPriestess(cid)

	doCreatureSay(cid, "HEALERS! COME AND HEAL ME!", TALKTYPE_MONSTER_YELL)
	for i = 1, toSummon do
		if #foundTiles == 0 then
			std.clog("[Dark General Summon Dark Priestess] No available tile found to summon")
			break
		end

		local pos = math.random(1, #foundTiles)

		if not doCreateMonster("Dark Priestess", foundTiles[pos], false, false, false) then
			std.clog("[Dark General Summon Dark Priestess] No place found to summon")
		end

		table.remove(foundTiles, pos)			
	end

	foundTiles = {}
end