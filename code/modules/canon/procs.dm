/proc/canonHandleRoundEnd()
	saveAllActiveCharacters()
	universe.saveToDB()

/proc/saveAllActiveCharacters()
	for( var/datum/character/C in all_characters )
		if( C.new_character )
			testing( "Didn't save [C.name] because they were a new character" )
			continue

		if( C.temporary ) // If they've been saved to the database previously
			testing( "Didn't save [C.name] because they were temporary" )
			continue

		C.saveCharacter()

