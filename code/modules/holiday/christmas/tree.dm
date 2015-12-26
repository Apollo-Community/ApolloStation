/obj/structure/flora/tree/pine/c2015
	var/decoration_count = 0
	var/max_decorations = 0
	var/list/contributers
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"
	name = "Christmas Tree"
	desc = "A Christmas Tree delivered by CentCom, lacking any decorations. It looks like it is going to die."

/obj.structure/flora/tree/pine/c2015/new()
	..()
	//Don't know how many we'll have so :>
	for(var/type in subtypes( /obj/item/weapon/spec_decoration ))
		max_decorations++

/obj/structure/flora/tree/pine/c2015/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/spec_decoration))
	    decoration_count++
	    user << "You add the decoration to the Christmas Tree"

	if(icon_tate == "pine_c")
		desc = "A Christmas Tree delivered by CentComm. It looks like it is going to die."

	if(!contributers.Find(user))
    	contributers.Add(user)
    for(var/mob/living/M in orange(src,7))
		if(M != user)
			M << "You feel the Christmas spirit build up as [user.name] adds the decoration to the Christmas Tree."
	if(ispath(W, /obj/item/weapon/reagent_containers/glass/fertilizer)
		user << "You pour the [W.name] onto the tree!"

	    if(icon_state == "pine_c")
			desc = "A Joyous Christmas Tree delivered by CentComm!"

	    if( log_acc_item_to_db( user.ckey, "Christmas Sweater" ))
			M << "<span class='notice'><b>Christmas Uber Secret - Congratulations! You grew the tree to be big and strong!. A Christmas Sweater has been added to your account as a reward.</b></span>"
	    else
			M << "<span class='notice'><b>Christmas Uber Secret - You've already collected this item. Sorry!</b></span>"
	else
		user << "You don't really think [W.name] is really approprate for decoration"
		user << "Screw it, you throw it into the tree anyway"

		spawn(rand(50,200))
	    	W.loc = src.loc
	    	user << "The [W.name] slowly gets sucked into the Christmas Tree. Spooky stuff."

		qdel(W)

	if(decoration_count == max_decorations)
		for(var/mob/M in contributers)
			if( log_acc_item_to_db( M.ckey, "Holiday Wreath" ))
		    	M << "<span class='notice'><b>Christmas Secret - Congratulations! You helped decorate the Christmas Tree and raise the holiday spirit! A Holiday Wreath has been added to your account as a reward.</b></span>"
		    else
		    	M << "<span class='notice'><b>Christmas Secret - You've already collected this item. Sorry!</b></span>"

    	//Spawn the ghost here
		new /mob/living/simple_animal/holiday_spirit( get_turf( src ))