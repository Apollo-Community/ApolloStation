// Forms are a type of paper that can be checked for the required signatures, usually used in conjuction with computers
/obj/item/weapon/paper/form
	var/list/required_signatures = list()
	deffont = "Courier"

/obj/item/weapon/paper/form/proc/numberOfRequiredSignatures()
	var/list/check = required_signatures & signatures
	return check.len

/obj/item/weapon/paper/form/proc/isFilledOut()
	if( numberOfRequiredSignatures() == required_signatures.len )
		return 1
	return 0

/obj/item/weapon/paper/form/job
	var/job // What job is being granted?
	var/job_verb

/obj/item/weapon/paper/form/job/New( var/set_job )
	job = set_job

	..()

/obj/item/weapon/paper/form/job/termination
	name = "NanoTrasen Departmental Termination Form"
	job_verb = "terminated from"

/obj/item/weapon/paper/form/job/termination/New( var/date, var/set_department, var/employee )
	job = set_department

	info = {"\[center\]\[logo\]\[/center\]
\[center\]\[b\]\[i\]NanoTrasen Departmental Termination Form\[/b\]\[/i\]\[/center\]\[hr\]
Upon signature of this document by the Department authority on [date], the contract of appointment within the [job] for [employee] is hereby null and void. Abuse of this form may result in the termination of the Department authority.\[br\]

\[b\]Cause for Termination:\[/b\] \[field\]
\[b\]Department Authority:\[/b\] \[field\]
\[hr\]"}

	..( set_department )

/obj/item/weapon/paper/form/job/induct
	name = "NanoTrasen Departmental Induction Form"
	job_verb = "inducted into"

/obj/item/weapon/paper/form/job/induct/New( var/date, var/set_department )
	job = set_department

	info = {"\[center\]\[logo\]\[/center\]
\[center\]\[b\]\[i\]NanoTrasen Departmental Induction Form\[/b\]\[/i\]\[/center\]\[hr\]
Upon signature of this document by the employee, and witnessed by the Department authority of \the [job] on [date], the employee will legally be inducted into \the [job]. The Department authority is to provide them with instruction as to their role and function, or lack thereof, within the department.\[br\]

\[b\]Employee:\[/b\] \[field\]
\[b\]Department Authority:\[/b\] \[field\]
\[hr\]"}

	..( set_department )

/obj/item/weapon/paper/form/job/promotion
	name = "NanoTrasen Employee Promotion Form"
	job_verb = "promoted to"

/obj/item/weapon/paper/form/job/promotion/New( var/date, var/set_job, var/department )
	job = set_job

	info = {"\[center\]\[logo\]\[/center\]
\[center\]\[b\]\[i\]NanoTrasen Employee Promotion Form\[/b\]\[/i\]\[/center\]\[hr\]
Upon signature of this document by the employee, and witnessed by the Department authority of the [department] on [date], the employee may legally fulfill all duties in authority as [job] as required of them. Failure to perform this responsibility hereto is subject to appointment termination without consent.\[br\]

\[b\]Employee:\[/b\] \[field\]
\[b\]Department Authority:\[/b\] \[field\]
\[hr\]"}

	..(set_job)

/obj/item/weapon/paper/form/command_recommendation
	name = "NanoTrasen Command Recommendation Form"

/obj/item/weapon/paper/form/command_recommendation/New( var/date, var/name )
	info = {"\[center\]\[logo\]\[/center\]
\[center\]\[b\]\[i\]NanoTrasen Command Recommendation Form\[/b\]\[/i\]\[/center\]\[hr\]
Upon signature of this document by one or several Command Officers on [date], [name] is hereby recommended for expanded responsibilities as a member of command staff. The signer of this form recognizes the potential in [name], and understands their skills to be a valuable addition to command. Misuse of this form may result in the Command Officer being pressed with criminal charges.\[br\]

\[b\]Cause for Recommendation:\[/b\] \[field\]
\[b\]Recommended Position:\[/b\] \[field\]
\[b\]Command Officer(s) Signature(s):\[/b\] \[field\]
\[hr\]"}

	..()

/obj/item/weapon/paper/form/job/demotion
	name = "NanoTrasen Employee Demotion Form"
	job_verb = "demoted from"

/obj/item/weapon/paper/form/job/demotion/New( var/date, var/set_job, var/employee, var/department )
	job = set_job

	info = {"\[center\]\[logo\]\[/center\]
\[center\]\[b\]\[i\]NanoTrasen Employee Demotion Form\[/b\]\[/i\]\[/center\]\[hr\]
Upon signature of this document by the Department authority on [date], the contract of appointment with the [department] for [employee] as [job] is hereby null and void. Abuse of this form may result in the termination of the Department authority.\[br\]

\[b\]Cause for Demotion:\[/b\] \[field\]
\[b\]Department Authority:\[/b\] \[field\]
\[hr\]"}

	..(set_job)

/obj/item/weapon/paper/form/incident
	var/datum/crime_incident/incident

/obj/item/weapon/paper/form/incident/New()
	info = {"\[center\]\[logo\]\[/center\]
\[center\]\[b\]\[i\]Encoded NanoTrasen Criminal Incident Form\[/b\]\[/i\]\[hr\]
\[small\]FOR USE BY SECURITY ONLY\[/small\]\[br\]
\[barcode\]\[/center\]"}

	..()