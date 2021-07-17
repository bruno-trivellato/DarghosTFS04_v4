local dialog = NpcDialog:new()
local npcSys = _NpcSystem:new()
npcSys:setDialog(dialog)

local shop = NpcShop:new(dialog, NPC_TRADETYPE_HONOR)

local LIST_MISC = 1
local LIST_KNIGHT_SET = 2
local LIST_PALADIN_SET = 3
local LIST_SORCERER_SET = 4
local LIST_DRUID_SET = 5

local itemList = {

	-- utils
	{ buy = 50, subType = 100, name = "infernal bolt" }
	,{ buy = 35, subType = 100, name = "burst arrow" }
	,{ buy = 50, name = "flask of rusty remover"}
	,{ id = 10511, buy = 300, name = "sneaky stabber of eliteness"}
	,{ id = 10513, buy = 300, name = "squeezing gear of girlpower"}
	,{ id = 10515, buy = 300, name = "whacking driller of fate"}
	,{ buy = 800, subType = 50, name = "demonic essence"}
	
	-- special backpacks
	,{ buy = 500, name = "dragon backpack"}
	,{ buy = 500, name = "moon backpack"}
	,{ buy = 500, name = "heart backpack"}
	,{ buy = 750, requireRating = 500, name = "jewelled backpack"}
	
	-- powerfull potions
	,{ buy = 250, requireRating = 500, name = "bullseye potion"}
	,{ buy = 200, requireRating = 500, name = "berserk potion"}
	,{ buy = 250, requireRating = 500, name = "mastermind potion"}	
	
	-- special rings
	,{ id = 12676, buy = 2850}
	,{ id = 12677, buy = 2850}
	,{ id = 12678, buy = 2850}
	,{ id = 12682, buy = 2850}
	,{ id = 12684, buy = 2850}
	,{ id = 12686, buy = 2850}
	,{ id = 12688, buy = 2850}
	
	-- outfit & addons items
	,{ buy = 6250, requireRating = 1200, name = "elane's crossbow"}
	,{ buy = 6250, requireRating = 1200, name = "huge chunk of crude iron"}
	,{ buy = 6250, requireRating = 1200, name = "soul stone"}
	,{ buy = 6250, requireRating = 1200, name = "nose ring"}
	,{ buy = 6250, subType = 100, requireRating = 1200, name = "turtle shell"}
	,{ buy = 6250, requireRating = 1200, name = "mandrake"}
	,{ buy = 6250, requireRating = 1200, name = "mermaid comb"}
	--,{ id = 12691, buy = 7500, setActionId = 22, requireRating = 1600, name = "warmaster outfit ticket"}
	--,{ id = 12691, buy = 7500, setActionId = 21, requireRating = 1600, name = "yalaharian outfit ticket"}
	--,{ id = 12691, buy = 7500, setActionId = 23, requireRating = 1600, name = "wayfarer outfit ticket"}
}

shop:addNegotiableListItems(LIST_MISC, itemList)

