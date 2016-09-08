/proc/canonHandleRoundEnd()
	if( ticker.current_state == GAME_STATE_PREGAME )
		testing( "Didn't save the world because we were in the lobby" )
		return

	saveAllActiveCharacters()
	universe.saveConstructionStation()
	universe.saveToDB()

/proc/saveAllActiveCharacters()
	for( var/datum/character/C in all_characters )
		if( !C.ckey )
			testing( "Didn't save [C.name] because they had no ckey" )
			continue

		if( C.new_character )
			testing( "Didn't save [C.name] / ([C.ckey]) because they were a new character" )
			continue

		if( C.temporary ) // If they've been saved to the database previously
			testing( "Didn't save [C.name] / ([C.ckey]) because they were temporary" )
			continue

		if( !C.saveCharacter() )
			testing( "Couldn't save [C.name] / ([C.ckey]) for some other reason" )
		else
			testing( "Saved [C.name] / ([C.ckey])" )
