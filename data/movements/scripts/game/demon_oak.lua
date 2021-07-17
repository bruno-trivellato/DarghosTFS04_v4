function onStepIn(cid, item, position, fromPosition)

	setGlobalStorageValue(gid.DEMON_OAK_PLAYER_INSIDE, -1)
	unlockTeleportScroll(cid)	
	return TRUE
end