-- Knights
--[[itemList = {

        { buy = 4500, name = "gladiator helm"}
        ,{ buy = 5250, name = "gladiator chest"}
        ,{ buy = 4500, name = "gladiator legs"}
        ,{ buy = 2850, name = "gladiator boots"}
        ,{ buy = 2850, name = "gladiator pendant"}
        
        ,{ buy = 7250, name = "gladiator's blade"}
        ,{ buy = 7250, name = "gladiator's decapitator"}
        ,{ buy = 7250, name = "gladiator's hammer"}
        
        ,{ buy = 4500, name = "sacred helm"}
        ,{ buy = 5250, name = "sacred chest"}
        ,{ buy = 4500, name = "sacred legs"}
        ,{ buy = 2850, name = "sacred boots"}
        ,{ buy = 2850, name = "sacred pendant"}
        
        ,{ buy = 4250, name = "sacred sword"}
        ,{ buy = 4250, name = "sacred axe"}
        ,{ buy = 4250, name = "sacred hammer"}
        ,{ buy = 4250, name = "sacred shield"}        
}

shop:addNegotiableListItems(LIST_KNIGHT_SET, itemList)

-- Paladin
itemList = {

        { buy = 4500, name = "demonhunter helm"}
        ,{ buy = 5250, name = "demonhunter chest"}
        ,{ buy = 4500, name = "demonhunter legs"}
        ,{ buy = 2850, name = "demonhunter boots"}
        ,{ buy = 2850, name = "demonhunter pendant"}
        
        ,{ buy = 7250, name = "demonhunter crossbow"} 
}

shop:addNegotiableListItems(LIST_PALADIN_SET, itemList)

-- Sorcerer
itemList = {

        { buy = 4500, name = "arcanist hat"}
        ,{ buy = 5250, name = "arcanist robe"}
        ,{ buy = 4500, name = "arcanist legs"}
        ,{ buy = 2850, name = "arcanist boots"}
        ,{ buy = 2850, name = "pendant of fallen dragon"}
        
        ,{ buy = 7250, name = "knowledge of fallen dragon"} 
}

shop:addNegotiableListItems(LIST_SORCERER_SET, itemList)

-- Druid
itemList = {

        { buy = 4500, name = "ancient nature mask"}
        ,{ buy = 5250, name = "ancient nature chest"}
        ,{ buy = 4500, name = "ancient nature legs"}
        ,{ buy = 2850, name = "ancient nature boots"}
        ,{ buy = 2850, name = "pendant of fallen dragon"}
        
        ,{ buy = 7250, name = "knowledge of fallen dragon"} 
}

shop:addNegotiableListItems(LIST_DRUID_SET, itemList)]]--

function onCreatureSay(cid, type, msg)
	msg = string.lower(msg)
	local distance = getDistanceTo(cid) or -1
	if((distance < npcSys:getTalkRadius()) and (distance ~= -1)) then
            
        local list_id = nil
        local voc_msg = ""
        
        if(isKnight(cid)) then
            list_id = LIST_KNIGHT_SET
            voc_msg = "knight"
        elseif(isPaladin(cid)) then
            list_id = LIST_PALADIN_SET
            voc_msg = "paladin"
        elseif(isSorcerer(cid)) then
            list_id = LIST_SORCERER_SET
            voc_msg = "sorcerer"
        elseif(isDruid(cid)) then
            list_id = LIST_DRUID_SET
            voc_msg = "druid"                             
        end            
            
		if((msg == "hi" or msg == "hello" or msg == "ola") and not (npcSys:isFocused(cid))) then
			dialog:say("Olá bravo " .. getCreatureName(cid) .."! Eu {troco} uma série de itens por pontos de honra. Você ganha pontos de honra por suas participações em Battlegrounds.", cid)
			npcSys:addFocus(cid)
		elseif(npcSys:isFocused(cid) and (msg == "trade" or msg == "troco" or msg == "trocar")) then
			dialog:say("Otimo, aqui está, sinta-se a vontade...", cid)					
			shop:onPlayerRequestTrade(LIST_MISC, cid)
			npcSys:setTopic(cid, 2)
        --[[elseif(npcSys:isFocused(cid) and (msg == "equipamentos" or msg == "equipamento" or msg == "equip" or msg == "weapons" or msg == "armas")) then                        
            dialog:say("De uma olhada nestas raridades bravo " .. voc_msg .. "...", cid)                                      
            shop:onPlayerRequestTrade(list_id, cid)
            npcSys:setTopic(cid, 2)]]--                     
		elseif(npcSys:isFocused(cid) and isInArray({"sim", "yes"}, msg) and npcSys:getTopic(cid) == 2) then
			shop:onPlayerConfirmBuy(cid)
		elseif(npcSys:isFocused(cid) and isInArray({"não", "nao", "no"}, msg)) then
			shop:onPlayerDeclineBuy(cid)
		elseif((npcSys:isFocused(cid)) and (msg == "bye" or msg == "goodbye" or msg == "cya" or msg == "adeus")) then
			dialog:say("Até mais!", cid)
			npcSys:removeFocus(cid)		
		end
	end
end

function onCreatureDisappear(cid) npcSys:onCreatureDisappear(cid) end
function onPlayerCloseChannel(cid) npcSys:onPlayerCloseChannel(cid) end
function onThink() npcSys:onThink() end