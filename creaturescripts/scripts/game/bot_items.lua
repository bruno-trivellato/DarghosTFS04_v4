local function string(o)
    return '"' .. tostring(o) .. '"'
end

local function recurse(o, indent)
    if indent == nil then indent = '' end
    local indent2 = indent .. '  '
    if type(o) == 'table' then
        local s = indent .. '{' .. '\n'
        local first = true
        for k,v in pairs(o) do
            if first == false then s = s .. ', \n' end
            if type(k) ~= 'number' then k = string(k) end
            s = s .. indent2 .. '[' .. k .. '] = ' .. recurse(v, indent2)
            first = false
        end
        return s .. '\n' .. indent .. '}'
    else
        return string(o)
    end
end
 
local function var_dump(...)
    local args = {...}
    if #args > 1 then
        var_dump(args)
    else
        print(recurse(args[1]))
    end
end

local _ITEMS = {
	
	{
		vocationCheck = function(cid) return isSorcerer(cid) or isDruid(cid) end,
		sets = {
			[CONST_SLOT_HEAD] = {
				{
					level_from = 0, level_to = 40,
					items = { "viking helmet", "legion helmet", "soldier helmet", "steel helmet", "dark helmet" }
				},{
					level_from = 41, level_to = 999,
					items = { "hat of the mad", "batwing hat" }
				}
			},
			[CONST_SLOT_ARMOR] = {
				{
					level_from = 0, level_to = 50,
					items = { "scale armor", "plate armor", "dark armor", "ethno coat" }
				},{
					level_from = 51, level_to = 999,
					items = { "focus cape", "blue robe", "spirit cloak" }
				},
			},
			[CONST_SLOT_LEGS] = {
				{
					level_from = 0, level_to = 40,
					items = { "plate legs", "brass legs" }
				},{
					level_from = 41, level_to = 80,
					items = { "blue legs", "plate legs" }
				},{
					level_from = 81, level_to = 999,
					items = { "blue legs", "magma legs", "terra legs" }
				},				
			},
			[CONST_SLOT_FEET] = {
				{
					level_from = 0, level_to = 50,
					items = { "leather boots" }
				},{
					level_from = 51, level_to = 999,
					items = { "boots of haste", "leather boots" }
				}
			},
			[CONST_SLOT_LEFT] = {
				{
					vocationCheck = function(cid) return isDruid(cid) end,
					list = {
						{
							level_from = 0, level_to = 12,
							items = { "snakebite rod" }
						},{
							level_from = 13, level_to = 18,
							items = { "moonlight rod" }
						},{
							level_from = 19, level_to = 32,
							items = { "necrotic rod" }
						},{
							level_from = 33, level_to = 41,
							items = { "hailstorm rod" }
						},{
							level_from = 42, level_to = 999,
							items = { "underworld rod" }
						}
					}
				},{
					vocationCheck = function(cid) return isSorcerer(cid) end,
					list = {
						{
							level_from = 0, level_to = 12,
							items = { "wand of vortex" }
						},{
							level_from = 13, level_to = 18,
							items = { "wand of dragonbreath" }
						},{
							level_from = 19, level_to = 25,
							items = { "wand of decay" }
						},{
							level_from = 26, level_to = 36,
							items = { "wand of cosmic energy" }
						},{
							level_from = 37, level_to = 41,
							items = { "wand of starstorm" }
						},{
							level_from = 42, level_to = 999,
							items = { "wand of voodoo" }
						}
					}
				}
			},
			[CONST_SLOT_RIGHT] = {
				{
					level_from = 0, level_to = 35,
					items = { "spellbook of warding", "dragon shield", "guardian shield", "spellbook of enlightenment" }
				},{
					level_from = 36, level_to = 999,
					items = { "spellbook of warding", "demon shield", "spellbook of mind control" }
				},
			},
			[CONST_SLOT_BACKPACK] = {
				ids = { 1988, 2002, 2004, 2001, 1999, 2000, 2003 },
				items = { "rope", "shovel" },
				supply = {
					{
						level_from = 0, level_to = 49,
						items = { "mana potion" }
					},{
						level_from = 50, level_to = 79,
						items = { "strong mana potion", "sudden death rune" }
					},{
						level_from = 80, level_to = 999,
						items = { "strong mana potion", "great mana potion", "sudden death rune" }
					}
				}
			}
		}
	},{
		vocationCheck = function(cid) return isKnight(cid) end,
		sets = {
			[CONST_SLOT_HEAD] = {
				{
					level_from = 0, level_to = 40,
					items = { "viking helmet", "legion helmet", "soldier helmet", "steel helmet", "dark helmet" }
				},{
					level_from = 41, level_to = 90,
					items = { "soldier helmet", "steel helmet", "crown helmet", "crusader helmet", "warrior helmet" }
				},{
					level_from = 91, level_to = 999,
					items = { "crusader helmet", "warrior helmet", "zaoan helmet", "royal helmet" }
				},
			},
			[CONST_SLOT_ARMOR] = {
				{
					level_from = 0, level_to = 50,
					items = { "scale armor", "plate armor", "dark armor" }
				},{
					level_from = 51, level_to = 999,
					items = { "knight armor", "crown armor", "plate armor", "dark armor" }
				},
			},
			[CONST_SLOT_LEGS] = {
				{
					level_from = 0, level_to = 40,
					items = { "plate legs", "brass legs" }
				},{
					level_from = 41, level_to = 80,
					items = { "zaoan legs", "plate legs", "knight legs" }
				},{
					level_from = 81, level_to = 999,
					items = { "zaoan legs", "crown legs", "knight legs" }
				},				
			},
			[CONST_SLOT_FEET] = {
				{
					level_from = 0, level_to = 50,
					items = { "leather boots" }
				},{
					level_from = 51, level_to = 999,
					items = { "boots of haste", "leather boots" }
				}
			},
			[CONST_SLOT_LEFT] = {
				{
					skillCheck = function(skillid) return skillid == SKILL_SWORD end,
					list = {
						{
							level_from = 0, level_to = 19,
							items = { "spike sword", "serpent sword" }
						},{
							level_from = 20, level_to = 24,
							items = { "crimson sword", "spike sword", "two handed sword" }			
						},{
							level_from = 25, level_to = 34,
							items = { "wyvern fang", "crystal sword", "crimson sword" }
						},{
							level_from = 35, level_to = 49,
							items = { "wyvern fang", "crystal sword", "crimson sword", "blacksteel sword" }
						},{
							level_from = 50, level_to = 69,
							items = { "wyvern fang", "relic sword", "dragon slayer" }
						},{
							level_from = 70, level_to = 999,
							items ={ "relic sword", "mystic blade", "giant sword" }
						}
					}
				},{
					skillCheck = function(skillid) return skillid == SKILL_AXE end,
					list = {
						{
							level_from = 0, level_to = 29,
							items = { "orcish axe", "steel axe", "battle axe", "ripper lance" }
						},{
							level_from = 30, level_to = 44,
							items = { "barbarian axe", "double axe", "dwarven axe", "halberd" }
						},{
							level_from = 45, level_to = 59,
							items = { "barbarian axe", "beastslayer axe", "headchopper", "titan axe" }
						},{
							level_from = 60, level_to = 89,
							items = { "fire axe", "noble axe", "dragon lance", "titan axe" }
						},{
							level_from = 90, level_to = 999,
							items = { "fire axe", "noble axe", "dragon lance", "royal axe" }
						}
					}
				},{
					skillCheck = function(skillid) return skillid == SKILL_CLUB end,
					list = {
						{
							level_from = 0, level_to = 29,
							items = { "morning star", "daramian mace", "battle hammer" }
						},{
							level_from = 30, level_to = 55,
							items = { "morning star", "skull staff", "dragon hammer", "spiked squelcher" }
						},{
							level_from = 56, level_to = 79,
							items = { "skull staff", "war hammer" }
						},{
							level_from = 80, level_to = 999,
							items = { "cranial basher", "skull staff", "war hammer" }
						}
					}
				}				
			},
			[CONST_SLOT_RIGHT] = {
				{
					level_from = 0, level_to = 29,
					items = { "dwarven shield", "guardian shield" }
				},{
					level_from = 30, level_to = 49,
					items = { "dwarven shield", "guardian shield", "dragon shield", "tower shield" }
				},{
					level_from = 50, level_to = 80,
					items = { "dragon shield", "tower shield", "crown shield", "vampire shield", "medusa shield" }
				},{
					level_from = 81, level_to = 999,
					items = { "crown shield", "vampire shield", "medusa shield", "demon shield" }
				}
			},
			[CONST_SLOT_BACKPACK] = {
				ids = { 1988, 2002, 2004, 2001, 1999, 2000, 2003 },
				items = { "rope", "shovel" },
				supply = {
					{
						level_from = 0, level_to = 29,
						items = { "health potion" }
					},{
						level_from = 30, level_to = 55,
						items = { "health potion", "mana potion" }
					},{
						level_from = 56, level_to = 90,
						items = { "mana potion", "strong health potion" }
					},{
						level_from = 91, level_to = 999,
						items = { "mana potion", "strong health potion", "great health potion" }
					}
				}
			}
		}
	},{
		vocationCheck = function(cid) return isPaladin(cid) end,
		sets = {
			[CONST_SLOT_HEAD] = {
				{
					level_from = 0, level_to = 40,
					items = { "viking helmet", "legion helmet", "soldier helmet", "steel helmet", "dark helmet" }
				},{
					level_from = 41, level_to = 90,
					items = { "soldier helmet", 	"steel helmet", "crown helmet", "crusader helmet", "warrior helmet" }
				},{
					level_from = 91, level_to = 999,
					items = { "crusader helmet", "warrior helmet", "zaoan helmet", "royal helmet" }
				},
			},
			[CONST_SLOT_ARMOR] = {
				{
					level_from = 0, level_to = 50,
					items = { "scale armor", "plate armor", "dark armor" }
				},{
					level_from = 51, level_to = 999,
					items = { "knight armor", "crown armor", "paladin armor" }
				},
			},
			[CONST_SLOT_LEGS] = {
				{
					level_from = 0, level_to = 40,
					items = { "plate legs", "brass legs" }
				},{
					level_from = 41, level_to = 80,
					items = { "zaoan legs", "plate legs", "knight legs" }
				},{
					level_from = 81, level_to = 999,
					items = { "zaoan legs", "crown legs", "knight legs" }
				},				
			},
			[CONST_SLOT_FEET] = {
				{
					level_from = 0, level_to = 50,
					items = { "leather boots" }
				},{
					level_from = 51, level_to = 999,
					items = { "boots of haste", "leather boots" }
				}
			},
			[CONST_SLOT_LEFT] = {
				{
					level_from = 0, level_to = 24,
					items = { "spear" }
				},{
					level_from = 25, level_to = 44,
					items = { "royal spear", "hunting spear" }
				},{
					level_from = 45, level_to = 999,
					items = { "enchanted spear" }
				}			
			},
			[CONST_SLOT_RIGHT] = {
				{
					level_from = 0, level_to = 29,
					items = { "dwarven shield", "guardian shield" }
				},{
					level_from = 30, level_to = 49,
					items = { "dwarven shield", "guardian shield", "dragon shield", "tower shield" }
				},{
					level_from = 50, level_to = 80,
					items = { "dragon shield", "tower shield", "crown shield", "vampire shield", "medusa shield" }
				},{
					level_from = 81, level_to = 999,
					items = { "crown shield", "vampire shield", "medusa shield", "demon shield" }
				}
			},
			[CONST_SLOT_BACKPACK] = {
				ids = { 1988, 2002, 2004, 2001, 1999, 2000, 2003 },
				items =  { "rope", "shovel" },
				supply = {
					{
						level_from = 0, level_to = 29,
						items = { "health potion" }
					},{
						level_from = 30, level_to = 55,
						items = { "health potion", "mana potion" }
					},{
						level_from = 56, level_to = 90,
						items = { "strong mana potion", "strong health potion" }
					},{
						level_from = 91, level_to = 999,
						items = { "great spirit potion" }
					}
				}
			}
		}
	}
}

