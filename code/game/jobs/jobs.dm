var/const/CIVILIAN			= 0

var/const/CAPTAIN			=(1<<0)
var/const/HOP				=(1<<1)
var/const/ASSISTANT			=(1<<2)
var/const/BARTENDER			=(1<<3)
var/const/CHEF				=(1<<4)
var/const/JANITOR			=(1<<5)
var/const/LIBRARIAN			=(1<<6)
var/const/LAWYER			=(1<<7)
var/const/CHAPLAIN			=(1<<8)
var/const/ENTERTAINER		=(1<<9)


var/const/ENGINEERING		= 1

var/const/CHIEF_ENGINEER	=(1<<0)
var/const/ENGINEER			=(1<<1)
var/const/ATMOSTECH			=(1<<2)
var/const/ENGINEER_ASSISTANT=(1<<3)


var/const/SUPPLY			= 2

var/const/QUARTERMASTER		=(1<<0)
var/const/MINER				=(1<<1)
var/const/SUPPLYTECH		=(1<<2)


var/const/MEDICAL			= 3

var/const/CMO				=(1<<1)
var/const/CHEMIST			=(1<<2)
var/const/PSYCHIATRIST		=(1<<3)
var/const/DOCTOR			=(1<<4)
var/const/VIROLOGIST		=(1<<5)
var/const/NURSE				=(1<<6)

var/const/SCIENCE			= 4

var/const/RD				=(1<<0)
var/const/SCIENTIST			=(1<<1)
var/const/ROBOTICIST		=(1<<2)
var/const/XENOBIOLOGIST		=(1<<3)
var/const/RESEARCH_ASSISTANT=(1<<4)

var/const/SECURITY			= 5

var/const/HOS				=(1<<0)
var/const/WARDEN			=(1<<1)
var/const/DETECTIVE			=(1<<2)
var/const/OFFICER			=(1<<3)
var/const/CADET				=(1<<4)

var/const/SYNTHETIC			= 6

var/const/AI				=(1<<0)
var/const/CYBORG			=(1<<1)

var/const/ALL_ROLES			=BITFLAGS_MAX

var/list/assistant_occupations = list()

var/list/command_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer"
)


var/list/engineering_positions = list(
	"Chief Engineer",
	"Engineer",
	"Atmospheric Technician",
	"Engineer Assistant"
)


var/list/medical_positions = list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Psychiatrist",
	"Virologist",
	"Nurse"
)


var/list/science_positions = list(
	"Research Director",
	"Scientist",
	"Roboticist",
	"Xenobiologist",
	"Chemist",
	"Research Assistant"
)

//BS12 EDIT
var/list/civilian_positions = list(
	"Head of Personnel",
	"Bartender",
	"Chef",
	"Janitor",
	"Librarian",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner",
	"Lawyer",
	"Chaplain",
	"Entertainer",
	"Assistant"
)


var/list/security_positions = list(
	"Head of Security",
	"Warden",
	"Detective",
	"Security Officer",
	"Security Cadet"
)


var/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	"pAI"
)


/proc/guest_jobbans(var/job)
	return ((job in command_positions))

/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)	continue
		occupations += job

	return occupations

/proc/get_alternate_titles(var/job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(J.title == job)
			titles = J.alt_titles

	return titles
