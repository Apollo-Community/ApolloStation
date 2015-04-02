/mob/living/carbon/verb/give()
	set category = "IC"
	set name = "Give"
	set src in view(1)
	if(src.stat == 2 || usr.stat == 2 || src.client == null)
		return
	if(src == usr)
		usr << "\red I feel stupider, suddenly."
		return
	var/obj/item/I
	if(!usr.hand && usr.r_hand == null)
		usr << "\red You don't have anything in your right hand to give to [src.name]"
		return
	if(usr.hand && usr.l_hand == null)
		usr << "\red You don't have anything in your left hand to give to [src.name]"
		return
	if(usr.hand)
		I = usr.l_hand
	else if(!usr.hand)
		I = usr.r_hand
	if(!I)
		return
	if(src.r_hand == null || src.l_hand == null)
		switch(alert(src,"[usr] wants to give you \a [I]?",,"Yes","No"))
			if("Yes")
				if(!I)
					return
				if(!Adjacent(usr))
					usr << "\red You need to stay in reaching distance while giving an object."
					src << "\red [usr.name] moved too far away."
					return

				if((usr.hand && usr.l_hand != I) || (!usr.hand && usr.r_hand != I))
					usr << "\red You need to keep the item in your active hand."
					src << "\red [usr.name] seem to have given up on giving \the [I.name] to you."
					return
				if(src.r_hand != null && src.l_hand != null)
					src << "\red Your hands are full."
					usr << "\red Their hands are full."
					return
				else
					var/mob/living/carbon/human/M = src
					if(src.r_hand == null)
						var/datum/organ/external/O = M.organs_by_name["r_hand"]								//Seemed the easiest way to keep the same functionality, still really messy >.>
						if(O.status & ORGAN_DESTROYED)
							src << "You cannot pick that item up with your stump of a hand!"
							usr << "You tried to give [src.name] [I.name] but they couldn't grasp it with their stump."
							return
						usr.drop_item()
						src.r_hand = I
					else
						var/datum/organ/external/O = M.organs_by_name["l_hand"]
						if(O.status & ORGAN_DESTROYED)
							src << "You cannot pick that item up with your stump of a hand!"
							usr << "You tried to give [src.name] [I.name] but they couldn't grasp it with their stump."
							return
						usr.drop_item()
						src.l_hand = I


				I.loc = src
				I.layer = 20
				I.add_fingerprint(src)
				src.update_inv_l_hand()
				src.update_inv_r_hand()
				usr.update_inv_l_hand()
				usr.update_inv_r_hand()
				src.visible_message("\blue [usr.name] handed \the [I.name] to [src.name].")
			if("No")
				src.visible_message("\red [usr.name] tried to hand [I.name] to [src.name] but [src.name] didn't want it.")
	else
		usr << "\red [src.name]'s hands are full."
