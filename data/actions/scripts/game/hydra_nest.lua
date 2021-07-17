local _HydraEggChance = 12500
local _HydraMessages = {
	"<GROARGGHHHTTTTTT!!!! ... um rugido de longe pode ser ouvido...>",
	"<o chão parece estar tremendo. Algo se aproxima!>"
}

local _SummonHydraMessage = "<Ghazran parece estar furioso! Ele chegou para proteger seu ninho!>"
local _GhazranPos = {x=2811, y=1806, z=10, stackpos=253}
local _GhazranSummoned = false

local ITEM_HYDRA_EGG = 4850

_EggsGained = 0


function onUse(cid, item, frompos, item2, topos)

	if(_GhazranSummoned) then
		return true	
	end

	if(isInArray(aid.ARIADNE_HYDRA_NEST, item.actionid) == TRUE) then
	
		if(math.random(1, 100000) <= _HydraEggChance) then
		
			_EggsGained = _EggsGained + 1
			doPlayerAddItem(cid, ITEM_HYDRA_EGG, 1)
			
			local msgRandom = math.random(1, #_HydraMessages)
			
			doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, _HydraMessages[msgRandom])
		else
		
			doPlayerSendCancel(cid, "Nada encontrado neste ninho, talvez deva procurar mais.")
		end	
		
		if(_EggsGained > 10 and math.random(1, 100) >= 50) then
			
			doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, _SummonHydraMessage)
			_GhazranSummoned = true
			
			addEvent(summonGhazran, 1000 * 5)
		end
	end
	
	return true
end

function onThink(lastBegin)

	if(not getCreatureByName("ghazran") and (Dungeons.isFree(gid.DUNGEONS_ARIADNE_GHAZRAN) or Dungeons.getLastBegin(gid.DUNGEONS_ARIADNE_GHAZRAN) ~= lastBegin)) then
		_GhazranSummoned = false
		_EggsGained = 0
	else
		addEvent(onThink, 1000 * 10, lastBegin)
	end
end

function summonGhazran()
	
	local cid = doSummonCreature("ghazran", _GhazranPos)
	registerCreatureEvent(cid, "monsterDeath")
	
	onThink(Dungeons.getLastBegin(gid.DUNGEONS_ARIADNE_GHAZRAN))
end