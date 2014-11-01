function onSay(cid, words, param, channel)
        local _ip = nil
        if(param ~= '') then
                _ip = tonumber(param)
                if(not _ip or _ip == 0) then
                        local revertIp = doRevertIp(param)
                        if(not revertIp) then
                                local tid = getPlayerByNameWildcard(param)
                                if(not tid) then
                                        _ip = nil
                                else
                                        _ip = getPlayerIp(tid)
                                end
                        else
                                _ip = doConvertIpToInteger(revertIp)
                        end
                end
        end

        local list = {}
        local players = getPlayersOnline()
        for i, pid in ipairs(players) do
            if getPlayerGroupId(pid) == 1 then
                local ip = getPlayerIp(pid)
            
                if(list[ip] == nil) then
                    list[ip] = {}
                end
                    
                table.insert(list[ip], pid)
            end
        end
        
        if(table.maxn(list) > 0) then
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Currently online players with same IP address(es) list:")
                local total = 0
                for ip, players in pairs(list) do
                    if(#players >= 2) then
                        local names = {}
                        
                        for _, pid in pairs(players) do
                            table.insert(names, getCreatureName(pid))
                            total = total + 1
                        end  
                        
                        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[" .. doConvertIntegerToIp(ip) .. ", " .. #players .. "]: " .. table.implode(", ", names))
                    end
                end
                
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Currently online players with same IP address(esses) total: " .. total)
        else
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Currently there aren't any players with same IP address(es).")
        end

        return true
end