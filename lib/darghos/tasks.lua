STORAGE_RANGE = 100
STORAGE_START = 52100

EXPERIENCE_RATE = 1

defaultDialogs = {
	STARTED_TASK = "Perfect! Come back here when your work is done!",
	COMPLETED_TASK_INIT = "Awasome! You done your work. Here yours reward:",
	COMPLETED_TASK_END = "I hope you're satisfied!",
	TELEPORTING = "Wait some seconds, you will be taken to another place..."
}

destinations = {
	secondNPC = {x = 1231, y = 2190, z = 8},
	academy = {x = 1235, y = 2170, z = 7}
}

CAP_ONE = {
	ISLAND_OF_PEACE = {
		FIRST = STORAGE_START,
		SECOND = STORAGE_START + 100,
		THIRD = STORAGE_START + 200,
		FOURTH = STORAGE_START + 300,
		FIFTH = STORAGE_START + 400,
		SIXTH = STORAGE_START + 500,
		SEVENTH = STORAGE_START + 600,
		EIGHTH = STORAGE_START + 700,
		NINTH = STORAGE_START + 800,
		TENTH = STORAGE_START + 900,
		ELEVENTH = STORAGE_START + 1000,
		TWELFTH = STORAGE_START + 1100,
		THIRTEENTH = STORAGE_START + 1200,
	},
	QUENDOR = {
		TRAVELER_IOP = STORAGE_START + 1300
	}
}

taskStats = {
	NONE = -1,
	STARTED = 0,
	COMPLETED = 1
}

-- Classe de items que serão usados nas Tasks
items = {
	brown_backpack	 		= 1988,
	chain_legs		 		= getItemIdByName("chain legs"),
	health_potion		 	= getItemIdByName("health potion"),
	mana_potion 	 		= getItemIdByName("mana potion"),
	wand_of_dragonbreath 	= getItemIdByName("wand of dragonbreath"),
	moonlight_rod		 	= getItemIdByName("moonlight rod"),
	steel_axe			 	= getItemIdByName("steel axe"),
	jagged_sword		 	= getItemIdByName("jagged sword"),
	daramanian_mace		 	= getItemIdByName("daramanian mace"),
	ranger_legs		 		= getItemIdByName("ranger legs"),
	brass_legs		 		= getItemIdByName("brass legs"),
	wand_of_decay	 		= getItemIdByName("wand of decay"),
	wand_of_draconia 		= getItemIdByName("wand of draconia"),
	necrotic_rod 			= getItemIdByName("necrotic rod"),
	northwind_rod 			= getItemIdByName("northwind rod"),
	belted_cape	 			= getItemIdByName("belted cape"),
	plate_armor	 			= getItemIdByName("plate armor"),
	spike_sword	 			= getItemIdByName("spike sword"),
	battle_hammer 			= getItemIdByName("battle hammer"),
	battle_axe	 			= getItemIdByName("battle axe"),
	stealth_ring 			= 2165,
	guardian_shield			= getItemIdByName("guardian shield"),
	plate_legs				= getItemIdByName("plate legs"),
	dwarven_legs			= getItemIdByName("dwarven legs"),
	dwarven_armor			= getItemIdByName("dwarven armor"),
	noble_armor				= getItemIdByName("noble armor"),
	wand_of_inferno			= getItemIdByName("wand of inferno"),
	hailstorm_rod			= getItemIdByName("hailstorm rod"),
	clerical_mace			= getItemIdByName("clerical mace"),
	crimson_sword			= getItemIdByName("crimson sword"),
	halberd					= getItemIdByName("halberd"),
	blue_robe				= getItemIdByName("blue robe"),
	bright_sword			= getItemIdByName("bright sword"),
	naginata				= getItemIdByName("naginata"),
	orcish_maul				= getItemIdByName("orcish maul"),
	green_dragon_scale		= getItemIdByName("green dragon scale"),
	knight_armor			= getItemIdByName("knight armor"),
	knight_legs				= getItemIdByName("knight legs"),
	underworld_rod			= getItemIdByName("underworld rod"),
	wand_of_voodoo			= getItemIdByName("wand of voodoo"),
	dragon_shield			= getItemIdByName("dragon shield"),
	giant_spider_silk		= getItemIdByName("giant spider silk"),
	golden_goblet			= getItemIdByName("golden goblet"),
	crown_legs				= getItemIdByName("crown legs"),
	crown_armor				= getItemIdByName("crown armor")
}

