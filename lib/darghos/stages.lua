STAGES_EXPERIENCE = 1
STAGES_EXP_PROTECTED = 2
STAGES_SKILLS = 3
STAGES_MAGIC = 4
STAGES_EXP_TENERIAN = 5

SKILL_STAGE_MAGES = 2
SKILL_STAGE_NON_LOGOUT_PLAYERS = SKILL_STAGE_MAGES

stages = {
	[STAGES_EXPERIENCE] = {
		{start_level = 8, multipler = 2}
	},
	
	--[[
	[STAGES_SKILLS] = {
		knight = {
			{end_level = 39, multipler = 300}, 
			{start_level = 40, end_level = 79, multipler = 200}, 
			{start_level = 80, end_level = 84, multipler = 100}, 
			{start_level = 85, end_level = 109, multipler = 50}, 
			{start_level = 110, end_level = 119, multipler = 25}, 
			{start_level = 120, end_level = 124, multipler = 10},
			{start_level = 125, multipler = 8}
		},
		paladin = {
			{end_level = 49, multipler = 300},  
			{start_level = 50, end_level = 89, multipler = 200}, 
			{start_level = 90, end_level = 94, multipler = 100}, 
			{start_level = 95, end_level = 119, multipler = 50}, 
			{start_level = 120, end_level = 129, multipler = 25}, 
			{start_level = 129, end_level = 134, multipler = 10}, 
			{start_level = 135, multipler = 8}			
		}
	},
	
	[STAGES_MAGIC] = {
		mage = {
			{end_level = 24, multipler = 50}, 
			{start_level = 25, end_level = 39, multipler = 30}, 
			{start_level = 40, end_level = 59, multipler = 15}, 
			{start_level = 60, end_level = 69, multipler = 10}, 
			{start_level = 70, end_level = 79, multipler = 8}, 
			{start_level = 80, end_level = 89, multipler = 5}, 
			{start_level = 90, end_level = 94, multipler = 4}, 
			{start_level = 95, end_level = 99, multipler = 3}, 
			{start_level = 100, end_level = 104, multipler = 2}, 
			{start_level = 105, multipler = 1}
		},
		paladin = {
			{end_level = 9, multipler = 50}, 
			{start_level = 10, end_level = 19, multipler = 30}, 
			{start_level = 20, end_level = 24, multipler = 15}, 
			{start_level = 25, end_level = 29, multipler = 10}, 
			{start_level = 30, end_level = 31, multipler = 5}, 
			{start_level = 32, multipler = 2}			
		},
		knight = {
			{end_level = 3, multipler = 50}, 
			{start_level = 4, end_level = 5, multipler = 30}, 
			{start_level = 6, end_level = 8, multipler = 15}, 
			{start_level = 9, end_level = 10, multipler = 10}, 
			{start_level = 10, end_level = 11, multipler = 5}, 
			{start_level = 12, multipler = 2}
		}
	},
	]]
	
	[STAGES_EXP_PROTECTED] = {
		{start_level = 8, multipler = 1}
	},	
}

function getPlayerMultiple(cid, stagetype, skilltype)

	local _stages = stages[stagetype]
	
	if(_stages == nil) then
		-- skip?
		return 1
	end
	
	if(getPlayerTown(cid) == towns.ISLAND_OF_PEACE and darghos_use_protected_stages and stagetype == STAGES_EXPERIENCE) then
		_stages = stages[STAGES_EXP_PROTECTED]
	end

	local world_id = getConfigValue('worldId')
	if(world_id == WORLD_TENERIAN) then
		_stages = stages[STAGES_EXP_TENERIAN]
	end
	
	if(stagetype == STAGES_MAGIC or stagetype == STAGES_SKILLS) then
		if(isSorcerer(cid) or isDruid(cid)) then
			if(stagetype == STAGES_MAGIC) then
				_stages = _stages.mage
			else
				return SKILL_STAGE_MAGES
			end
		elseif(isPaladin(cid)) then
			if(skilltype == SKILL_DISTANCE) then
				_stages = _stages.paladin
			else
				_stages = _stages.knight
			end
		elseif(isKnight(cid)) then
			_stages = _stages.knight
		end
	end
	
	local skipedNames = {"Little Mystyk", "Boltada Maligna"}
	if(isInArray({STAGES_SKILLS, STAGES_MAGIC}, stagetype) and getPlayerGroupId(cid) == GROUPS_PLAYER_BOT and not isInArray(skipedNames, getPlayerName(cid))) then
		return SKILL_STAGE_NON_LOGOUT_PLAYERS
	end
	
	for k,v in pairs(_stages) do
	
		local attribute = getPlayerLevel(cid)
		
		if(stagetype == STAGES_MAGIC) then
			attribute = getPlayerMagLevel(cid, true)
		elseif(stagetype == STAGES_SKILLS) then
			attribute = getPlayerSkillLevel(cid, skilltype)
		end
	
		local start_level = v.start_level or 0
		local lastStage = (v.end_level == nil) and true or false
		
		if(lastStage and attribute >= start_level) then
			return v.multipler
		end
		
		if(not lastStage) then
			if(attribute >= start_level and attribute <= v.end_level) then
				return v.multipler
			end
		end
	end
	
	return 1
