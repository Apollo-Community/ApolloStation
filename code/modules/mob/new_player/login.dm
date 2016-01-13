/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying

	var/alien_of_the_week = "This week's de-whitelisted alien: <b>[unwhitelisted_alien]</b>! Go ahead and give them a try, free of charge!"

	if(join_motd)
		var/motd = "<div class='motd'><center>[join_motd]<br>[alien_of_the_week]<br></center></div><hr>"
		src << motd
	else
		src << alien_of_the_week

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	if(length(newplayer_start))
		loc = pick(newplayer_start)
	else
		loc = locate(1,1,1)
	lastarea = loc

	sight |= SEE_TURFS
	player_list |= src
	player_list = sortList(player_list)

/*
	var/list/watch_locations = list()
	for(var/obj/effect/landmark/landmark in landmarks_list)
		if(landmark.tag == "landmark*new_player")
			watch_locations += landmark.loc

	if(watch_locations.len>0)
		loc = pick(watch_locations)
*/
	new_player_panel()
	spawn(40)
		if(client)
			client.playtitlemusic()