-- Classe de monstros que devem disparar o evento onKill, e em qual condição isso deve ocorrer
taskMonsters = {
	["troll"] = { CAP_ONE.ISLAND_OF_PEACE.FIRST },
	["rotworm"] = {CAP_ONE.ISLAND_OF_PEACE.SECOND},
	["carrion worm"] = {CAP_ONE.ISLAND_OF_PEACE.SECOND},
	["skeleton"] = {CAP_ONE.ISLAND_OF_PEACE.THIRD},
	["skeleton warrior"] = {CAP_ONE.ISLAND_OF_PEACE.THIRD},
	["amazon"] = {CAP_ONE.ISLAND_OF_PEACE.SIXTH},
	["valkyrie"] = {CAP_ONE.ISLAND_OF_PEACE.SIXTH},
	["dwarf"] = {CAP_ONE.ISLAND_OF_PEACE.SEVENTH},
	["dwarf soldier"] = {CAP_ONE.ISLAND_OF_PEACE.SEVENTH},
	["dwarf guard"] = {CAP_ONE.ISLAND_OF_PEACE.SEVENTH},
	["cyclops"] = {CAP_ONE.ISLAND_OF_PEACE.NINTH},
	["cyclops smith"] = {CAP_ONE.ISLAND_OF_PEACE.NINTH},
	["orc"] = {CAP_ONE.ISLAND_OF_PEACE.TENTH},
	["orc spearman"] = {CAP_ONE.ISLAND_OF_PEACE.TENTH},
	["orc warrior"] = {CAP_ONE.ISLAND_OF_PEACE.TENTH},
	["orc shaman"] = {CAP_ONE.ISLAND_OF_PEACE.TENTH},
	["orc rider"] = {CAP_ONE.ISLAND_OF_PEACE.TENTH},
	["orc berserker"] = {CAP_ONE.ISLAND_OF_PEACE.TENTH},
	["orc leader"] = {CAP_ONE.ISLAND_OF_PEACE.TENTH},
	["orc warlord"] = {CAP_ONE.ISLAND_OF_PEACE.TENTH},
	["dragon"] = {CAP_ONE.ISLAND_OF_PEACE.ELEVENTH},
	["giant spider"] = {CAP_ONE.ISLAND_OF_PEACE.TWELFTH},
	["dragon lord"] = {CAP_ONE.ISLAND_OF_PEACE.THIRTEENTH},
}

