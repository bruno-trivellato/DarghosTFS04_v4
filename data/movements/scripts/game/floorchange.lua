function onStepIn(cid, item, position, fromPosition, toPosition)
	if getPlayerStorageValue(cid, sid.SCRIPTBOT_RECORDING) == 1 then
		local pos = getPlayerStorageValue(cid, sid.SCRIPTBOT_LAST_POS) ~= -1 and unpackPosition(getPlayerStorageValue(cid, sid.SCRIPTBOT_LAST_POS)) or false

		if not pos or getDistanceBetween(fromPosition, pos) > 0 then
			setPlayerStorageValue(cid, sid.SCRIPTBOT_LAST_POS, packPosition(fromPosition))
			botScriptMove(fromPosition)	
		end

		local dir = getDirectionTo(fromPosition, position)
		botScriptMoveDir(dir)
	end
end