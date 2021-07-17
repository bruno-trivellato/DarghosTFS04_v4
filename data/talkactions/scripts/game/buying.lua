local msg_needmoney = "You do not have enough money."
local msg_needcap = "You do not have enough capacity."
local msg_needpremium = "You need a premium account to be promoted."
local msg_alreadypromoted = "You already have a promotion."
local msg_needlevel = "You only can promote when have reached level |LEVEL|."

local callbacks = {
	
	["!aol"] = function(cid)

		local aol_price = 60000
		local aol_id = 2173

		if(getPlayerMoney(cid) < aol_price) then
			doPlayerSendCancel(cid, msg_needmoney)
			return false
		end

		local item = doCreateItemEx(aol_id, 0)

		if(doPlayerAddItemEx(cid, item, false) ~= RETURNVALUE_NOERROR) then
			doPlayerSendCancel(cid, msg_needcap)
		end

		doPlayerRemoveMoney(cid, aol_price)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Bought 1x amulet of loss for " .. aol_price .." gold.")
		return true
	end,

	["!promotion"] = function(cid)
		local promotion_price = 20000
		local need_premium = false
		local max_promotion_level = 1
		local min_level = 20

		if(getPlayerMoney(cid) < promotion_price) then
			doPlayerSendCancel(cid, msg_needmoney)
			return false
		end

		if(need_premium and not isPremium(cid)) then
			doPlayerSendCancel(cid, msg_needpremium)
			return false			
		end

		if(getPlayerPromotionLevel(cid) >= max_promotion_level) then
			doPlayerSendCancel(cid, msg_alreadypromoted)
			return false						
		end

		if(getPlayerLevel(cid) < min_level) then
			doPlayerSendCancel(cid, msg_needlevel:gsub("|LEVEL|", min_level))
			return false
		end

		doPlayerRemoveMoney(cid, promotion_price)
		setPlayerPromotionLevel(cid, max_promotion_level)

		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Congratulations! You are promoted!")
		return true
	end
}

function onSay(cid, words, param)	

	if(callbacks[words] ~= nil) then
		callbacks[words](cid)
		return true
	end

	return false
end