-- Classe de informações gerais das tasks
tasksList = {
	[CAP_ONE.ISLAND_OF_PEACE.FIRST] = {
		monsters = {{name = "troll", amount = 50, storagePos = 1}},
		dialogs = {
			description = "The trolls population are out of control, we need a help slaying then on the underground. You will receive a reward by doing this task. If you want help us, say {yes}.",
			taskObjectives = "Right, go to the south if this temple and you will find a swer grate. Inside then you need defeat 50 trolls or trolls champion. You agree?",
			taskStarted = defaultDialogs.STARTED_TASK,
			taskIncomplete = "Your task is still incomplete. Remember: You need slay 50 trolls or champion trolls! Be fast!",
			taskCompleted = {
				defaultDialogs.COMPLETED_TASK_INIT,
				defaultDialogs.COMPLETED_TASK_END,
			},
		},
		events = {
			onComplete = { 
				type = "question", 
				text = "I have another task to you. You want to know more about?", 
				onConfirm = "action",
				confirmParam = "callResponseTask"
			}
		},
		reward = {exp = 3500, money = 500, container = { id = items.brown_backpack, 
			items.chain_legs, items.mana_potion, items.health_potion
		}}
	},
	
	[CAP_ONE.ISLAND_OF_PEACE.SECOND] = {
		monsters = {{name = "rotworm", amount = 80, storagePos = 1}, {name = "carrion worm", amount = 20, storagePos = 2}},
		dialogs = {
			description = "The rotworms are destroying our farm, they devour everthing and nothing remains! We need your help! You agree?",
			taskObjectives = "I'm glad to know! On the west from here you will find a swer grate. Is this the hiddin place of the rotworms. I think that defeat 40 rotworms and 20 carrion worms will be enought for now. Do you accept this task?",
			taskStarted = defaultDialogs.STARTED_TASK,
			taskIncomplete = "Your task is still incomplete. Remember: You need slay 40 rotworms and 20 carrion worms! Pay attention on the clock!",
			taskCompleted = {
				defaultDialogs.COMPLETED_TASK_INIT,
				defaultDialogs.COMPLETED_TASK_END,
			},
		},		
		events = {
			onComplete = { 
				type = "question", 
				text = "I know that my friend Hector is needing a help with some tasks. You will find they on a cave on the north from here (the entrance is a bit hidden, and can be hard to see). Otherwise, if you want help Hector, I can take you there, you want?", 
				onConfirm = "teleport",
				confirmParam = destinations.secondNPC,
				onConfirmText = defaultDialogs.TELEPORTING
			}
		},		
		reward = {exp = 4500, money = 700, container = { id = items.brown_backpack,
			isSorcerer = { items.wand_of_dragonbreath },
			isDruid = { items.moonlight_rod },
			isKnight = { meleeOptions = { axe = items.steel_axe, sword = items.jagged_sword, club = items.daramanian_mace}}
		}}
	},
	[CAP_ONE.ISLAND_OF_PEACE.THIRD] = {
		requiredTask = CAP_ONE.ISLAND_OF_PEACE.SECOND,
		monsters = {{name = "skeleton", amount = 60, storagePos = 1}, {name = "skeleton warrior", amount = 12, storagePos = 2}},
		dialogs = {
			requireTask = "You want help me? It's good, but Mereus still have some tasks for you. Complete Mereus tasks then go back here.",
			description = "This is a cursed sarcophagus... Time from time he go back to activity and terrorify everbody on the city! You want help us with that?",
			taskObjectives = "Good! Keep going to north and will enter on the sarcophagus... Inside then slay 45 skeletons and 12 skeleton warriors. This will decrease the curse. Can I rely on you?",
			taskStarted = defaultDialogs.STARTED_TASK,
			taskIncomplete = "Your task is still incomplete. Remember: You need slay 45 skeletons e 12 skeleton warriors! The curse is still in everthing!",
			taskCompleted = { 
				defaultDialogs.COMPLETED_TASK_INIT,
				defaultDialogs.COMPLETED_TASK_END,
			},
		},
		events = {
			onComplete = { 
				type = "question", 
				text = "Still have so many tasks here... But you are still weak... On the academy I know a guy that can help you. Are ready to take you to academy?", 
				onConfirm = "teleport",
				confirmParam = destinations.academy,
				onConfirmText = defaultDialogs.TELEPORTING
			}
		},			
		reward = {exp = 5100, money = 1000, container = { id = items.brown_backpack,
			isPaladin = { items.ranger_legs },
			isKnight = { items.brass_legs },
			isSorcerer = { items.brass_legs },
			isDruid = { items.brass_legs }
		}}
	},
	[CAP_ONE.ISLAND_OF_PEACE.FOURTH] = {
		requiredTask = CAP_ONE.ISLAND_OF_PEACE.THIRD,	
		reward = {paladinDistTo = 55, paladinShieldTo = 45, knightSkillTo = 50, magicLevelTo = 15}
	},
	[CAP_ONE.ISLAND_OF_PEACE.FIFTH] = {
		requiredTask = CAP_ONE.ISLAND_OF_PEACE.FOURTH
	},
	[CAP_ONE.ISLAND_OF_PEACE.SIXTH] = {
		requiredTask = CAP_ONE.ISLAND_OF_PEACE.FOURTH,
		monsters = {{name = "amazon", amount = 60, storagePos = 1}, {name = "valkyrie", amount = 25, storagePos = 2}},
		dialogs = {
			requireTask = "Yes, I need some help with tasks out of the city... Unfortunately, you still is too weak to this... You need complete all tasks from inside the city then come back here...",
			description = "The ladie warriors are treacherous creatures, they ambush unprepared adventuerers that have no chances to live, we need end with that... You accept this task?",
			taskObjectives = {
				"Perfect! They camp is not far way from here. Go to northeast from here and you will find an old structure dominated by vegetation. Keep going and you will find the camp [...]",
				"You need slay 60 amazons and 25 valkyries. This will make the ladies stay away from the adventurers. Be careful when reach the camp, are so many ladies! You accept the task?"
			},
			taskStarted = defaultDialogs.STARTED_TASK,
			taskIncomplete = "Your task is still incomplete. Remember: You need slay 60 amazons and 25 valkyries or our adventurers will continue to be ambushed!",
			taskCompleted = { 
				defaultDialogs.COMPLETED_TASK_INIT,
				defaultDialogs.COMPLETED_TASK_END,
			},
		},
		events = {
			onComplete = { 
				type = "question", 
				text = "I have another task for you. You want know more?", 
				onConfirm = "action",
				confirmParam = "callResponseTask"
			}
		},		
		reward = {exp = 7000, money = 1000, container = { id = items.brown_backpack,
			isSorcerer = { items.wand_of_draconia, container = { id = items.brown_backpack, inside = { items.mana_potion, amount = 20}}  },
			isDruid = { items.northwind_rod, container = { id = items.brown_backpack, inside = { items.mana_potion, amount = 20}}  },
			isPaladin = { items.belted_cap, container = { id = items.brown_backpack, inside = { items.health_potion, amount = 20}} },
			isKnight = { items.plate_armor, meleeOptions = { sword = items.spike_sword, club = items.battle_hammer, axe = items.battle_axe }, container = { id = items.brown_backpack, inside = { items.health_potion, amount = 20}} },
		}}
	},
	[CAP_ONE.ISLAND_OF_PEACE.SEVENTH] = {
		--requiredTask = CAP_ONE.ISLAND_OF_PEACE.SIXTH,
		requirePoints = 360,
		monsters = {{name = "dwarf", points = 1}, {name = "dwarf soldier", points = 3}, {name = "dwarf guard", points = 6}},
		dialogs = {
			--requireTask = "",
			description = "The dwarfs from the Kranos mines are never friendly with us. They are over the limits of the underground and stealing a treasure that to us belongs. Lets go fight against this insolence?",
			taskObjectives = {
				"Perfect! Go to east until you find the three mines of Kranos. On the higher levels you will find weaker dwarfs. Be careful with stronger dwarfs on the lower levels [...]",
				"Some rumours talk about an treasure that can be find on the lower levels on one of the mines. This treasure is protected by a terrefic creatures that keep even the dwarfs away [...]",
				"On this task, you need collect points defeating any kind of dwarf: dwarfs (1 point), dwarf soldiers (3 points), dwarf guards (6 points). 360 points are needed to complete the task. You want?"
			},
			taskStarted = defaultDialogs.STARTED_TASK,
			taskIncomplete = "Your task is still incomplete. Remember: You need reach 360 points defeating dwarfs, dwarf soldiers e dwarf guards! They are stealing our wealth!",
			taskCompleted = { 
				defaultDialogs.COMPLETED_TASK_INIT,
				defaultDialogs.COMPLETED_TASK_END,
			},
		},
		events = {
			onComplete = { 
				type = "question", 
				text = "Your next task will be a royal mission for our King! You want know more about that?",
				action = "setState",
				confirmParam = 5
			}
		},
		reward = {exp = 24000, container = { id = items.brown_backpack,
			items.stealth_ring,
			items.guardian_shield,
			isSorcerer = { items.wand_of_inferno, items.plate_legs },
			isDruid = { items.hailstorm_druid, items.plate_legs },
			isPaladin = { items.belted_cape, items.plate_legs },
			isKnight = { items.noble_armor, items.plate_legs, meleeOptions = { club = items.clerical_mace, sword = items.crimson_sword, axe = items.halberd } },
		}}
	},
	[CAP_ONE.ISLAND_OF_PEACE.EIGHTH] = {
		requiredTask = CAP_ONE.ISLAND_OF_PEACE.SEVENTH,
		requireItems = { { items.golden_goblet} },
		reward = { action = "promotePlayer" }
	},
	[CAP_ONE.ISLAND_OF_PEACE.NINTH] = {
		requiredTask = CAP_ONE.ISLAND_OF_PEACE.EIGHTH,
		monsters = {{name = "cyclops", amount = 240, storagePos = 1}, {name = "cyclops smith", amount = 35, storagePos = 2}},
		dialogs = {
			requireTask = "Dul! You are not prepared to face my tasks. Try with Wiston, the Guard.",
			description = "We see some activity of the Cyclops, the alies of the Orcs not far way from here... We need exterminate some of these giants. You want help us?",
			taskObjectives = "Ar fis! Follow to west from here and you will find a montain populated by Cyclops. Defeat 240 cyclops e 35 cyclops smiths. You accept this task?",
			taskStarted = "I'm waiting for you, Ith! But be carefull, on the mountain you can see a bridge that go to west. Doing this you will reach on Dragon's Lair. Better not go there.",
			taskIncomplete = "Your task is still incomplete. Remember: You need defeat 240 cyclops and 35 cyclops smiths!",
			taskCompleted = { 
				defaultDialogs.COMPLETED_TASK_INIT,
				defaultDialogs.COMPLETED_TASK_END,
			},
		},		
		events = {
			onComplete = { 
				type = "question", 
				text = "Dul! I need some more help. Lets go to the next task?", 
				onConfirm = "action",
				confirmParam = "callResponseTask"
			}
		},			
		reward = {exp = 80000, money = 3000, container = { id = items.brown_backpack,
			isSorcerer = { items.blue_robe },
			isDruid = { items.blue_robe }
		}}
	},			
	[CAP_ONE.ISLAND_OF_PEACE.TENTH] = {
		--requiredTask = CAP_ONE.ISLAND_OF_PEACE.NINTH,
		requirePoints = 10200,
		monsters = {
			{name = "orc", points = 2}, 
			{name = "orc spearman", points = 3}, 
			{name = "orc warrior", points = 5}, 
			{name = "orc shaman", points = 8}, 
			{name = "orc rider", points = 8}, 
			{name = "orc berserker", points = 16}, 
			{name = "orc leader", points = 45}, 
			{name = "orc warlord", points = 155}
		},
		dialogs = {
			--requireTask = "",
			description = "Awasome, Dul! On the south you can find the Orc Fortress. Our spy infiltred belive that they are planning something big! Can you help?",
			taskObjectives = {
				"Human, we belive that if you defeat some of the elite Orcs this will keep the orcs away from the city. This task can done more quickly in a group togheter with other players. [...]",
				"You need collect 10200 points, for each orc defeat you get: orc (2 points), spearman (3 pontos), warrior (5 pontos), shaman and rider (8 pontos), berserker (16 points), leader (45 points) and warlord (155 points)... You are ready?"
			},
			taskStarted = defaultDialogs.STARTED_TASK,
			taskIncomplete = "Your task is still incomplete. Remember: You need collect 10200 points defeating any king of orcs!",
			taskCompleted = { 
				defaultDialogs.COMPLETED_TASK_INIT,
				"Here you reward. Good eh? By the way, you want to be a Dragon's Slayer? Go to the Cyclops's mountain and cross the bridge from the west and find Mesth'zaros...",
			},
		},
		reward = {exp = 186000, money = 5000, container = { id = items.brown_backpack,
			isSorcerer = { 
				{ container = {id = items.brown_backpack, inside = { items.mana_potion, amount = 50}}}, 
				{ container = {id = items.brown_backpack, inside = { items.mana_potion, amount = 50}}} 
			},
			isDruid = { 
				{ container = {id = items.brown_backpack, inside = { items.mana_potion, amount = 50}}}, 
				{ container = {id = items.brown_backpack, inside = { items.mana_potion, amount = 50}}} 
			},
			isPaladin = { container = { id = items.brown_backpack, inside = { items.health_potion, amount = 50}} },
			isKnight = { meleeOptions = { sword = items.bright_sword, axe = items.naginata, club = items.orcish_maul }, container = { id = items.brown_backpack, inside = { items.health_potion, amount = 20}} },
		}}
	},	
	[CAP_ONE.ISLAND_OF_PEACE.ELEVENTH] = {
		requiredTask = CAP_ONE.ISLAND_OF_PEACE.TENTH,
		requireItems = { { items.green_dragon_scale, amount = 1} },
		monsters = {{name = "dragon", amount = 90, storagePos = 1}},
		dialogs = {
			requireTask = "You need first complete the Elf's tasks. Find Van'Caelnis near city.",
			description = "Dragons are ruthless creatures to beginners, however when defeat they give a awasome rewards. You want be a Dragon's Slayer?",
			taskObjectives = "You are a brave young, but is needed more then bravery to be a dragon's slayer... To be a dragon's slayer you need defeat 90 dragons and collect at least one green dragon scale. Are ready?",
			taskStarted = defaultDialogs.STARTED_TASK,
			taskIncomplete = "Your task is still incomplete. Remember: You need defeat 90 dragons and dont forget to give me one green dragon scale!",
			taskCompleted = { 
				defaultDialogs.COMPLETED_TASK_INIT,
				"From now you are ready to face any creature on this island. I know that Boros Krum facing some challanges with the Spiders... Follow to the Spiders place on the south!",
			},
		},		
		reward = {exp = 250000, money = 10000, container = { id = items.brown_backpack,
			items.dragon_shield,
			isSorcerer = { items.wand_of_voodoo },
			isDruid = { items.underworld_rod },
			isKnight = { items.knight_armor, items.knight_legs }
		}}
	},		
	[CAP_ONE.ISLAND_OF_PEACE.TWELFTH] = {
		requiredTask = CAP_ONE.ISLAND_OF_PEACE.ELEVENTH,
		requireItems = { { items.giant_spider_silk, amount = 5} },
		monsters = {{name = "giant spider", amount = 120, storagePos = 1}},
		dialogs = {
			requireTask = "My tasks require you to be a authentic dragon's slayer. Find Mesth'zaros and see how be a dragon's slayer.",
			description = "You can see the Spiders? They are everywhere! We need decimate these spiders otherwise all the island will be taken by these creatures! Are ready?",
			taskObjectives = "You must defeat 120 giant spiders. Also I need at least 5 giant spider silk's to see how put these creatures under control. You agree?",
			taskStarted = defaultDialogs.STARTED_TASK,
			taskIncomplete = "Your task is still incomplete. Remember: You need defeat 120 giant spiders and give me 5 giant spider silk's!",
			taskCompleted = { 
				defaultDialogs.COMPLETED_TASK_INIT,
				"You reward is awasome! I think that now you are ready to face the most terrible creature on the island. The big red... Go talk with the Dragon's slayer again...",
			},
		},		
		reward = {exp = 250000, money = 10000}
	},		
	[CAP_ONE.ISLAND_OF_PEACE.THIRTEENTH] = {
		requiredTask = CAP_ONE.ISLAND_OF_PEACE.TWELFTH,
		monsters = {{name = "dragon lord", amount = 15, storagePos = 1}},
		dialogs = {
			requireTask = "You need complete the task with Boros Krum. Follow to south to the place of Spiders!",
			description = "On the northwest from here you will find your last challange: the dragon lords, the most fearsome creature on this island. You are ready?",
			taskObjectives = "You must defeat 15 dragon lords. If you have success a big reward you will receive. You want?",
			taskStarted = defaultDialogs.STARTED_TASK,
			taskIncomplete = "Your task is still incomplete. Remember: You need defeat 15 dragon lords!",
			taskCompleted = { 
				defaultDialogs.COMPLETED_TASK_INIT,
				"Now you faced all the challenges on this island now. Now you must move on and explore all the Darghos world for new challanges. Go back to the city and move to the boat and ask you want go to Quendor. Then go to depot and find Daves, notify he all your valuable help here. Have a good luck, young dragon's slayer!",
			},
		},
		reward = {exp = 300000, money = 10000}
	},
	
	
	[CAP_ONE.QUENDOR.TRAVELER_IOP] = {
		requiredTask = CAP_ONE.ISLAND_OF_PEACE.THIRTEENTH,
		reward = {exp = 150000, money = 20000, container = { id = items.brown_backpack,
			items.crown_armor, items.crown_legs}
		}
	}
}

