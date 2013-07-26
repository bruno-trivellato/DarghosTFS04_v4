local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_BLOCKARMOR, TRUE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_WEAPONTYPE)
setCombatParam(combat, COMBAT_PARAM_USECHARGES, TRUE)

if(darghos_distro == DISTROS_TFS) then
	function getSpellDamage(cid, level, weaponSkill, weaponAttack, attackStrength)
        --[[
		local min = (((weaponSkill+weaponAttack)/3)+(level/5))
		local max = ((weaponSkill+weaponAttack)+(level/5))
	
		return -min, -max
		]]

        -- 8.3 formula
        local maxWeaponDamage = ((weaponSkill * (weaponAttack * 0.0425)) + (weaponAttack * 0.2)) * 2	
		
		local missChance = 10
		
		if(level > 75) then
			missChance = 8
		elseif(level > 125) then
			missChance = 5
		elseif(level > 200) then
			missChance = 3			
		elseif(level > 250) then
			missChance = 1	
		end
		
		if(math.random(1, 100) <= missChance) then	
			return 0, 0
		end
		
		local avgNormalDmg = math.random(math.floor(maxWeaponDamage / 2))
		local avgFullDmg = maxWeaponDamage
		
		local fullHitChance = 20
		local minFullHit = math.floor(maxWeaponDamage * 0.9)
		local damage = math.random(avgNormalDmg, avgFullDmg)
		
		if(damage < minFullHit and math.random(1, 100) <= fullHitChance) then
			damage = math.random(minFullHit, avgFullDmg)
		end
		
        return -damage, -damage
	end
elseif(darghos_distro == DISTROS_OPENTIBIA) then
	function getSpellDamage(cid, weaponSkill, weaponAttack, attackStrength)
		local level = getPlayerLevel(cid)
	
		local min = (((weaponSkill+weaponAttack)/3)+(level/5))
		local max = ((weaponSkill+weaponAttack)+(level/5))
	
		return -min, -max
	end
end


setCombatCallback(combat, CALLBACK_PARAM_SKILLVALUE, "getSpellDamage")

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
