--[[

	Funcionamento do Magic Wall (de acordo com o Tibia Wikia):

	Inicialmente, ele sera um Magic Wall simples.
	Quando usado o vial o wall ficará energizado por 20 segundos e então ele passará a pegar fogo (pequeno), e deverá ser usado novamente o vial e ele retornará ao estado de energizado.
	Este processo deverá ser repetido 3 vezes, na ultima o wall pegara fogo (grande) durante 10 segundos, e neste periodo, quem usar (até 5 jogadores) o vial tera completado a missão, após passado os 10 segundos, o wall voltará a condição incial e todo processo deverá ser repetido.
	
	Quando iniciada a quest, serão sumonados 5 demons em cada 1 dos 5 portais, estes demons ao serem mortos renascen instantanemaente no portal (ver o onKill creature event)
]]--

local ITEMS_MAGIC_BARRIER = 8753
local ITEMS_FIRE_BARRIER_SMALL = 8755
local ITEMS_FIRE_BARRIER_MEDIUM = 8757
local ITEMS_FIRE_BARRIER_FULL = 8759

local WALL_ENERGIZE_TIME = 20
local WALL_FULL_FIRE_TIME = 10

local MAX_PLAYERS_CAN_FINISH = 5

local startLastEvent = false
local summoningDemons = false
local replaceEvent = nil
local finishedTimes = 0

function summonDemons()
	
	if(summoningDemons) then
		return
	end
	
	summoningDemons = true
	
	local demons = {
		getThingPosition(uid.INQ_DEMON_1),
		getThingPosition(uid.INQ_DEMON_2),
		getThingPosition(uid.INQ_DEMON_3),
		getThingPosition(uid.INQ_DEMON_4),
		getThingPosition(uid.INQ_DEMON_5),
	}
	
	for k,v in pairs(demons) do
		local demon = doSummonCreature("demon", v)
		registerCreatureEvent(demon, "inquisitionReplaceDemons")
	end
end

function scheduleReplaceWall()

	replaceEvent = addEvent(replaceWall, 1000 * WALL_ENERGIZE_TIME)
end

function scheduleResetWall()

	replaceEvent = addEvent(replaceWall, 1000 * WALL_FULL_FIRE_TIME, true)
end

function replaceWall(reset)

	local wall = getThing(uid.INQ_MWALL)
	local newid = (reset) and ITEMS_MAGIC_BARRIER or wall.itemid + 1

	if(reset) then
		startLastEvent = false
		finishedTimes = 0
	end	

	doTransformItem(wall.uid, newid)
	doSendMagicEffect(getThingPosition(wall.uid), CONST_ME_HOLYAREA)
end

function completeMission(cid, item)

	if(getPlayerStorageValue(cid, sid.INQ_DONE_MWALL) == 1) then
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Voc�s ja enfraqueceu a fonte da origem demoniaca o sulficiente.")			
		return
	end

	finishedTimes = finishedTimes + 1

	if(not startLastEvent) then
		startLastEvent = true
		scheduleResetWall()
	end

	if(finishedTimes <= MAX_PLAYERS_CAN_FINISH) then
	
		if(finishedTimes == MAX_PLAYERS_CAN_FINISH) then
			stopEvent(replaceEvent)
			replaceWall(true)
		end
		
		doRemoveItem(item.uid)
		doCreatureSay(cid, "Meu frasco com o liquido sagrado acaba de terminar! Minha miss�o aqui est� concluida!", TALKTYPE_ORANGE_1)
		doSendMagicEffect(getThingPosition(uid.INQ_MWALL), CONST_ME_FIREAREA)	
		setPlayerStorageValue(cid, sid.INQ_DONE_MWALL, 1)
	end
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	
	local wall = getThing(uid.INQ_MWALL)
	
	if(itemEx.uid == wall.uid) then
		if(itemEx.itemid == ITEMS_MAGIC_BARRIER) then
			summonDemons()
			replaceWall()
			scheduleReplaceWall()
		elseif(itemEx.itemid == ITEMS_FIRE_BARRIER_SMALL or itemEx.itemid == ITEMS_FIRE_BARRIER_MEDIUM) then
			replaceWall()
			scheduleReplaceWall()
		elseif(itemEx.itemid == ITEMS_FIRE_BARRIER_FULL) then
			completeMission(cid, item)
		end
	end
end