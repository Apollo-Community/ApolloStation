/obj/machinery/computer/form_printer
	name = "\improper form printing console"
	desc = "Terminal for handling NanoTrasen official forms and certificates."
	icon_state = "id"
	circuit = "/obj/item/weapon/circuitboard/card"	//Need to find a better circuit for this.. maybe make on.
	light_color = COMPUTER_BLUE
	var/index = 0
	var/list/forms = list(\
	"HURT FEELINGS REPORT" = "/obj/item/weapon/paper/form/hurtFeels",\
	"Atmospherics Qualification Cerificate" = "/obj/item/weapon/paper/form/atmosCert",\
	"Dungeons and Dragons" = "/obj/item/weapon/paper/form/dndSheet"
	)

/obj/machinery/computer/form_printer/proc/requestForm(mob/user as mob)
	var/formType = forms["Dungeons and Dragons"]
	var/obj/item/weapon/paper/form/new_form = new formType ( print_date( universe.date ), user, index)
	new_form.loc = src.loc
	index += 1

/obj/machinery/computer/form_printer/attack_hand(mob/user as mob)
	if(..()) return
	if(stat & (NOPOWER|BROKEN)) return
	alert("Test print form ?",,"GO FOR IT!")
	requestForm(user)

/*
/obj/machinery/computer/form_printer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
       // this is the data which will be sent to the ui, it must be a list
       var/data[0]

       // we'll add some simple data here as an example
       data["myName"] = name
       data["myDesc"] = desc
       data["someString"] = "I am a string."
       data["aNumber"] = 123

       data["assocList"] = list("key1" = "Value1", "key2" = "Value2")

       // the backslash tells the compiler to ignore the carriage return, treating the easy-to-read format as a single line.
       data["arrayOfAssocLists"] = list(\
           list("key1" = "ValueA1", "key2" = "ValueA2"),\
           list("key1" = "ValueB1", "key2" = "ValueB2"),\
           list("key1" = "ValueC1", "key2" = "ValueC2")
       )

       data["emptyArray"] = list()

       // update the ui with data if it exists, returns null if no ui is passed/found or if force_open is 1/true
       ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
       if (!ui)
           // the ui does not exist, so we'll create a new() one
           // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
           ui = new(user, src, ui_key, "womdinger.tmpl", "Womdinger UI", 520, 410)
           // when the ui is first opened this is the data it will use
           ui.set_initial_data(data)
           // open the new ui window
           ui.open()
*/