-- Static Methods

tasks = {}

function tasks.hasStartedTask(cid)

	local task = tasks.getStartedTask(cid)
	
	if(task == STORAGE_NULL) then
		return false
	end
		
	return true	
end

function tasks.getStartedTask(cid)
	return getPlayerStorageValue(cid, sid.TASK_STARTED)
end



-- Object Methods

Task = {
	taskid = 0,
	cid = 0,
	itemsStr = "",
	itemsStrFirst = true,
	npcname = "",
}

function Task:new()
	local obj = {}
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function Task:loadById(taskid)

	for k,v in pairs(tasksList) do
		if(k == taskid) then
			self.taskid = taskid
			return true
		end
	end
	
	return false
end

function Task:setNpcName(name)
	self.npcname = name
end

function Task:setPlayer(player)
	self.cid = player
end

function Task:getMonsters()
	return tasksList[self.taskid].monsters
end

function Task:getRequirePoints()
	
	return tasksList[self.taskid].requirePoints
end

function Task:getPlayerKillsCount(monsterPos)
	local value = getPlayerStorageValue(self.cid, monsterPos)
	
	if(value == STORAGE_NULL) then
		return 0
	end
	
	return value
end

function Task:setPlayerKillsCount(monsterPos, value)
	setPlayerStorageValue(self.cid, monsterPos, value)
