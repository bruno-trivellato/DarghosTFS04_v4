
local COOLDOWN_PORTAL = 25 * 60
local PORTAL_MAX_USES = 3
local current_aid = 0

-- usefull functions
local function getAid()
	
	local aid = aid.TELEPORT_SYSTEM_INIT + current_aid
	current_aid = current_aid + 1
	return aid
end

local function pushBack(cid, position, fromPosition, displayMessage)
	displayMessage = displayMessage or false
	doTeleportThing(cid, fromPosition, false)
	doSendMagicEffect(position, CONST_ME_MAGIC_BLUE)
	if(displayMessage) then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "The tile seems to be protected against unwanted intruders.")
	end
end

teleportAids = {
	
	-----------------
	---- Aaragon ----
	-----------------
	
	[8500] = {
		name = "Dragons Lair (deeper)"
		,desc = "Be prepared to face Dragon Lords, but also Dragons and Hatchlings."
		,min_level = 80
	}
	,[8501] = {
		name = "Ancient Fort (entrance)"
		,desc = "Be prepared to face Monks and Dark Monks also Hunters and Black Knights."
		,min_level = 35
	}
	,[8502] = {
		name = "Arahcnideos Camp & Ghost Tower"
		,desc = "Be prepared to face Tarantulas and Giant Spiders. You can find also a tower Demon Skeletons, Ghouls, Mummy, Crypt Shamblers, Vampires and Ghosts not too far."
		,min_level = 35
	}
	,[8503] = {
		name = "Soulthern Lands"
		,desc = "Be prepared to face so many Wyverns."
		,min_level = 25
	}
	,[8504] = {
		name = "Ancient Fort (deeper)"
		,desc = "Be prepared to face so many Warlocks (on the stairs down) also Heros."
		,min_level = 90
	}
	,[8505] = {
		name = "Ancient Fort (deeper)"
		,desc = "BEWARE: Be prepared to face so many Demons (on the stairs down)."
		,min_level = 100
	}
	,[8506] = {
		name = "Middle Lands"
		,desc = "Be prepared to face Cyclops, Cyclops Drone and Cyclops Smith. You can find not too far Dragons and a Tower with some Undeads with the NPC Rashid inside."
		,min_level = 20
	}
	,[8507] = {
		name = "Western Lands"
		,desc = "Be prepared to face Wyverns on the mountain."
		,min_level = 25
	}
	,[8508] = {
		name = "Undeads Camp"
		,desc = "On the higher floors be prepared to face Ghouls, Demon Skeletons and Vampires (deeper). BEWARE: In the lower and hidden floors be prepared to face Grim Reapers."
		,min_level = 20
	}
	,[8509] = {
		name = "Middle Lands (Crystals Caverns)"
		,desc = "Be prepared to face Wyrms also Energy Elementals and Massive Energy Elementals (lower floors)."
		,min_level = 50
	}
	,[8510] = {
		name = "Ancient Fort (deeper)"
		,desc = "Be prepared to face Black Knights and Beholders."
		,min_level = 40
	} 
	,[8511] = {
		name = "Southern Lands (deeper)"
		,desc = "Be prepared to face Heros and Warlocks."
		,min_level = 90
	}
	,[8512] = {
		name = "Middle Lands (The High Peaks)"
		,desc = "Be prepared to face Bog Raiders on the mountain."
		,min_level = 40
	}
	,[8513] = {
		name = "Ancient Fort (deeper)"
		,desc = "BEWARE: Be prepared to face Demons."
		,min_level = 100
	}
	,[8514] = {
		name = "Ancient Fort (deeper)"
		,desc = "Be prepared to face Heros."
		,min_level = 40
	}
	,[8515] = {
		name = "Southern Land (entrance)"
		,desc = "Be prepared to face Monks."
		,min_level = 20
	}
	,[8516] = {
		name = "Western Lands"
		,desc = "Be prepared to face Dragons and Hatchlings, also some Dragon Lords on the higher floors."
		,min_level = 40
	} 
	-- 17 was unused but need to be casted to not bug the sequence
	,[8517] = {
		name = "???"
		,desc = "???"
		,min_level = 10
	}
	
	
	------------------
	---- Salazart ----
	------------------      
	
	,[8518] = {
		name = "Minotaurs Tower"
		,desc = "Be prepared to face Minotaur, Minotaur Guard, Minotaur Archer and Minotaur Mage."
		,min_level = 8
	}
	,[8519] = {
		name = "Ghostland (entrance)"
		,desc = "Be prepared to face Skeletons, Skeleleton Warriors, Scorpions, Ghouls, Ghosts, Pirate Skeletons, Pirate Ghost, Demon Skeletons, Vampires, Lichs."
		,min_level = 15
	}
	,[8520] = {
		name = "Djinns Palace"
		,desc = "Be prepared to face Green Djinns, Blue Djinns also Marid and Efreet (deeper)."
		,min_level = 35
	}
	,[8521] = {
		name = "Mountain"
		,desc = "Be prepared to face Wyverns (on the mountain and in the underground)."
		,min_level = 25
	}
	,[8522] = {
		name = "Hidden Deadly Tomb"
		,desc = "Be prepared to face Giant Spiders."
		,min_level = 50
	}
	,[8523] = {
		name = "Larva Lake Catacombs"
		,desc = "Be prepared to face Skeletons, Ghouls and Banshees. BEWARE: In the lower floors be prepared to face Demons."
		,min_level = 80
	}
	,[8524] = {
		name = "Northern Peaks"
		,desc = "Be prepared to face Stone Golems."
		,min_level = 20
	}
	,[8525] = {
		name = "Northern Peaks (Frontier)"
		,desc = "Be prepared to face Nomads."
		,min_level = 10
	}
	,[8526] = {
		name = "Salazart Underground"
		,desc = "Be prepared to face Rotworms, Carrion Worms and Rotworms Queen."
		,min_level = 5
	}
	,[8527] = {
		name = "Ghostland (deeper)"
		,desc = "BEWARE: Be prepared to face Grim Reapers."
		,min_level = 100
	}
	,[8528] = {
		name = "Northern Peaks"
		,desc = "Be prepared to face Wyverns, Dragons and Sand Dragons (deeper)."
		,min_level = 30
	}
	,[8529] = {
		name = "Larva Lake Catacombs"
		,desc = "Be prepared to face Warlocks and Demons."
		,min_level = 90
	}      
	,[8530] = {
		name = "Rocks Catacombs"
		,desc = "Be prepared to face Skeletons, Ghouls, Mummies, Vampires also Bone Beasts, Crypt Shamblers and Necromancers in the lower floors."
		,min_level = 15
	}    
	,[8531] = {
		name = "Desert Underground"
		,desc = "Be prepared to face Larva and Scarabs."
		,min_level = 10
	}
	,[8532] = {
		name = "Desert Underground"
		,desc = "Be prepared to face Scarabs and Ancient Scarabs."
		,min_level = 20
	}  
	,[8533] = {
		name = "Banuta (deeper)"
		,desc = "Be prepared to face Hydras, Giant Spiders, Serpent Spawns, Medusas, Massive Fire Elementals and Frost Dragons also Souleaters, Draken Warmasters, Draken Spellwavers and Draken Elite (in the lower floors)."
		,min_level = 100
	}
	,[8534] = {
		name = "Nargor"
		,desc = "Be prepared to face so many types of Pirates."
		,min_level = 35
		,required_storages = { 
			{ id = sid.GOROMA_ENTER, fail = "You need to finish a mission with the NPC Myh Sayn before using this teleport." }
		}
	}
	,[8535] = {
		name = "Ferumbras Tower"
		,desc = "BEWARE: Be prepared to face so many strong creatures as Hydras, Serpent Spawns, Dragon Lords, Behemoths, Warlocks and Demons."
		,min_level = 120
		,required_storages = { 
			{ id = sid.GOROMA_ENTER, fail = "You need to finish a mission with the NPC Myh Sayn before using this teleport." }
		}
	}
	,[8536] = {
		name = "Laguna Islands"
		,desc = "Be prepared to face Toad, Tortoises, Thornback Tortoises and Blood Crab."
		,min_level = 25
		,required_storages = { 
			{ id = sid.GOROMA_ENTER, fail = "You need to finish a mission with the NPC Myh Sayn before using this teleport." }
		}
	}
	,[8537] = {
		name = "Eastern Lost Jungle"
		,desc = "Be prepared to face Giant Spiders also Quara Pincher, Quara Predator, Quara Mantassin, Quara Hydromancer (underground)."
		,min_level = 60
		,required_storages = { 
			{ id = sid.GOROMA_ENTER, fail = "You need to finish a mission with the NPC Myh Sayn before using this teleport." }
		}
	}
	,[8538] = {
		name = "Eastern Lost Jungle"
		,desc = "Be prepared to face Giant Spiders also Quara Pincher, Quara Predator, Quara Mantassin, Quara Hydromancer (underground)."
		,min_level = 60
		,required_storages = { 
			{ id = sid.GOROMA_ENTER, fail = "You need to finish a mission with the NPC Myh Sayn before using this teleport." }
		}
	}
	,[8539] = {
		name = "Eastern Lost Jungle"
		,desc = "Be prepared to face Giant Spiders."
		,min_level = 60
		,required_storages = { 
			{ id = sid.GOROMA_ENTER, fail = "You need to finish a mission with the NPC Myh Sayn before using this teleport." }
		}
	}  
	,[8540] = {
		name = "Banuta (entrance)"
		,desc = "Be prepared to face Kongras, Merlkins and Silbangs."
		,min_level = 30
	}
	,[8541] = {
		name = "Northern Catacombs"
		,desc = "Be prepared to face Skeletons and Ghouls also Mummies, Necromancers, Bone Beasts and Lichs on the lower floors."
		,min_level = 15
	}
	,[8542] = {
		name = "Oil Lake Catacombs"
		,desc = "Be prepared to face Skeletons, Ghouls, Ghosts, Demon Skeletons, Vampires, Crypt Shamblers, Necromancers and Banshees also Warlocks and Behemoths on the lower floors."
		,min_level = 30
	} 
	,[8543] = {
		name = "Ancient Lost Catacombs"
		,desc = "Be prepared to face Skeletons, Ghouls, Demon Skeletons, Vampires also Liches and Undead Dragons on the lower floors."
		,min_level = 50
	}
	,[8544] = {
		name = "Western Peaks"
		,desc = "Be prepared to face Dragons and Dragon Lords. BEWARE: Be prepare to face Sand Dragons and Mirage Guardians in the deeper."
		,min_level = 40
	}
	,[8545] = {
		name = "Northern Peaks"
		,desc = "Be prepared to face Sand Dragons and Mirage Guardians."
		,min_level = 100
	}
	,[8546] = {
		name = "Eastern Lands"
		,desc = "Be prepared to face Dragons, Dragon Lords and Hatchlings."
		,min_level = 35
	}
	,[8547] = {
		name = "Eastern Lands"
		,desc = "Be prepared to face Dragons, Dragon Lords and Hatchlings."
		,min_level = 35
	}
	,[8548] = {
		name = "Eastern Lands"
		,desc = "Be prepared to face Dragons, Dragon Lords and Hatchlings."
		,min_level = 35
	}
	,[8549] = {
		name = "Northern Lost Jungle"
		,desc = "Be prepared to face Hydras also Serpent Spawn."
		,min_level = 70
	}
	,[8550] = {
		name = "Southern Lost Jungle"
		,desc = "Be prepared to face Hydras."
		,min_level = 70
	}
	,[8551] = {
		name = "Southern Lost Jungle"
		,desc = "Be prepared to face Lizard Templar, Lizard Sentinel and Lizard Snakecharmer."
		,min_level = 45
	}
	,[8552] = {
		name = "Southern Lost Jungle"
		,desc = "Be prepared to face Dworc Venonsnipers, Dworc Fleshhunter, Dworc Voodoomaster."
		,min_level = 15
	}
	,[8553] = {
		name = "Middle Lost Jungle"
		,desc = "Be prepared to face Centipede also Dworc Venonsnipers, Dworc Fleshhunter, Dworc Voodoomaster (lower floor)."
		,min_level = 15
	}
	,[8554] = {
		name = "Western Lost Jungle"
		,desc = "Be prepared to face Giant Spiders (lower floor)."
		,min_level = 35
	}
	,[8555] = {
		name = "Lost Jungle (entrance)"
		,desc = "Be prepared to face Elephants and Carniphilas."
		,min_level = 20
	}
	
	-------------------
	----- Quendor -----
	-------------------        
	
	,[8556] = {
		name = "Northern Mountains"
		,desc = "Be prepared to face Cyclops, Cyclops Drone and Cyclops Smith also Dragons and Hatchlings (higher floors)."
		,min_level = 20
	}
	,[8557] = {
		name = "Ancient Dungeon (entrance)"
		,desc = "Be prepared to face Trolls, Rotworms, Orcs, Minotaurs, Slimes, Cyclops, Skeletons, Ghouls and Demon Skeletons, Fire Devils also Dragons, Necromancers, Priestess and Behemoths (lower floors)."
		,min_level = 8
	} 
	,[8558] = {
		name = "Orc Fortress"
		,desc = "Be prepared to face Orcs, Orc Spearmans, Orc Riders, Orc Berserkers, Orc Leaders also Orc Warlords and Dragons (lower floors)."
		,min_level = 35
	}
	,[8559] = {
		name = "Amazon Camp"
		,desc = "Be prepared to face Amazons and Valkiries also Ghouls, Mummies and Vampires (lower floors)."
		,min_level = 15
	}      
	,[8560] = {
		name = "Middle Lands"
		,desc = "Be prepared to face Globins and Cyclops (ground and higher floors) also Ghouls, Demon Skeletons, Mummies, Vampires, Monks, Priestess, Beholders, Necromancers, Heros, Behemoths and Demons (lower floors)."
		,min_level = 15
	}
	,[8561] = {
		name = "Middle Lands (Dwarven Mines)"
		,desc = "Be prepared to face Dwarfs, Dwarfs Soldiers, Dwarf Guards, Dwarf Geomancers also Giant Spiders (lower floors)."
		,min_level = 15
	}
	,[8562] = {
		name = "Quendor Underground"
		,desc = "Be prepared to face Trolls, Rotworms and Carrion Worms."
		,min_level = 8
	}
	,[8563] = {
		name = "Middle Lands (Dragons Lair)"
		,desc = "Be prepared to face Smugglers and Bandits (underground) also Dragons, Dragon Lords and Hatchlings (mountain)."
		,min_level = 35
	}
	,[8564] = {
		name = "Southern Lands (Mintwallin Entrance)"
		,desc = "Be prepared to face Minotaur, Minotaur Guard, Minotaur Archer and Minotaur Mage."
		,min_level = 25
	}
	,[8565] = {
		name = "Southern Lands (Highlands Peaks)"
		,desc = "Be prepared to face Cyclops, Dragons, Wyverns, Demon Skeletons and Elf Arcanists."
		,min_level = 25
	}
	,[8566] = {
		name = "Southern Lands"
		,desc = "Be prepared to face Cyclops, Dragons, Tarantulas and Giant Spiders."
		,min_level = 35
	}   
	,[8567] = {
		name = "Southern Lands (Cultists Dungeon)"
		,desc = "Be prepared to face face Ghouls, Demon Skeletons, Vampires, Necromancers, Novices of the Cult, Acolytes of the Cult, Adepths of the Cult and Enlightened of the Cult."
		,min_level = 25
	}
	,[8568] = {
		name = "Demona (Entrance)"
		,desc = "Be prepared to face Dwarf Guards, Minotaur Guard, Elf Arcanist and Stone Golems (before the door) also Warlocks (after the door)."
		,min_level = 35
	}
	,[8569] = {
		name = "Pits of Inferno (Garden Dungeon)"
		,desc = "BEWARE: Be prepared to face Destroyers, Nightmares, Hellfire Fighters, Diabolic Imp, Plaguesmith, Blightwalker, Betrayed Wraith, Dark Torturers and Lost Soul."
		,min_level = 80
		,required_items = { 
			{ itemtype = 1970, fail = "You need to be with the book Holy Tible to use this teleport. You can buy this from the NPC Oldrak in an temple on Southern Lands, near the Cultists Dungeon." }
		}
	}
	,[8570] = {
		name = "Pits of Inferno (Dragons Lair and Quest Entrance)"
		,desc = "BEWARE: Be prepared to face Dragon Lords and Hatchlings also Elite versions of Destroyers, Nightmares, Hellfire Fighters, Diabolic Imps and other Pits of Inferno creatures."
		,min_level = 80
		,required_items = { 
			{ itemtype = 1970, fail = "You need to be with the book Holy Tible to use this teleport. You can buy this from the NPC Oldrak in an temple on Southern Lands, near the Cultists Dungeon." }
		}
	} 
	
	-------------------
	------ Thorn ------
	-------------------
	
	,[8571] = {
		name = "Ghostland"
		,desc = "Be prepared to face Skeletons, Ghouls, Stalkers, Demon Skeletons also Vampires, Necromancers, Banshees, Dragons, Dragon Lords, Giant Spiders and Warlocks (lower floors)."
		,min_level = 12
	}
	,[8572] = {
		name = "Great Swamp"
		,desc = "Be prepared to face Wolfs, Bandits, Smuggler and Wild Warrior (ground) also Swamp Trolls and Slimes (underground)."
		,min_level = 8
	} 
	,[8573] = {
		name = "Great Swamp"
		,desc = "Be prepared to face Spiders, Tarantulas, Giant Spiders also Beholders, Elder Beholders and Black Knight."
		,min_level = 40
	}
	,[8574] = {
		name = "Great Swamp (Dragons Lair)"
		,desc = "Be prepared to face Dragons, Dragon Lords and Hatchlings."
		,min_level = 35
	}
	,[8575] = {
		name = "Thorn Underground"
		,desc = "Be prepared to face Bugs, Rotworms, Rotworms Queen and Slimes."
		,min_level = 8
	}
	,[8576] = {
		name = "Middle Lands"
		,desc = "Be prepared to face Wolfs, Bears, Chickens and Cyclops (lower floors)."
		,min_level = 8
	}
	,[8577] = {
		name = "Northren Lands"
		,desc = "Be prepared to face Wasps, Wyverns, Dragons, Dragon Lords and Hatchlings."
		,min_level = 25
	}
	,[8578] = {
		name = "Northren Lands (Cultitis Temple)"
		,desc = "Be prepared to face Skeletons, Demon Skeletons, Novice of the Cult, Acolyte of the Cult, Adept of the Cult and Enlightened of the Cult."
		,min_level = 20
	}
	,[8579] = {
		name = "Middle Lands (Minotaur Camp)"
		,desc = "Be prepared to face Minotaur, Minotaur Guard, Minotaur Archer and Minotaur Mage."
		,min_level = 15
	}
	,[8580] = {
		name = "Great Swamp (Roads Underground)"
		,desc = "Be prepared to Trolls, Troll Champions, Orcs, Orc Spearman, Orc Warriors, Rotworms, Carrion Worms and Minotaurs."
		,min_level = 8
	}
	,[8581] = {
		name = "Elfs Village"
		,desc = "Be prepared to Elfs, Elfs Scout and Elfs Arcanist also Demon Skeletons."
		,min_level = 15
	}
	,[8582] = {
		name = "Great Swamp (Roads)"
		,desc = "Be prepared to Amazons and Valkyries."
		,min_level = 10
	} 
	,[8583] = {
		name = "Great Swamp (Roads Underground)"
		,desc = "Be prepared to Rotworms and Carrions Worm."
		,min_level = 8
	}    
	,[8584] = {
		name = "Great Swamp (Giant Peaks)"
		,desc = "Be prepared to Cyclops and Dragons."
		,min_level = 15
	}
	,[8585] = {
		name = "Northern Lands (Mountain)"
		,desc = "Be prepared to Orcs, Orc Spearmans, Orc Warriors also Dragons."
		,min_level = 8
	}
	
	--[[
		Dungeons
	]]
	,[8586] = {
		name = "Ariadne Dungeon (Trolls Wing)"
		,desc = "Group with 8 or more members is highly recommended! Then, be prepared to face Sen Gan Guards, Sen Gan Shamans, Sen Gan Hunters, Big Oozes, Swamp Things and the boss Ghazran."
		,min_level = 300
		,required_items = { { itemtype = 5908, fail = "You must be with a Obsidian Knife to enter on this dungeon."} }
	} 
}

