local m_posi = {
 {x= KASHMIR_GLOBE_POSITION.x - 4,y=KASHMIR_GLOBE_POSITION.y,z=KASHMIR_GLOBE_POSITION.z},
 {x= KASHMIR_GLOBE_POSITION.x + 4,y=KASHMIR_GLOBE_POSITION.y,z=KASHMIR_GLOBE_POSITION.z},
 {x=KASHMIR_GLOBE_POSITION.x,y=KASHMIR_GLOBE_POSITION.y + 4,z=KASHMIR_GLOBE_POSITION.z},
 {x=KASHMIR_GLOBE_POSITION.x,y=KASHMIR_GLOBE_POSITION.y - 4,z=KASHMIR_GLOBE_POSITION.z},
 {x=KASHMIR_GLOBE_POSITION.x,y=KASHMIR_GLOBE_POSITION.y + 5,z=KASHMIR_GLOBE_POSITION.z},
 {x=KASHMIR_GLOBE_POSITION.x,y=KASHMIR_GLOBE_POSITION.y - 5,z=KASHMIR_GLOBE_POSITION.z}
}

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
    local tmp = getTopCreature(KASHMIR_ROOM_BLIND_FIELD_POSITION).uid;
    if(checkFunction(tmp))then
        table.insert(rarr, tmp);
    end
    return rarr;
end

function getCreatureFromArea(fromPos, toPos,name) 
    for fx = fromPos.x, toPos.x do
        for fy = fromPos.y, toPos.y do
            for fz = fromPos.z, toPos.z do
                local tmp = getTopCreature({x=fx,y=fy,z=fz}).uid;
                if(tmp > 0)then
                    if(string.lower(name) == string.lower(getCreatureName(tmp)))then
                        return tmp;
                    end
                end
            end
        end
    end
    local tmp = getTopCreature(KASHMIR_ROOM_BLIND_FIELD_POSITION).uid;
    if(tmp > 0)then
        if(string.lower(name) == string.lower(getCreatureName(tmp)))then
            return tmp;
        end
    end
    return 0;
end

