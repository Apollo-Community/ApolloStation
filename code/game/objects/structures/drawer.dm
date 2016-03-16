/obj/structure/dresser
    name = "dresser"
    desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
    icon = 'icons/custom/drawer.dmi'
    icon_state = "bluewallscrews"
    density = 0 // Can players walk through it? If you put them in small 4x4 rooms I suggest setting this to 0 from the map editor.
    anchored = 1 // Can players drag it around? Probably not, but maybe you want to be able to do so.
    var/selection
    var/new_shirt
    var/new_undies


/obj/structure/dresser/attack_hand(mob/user as mob)
    if(!Adjacent(user))//no tele-grooming
        return
    if(ishuman(user)) // No lusty Xeno maid for you. Also it would break things I think. Do aliens even have an underwear variable?
        var/mob/living/carbon/human/H = user // That's you! You are now H.

        selection = input("What would you like to change?", "eugh", null, null) in list("Undershirt", "Underwear")
        if(selection == "Undershirt")
            new_shirt = input("Select your undershirt!", "Changing Undershirt", null, null) in list("None", "Black Tanktop", "White Tanktop", "Black T-shirt", "White T-shirt")
            if(new_shirt == "None") H.undershirt = 0
            if(new_shirt == "Black Tanktop" ) H.undershirt = "u1"
            if(new_shirt == "White Tanktop") H.undershirt = "u2"
            if(new_shirt == "Black T-shirt") H.undershirt = "u3"
            if(new_shirt == "White T-shirt") H.undershirt = "u4"
        else
            if (H.gender == FEMALE)
                new_undies = input("Select your underwear!", "Changing Underwear", null, null) in list("None", "Red", "White", "Yellow", "Purple", "Black", "Thong", "Black Sports", "White Sports")
                if(new_undies == "None") H.underwear = 0 // See human.dmi to see what icons these numbers correspond to. 0 or anything else not in those icons will just make you go commando.
                if(new_undies == "Red" ) H.underwear = "f1"
                if(new_undies == "White") H.underwear = "f2"
                if(new_undies == "Yellow") H.underwear = "f3"
                if(new_undies == "Purple") H.underwear = "f4"
                if(new_undies == "Black") H.underwear = "f5"
                if(new_undies == "Kinky") H.underwear = "f6"
                if(new_undies == "Black Sports") H.underwear = "f7"
                if(new_undies == "White Sports") H.underwear = "f8"
            else // Because if you're anything beside female, male underwear is fine for you.
                new_undies = input("Select your underwear!", "Changing Underwear", null, null) in list("None", "White", "Gray", "Green", "Blue", "Black", "Jockstrap")
                if(new_undies == "None") H.underwear = 0
                if(new_undies == "White" ) H.underwear = "m1"
                if(new_undies == "Gray") H.underwear = "m2"
                if(new_undies == "Green") H.underwear = "m3"
                if(new_undies == "Blue") H.underwear = "m4"
                if(new_undies == "Black") H.underwear = "m5"
                if(new_undies == "Jockstrap") H.underwear = "m6"

        if(!Adjacent(user)) //no tele-grooming
            return

        add_fingerprint(H)
        H.regenerate_icons() // I don't know if there's something to update specifically the underwear overlay, so, someone inform me if there is. Otherwise this works for now but I feel like there's probably a better way to do it.