portalSystem = {}

function portalSystem.onStepInfoField(cid, item, position, fromPosition)
	
	local tpProperties = teleportAids[item.actionid]
	
	if(tpProperties == nil) then
		error("Unknown teleport properties for action id #" .. item.actionid)
		pushBack(cid, position, fromPosition, false)
		
		return true
	end

	if(not darghos_enable_portals) then
		doPlayerSendCancel(cid, "The access of portal's hunts was blocked.")
		pushBack(cid, position, fromPosition, false)
		return true
	end
	
	if(getPlayerLevel(cid) < tpProperties.min_level) then
		
		doPlayerSendCancel(cid, "You need at least level " .. tpProperties.min_level .. " to access the destination of this place.")
		pushBack(cid, position, fromPosition, false)
		return true
	end
	
	local uses = (getPlayerStorageValue(cid, sid.PORTAL_ROOM_USES) >= 0) and getPlayerStorageValue(cid, sid.PORTAL_ROOM_USES) or 0 
	if(not isPremium(cid) and uses == 3) then
		
		local lastPortalUse = getPlayerStorageValue(cid, sid.PORTAL_ROOM_LAST_USE)
		if(lastPortalUse ~= -1 and lastPortalUse + COOLDOWN_PORTAL < os.time()) then
			setPlayerStorageValue(cid, sid.PORTAL_ROOM_LAST_USE, -1)
			setPlayerStorageValue(cid, sid.PORTAL_ROOM_USES, 0)
		else
			local minsLeft = math.ceil(((lastPortalUse + COOLDOWN_PORTAL) - os.time()) / 60)
			local minsStr = minsLeft == 0 and "less then one minute" or minsLeft .. " minutes"
			doPlayerSendCancel(cid, "You need to wait for " .. minsStr .. " to use the portal again.")
			pushBack(cid, position, fromPosition, false)
			return true            
		end
	end
	
	if(tpProperties.required_storages ~= nil) then
		for k,v in pairs(tpProperties.required_storages) do
			if(tonumber(getPlayerStorageValue(cid, v.id)) < 1) then
				doPlayerSendCancel(cid, v.fail)
				pushBack(cid, position, fromPosition, false)
				return true
			end
		end
	end
	
	if(tpProperties.required_items ~= nil) then
		for k,v in pairs(tpProperties.required_items) do
			if(getPlayerItemCount(cid, v.itemtype) < 1) then
				doPlayerSendCancel(cid, v.fail)
				pushBack(cid, position, fromPosition, false)
				return true
			end
		end
	end    
	
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,"This portal will take you to a place know as: " .. tpProperties.name)
	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, tpProperties.desc)
	
	return true    
