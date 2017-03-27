MINIONS_AREA = {
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
}

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)

function onTargetCreature(cid, target) 
	if(string.lower(getCreatureName(target)) == "behemoth") then
		doCreatureSay(target, "My KING! Here my's life for you!", TALKTYPE_MONSTER_YELL)
		local fullHp = getCreatureMaxHealth(target)
		local kingHealth = getCreatureHealth(cid)
		doCreatureAddHealth(target, -getCreatureHealth(target), CONST_ME_HEARTS, COLOR_GREY)
		doCreatureAddHealth(cid, fullHp, CONST_ME_MAGIC_BLUE)
	end
end

setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

local area = createCombatArea(MINIONS_AREA)
setCombatArea(combat, area)	

local NEXT_PHASE_HEALTH = 90

local SUMMON_BEHEMOTHS_INTERVAL = 1000 * 20

local INTERNAL_TICKS = 0
local TICKSADD = 1000 * 2

function onCastSpell(cid, var)
	INTERNAL_TICKS = INTERNAL_TICKS + TICKSADD

	if(INTERNAL_TICKS >= SUMMON_BEHEMOTHS_INTERVAL) then
		summonBehemoths(cid)
	end

	local lifePercent = math.floor((getCreatureHealth(cid) * 100) / getCreatureMaxHealth(cid))

	if(lifePercent <= NEXT_PHASE_HEALTH) then
		NEXT_PHASE_HEALTH = NEXT_PHASE_HEALTH - 10
		doCombat(cid, combat, var)
	end
end

function summonBehemoths(cid)
	INTERNAL_TICKS = 0

	local pos = getCreaturePosition(cid)

	local list = getSpectators({x = 1995, y = 1820, z = 15}, 18, 18, false)
	local behemoths = 0

	local plist = {}
	for k,v in ipairs(list) do
		if string.lower(getCreatureName(v)) == "behemoth" then
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
			{x = 1996, y = 1812, z = 15},
			{x = 1998, y = 1812, z = 15},
			{x = 2000, y = 1814, z = 15},
			{x = 2004, y = 1818, z = 15},
			{x = 2006, y = 1820, z = 15},
			{x = 2005, y = 1822, z = 15},
			{x = 1998, y = 1828, z = 15},
			{x = 1995, y = 1828, z = 15},
			{x = 1993, y = 1828, z = 15},
			{x = 1988, y = 1822, z = 15},
			{x = 1988, y = 1820, z = 15},
			{x = 1989, y = 1818, z = 15},
			{x = 1990, y = 1812, z = 15},
			{x = 1989, y = 1829, z = 15},
			{x = 2003, y = 1831, z = 15},
			{x = 2005, y = 1825, z = 15}
		}

		local used = table.copy(behe_positions)

		for i=1, 8 do
			local pos = math.random(1, #used)
			
			if not doCreateMonster("behemoth", used[pos], false, false, false) then
				std.clog("[Behemoth King Minions] No place found to summon")
			end

			table.remove(used, pos)
		end
	end
end