end

function Task:sendKillMessage(str)
	doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_ORANGE, str)
end

function Task:setStarted()
	setPlayerStorageValue(self.cid, self.taskid, taskStats.STARTED)
	setPlayerStorageValue(self.cid, sid.TASK_STARTED, self.taskid)
end

function Task:setCompleted()
	consoleLog(T_LOG_NOTIFY, self.npcname, "Task:setCompleted", "Setting player to task completed!", {player=getCreatureName(self.cid), startedTask=self.taskid})
	setPlayerStorageValue(self.cid, self.taskid, taskStats.COMPLETED)
	setPlayerStorageValue(self.cid, sid.TASK_STARTED, -1)
end

function Task:getState()
	return getPlayerStorageValue(self.cid, self.taskid)
end

function Task:doPlayerAddReward()

	if(self:getState() == taskStats.COMPLETED) then
		consoleLog(T_LOG_WARNING, self.npcname, "Task:doPlayerAddReward", "The Player are receiving reward!", {taskid=self.taskid, player=getCreatureName(self.cid)})
	end

	local reward = tasksList[self.taskid].reward
	
	if(reward.paladinDistTo ~= nil and isPaladin(self.cid)) then
	
		local count = reward.paladinDistTo - getPlayerSkill(self.cid, LEVEL_SKILL_DISTANCE)
		local oldskill = getPlayerSkill(self.cid, LEVEL_SKILL_DISTANCE)
		if(count > 0) then
			doPlayerAddSkill(self.cid, LEVEL_SKILL_DISTANCE, count)
			doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_BLUE, "You advanced from distance skill " .. oldskill .. " to " .. reward.paladinDistTo .. ".")
		end
		
		if(reward.paladinShieldTo ~= nil and isPaladin(self.cid)) then
			local count = reward.paladinShieldTo - getPlayerSkill(self.cid, LEVEL_SKILL_SHIELDING)
			local oldskill = getPlayerSkill(self.cid, LEVEL_SKILL_SHIELDING)
			if(count > 0) then
				doPlayerAddSkill(self.cid, LEVEL_SKILL_SHIELDING, count)
				doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_BLUE, "You advanced from shield skill " .. oldskill .. " to " .. reward.paladinShieldTo .. ".")
			end
		end
	elseif(reward.knightSkillTo ~= nil and isKnight(self.cid)) then
	
		local skillid = getPlayerHighMelee(self.cid)
	
		local count = reward.knightSkillTo - getPlayerSkill(self.cid, skillid)
		local oldskill = getPlayerSkill(self.cid, skillid)
		if(count > 0) then
			doPlayerAddSkill(self.cid, skillid, count)
			doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_BLUE, "You advanced you best meele skill " .. oldskill .. " to " .. reward.knightSkillTo .. ".")
		end
		
		local count = reward.knightSkillTo - getPlayerSkill(self.cid, LEVEL_SKILL_SHIELDING)
		local oldskill = getPlayerSkill(self.cid, LEVEL_SKILL_SHIELDING)
		if(count > 0) then
			doPlayerAddSkill(self.cid, LEVEL_SKILL_SHIELDING, count)
			doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_BLUE, "You advanced shield skill " .. oldskill .. " to " .. reward.knightSkillTo .. ".")
		end
	elseif(reward.magicLevelTo ~= nil and (isSorcerer(self.cid) or isDruid(self.cid))) then
	
		local count = reward.magicLevelTo - getPlayerMagLevel(self.cid)
		local oldml = getPlayerMagLevel(self.cid)
		if(count > 0) then
			doPlayerAddMagLevel(self.cid, count)
			doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_BLUE, "oc� avan��u de magic level " .. oldml .. " para " .. reward.magicLevelTo .. ".")
		end
	end
	
	if(reward.exp ~= nil) then
		doPlayerAddExp(self.cid, reward.exp * EXPERIENCE_RATE)
		doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_BLUE, "You are rewarded with " .. (reward.exp * EXPERIENCE_RATE) .. " experience points by finish your task.")
	end
	
	if(reward.money ~= nil) then
		doPlayerAddMoney(self.cid, reward.money)
		doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_BLUE, "You are rewarded with " .. reward.money .. " gold coins by finishing you task.")
	end	
	
	self:doPlayerAddRewardItems()
