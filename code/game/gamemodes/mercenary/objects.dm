/obj/item/weapon/paper/merc
	name = "top secret documents"

/obj/item/weapon/paper/merc/update_icon()
	icon_state = "paper_stack_words"

/obj/item/weapon/paper/merc/examine(mob/user)
	if( in_range(src, user) )
		user << "<span class='notice'>You glance at the cover of the report... and decide not to read it for fear of losing your job.</span>"
	else
		user << "<span class='notice'>You have to go closer if you want to read it.</span>"
	return