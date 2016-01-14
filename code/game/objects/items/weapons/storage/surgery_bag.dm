/*
** Surgery bag - Holds surgery tools.
**
** Comes rolled up, when un-rolled it anchors itself in place. Then can be accessed like a backpack.
** Alternatively, can be worn like a backpack
*/

/obj/item/weapon/storage/surgery_bag
    name = "Surgery Bag"
    desc = "Contains all the surgical tools you'll need."
    icon = 'icons/apollo/objects.dmi'
    icon_state = "sbag_rolled"
    can_hold = list("/obj/item/weapon/scalpel",
                    "/obj/item/weapon/hemostat",
                    "/obj/item/weapon/retractor",
                    "/obj/item/weapon/bonegel",
                    "/obj/item/weapon/bonesetter",
                    "/obj/item/weapon/cautery")
    var/empty = 0
    //Ancored being used to determine if it is rolled or not.

/obj/item/weapon/storage/surgery_bag/New()
    ..()
    if (empty) return
    new /obj/item/weapon/scalpel( src )
    new /obj/item/weapon/hemostat(src)
    new /obj/item/weapon/retractor(src)
    new /obj/item/weapon/bonegel(src)
    new /obj/item/weapon/bonesetter(src)
    new /obj/item/weapon/cautery(src)
    return

/obj/item/weapon/storage/surgery_bag/examine(mob/user)
    if(anchored)
        var/tools = ""
        for(var/obj/O in contents)
            tools += "[O.name],"
        if(tools)
            tools = copytext(tools, 1, -1)  //Strips the ","
        user << "<span class='info'>A surgical bag containing the following: [tools]</span>"
    else
        user << "<span class='info'>A rolled up surgical bag. Could come in handing in a pinch.</span>"

/obj/item/weapon/storage/surgery_bag/attackby(obj/item/weapon/W as obj, mob/user as mob)
    if(!anchored)
        usr << "<span class='warning'>You can't find a way to put [W.name] into the [src] while it is rolled up</span>"
        return
    ..()

/obj/item/weapon/storage/surgery_bag/MouseDrop(over_object, src_location, over_location)
    if(!anchored)
        src.add_fingerprint(usr)
        usr << "<span class='warning'>You have to unroll the [src.name] first!"
        return
    ..()

/obj/item/weapon/storage/surgery_bag/attack_self(mob/user)
    if(!anchored)
        src.add_fingerprint(usr)
        usr << "<span class='warning'>You have to unroll the [src.name] first!"
        return
    ..()

/obj/item/weapon/storage/surgery_bag/attack_hand(mob/user)
    if(src.loc == user && !anchored)
        src.add_fingerprint(usr)
        usr << "<span class='warning'>You have to unroll the [src.name] first!"
        return
    if(anchored)
        src.open(user)
        return
    ..()

/obj/item/weapon/storage/surgery_bag/pickup(mob/user)
    if(anchored)    //Opens the bag if it is rolled out
        return

/obj/item/weapon/storage/surgery_bag/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
    if(W in contents)
        usr << "<span class='warning'>There are only slots for one of each item! Damn budget cuts</span>"
    else
        if(..())
            src.overlays += image('icons/apollo/objects.dmi', "sb_[W.name]")

/obj/item/weapon/storage/surgery_bag/remove_from_storage(obj/item/W as obj, atom/new_location)
    if(..())
        src.overlays -= image('icons/apollo/objects.dmi', "sb_[W.name]")

/obj/item/weapon/storage/surgery_bag/verb/toggle_roll(mob/user)
    set name = "Roll/Unroll surgery bag "
    set category = "Object"
    set src in view(1)
    set desc = "Roll/Unroll surgical bag."

    if(anchored)    //Roll it up
        user << "<span class='info'>You roll the [src.name] up into a tidy little bag.</span>"
        anchored = 0
        overlays.Cut()          //Removes overlays
        src.close(user)         //Closes the bag UI
        icon_state = "sbag_rolled"
    else            //Unroll it
        if(!isturf(src.loc))      // You're only allowed to unroll on turfs
            user << "<span class='warning'>You fumble around but don't have enough space to unroll the [src.name]</span>"
        else
            anchored = 1          // So people can't move it
            user << "<span class='info'>You unroll the [src.name]. Time to get to work!"
            icon_state = "sbag_unrolled"
            for(var/obj/O in contents)
                src.overlays += image('icons/apollo/objects.dmi', "sb_[O.name]")
