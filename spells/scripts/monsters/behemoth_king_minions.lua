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

	local list = getSpectators(pos, 10, 10, false)
	local behemoths = 0

	for k,v in ipairs(list) do
		if string.lower(getCreatureName(v)) == "behemoth" then
			behemoths = behemoths + 1
		end
	end

	if(behemoths <= 16) then
		doCreatureSay(cid, "BEHEMOTHS COME AND SERVE YOUR MASTER!", TALKTYPE_MONSTER_YELL)

		
		local respawn = {{name = "behemoth", count = 8}};

		doCreateRespawnArea(respawn, pos, 7)
	end
end