//Not really sure where to put this - so it can just live here?

/obj/playerlist
  var/recent = null
  var/player

/obj/playerlist/Click()
  if(usr.client.holder)
    if(player:mob && recent != usr)
      get_mob_info(player:mob, usr)
      recent = usr
      spawn(20)
        if(recent)
          recent = null

/obj/playerlist/DblClick()
  if(usr.client.holder)
    if(player:mob)
      if(istype(usr,/mob/new_player))
        usr << "<font color='red'>Error: Can't admin-ghost whilst in the lobby. Join or Observe first.</font>"
        return
      else if(istype(usr,/mob/living))
        var/mob/body = usr
        var/mob/dead/observer/ghost = body.ghostize(1)
        ghost.admin_ghosted = 1

        if(body && !body.key)
          body.key = "@[usr.key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus

        var/turf/T = get_turf(player:mob)
        if(T && isturf(T))
          ghost.loc = T
      else  // yolo teleport
        if(player:mob == usr:client:mob)  //They probably want back into their body
          var/mob/dead/observer/ghost = usr
          ghost.reenter_corpse()
          return
        var/turf/T = get_turf(player:mob)
        if(T && isturf(T))
          usr.loc = T