end

function Task:doPlayerAddRewardItems()
	
	self:resetItemString()
	
	local container = tasksList[self.taskid].reward.container
	
	if(container == nil) then
		return
	end
	
	local _container = nil
	
	if(container.id ~= nil) then
		_container = doCreateItemEx(container.id, 1)
	else
		consoleLog(T_LOG_WARNING, self.npcname, "Task:doPlayerAddRewardItems", "Container id not found!")
	end
	
	for ck, cv in pairs(container) do
		if(ck == "id") then
			-- nada a fazer
		elseif(ck == "isSorcerer") then
			if(isSorcerer(self.cid)) then
				self:parseVocationItems(cv, _container)
			end
		elseif(ck == "isDruid") then	
			if(isDruid(self.cid)) then
				self:parseVocationItems(cv, _container)
			end		
		elseif(ck == "isPaladin") then	
			if(isPaladin(self.cid)) then
				self:parseVocationItems(cv, _container)
			end			
		elseif(ck == "isKnight") then	
			if(isKnight(self.cid)) then
				self:parseVocationItems(cv, _container)
			end			
		else
			if(doAddContainerItem(_container, cv) ~= LUA_ERROR) then
				self:addItemToString(cv)
			else
				consoleLog(T_LOG_ERROR, self.npcname, "Task:doPlayerAddRewardItems", "Cant add item to main container.", {taskid=self.taskid, player=getCreatureName(self.cid), itemid=cv})
			end
		end
	end
	
	if(self.itemsStr ~= "") then
		local ret = doPlayerAddItemEx(self.cid, _container, TRUE)
		
		if(ret ~= LUA_NO_ERROR) then
			--print("FODEU")
		end
		
		self.itemsStr = self.itemsStr .. "."
		doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_BLUE, self.itemsStr)
	end
