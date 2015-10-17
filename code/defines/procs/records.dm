/proc/CreateGeneralRecord()
	var/mob/living/carbon/human/dummy = new()
	dummy.mind = new()
	var/icon/front = new(get_id_photo(dummy), dir = SOUTH)
	var/icon/side = new(get_id_photo(dummy), dir = WEST)
	var/datum/data/record/G = new /datum/data/record()
	G.fields["name"] = "New Record"
	G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
	G.fields["rank"] = "Unassigned"
	G.fields["real_rank"] = "Unassigned"
	G.fields["sex"] = "Male"
	G.fields["age"] = "Unknown"
	G.fields["fingerprint"] = "Unknown"
	G.fields["p_stat"] = "Active"
	G.fields["m_stat"] = "Stable"
	G.fields["species"] = "Human"
	G.fields["home_system"]	= "Unknown"
	G.fields["citizenship"]	= "Unknown"
	G.fields["faction"]		= "Unknown"
	G.fields["religion"]	= "Unknown"
	G.fields["photo_front"]	= front
	G.fields["photo_side"]	= side
	data_core.general += G

	qdel(dummy)
	data_core.manifest_sort()
	return G

/proc/CreateSecurityRecord(var/name as text, var/id as text)
	var/datum/data/record/R = new /datum/data/record()
	R.fields["name"] = name
	R.fields["id"] = id
	R.name = text("Security Record #[id]")
	R.fields["criminal"] = "None"
	R.fields["mi_crim"] = "None"
	R.fields["mi_crim_d"] = "No minor crime convictions."
	R.fields["ma_crim"] = "None"
	R.fields["ma_crim_d"] = "No major crime convictions."
	R.fields["notes"] = "No notes."
	data_core.security += R
	data_core.manifest_sort()
	return R

/proc/CreateMedicalRecord(var/name as text, var/id as text)
	var/datum/data/record/R = new /datum/data/record()
	R.fields["name"] = name
	R.fields["id"] = id
	R.name = text("Medical Record #[]", R.fields["id"])
	R.fields["b_type"] = "Unknown"
	R.fields["b_dna"] = "Unknown"
	R.fields["mi_dis"] = "None"
	R.fields["mi_dis_d"] = "No minor disabilities have been declared."
	R.fields["ma_dis"] = "None"
	R.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
	R.fields["alg"] = "None"
	R.fields["alg_d"] = "No allergies have been detected in this patient."
	R.fields["cdi"] = "None"
	R.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
	R.fields["notes"] = "No notes."
	data_core.medical += R
	data_core.manifest_sort()
	return R

/proc/find_security_record(field, value)
	return find_record(field, value, data_core.security)

/proc/find_record(field, value, list/L)
	for(var/datum/data/record/R in L)
		if(R.fields[field] == value)
			return R
