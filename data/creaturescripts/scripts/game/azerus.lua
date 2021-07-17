function getCreaturesFromArea(fromPos, toPos,checkFunction) 
    local rarr = {};
    checkFunction = checkFunction or function(arg) return true; end;
    for fx = fromPos.x, toPos.x do
        for fy = fromPos.y, toPos.y do
            for fz = fromPos.z, toPos.z do
                local tmp = getTopCreature({x=fx,y=fy,z=fz}).uid;
                if(checkFunction(tmp))then
                    table.insert(rarr, tmp);
                end
            end
        end
    end
    local tmp = getTopCreature(KASHMIR_ROOM_BLIND_FIELD_POSITION).uid
    if(checkFunction(tmp))then
        table.insert(rarr, tmp)
    end
    return rarr;
end

local function fixGlobe()
    doItemSetAttribute(getTileItemById(KASHMIR_GLOBE_POSITION, 9767).uid, "aid", aid.KASHMIR_GLOBE_READY)
end

function endAzerusFightC()
    local monsters = getCreaturesFromArea(KASHMIR_ROOM_TOP_LEFT_POSITION,KASHMIR_ROOM_BOTTOM_RIGHT_POSITION,isMonster)
    while(#monsters > 0)do
        for _,m in pairs(monsters)do
            doRemoveCreature(m)
        end
        monsters = getCreaturesFromArea(KASHMIR_ROOM_TOP_LEFT_POSITION,KASHMIR_ROOM_BOTTOM_RIGHT_POSITION,isMonster)
    end
    doSetStorage(gid.KASHMIR_QUEST_RUNNING,-1)
    --doCreateTeleport(1387, KASHMIR_TP_IN_DESTINATION,KASHMIR_TP_IN_SELF_POSITION)
    
    --doCreateTeleport(1387, KASHMIR_TP_OUT_DESTINATION,KASHMIR_TP_OUT_SELF_POSITION)
    tp = getTileItemById(KASHMIR_TP_OUT_SELF_POSITION,7493).uid;
    if(tp > 0)then
	doTransformItem(uid.KASHMIR_TP_OUT, 1387)
    end
    addEvent(fixGlobe,60*12*1000)
end

function onDeath(cid, corpse, deathList)
    doSetStorage(gid.KASHMIR_QUEST_RUNNING,0)
    addEvent(endAzerusFightC,200*1000)
    doCreatureSay(cid, "Você tem 3 minutos para entrar no teleport.", TALKTYPE_ORANGE_1)
    return true;
end  