end

function Task:parseVocationItems(node, container)
	for key, value in pairs(node) do
		if(key == "container") then
			-- container = { id = items.brown_backpack, inside = { items.mana_potion, amount = 20}}
			local internalContainer = nil
			if(value.id ~= nil) then
				internalContainer = doCreateItemEx(value.id, 1)
			else
				--print("[WARNING] Task:parseVocationItems :: Internal id to container not found")
			end
		
			self:parseInternalContainer(value, internalContainer)
			if(doAddContainerItemEx(container, internalContainer) == LUA_ERROR) then
				consoleLog(T_LOG_ERROR, self.npcname, "Task:parseVocationItems", "Cant add internal container to main container.", {taskid=self.taskid, player=getCreatureName(self.cid)})
			end
		elseif(key == "meleeOptions") then
			self:parseMeleeWeapon(value, container)
		else
			if(doAddContainerItem(container, value) ~= LUA_ERROR) then
				self:addItemToString(value)
			else
				consoleLog(T_LOG_ERROR, getNpcName(), "Task:parseVocationItems", "Can not add item to main container.", {taskid=self.taskid, player=getCreatureName(self.cid)})
			end
		end
	end
end

function Task:parseInternalContainer(node, internalContainer)

	local itemid = node.inside[1]
	local amount = node.inside.amount
	
	self:addItemToString(itemid, true)
	
	for i = 1, amount, 1 do
		local itemEx = doCreateItemEx(itemid)
		if(doAddContainerItemEx(internalContainer, itemEx) == LUA_ERROR) then
			consoleLog(T_LOG_ERROR, self.npcname, "Task:parseInternalContainer", "Cant add a item to internal container.", {taskid=self.taskid, player=getCreatureName(self.cid), itemid=itemid, amount=i})	
		end
	end
