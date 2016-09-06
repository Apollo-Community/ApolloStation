/client/proc/TemplatePanel()
	set name = "Template Panel"
	set category = "Admin"

	// Place
	var/place = check_rights(R_BUILDMODE)
	// Upload, Delete, Reset
	var/other = check_rights(R_BUILDMODE)

	if(!place)
		return 0

	var/dat = "<center><span class='statusDisplay'>"

	if(place)
		dat += "<a href='?_src_=holder;template_panel=1;action=place'>Place</a>"

	if(other)
		dat += " | <a href='?_src_=holder;template_panel=1;action=upload'>Upload and Place</a>"

	dat += "</span><br><br>"

	if(length(template_controller.placed_templates))
		dat += "<table>"
		dat += "<tr><th>Name</th><th>Position</th>[other ? "<th>Actions</th>" : ""]"

		for(var/datum/dmm_object_collection/template in template_controller.placed_templates)
			dat += "<tr><td>[template.name]</td><td>{[template.location.x], [template.location.y], [template.location.z]}</td>"
			if(other)
				dat += "<td>"
				dat += "<a href='?_src_=holder;template_panel=1;action=delete;template=\ref[template]'>Delete</a> | "
				dat += "<a href='?_src_=holder;template_panel=1;action=reset;template=\ref[template]'>Reset</a> | "
				dat += "<a href='?_src_=holder;template_panel=1;action=jump;template=\ref[template]'>Jump</a>"
				dat += "</td>"

			dat += "</tr>"

		dat += "</table>"

	dat += "</center>"

	var/datum/browser/popup = new(mob, "templ_panel", "Template Panel")
	popup.set_content(dat)
	popup.open()

/client/proc/save_construction_station()
	set category = "Debug"
	set name = "Save Construction Station"
	set desc = "Saves the construction station to maps/serialized/construction_station.dmm"

	dmm_serializer.serialize_block(82, 35, 4, 98, 164, "construction_station")
	log_debug("[key_name(usr)] has saved the construction station")

/client/proc/reset_construction_station()
	set category = "Admin"
	set name = "Reset Construction Station"
	set desc = "Resets the construction station to the original state."

	var/path = "maps/templates/persistent/construction_station.dmm"
	if(fexists(path))
		if(alert("This will reset the construction area back to its original state, and the current construction station will be unrecoverable after the round ends. Are you sure you want to do this?",,"Yes","No")=="No")
			return

		fdel(path)

		message_admins("[key_name(usr)] has reset the construction station.")