end

function portalSystem.onTroughtPortal(cid, item, position, fromPosition)
	
	if(item.actionid == aid.PORTAL_HUNTS and not isPremium(cid)) then
		
		local uses = (getPlayerStorageValue(cid, sid.PORTAL_ROOM_USES) >= 0) and getPlayerStorageValue(cid, sid.PORTAL_ROOM_USES) or 0
		
		if(uses < PORTAL_MAX_USES) then
			uses = uses + 1
		end
		
		setPlayerStorageValue(cid, sid.PORTAL_ROOM_USES, uses)
		
		local portalUse = getPlayerStorageValue(cid, sid.PORTAL_ROOM_LAST_USE)
		
		if(uses == 1 or (portalUse + COOLDOWN_PORTAL) < os.time()) then
			portalUse = os.time()
			setPlayerStorageValue(cid, sid.PORTAL_ROOM_LAST_USE, portalUse)
		end
		
		if(uses == PORTAL_MAX_USES) then
			setPlayerStorageValue(cid, sid.PORTAL_ROOM_LAST_BLOCK, os.time())
		end
		
		local minsLeft = math.ceil(((portalUse + COOLDOWN_PORTAL) - os.time()) / 60)
		local minsStr = minsLeft == 0 and "less then one minute" or minsLeft .. " minutes"            
		
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,"Portal uses: " .. uses .. "/" .. PORTAL_MAX_USES)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,"All your portal uses will be reseted in " .. minsStr .. ".")
		
		
	end    
end