end

function Task:parseMeleeWeapon(node, container)

	local skillid = getPlayerHighMelee(self.cid)

	for key,value in pairs(node) do
		if(key == "club" and skillid == LEVEL_SKILL_CLUB) then	
			if(doAddContainerItem(container, value) ~= LUA_ERROR) then
				self:addItemToString(value)
			else
				consoleLog(T_LOG_ERROR, self.npcname, "Task:parseMeleeWeapon", "Can not add player melee weapon (club).", {taskid=self.taskid, player=getCreatureName(self.cid), itemid=value})
			end
		elseif(key == "axe" and skillid == LEVEL_SKILL_AXE) then	
			if(doAddContainerItem(container, value) ~= LUA_ERROR) then
				self:addItemToString(value)
			else
				consoleLog(T_LOG_ERROR, self.npcname, "Task:parseMeleeWeapon", "Can not add player melee weapon (axe).", {taskid=self.taskid, player=getCreatureName(self.cid), itemid=value})
			end			
		elseif(key == "sword" and skillid == LEVEL_SKILL_SWORD) then	
			if(doAddContainerItem(container, value) ~= LUA_ERROR) then
				self:addItemToString(value)
			else
				consoleLog(T_LOG_ERROR, self.npcname, "Task:parseMeleeWeapon", "Can not add player melee weapon (sword).", {taskid=self.taskid, player=getCreatureName(self.cid), itemid=value})
			end		
		end
	end
end

function Task:resetItemString()
	self.itemsStrFirst = true
end

function Task:addItemToString(item, isBackpack)

	if(self.itemsStrFirst) then
		self.itemsStr = "The following items are received as reward of the completed task: " .. getItemNameById(item)
		self.itemsStrFirst = false
	else
		if(isBackpack == nil) then
			isBackpack = false
		end
		
		if(isBackpack) then
			self.itemsStr = self.itemsStr .. ", " .. "backpack of " .. getItemNameById(item)
		else
			self.itemsStr = self.itemsStr .. ", " .. getItemNameById(item)
		end
	end
end

function Task:checkPlayerRequirements()
	local requiredTask = tasksList[self.taskid].requiredTask
	
	if(getPlayerStorageValue(self.cid, requiredTask) == taskStats.COMPLETED) then	
		return true
	end
	
	return false
end

function Task:removeRequiredItems()
	
	-- requireItems = { { items.golden_goblet} },
	local items = tasksList[self.taskid].requireItems
	
	if(items == nil) then
		return true
	end
	
	for k,v in pairs(items) do	
		local item = v
		local amount = 1
		
		if(item["amount"] ~= nil) then
			amount = item["amount"]
		end
		
		if(getPlayerItemCount(self.cid, item[1]) < amount) then
			return false
		end
	end
	
	for k,v in pairs(items) do	
		local item = v
		local amount = 1
		
		if(item["amount"] ~= nil) then
			amount = item["amount"]
		end		
		
		if(doPlayerRemoveItem(self.cid, item[1], amount) ~= TRUE ) then
			-- apesar do player possuir o item não foi possivel remover-lo
			return false
		end
	end	
	
	return true
end