function parseItemsNodeByLevel(cid, node)

	for _,v in pairs(node) do
		if(v.vocationCheck ~= nil) then
			if(v.vocationCheck(cid)) then
				return parseItemsNodeByLevel(cid, v.list)
			end
		elseif(v.skillCheck ~= nil) then
			if(v.skillCheck(getPlayerHigherSkill(cid))) then
				return parseItemsNodeByLevel(cid, v.list)
			end
		else
			
			if(v.level_from ~= nil and v.level_to ~= nil) then
				if(getPlayerLevel(cid) >= v.level_from and getPlayerLevel(cid) <= v.level_to) then
					return v.items
				end		
			else
				var_dump(v)
			end	
		end
	end

	error("parseItemsNodeByLevel() no one level found")
	var_dump(node)
	return false
end

function randomizeItemList(items)
	local rand = math.random(1, #items)
	local itemId = getItemIdByName(items[rand])
	if(itemId ~= 0) then
		return itemId
	else
		error("randomizeItemList() unknown item name: " .. var_dump(items[rand]) .. " " .. var_dump(items))
		return false
	end
end

function getPlayerHigherSkill(cid)

	local higherSkill = SKILL_AXE
	local higherValue = getPlayerSkillLevel(cid, SKILL_AXE)

	if(getPlayerSkillLevel(cid, SKILL_SWORD) > higherValue) then
		higherValue = getPlayerSkillLevel(cid, SKILL_SWORD)
		higherSkill = SKILL_SWORD
	end	

	if(getPlayerSkillLevel(cid, SKILL_CLUB) > higherValue) then
		higherValue = getPlayerSkillLevel(cid, SKILL_CLUB)
		higherSkill = SKILL_CLUB
	end

	return higherSkill
end

function doPlayerSwapItem(cid, _slot, node)

	local target = node.sets[_slot]

	local slotItems = parseItemsNodeByLevel(cid, target)

	local slot = getPlayerSlotItem(cid, _slot)
	if(slot.uid == 0 or not isInArray(slotItems, getItemNameById(slot.itemid))) then
		if(slot.uid ~= 0) then
			doRemoveItem(slot.uid)
		end

		local itemId = randomizeItemList(slotItems)
		doPlayerAddItem(cid, itemId, 1, false, _slot)

		return itemId
	end

	return nil
end

function onLogin(cid)

	if(doPlayerIsBot(cid)) then

		for _, node in pairs(_ITEMS) do
			if(node.vocationCheck(cid)) then

				local slots = { CONST_SLOT_HEAD, CONST_SLOT_ARMOR, CONST_SLOT_LEGS, CONST_SLOT_FEET, CONST_SLOT_LEFT, CONST_SLOT_RIGHT }

				local dualHand = false

				for k, _slot in pairs(slots) do
					if(_slot ~= CONST_SLOT_RIGHT or not dualHand) then
						doPlayerSwapItem(cid, _slot, node)
					end
					dualHand = doPlayerWeaponIsDualHand(cid)
				end

				local slot = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
				if(slot.uid ~= 0) then
					doRemoveItem(slot.uid)
				end

				local container_id = node.sets[CONST_SLOT_BACKPACK].ids[math.random(1, #node.sets[CONST_SLOT_BACKPACK].ids)]
				local item = doCreateItemEx(container_id, 1)

				for k, name in pairs(node.sets[CONST_SLOT_BACKPACK].items) do
					if(not getItemIdByName(name)) then
						var_dump(name)
					end

					doAddContainerItem(item, getItemIdByName(name))
				end

				local insideContainer = parseItemsNodeByLevel(cid, node.sets[CONST_SLOT_BACKPACK].supply)

				for k, name in pairs(insideContainer) do
					if(not getItemIdByName(name)) then
						var_dump(name)
					end
					doAddContainerItem(item, getItemIdByName(name))
				end

				local ret = doPlayerAddItemEx(cid, item, false, CONST_SLOT_BACKPACK)

				if(ret ~= RETURNVALUE_NOERROR) then
					error("onLogin() cannot add container to bot free cap " .. getPlayerFreeCap(cid) .. "/" .. getItemWeight(item))
				end		
			end
		end	
	end

	return true
end