local function FirstWave(count, spawnazerus) 
    if(getStorage(gid.KASHMIR_QUEST_RUNNING) < 1)then
        return;
    end
    spawnazerus = spawnazerus or false;
    if(spawnazerus)then
        doCreateMonster("Azerus", m_posi[math.random(1,#m_posi)], false, true);
        for _,pos in pairs(m_posi) do
            doCreateMonster("Rift Worm", pos, false, true);
        end
    else
        for i =1, count do
            doCreateMonster("Rift Worm", m_posi[math.random(1,#m_posi)], false, true);
        end
    end
    addEvent(FirstWave,math.random(KASHMIR_TTIME[1],KASHMIR_TTIME[2])*1000,math.random(1,#m_posi));
end 

local function SecondWave(count, replaceazerus) 
    if(getStorage(gid.KASHMIR_QUEST_RUNNING) < 1)then
        return;
    end
    replaceazerus = replaceazerus or false;
    if(replaceazerus)then
        local tmp = getCreatureByName("Azerus");
        if(tmp > 0)then
            doRemoveCreature(tmp);
        end
        doCreateMonster("Azerus1", m_posi[math.random(1,#m_posi)], false, true);
        
        for _,pos in pairs(m_posi) do
            doCreateMonster("Rift Brood", pos, false, true);
        end
    else
        for i =1, count do
            doCreateMonster("Rift Brood", m_posi[math.random(1,#m_posi)], false, true);
        end
    end
    addEvent(SecondWave,math.random(KASHMIR_TTIME[1],KASHMIR_TTIME[2])*1000,math.random(1,#m_posi));
end 

local function ThirdWave(count, replaceazerus) 
    if(getStorage(gid.KASHMIR_QUEST_RUNNING) < 1)then
        return;
    end
    replaceazerus = replaceazerus or false;
    if(replaceazerus)then
        local tmp = getCreatureByName("Azerus");
        if(tmp > 0)then
            doRemoveCreature(tmp);
        end
        doCreateMonster("Azerus2", m_posi[math.random(1,#m_posi)], false, true);
        for _,pos in pairs(m_posi) do
            doCreateMonster("Rift Scythe", pos, false, true);
        end
    else
        for i =1, count do
            doCreateMonster("Rift Scythe", m_posi[math.random(1,#m_posi)], false, true);
        end
    end
    addEvent(ThirdWave,math.random(KASHMIR_TTIME[1],KASHMIR_TTIME[2])*1000,math.random(1,#m_posi));
end 

local function FourthWave(count, replaceazerus) 
    if(getStorage(gid.KASHMIR_QUEST_RUNNING) < 1)then
        return;
    end
    if(replaceazerus)then
        local tmp = getCreatureByName("Azerus");
        if(tmp > 0)then
            doRemoveCreature(tmp);
        end
        tmp = doCreateMonster("Azerus3", m_posi[math.random(1,#m_posi)], false, true);
        registerCreatureEvent(tmp, "AzerusDeath");
        
        for _,pos in pairs(m_posi) do
            doCreateMonster("War Golem", pos, false, true);
        end
    else
        for i =1, count do
            doCreateMonster("War Golem", m_posi[math.random(1,#m_posi)], false, true);
        end
    end
    addEvent(FourthWave,math.random(KASHMIR_TTIME[1],KASHMIR_TTIME[2])*1000,math.random(1,#m_posi));
end 

local function fixGlobe()
    doItemSetAttribute(getTileItemById(KASHMIR_GLOBE_POSITION, 9767).uid, "aid", aid.KASHMIR_GLOBE_READY)
end

local function checkArea()
    if(getStorage(gid.KASHMIR_QUEST_RUNNING) > 0)then
        local players = getCreaturesFromArea(KASHMIR_ROOM_TOP_LEFT_POSITION, KASHMIR_ROOM_BOTTOM_RIGHT_POSITION, isPlayer);
        if(#players < 1)then
            doSetStorage(gid.KASHMIR_QUEST_RUNNING,0);
            endAzerusFightA();
            addEvent(fixGlobe, 60*1000);
        else
            addEvent(checkArea, 10*1000);
        end
    end
end

function endAzerusFightA()
    local monsters = getCreaturesFromArea(KASHMIR_ROOM_TOP_LEFT_POSITION,KASHMIR_ROOM_BOTTOM_RIGHT_POSITION,isMonster);
    while(#monsters > 0)do
        for _,m in pairs(monsters)do
            doRemoveCreature(m);
        end
        monsters = getCreaturesFromArea(KASHMIR_ROOM_TOP_LEFT_POSITION,KASHMIR_ROOM_BOTTOM_RIGHT_POSITION,isMonster);
    end
     tp = getTileItemById(KASHMIR_TP_OUT_SELF_POSITION,7493).uid;
    if(tp > 0)then
	doTransformItem(uid.KASHMIR_TP_OUT, 1387)
    end
    doSetStorage(gid.KASHMIR_QUEST_RUNNING,-1)
    --doCreateTeleport(1387, KASHMIR_TP_IN_DESTINATION,KASHMIR_TP_IN_SELF_POSITION);
    --doCreateTeleport(1387, KASHMIR_TP_OUT_DESTINATION,KASHMIR_TP_OUT_SELF_POSITION);
end

function onUse(cid, item, fromPosition, itemEx, toPosition) 
    if item.actionid == aid.KASHMIR_GLOBE_READY then
        doItemSetAttribute(item.uid, "aid", aid.KASHMIR_GLOBE_WAITING)
	
    else
        doCreatureSay(cid, "Você precisa esperar algum tempo para que o globo recarregue sua energia.", TALKTYPE_ORANGE_1)
        return;
    end

    --[[local tp = getTileItemById(KASHMIR_TP_IN_SELF_POSITION,1387).uid;
    if(tp > 0)then
        doRemoveItem(tp)
    end]]
    tp = getTileItemById(KASHMIR_TP_OUT_SELF_POSITION,1387).uid;
    if(tp > 0)then
	doTransformItem(uid.KASHMIR_TP_OUT, 7493)
    end
    
    doSetStorage(gid.KASHMIR_QUEST_RUNNING,1);
    checkArea();
    FirstWave(0,true) 
    addEvent(SecondWave, math.random(60,70)*1000,0,true) 
    addEvent(ThirdWave, math.random(100,130)*1000,0,true) 
    addEvent(FourthWave, math.random(190,210)*1000,0,true) 
    return true 
end  