end

function isStagedSkill(skilltype, includeMagic)
	includeMagic = includeMagic or false 
	
	local skills = {SKILL_CLUB, SKILL_SWORD, SKILL_AXE, SKILL_DISTANCE, SKILL_SHIELD}
	
	if(includeMagic) then
		table.insert(skills, SKILL__MAGLEVEL)
	end

	return isInArray(skills, skilltype)
end

function changeStage(cid, skilltype, multiple)

	if(skilltype == SKILL__LEVEL) then
		
		local changePvpDebuffExpire = getPlayerStorageValue(cid, sid.CHANGE_PVP_EXP_DEBUFF)		
		local changePvpDebuff = 1
		
		if(changePvpDebuffExpire ~= nil and os.time() < changePvpDebuffExpire)  then
			changePvpDebuff = round(darghos_change_pvp_debuff_percent / 100, 2)
		end
		
		local expSpecialBonus = 0
		
		local lastKillDarkGeneral = getStorage(gid.LAST_KILL_DARK_GENERAL)
		
		
		if(lastKillDarkGeneral > 0 and time() < lastKillDarkGeneral + (darghos_kill_dark_general_exp_bonus_days * 60 * 60 * 24)) then
			local endEvent = os.date("*t", lastKillDarkGeneral + (darghos_kill_dark_general_exp_bonus_days * 60 * 60 * 24))
			local now = os.date("*t")
			if(now.day <= endEvent.day) then
				expSpecialBonus = darghos_kill_dark_general_exp_bonus_percent
			end
		end	
		
		local expSpecialBonusEnd = getPlayerStorageValue(cid, sid.EXP_MOD_ESPECIAL_END)
		
		 if(expSpecialBonusEnd ~= -1  and os.time() <= expSpecialBonusEnd) then
			
		 	expSpecialBonus = expSpecialBonus + ((getPlayerStorageValue(cid, sid.EXP_MOD_ESPECIAL) > 0) and tonumber(getPlayerStorageValue(cid, sid.EXP_MOD_ESPECIAL)) or 0)
		 end

		 if(getPlayerStorageValue(cid, sid.DOUBLE_EXP_EVENT) == 1) then
		 	expSpecialBonus = expSpecialBonus + 100
		 end
		 
		 expSpecialBonus = round(expSpecialBonus / 100) + 1.00
		 
		setExperienceRate(cid, multiple * darghos_exp_multipler * changePvpDebuff * expSpecialBonus)
		
	elseif(isStagedSkill(skilltype, true)) then
		setSkillRate(cid, skilltype, multiple * darghos_skills_multipler)
	else
		print("changeStage() | Unknown skilltype " .. skilltype .. " when change the stage for " .. getPlayerName(cid) .. " by " .. multiple .. "x.")
	end
end

function reloadExpStages(cid)
	changeStage(cid, SKILL__LEVEL, getPlayerMultiple(cid, STAGES_EXPERIENCE))
end

function setStagesOnLogin(cid)

	local v = getPlayerMultiple(cid, STAGES_EXPERIENCE)
	if v ~= 0 then
		changeStage(cid, SKILL__LEVEL, v)
	end
	
	v = getPlayerMultiple(cid, STAGES_MAGIC)
	
	if v ~= 0 then
		changeStage(cid, SKILL__MAGLEVEL, v)
	end
	
	for i = SKILL_CLUB, SKILL_SHIELD do
		changeStage(cid, i, getPlayerMultiple(cid, STAGES_SKILLS, i))
	end	
end

function setStageType(cid, skilltype) setStageOnAdvance(cid, skilltype) end
function setStageOnAdvance(cid, skilltype)

	if(isStagedSkill(skilltype)) then
		changeStage(cid, skilltype, getPlayerMultiple(cid, STAGES_SKILLS, skilltype))
	elseif(skilltype == SKILL__MAGLEVEL) then
		changeStage(cid, SKILL__MAGLEVEL, getPlayerMultiple(cid, STAGES_MAGIC))
	elseif(skilltype == SKILL__LEVEL) then
		changeStage(cid, SKILL__LEVEL, getPlayerMultiple(cid, STAGES_EXPERIENCE))
	end
end

function setStageOnChangePvp(cid)
	reloadExpStages(cid)
end