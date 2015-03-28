/obj/item/weapon/reagent_containers/tube
	name = "tube"
	desc = "A squeezable tube used for holding fluids and pastes."
	icon = 'icons/obj/tube.dmi'
	icon_state = "tube_full"
	matter = list("plastic" = 150)
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5,10,15)
	volume = 15
	w_class = 1
	sharp = 1

/obj/item/weapon/reagent_containers/tube/afterattack(obj/target, mob/user , flag)
	if(!do_mob(user, target, 0))
		return

	src.reagents.reaction(target, INGEST)
	src.reagents.trans_to(target, amount_per_transfer_from_this)

	for(var/mob/O in viewers(world.view, user))
		if( ismob( target ))
			O.show_message(text("[user] squirts the [src] into [target] mouth!"), 1)
		else
			O.show_message(text("[user] squirts the [src] onto [target]."), 1)

	update_icon()

/obj/item/weapon/reagent_containers/tube/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		icon_state = "tube_full"
	else
		icon_state = "tube_empty"

/obj/item/weapon/reagent_containers/tube/syndicream
	desc = "A squeezable tube used for holding fluids and pastes. This one says it contains \"Syndicream\", a delicious cream used to encourage organ regeneration."

	New()
		..()
		reagents.add_reagent("syndicream", 15)
		update_icon()