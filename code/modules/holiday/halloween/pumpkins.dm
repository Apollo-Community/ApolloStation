//Apollo Halloween 2015 stuff

#define MAX_PUMPKINS 7
#define HALLOWEEN_OBJ "/obj/item/weapon/flame/lighter/zippo/pumpkin"

/hook/startup/proc/load_eggs()
	for(var/type in subtypes( /obj/item/weapon/spec_pumpkin ))
		var/loc_found = 0
		for( var/i = 0; i < 10; i++ )
			var/turf/T = pick(pumpkin_starts)
			if( i == 9 || !( locate( /obj/item/weapon/spec_pumpkin ) in T ))
				loc_found = 1
				new type(pick(T))
			if( loc_found )
				break

/obj/item/weapon/spec_pumpkin
	name = "jack-o-lantern"
	icon = 'icons/apollo/halloween.dmi'
	icon_state = ""
	w_class = 2.0
	desc = "A scary jack-o-lantern! Maybe there's something inside..."
	var/mobs_opened = list()
	var/log = null

/obj/item/weapon/spec_pumpkin/attack_self(mob/user as mob)
	open( user )

/obj/item/weapon/spec_pumpkin/verb/open(mob/user as mob)
	set name = "Open Jack-O-Lantern"
	set category = "Object"
	set src in oview(1)

	if( user in mobs_opened )
		var/difference = MAX_PUMPKINS-user.pumpkins_found
		if( difference ) // If they haven't already found all of them
			user << "<span class='notice'><b>You've already found this one, go look for the remaining [difference] jack-o-lanterns!</b></span>"
		else
			user << "<span class='notice'><b>You've already found all of the jack-o-lanterns!</b></span>"
		return

	mobs_opened += user
	user.pumpkins_found++

	if(( user.pumpkins_found >= MAX_PUMPKINS ))
		if( log_acc_item_to_db( user.ckey, HALLOWEEN_OBJ ))
			user << "<span class='notice'><b>Congratulations! You've collected all of the jack-o-lanterns! The Pumpkin Zippo lighter has been added to your account as a reward.</b></span>"
		else
			user << "<span class='notice'><b>You've already recieved the item for this holiday event, come back in a few months for the next one!</b></span>"
			return
	else
		var/difference = MAX_PUMPKINS-user.pumpkins_found
		if( difference ) // If they haven't already found all of them
			user << "<span class='notice'><b>Found a jack-o-lantern! Go find the remaining [difference] jack-o-lanterns!</b></span>"

	respawn( user )

/obj/item/weapon/spec_pumpkin/proc/respawn(mob/user as mob)
	var/paper = new log()

	if( user )
		user.drop_item(src)
		user.put_in_hands(paper)

	var/loc_found = 0
	for( var/i = 0; i < 10; i++ )
		var/turf/T = pick(pumpkin_starts)
		if( i == 9 || !( locate( /obj/item/weapon/spec_pumpkin ) in T ))
			loc_found = 1
			loc = T
		if( loc_found )
			break

/obj/item/weapon/spec_pumpkin/ex_act()
	respawn()

/* Am sad this one is getting cut
/obj/item/weapon/spec_pumpkin/dancer
	icon_state = "dancer"
*/

/obj/item/weapon/spec_pumpkin/jmmj
	icon_state = "JMMJ"
	log = /obj/item/weapon/paper/halloween/log1

/obj/item/weapon/spec_pumpkin/kwask
	icon_state = "Kwask"
	log = /obj/item/weapon/paper/halloween/log2

/obj/item/weapon/spec_pumpkin/stuicey
	icon_state = "stuicey"
	log = /obj/item/weapon/paper/halloween/log3

/obj/item/weapon/spec_pumpkin/king_nexus
	icon_state = "King_Nexus"
	log = /obj/item/weapon/paper/halloween/log4

/obj/item/weapon/spec_pumpkin/kodos
	icon_state = "Kodos"
	log = /obj/item/weapon/paper/halloween/log5

/obj/item/weapon/spec_pumpkin/gutsy
	icon_state = "gutsy"
	log = /obj/item/weapon/paper/halloween/log6

/obj/item/weapon/spec_pumpkin/dreaded_reborn
	icon_state = "dreaded_reborn"
	log = /obj/item/weapon/paper/halloween/log7

/obj/item/weapon/paper/halloween/log1
	name = "Treb Potanile, 09-25-2559"
	info = "<body> \
<h2>Log: Treb Potanile, Quartermaster,&nbsp;09-25-2559</h2> \
<p>The company had me write up another conduct report today. That&#39;s the third time this week. \
Every time they have me write one, it means something dangerous has been moved through my cargobay recently. \
Now, I had noticed a rather large crate move through here two days ago. Nearly as large as one of our own \
cargo shuttles. Took two&nbsp;RIPLEYs to move it, and the pilots complained it was real unbalanced, almost \
like something was moving inside. They even dropped the damn thing, luckily&nbsp;no one was injured. Now I&#39;m \
not a man who normally complains, but I&#39;m not a fan of my boys handling cargo we&rsquo;re not equipped to \
deal with. If they have me write up another one of these damn reports before the end of the week, I&#39;m going \
to have to have a talk with the boss.</p> \
</body>"

/obj/item/weapon/paper/halloween/log2
	name = "Ken Pratchet, 10-02-2559"
	info = "<body> <h2>Log: Ken Pratchet, Research Director, 10-02-2559</h2> \
<p>The subject, codenamed &quot;Pumpkin&quot;, was unloaded into its secure containment today, allowing for research to truly begin. I&#39;ve never seen such a thing&nbsp;before in my life. How NanoTrasen managed to get their hands on something like this&nbsp;is beyond me. Today we&#39;re attempting to determine its intelligence level. Initial tests show it is probably no smarter than the average individual. Its truly remarkable talent, though, is its ability to seemingly regenerate any injury. During transfer the container was dropped, and upon inspection it appeared the subject&nbsp;had sustained a serious bone fracture to the femoral shaft. Today, however, the subject appears to have completely healed. The subject has not been injected with a nanomachine booster, so whatever method it possesses to regenerate is entirely biological.</p> </body>"

/obj/item/weapon/paper/halloween/log3
	name = "Matthew Ricard, 10-10-2559"
	info = "<body> \
<h2>Log: Matthew Ricard, Research Assistant, 10-10-2559</h2> \
<p>They&#39;ve got me injecting chimpanzees with the blood plasma of&nbsp;&quot;Pumpkin&quot;. We&#39;re not sure yet what causes the incredible regeneration, but we&#39;re fairly certain its transmissable. The trials with the chimps will begin tomorrow, and continue through the end of the week. I&#39;m terribly excited that I managed to get assigned to this as my first lab position! This is true science, not the wishy-washy labs they had us doing back in academy. Truly groundbreaking stuff we&#39;re doing here, with the potential to change trillions of lives forever. I&#39;ll write again tomorrow about the results, here&#39;s hoping for the best!</p> \
</body>"

/obj/item/weapon/paper/halloween/log4
	name = "Ken Pratchet, 10-11-2559"
	info = "<body> \
<h2>Log: Ken Pratchet, Research Director, 10-11-2559</h2> \
<p>One of our research assistants, Matthew Ricard, was involved in an accident today during the experiments. He was adjusting one of our pieces of lab equipment during the chimpanzee trials when his arm was caught in one of the machines. Only had a compound fracture, but we believe he was exposed to some of the chimpanzee&#39;s blood. He&#39;s currently in quarantine until we discover if he&#39;s been affected as well. Perhaps we&#39;ll get to those human trials sooner than expected.</p> \
</body>"

/obj/item/weapon/paper/halloween/log5
	name = "Pyrel Teartum, 10-11-2559"
	info = "<body> \
<h2>Log: Pyrel Teartum, Cybersun Communications Officer, 10-11-2559</h2> \
<p>We got a comm relay from the outpost today about some damn idiot research assistant getting hurt in some lab accident. Aparently they got the poor sod in quarantine for some reason. This is the fourth&nbsp;accident we&#39;ve had since this whole damn&nbsp;project began. Whether its sabotage or not, I don&#39;t feel like the odds are on our side with this one. I just hope the superintendant will listen to me before its too late.</p> \
</body>"

/obj/item/weapon/paper/halloween/log6
	name = "Ken Pratchet, 10-18-2559"
	info = "<body> \
<h2>Log: Ken Pratchet, Research Director, 10-18-2559</h2> \
<p>Matthew Ricard is back on service again. Despite aparently coming in contact with infected material, he&#39;s well past the incubation period, and his arm still hasn&#39;t healed. We tested amputations today, which Matthew is bringing the reports of in a few minutes. We also sent out tissue samples to multiple other Cybersun laboratories. I&#39;ve heard talk about them wanting to militarize this thing, but there&#39;s been no official word on that yet. I think I hear Matthew coming now, so I&#39;ll report back with those reports soon.</p> \
</body>"

/obj/item/weapon/paper/halloween/log7
	name = "Pyrel Teartum, 10-20-2559"
	info = "<body> \
<h2>Log: Pyrel Teartum, Cybersun Communications Officer, 10-20-2559</h2> \
<p>Shit shit shit! We&#39;ve lost all communications with the outpost! We just got an emergency report 30 minutes about all of the airlocks on the outpost blowing open at the same time, and nothing since. Anyone there is surely dead now, no one survives this vacuum for long. Or so you would think. Satcom reported&nbsp;a large infrared signature moving across the moon&#39;s surface towards us. Worst part is, whatever it is, it&#39;s going to be here in less than 10 fucking minutes!&nbsp;I think I even&nbsp;heard the superintendant say&nbsp;something about arming our fucking&nbsp;nuke! What the fucking&nbsp;hell were they doing over there?</p> \
</body>"
