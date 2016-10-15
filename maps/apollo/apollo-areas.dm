//Apollo Station
var/list/the_station_areas = list (
	/area/shuttle/arrival,
	/area/shuttle/escape/station,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/atmos,
	/area/maintenance,
	/area/hallway,
	/area/bridge,
	/area/crew_quarters,
	/area/holodeck,
	/area/library,
	/area/chapel,
	/area/lawoffice,
	/area/engine,
	/area/solar,
	/area/assembly,
	/area/teleporter,
	/area/medical,
	/area/security,
	/area/quartermaster,
	/area/janitor,
	/area/hydroponics,
	/area/rnd,
	/area/storage,
	/area/ai_monitored/storage/eva, //do not try to simplify to "/area/ai_monitored" --rastaf0
	/area/ai_monitored/storage/secure,
	/area/ai_monitored/storage/emergency,
	/area/turret_protected/ai_upload, //do not try to simplify to "/area/turret_protected" --rastaf0
	/area/turret_protected/ai_upload_foyer,
	/area/turret_protected/ai,
)

/*=========================================
================01 - Apollo================
===========================================*/

/area/shuttle/transport1/station
	icon_state = "shuttle"
	name = "\improper Transport Shuttle"

/area/shuttle/arrival/apollo
	icon_state = "shuttle"
	name = "\improper NOS Apollo Arrival Shuttle"

//Escape Pods
/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/station //Pod 4 was lost to meteors
	icon_state = "shuttle2"

//Hallways
/area/hallway/
	environment = HALLWAY

/area/hallway/primary/fore_port
	name = "\improper Fore Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/central_fore
	name = "\improper Central Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/fore_starboard
	name = "\improper Fore Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/aft_starboard
	name = "\improper Aft Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/aft_port
	name = "\improper Aft Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/secondary/entry/port
	name = "\improper Arrival Shuttle Hallway - Port"
	icon_state = "entry_2"


//Security
/area/crew_quarters/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"

/area/security
	environment = HALLWAY

/area/security/main
	name = "\improper Security Office"
	icon_state = "security"

/area/security/interrogate
	name = "\improper Security Interrogation"
	icon_state = "security"

/area/security/meeting
	name = "\improper Security Meeting Room"
	icon_state = "security"

/area/security/tribunal
	name = "\improper Courtroom"
	icon_state = "security"

/area/security/evidence
	name = "\improper Security Evidence"
	icon_state = "security"

/area/security/brig
	name = "\improper Brig"
	icon_state = "brig"
	environment = SEWER_PIPE

/area/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"

/area/security/warden
	name = "\improper Warden"
	icon_state = "Warden"
	environment = QUARRY

/area/security/armoury
	name = "\improper Armory"
	icon_state = "Warden"
	environment = QUARRY

/area/security/detectives_office
	name = "\improper Detective's Office"
	icon_state = "detective"
	environment = QUARRY

/area/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"
	environment = HALLWAY

/area/security/tactical
	name = "\improper Tactical Equipment"
	icon_state = "Tactical"
	environment = QUARRY

/area/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	environment = ALLEY

/area/ai_monitored/storage/secure
	name = "Secure Storage"
	icon_state = "storage"
	environment = ALLEY

/area/ai_monitored/storage/emergency
	name = "Emergency Storage"
	icon_state = "storage"

//Command
/area/bridge
	name = "\improper Bridge"
	icon_state = "bridge"
	environment = STONEROOM

/area/bridge/bridgedorm
	name = "\improper Bridge Dormitory"
	icon_state = "bridge"
	environment = STONEROOM

/area/bridge/bridgelocker
	name = "\improper Bridge Locker Room"
	icon_state = "bridge"
	environment = STONEROOM

/area/bridge/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "bridge"
	music = list()
	environment = ROOM

/area/crew_quarters/captain
	name = "\improper Captain's Office"
	icon_state = "captain"

/area/crew_quarters/heads/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hor
	name = "\improper Research Director's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/chief
	name = "\improper Chief Engineer's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hos
	name = "\improper Head of Security's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/cmo
	name = "\improper Chief Medical Officer's Office"
	icon_state = "head_quarters"

/area/teleporter
	name = "\improper Teleporter"
	icon_state = "teleporter"
	music = list( 'sound/ambience/signal.ogg' )
	environment = QUARRY

/area/lawoffice
	name = "\improper Internal Affairs"
	icon_state = "law"
	environment = QUARRY

/area/security/vacantoffice
	name = "\improper Bridge Vacant Office"
	icon_state = "security"
	environment = QUARRY

/area/security/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"
	environment = QUARRY

/area/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint1"

//Medical
/area/medical
	environment = HALLWAY

/area/medical/hallway_fore
	name = "\improper Medbay Hallway - Fore"
	icon_state = "medbay3"

/area/medical/hallway_aft
	name = "\improper Medbay Hallway - Aft"
	icon_state = "medbay4"

/area/medical/biostorage
	name = "\improper Secondary Storage"
	icon_state = "medbay2"

/area/medical/reception
	name = "\improper Medbay Reception"
	icon_state = "medbay"

/area/medical/psych
	name = "\improper Psych Room"
	icon_state = "medbay3"

/area/crew_quarters/medbreak
	name = "\improper Break Room"
	icon_state = "medbay3"

/area/medical/patients_rooms
	name = "\improper Patient's Rooms"
	icon_state = "patients"

/area/medical/ward
	name = "\improper Recovery Ward"
	icon_state = "patients"

/area/medical/patient_wing
	name = "\improper Patient Wing"
	icon_state = "patients"

/area/medical/cmostore
	name = "\improper Secure Storage"
	icon_state = "CMO"

/area/medical/virology
	name = "\improper Virology"
	icon_state = "virology"

/area/medical/virologyaccess
	name = "\improper Virology Access"
	icon_state = "virology"

/area/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	music = list('sound/ambience/ambimo1.ogg','sound/ambience/ambimo2.ogg','sound/music/main.ogg')

/area/medical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/medical/surgery
	name = "\improper Operating Theatre 1"
	icon_state = "surgery"

/area/medical/surgery2
	name = "\improper Operating Theatre 2"
	icon_state = "surgery"

/area/medical/surgeryobs
	name = "\improper Operation Observation Room"
	icon_state = "surgery"

/area/medical/surgeryprep
	name = "\improper Pre-Op Prep Room"
	icon_state = "surgery"

/area/medical/cryo
	name = "\improper Cryogenics"
	icon_state = "cryo"

/area/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/medical/storage
	name = "\improper Storage Room"
	icon_state = "medbay3"

/area/medical/medicinestorage
	name = "\improper Medical Supplies"
	icon_state = "medbay3"

/area/medical/biostorage
	name = "\improper Biogear Storage Room"
	icon_state = "medbay3"

/*
//ONE DAY
/area/medical/genetics
	name = "\improper Genetics Lab"
	icon_state = "genetics"
*/

/area/medical/genetics_cloning
	name = "\improper Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "\improper Emergency Treatment Centre"
	icon_state = "exam_room"

//Science
/area/assembly/robotics
	name = "\improper Robotics Lab"
	icon_state = "robotics"
	environment = QUARRY

/area/assembly/chargebay
	name = "\improper Mech Bay"
	icon_state = "mechbay"
	environment = QUARRY

/area/rnd
	environment = HALLWAY

/area/rnd/research
	name = "\improper Research and Development"
	icon_state = "research"

/area/rnd/researchhalla
	name = "\improper Research Main Hallway"
	icon_state = "research"

/area/rnd/researchhallb
	name = "\improper Research Hazardous Materials Hallway"
	icon_state = "research"

/area/rnd/researchbreak
	name = "\improper Research Break Room"
	icon_state = "research"

/area/rnd/docking
	name = "\improper Research Dock"
	icon_state = "research_dock"

/area/rnd/lab
	name = "\improper Research Lab"
	icon_state = "toxlab"

/area/rnd/rdoffice
	name = "\improper Research Director's Office"
	icon_state = "head_quarters"

/area/rnd/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xeno_lab"

/area/rnd/xenobiology/xenoflora
	name = "\improper Xenoflora Lab"
	icon_state = "xeno_f_lab"

/area/rnd/storage
	name = "\improper Toxins Storage"
	icon_state = "toxstorage"

/area/rnd/test_area
	name = "\improper Toxins Test Area"
	icon_state = "toxtest"

/area/rnd/mixing
	name = "\improper Toxins Mixing Room"
	icon_state = "toxmix"

/area/rnd/misc_lab
	name = "\improper Miscellaneous Research"
	icon_state = "toxmisc"

/area/tcomms/
	music = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')
	environment = QUARRY

/area/tcomms/chamber
	name = "\improper Telecomms Central Compartment"
	icon_state = "tcomsatcham"

/area/turret_protected/tcommbreaker
	name = "\improper Telecomms Breaker Room"
	icon_state = "tcomsatcomp"

/area/tcomms/computer
	name = "\improper Telecomms Control Room"
	icon_state = "tcomsatcomp"

/area/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	music = list('sound/ambience/ambimalf.ogg')
	environment = ALLEY

/area/turret_protected/ai_upload_foyer
	name = "AI Upload Access"
	icon_state = "ai_foyer"
	music = list('sound/ambience/ambimalf.ogg')

/area/turret_protected/ai_server_room
	name = "AI Server Room"
	icon_state = "ai_server"

/area/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	music = list('sound/ambience/ambimalf.ogg')
	environment = ALLEY

/area/turret_protected/ai_cyborg_station
	name = "\improper Cyborg Station"
	icon_state = "ai_cyborg"

//Civilian
/area/crew_quarters
	name = "\improper Dormitories"
	icon_state = "Sleep"
	rad_shielded = 1
	environment = QUARRY

/area/crew_quarters/observe
	name = "\improper Observatory"
	icon_state = "green"

/area/crew_quarters/sleep
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/sleep/engi_wash
	name = "\improper Engineering Washroom"
	icon_state = "toilet"
	environment = BATHROOM

/area/crew_quarters/sleep/cryo
	name = "\improper Cryogenic Storage"
	icon_state = "Sleep"

/area/crew_quarters/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/crew_quarters/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/crew_quarters/bar
	name = "\improper Bar"
	icon_state = "bar"
	environment = QUARRY

/area/crew_quarters/lounge
	name = "\improper Lounge"
	icon_state = "Break Room"
	environment = QUARRY

/area/crew_quarters/diner
	name = "\improper Diner"
	icon_state = "bar"
	environment = QUARRY

/area/library
	name = "\improper Library"
	icon_state = "library"
	environment = QUARRY

/area/chapel/main
	name = "\improper Chapel"
	icon_state = "chapel"
	music = list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg','sound/music/traitor.ogg')
	environment = MOUNTAINS

/area/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"
	environment = QUARRY

/area/holodeck
	name = "\improper Holodeck"
	icon_state = "Holodeck"
	luminosity = 1
	lighting_use_dynamic = 0

/area/holodeck/alphadeck
	name = "\improper Holodeck Alpha"

/area/janitor/
	name = "\improper Custodial Closet"
	icon_state = "janitor"

/area/hydroponics
	name = "\improper Hydroponics"
	icon_state = "hydro"
	environment = CAVE

/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/security/vacantoffice2
	name = "\improper Vacant Office"
	icon_state = "security"
	environment = QUARRY

//Cargo
/area/storage
	environment = STONE_CORRIDOR

/area/quartermaster
	name = "\improper Quartermasters"
	icon_state = "quart"
	environment = QUARRY

/area/quartermaster/office
	name = "\improper Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "\improper Cargo Bay"
	icon_state = "quartstorage"
	environment = SEWER_PIPE

/area/quartermaster/qm
	name = "\improper Quartermaster's Office"
	icon_state = "quart"
	environment = QUARRY

/area/quartermaster/miningstorage
	name = "\improper Mining Storage"
	icon_state = "mining"

/area/quartermaster/sorting
	name = "\improper Delivery Office"
	icon_state = "quartstorage"

//Hangar
/area/podbay
	name = "\improper Podbay"
	icon_state = "yellow"
	environment = SEWER_PIPE

/area/podbay/hangar
	name = "\improper Hangar"
	icon_state = "green"
	environment = SEWER_PIPE

/area/hallway/secondary/exit
	name = "\improper Departures Lobby"
	icon_state = "escape"

/area/shuttle/escape/station
	name = "\improper Emergency Shuttle Station"
	icon_state = "shuttle2"

//Engineering
/area/desubber
	name = "\improper Phoron Desublimation Room"
	icon_state = "yellow"
	environment = QUARRY

/area/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	environment = CONCERT_HALL

/area/engine
	environment = SEWER_PIPE

/area/engine/engine_smes
		name = "Engineering SMES"
		icon_state = "engine_smes"

/area/engine/engine_room
		name = "\improper Engine Room"
		icon_state = "engine"

/area/engine/engine_airlock
		name = "\improper Engine Room Airlock"
		icon_state = "engine"

/area/engine/engine_monitoring
		name = "\improper Engine Monitoring Room"
		icon_state = "engine_monitoring"

/area/engine/engine_waste
		name = "\improper Engine Waste Handling"
		icon_state = "engine_waste"

/area/engine/engineering_monitoring
		name = "\improper Engineering Monitoring Room"
		icon_state = "engine_monitoring"

/area/engine/atmos_monitoring
		name = "\improper Atmospherics Monitoring Room"
		icon_state = "engine_monitoring"

/area/engine/engineering
		name = "Engineering"
		icon_state = "engine_smes"

/area/engine/engineering_foyer
		name = "\improper Engineering Foyer"
		icon_state = "engine"

/area/engine/engineering_supply
		name = "Engineering Supply"
		icon_state = "engine_supply"

/area/engine/break_room
		name = "\improper Engineering Break Room"
		icon_state = "engine"
		environment = QUARRY

/area/engine/hallway
		name = "\improper Engineering Hallway"
		icon_state = "engine_hallway"
		environment = HALLWAY

/area/engine/engine_hallway
		name = "\improper Engine Room Hallway"
		icon_state = "engine_hallway"
		environment = HALLWAY

/area/engine/workshop
		name = "\improper Engineering Workshop"
		icon_state = "engine_storage"

/area/engine/locker_room
		name = "\improper Engineering Locker Room"
		icon_state = "engine_storage"
		environment = QUARRY

/area/engine/construction
		name = "\improper Engineering Construction Zone"
		icon_state = "engine_storage"
		environment = SEWER_PIPE

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

//Solars
/area/solar
	requires_power = 1
	always_unpowered = 1
	lighting_use_dynamic = 0
	luminosity = 1
	environment = PLAIN

/area/solar/starboard
	name = "Aft Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/port
	name = "Aft Port Solar Array"
	icon_state = "panelsP"

//Maintenance
/area/maintenance/fore_port
	name = "Fore Port Maintenance"
	icon_state = "fpmaint"

/area/maintenance/port
	name = "Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/bridge_port
	name = "Bridge Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/bridge_starboard
	name = "Bridge Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/bridge_aft
	name = "Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/fore_starboard
	name = "Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/maintenance/aft_starboard
	name = "Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/engi_engine
	name = "Engine Maintenance"
	icon_state = "maint_engine"

/area/maintenance/engineering
	name = "Engineering Maintenance"
	icon_state = "maint_engineering"

/area/maintenance/central_port
	name = "Central Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/central_starboard
	name = "Central Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/central
	name = "Central Aft Maintenance"
	icon_state = "maintcentral"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/maintenance/incinerator
	name = "Incinerator"
	icon_state = "disposal"

/area/engine/drone_fabrication
	name = "\improper Drone Fabrication"
	icon_state = "engine"

	//Crew Quarters
/area/crew_quarters/maintrooms/medroom
	name = "\improper Fore Port Private Quarter"
	icon_state = "Sleep"

/area/crew_quarters/maintrooms/secroom1
	name = "\improper Fore Starboard Private Quarter One"
	icon_state = "Sleep"

/area/crew_quarters/maintrooms/arrivalroom1
	name = "\improper Port Private Quarter One"
	icon_state = "Sleep"

/area/crew_quarters/maintrooms/secroom2
	name = "\improper Fore Starboard Private Quarter Two"
	icon_state = "Sleep"

/area/crew_quarters/maintrooms/secroom3
	name = "\improper Fore Starboard Private Quarter Three"
	icon_state = "Sleep"

/area/crew_quarters/maintrooms/sciroom1
	name = "\improper Aft Starboard Private Quarter One"
	icon_state = "Sleep"

/area/crew_quarters/maintrooms/sciroom2
	name = "\improper Aft Starboard Private Quarter Two"
	icon_state = "Sleep"

/area/crew_quarters/maintrooms/sciroom3
	name = "\improper Aft Starboard Private Quarter Three"
	icon_state = "Sleep"

/area/crew_quarters/maintrooms/civroom
	name = "\improper Aft Port Private Quarter"
	icon_state = "Sleep"

/area/crew_quarters/maintrooms/centroom
	name = "\improper Central Private Quarter"
	icon_state = "Sleep"

	//Substations
/area/maintenance/substation
	name = "Substation"
	icon_state = "substation"
	environment = ALLEY

/area/maintenance/substation/engineering //Engineering
	name = "Engineering Substation"

/area/maintenance/substation/medical //Medbay
	name = "Medical Substation"

/area/maintenance/substation/research //Research
	name = "Research Substation"

/area/maintenance/substation/civilian_east //Cargo, Vacant Office, Custodial, Holodeck
	name = "Civilian Starboard Substation"

/area/maintenance/substation/civilian_west //Bar, Kitchen, Diner, Chapel, Observatory, Dorms, Locker Room, Library
	name = "Civilian Port Substation"

/area/maintenance/substation/security // Security, Brig, Permabrig, etc.
	name = "Security Substation"

/area/maintenance/substation/hangar // Hangar, Pod Hangar, Arrivals, Depatures, etc...
	name = "Hangar Substation"

	//Solars
/area/maintenance/starboard_solar
	name = "Aft Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/port_solar
	name = "Aft Port Solar Maintenance"
	icon_state = "SolarcontrolP"

	//Secret Rooms
/area/maintenance/secret/room1
	name = "Secret Room - Rainbow Outfits"
	icon_state = "secret"

/area/maintenance/secret/room2
	name = "Secret Room - Ghetto Surgery"
	icon_state = "secret"

/area/maintenance/secret/room3
	name = "Secret Room - Hidden Bar"
	icon_state = "secret"

/area/maintenance/secret/room4
	name = "Secret Room - Slums"
	icon_state = "secret"

/area/maintenance/secret/room5
	name = "Secret Room - Slum"
	icon_state = "secret"

/area/maintenance/secret/room6
	name = "Secret Room - Weed Room"
	icon_state = "secret"

/area/maintenance/secret/room7
	name = "Secret Room - Torture"
	icon_state = "secret"

/area/maintenance/secret/room8
	name = "Secret Room - Memories"
	icon_state = "secret"

/area/maintenance/secret/room9
	name = "Secret Room - AI Laws"
	icon_state = "secret"

/area/maintenance/secret/room10
	name = "Secret Room - Balloons"
	icon_state = "secret"


/*=========================================
=========02 - Engineering outpost==========
===========================================*/

/area/engioutpost
	name = "Engineering Outpost"
	icon_state = "LP"
	environment = HALLWAY

/area/engioutpost/solars
	name = "Engineering Outpost Solars"
	icon_state = "LPS"
	environment = PLAIN

/area/engioutpost/dock
	name = "Engineering Outpost"
	icon_state = "LP"
	environment = SEWER_PIPE

/*=========================================
==============03 - NMV Slater==============
===========================================*/

/area/slater
	environment = PLAIN

/area/slater/hallway1
	name = "Primary Hallway"
	icon_state = "hallP"
	environment = HALLWAY

/area/slater/hallway2
	name = "Secondary Hallway"
	icon_state = "hallS"
	environment = HALLWAY

/area/slater/bridge
	name = "NMV Slater Bridge"
	icon_state = "bridge"

/area/slater/bridge
	name = "NMV Slater Bridge"
	icon_state = "bridge"

/area/slater/foreman
	name = "NMV Slater Foreman's Office"
	icon_state = "bridge"

/area/slater/maint1
	name = "NMV Slater Fore Maintenance"
	icon_state = "fmaint"

/area/slater/maint2
	name = "NMV Slater Aft Maintenance"
	icon_state = "amaint"

/area/slater/maint3
	name = "NMV Slater Secondary Maintenance"
	icon_state = "pmaint"

/area/slater/engine
	name = "NMV Slater Engine Room"
	icon_state = "engine"

/area/slater/disposals
	name = "NMV Slater Disposals Control"
	icon_state = "disposal"

/area/slater/refinery
	name = "NMV Slater Refinery"
	icon_state = "mining_production"

/area/slater/cargo
	name = "NMV Slater Cargo Hold"
	icon_state = "storage"

/area/slater/hangar
	name = "NMV Slater Hangar"
	icon_state = "green"

/area/slater/expeditionprep
	name = "NMV Slater Expedition Prep"
	icon_state = "mining_eva"

/area/slater/medbay
	name = "NMV Slater Medbay"
	icon_state = "medbay"

/area/slater/lounge
	name = "NMV Slater Break Room"
	icon_state = "cafeteria"

/area/slater/dorm
	name = "NMV Slater Dormitory"
	icon_state = "Sleep"

/*=========================================
==============04 - Centcomm================
===========================================*/

/area/shuttle/transport1/centcom
	icon_state = "shuttle"
	name = "\improper Transport Shuttle"

/area/shuttle/pizza/centcom
	icon_state = "shuttle"
	name = "\improper Pizza Shuttle"

/area/shuttle/trade/centcom
	icon_state = "shuttle"
	name = "\improper Trade Shuttle"

/area/shuttle/hippie/centcom
	icon_state = "shuttle"
	name = "\improper Hippie Shuttle"

//Central command
/area/shuttle/escape/centcom
	name = "Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/centcom
	name = "Centcom"
	icon_state = "centcom"
	requires_power = 0

/area/centcom/control
	name = "Centcom Control"

/area/centcom/supply
	name = "Centcom Supply Shuttle"

/area/centcom/ferry
	name = "Centcom Transport Shuttle"

/area/centcom/shuttle
	name = "Centcom Administration Shuttle"

/area/centcom/test
	name = "Centcom Testing Facility"

/area/centcom/living
	name = "Centcom Living Quarters"

/area/centcom/holding
	name = "Holding Facility"

//ERT Ship
/area/shuttle/specops/centcom
	name = "Special Ops Shuttle"
	icon_state = "shuttlered"

/area/centcom/specops
	name = "Centcom Special Ops"

//Pod Ship
/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/centcom //Pod 4 was lost to meteors
	icon_state = "shuttle"

/area/centcom/evac
	name = "Centcom Emergency Shuttle"

//Thunderdome
/area/tdome
	name = "Thunderdome"
	icon_state = "thunder"
	requires_power = 0
	lighting_use_dynamic = 0
	ambience = list('sound/music/THUNDERDOME.ogg')

/area/tdome/arena
	name = "Thunderdome Arena"
	icon_state = "thunder"
	requires_power = 0

/area/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "red"

/area/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "blue"

/area/tdome/tdomeadmin
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "Thunderdome (Observer.)"
	icon_state = "purple"

//Trade Station
/area/centcom/trade
	name = "Remote Trade Outpost"
	icon_state = "green"
	requires_power = 0

//Pizzaland!!!!
/area/pizzaland
	name = "Pizzaland"
	icon_state = "red"
	requires_power = 0
	ambience = list('sound/music/1.ogg')

//Antag Areas
	//Syndicate Base
/area/antagasteroid
	name = "Antagonist Hideout"
	icon_state = "red"
	requires_power = 0
	lighting_use_dynamic = 0
	ambience = list('sound/music/traitor.ogg')

/area/syndicate_mothership
	name = "Mercenary Base"
	icon_state = "syndie-ship"
	requires_power = 0
	lighting_use_dynamic = 0

/area/syndicate_mothership/offsite_hanger
	name = "Elite Mercenary Squad"
	icon_state = "syndie-elite"

/area/syndicate_mothership/elite_squad
	name = "Elite Mercenary Squad"
	icon_state = "syndie-elite"

	//Wizard Room
/area/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	requires_power = 0
	lighting_use_dynamic = 0

	//Admin Prep Room
/area/adminprep/valanspreparea
	name = "valan prep room"
	icon_state = "red"
	requires_power = 0
	environment = PLAIN

//Holodeck Sources
/area/holodeck/source_plating
	name = "Holodeck - Off"
	icon_state = "Holodeck"

/area/holodeck/source_emptycourt
	name = "Holodeck - Empty Court"

/area/holodeck/source_boxingcourt
	name = "Holodeck - Boxing Court"

/area/holodeck/source_basketball
	name = "Holodeck - Basketball Court"

/area/holodeck/source_thunderdomecourt
	name = "Holodeck - Thunderdome Court"

/area/holodeck/source_beach
	name = "Holodeck - Beach"
	icon_state = "Holodeck" // Lazy.

/area/holodeck/source_wildlife
	name = "Holodeck - Wildlife Simulation"

/area/holodeck/source_meetinghall
	name = "Holodeck - Meeting Hall"

/area/holodeck/source_theatre
	name = "Holodeck - Theatre"

/area/holodeck/source_picnicarea
	name = "Holodeck - Picnic Area"

/area/holodeck/source_snowfield
	name = "Holodeck - Snow Field"

/area/holodeck/source_desert
	name = "Holodeck - Desert"

/area/holodeck/source_space
	name = "Holodeck - Space"
	has_gravity = 0

//Splash Screen
/area/start
	name = "start area"
	icon_state = "start"
	requires_power = 0
	has_gravity = 1
	lighting_use_dynamic = 0

var/list/centcom_areas = list (
	/area/centcom,
	/area/shuttle/escape/centcom,
	/area/shuttle/escape_pod1/centcom,
	/area/shuttle/escape_pod2/centcom,
	/area/shuttle/escape_pod3/centcom,
	/area/shuttle/escape_pod5/centcom,
	///area/shuttle/transport1/centcom,
	///area/shuttle/administration/centcom,
	/area/shuttle/specops/centcom,
)

/*=========================================
=================05 - Moon=================
===========================================*/

/area/planet/moon
	name = "moon"
	icon_state = "moon"
	environment = PLAIN

	base_turf = /turf/planet/lunar

//Exterior Zones
/area/planet/moon/exterior
	name = "moon"
	icon_state = "moon"
	environment = PLAIN

	ambience = list( 'sound/ambience/ambience_outpost.ogg' )
	music = list( 'sound/ambience/ambispace.ogg','sound/ambience/ambispace1.ogg','sound/ambience/ambispace2.ogg' )

/area/planet/moon/exterior/explored
	name = "explored moon"
	icon_state = "explored"

//Landing Zones
/area/planet/moon/landing_zone
	name = "landing zone"
	icon_state = "south"
	light_range = 1

/area/planet/moon/landing_zone/central
	name = "Central Outpost"

/area/planet/moon/landing_zone/engineering
	name = "Engineering Outpost"

/area/planet/moon/landing_zone/science
	name = "Research Outpost"

/area/planet/moon/landing_zone/mining
	name = "Mining Outpost"

/area/planet/moon/landing_zone/security
	name = "Security Prison"

/area/planet/moon/outpost
	name = "outpost"
	icon_state = "south"
	requires_power = 1
	environment = HALLWAY

//Main Outpost
/area/planet/moon/outpost/central
	name = "Central Outpost"
	icon_state = "bridge"

/area/planet/moon/outpost/central/medical
	name = "Central Outpost Medbay"
	icon_state = "medbay"

/area/planet/moon/outpost/central/EVA
	name = "Central Outpost EVA"
	icon_state = "eva"

/area/planet/moon/outpost/central/hallway
	name = "Central Outpost Hallway"

/area/planet/moon/outpost/central/lounge
	name = "Central Outpost Lounge"
	icon_state = "Sleep"

/area/planet/moon/outpost/central/incinerator
	name = "Central Outpost Incinerator"
	icon_state = "disposal"

/area/planet/moon/outpost/central/substation
	name = "Central Outpost Substation"
	icon_state = "substation"

//Engineering Outpost
/area/planet/moon/outpost/engineering
	name = "Engineering Outpost"
	icon_state = "engine"

/area/planet/moon/outpost/engineering/lounge
	name = "Engineering Outpost Lounge"
	icon_state = "Sleep"

/area/planet/moon/outpost/engineering/storage
	name = "Engineering Outpost Storage"
	icon_state = "engine_storage"

/area/planet/moon/outpost/engineering/EVA
	name = "Engineering Outpost EVA"
	icon_state = "eva"

/area/planet/moon/outpost/engineering/atmospherics
	name = "Engineering Outpost Atmospherics"
	icon_state = "atmos"

/area/planet/moon/outpost/engineering/SMES
	name = "Engineering Outpost SMES Storage"
	icon_state = "engine_smes"

/area/planet/moon/outpost/engineering/hallway
	name = "Engineering Outpost Hallway"
	icon_state = "engine"

/area/planet/moon/outpost/engineering/solars
	name = "Engineering Outpost Solars"
	icon_state = "panelsA"

//Mining Outpost
/area/planet/moon/outpost/mining
	name = "Mining Outpost"
	icon_state = "mining"

/area/planet/moon/outpost/mining/EVA
	name = "Mining Outpost EVA"
	icon_state = "eva"

/area/planet/moon/outpost/mining/lounge
	name = "Mining Outpost Lounge"
	icon_state = "mining_living"

/area/planet/moon/outpost/mining/refinery
	name = "Mining Outpost Refinery"
	icon_state = "mining_production"

/area/planet/moon/outpost/mining/maintenance
	name = "Mining Outpost Maintenance"
	icon_state = "fmaint"

/area/planet/moon/outpost/mining/foreman
	name = "Mining Outpost Foreman Office"

/area/planet/moon/outpost/mining/hallway
	name = "Mining Outpost"

/area/planet/moon/outpost/mining/substation
	name = "Mining Outpost Substation"
	icon_state = "substation"

//Research Outpost
/area/planet/moon/outpost/science
	name = "Research Outpost"
	icon_state = "anomaly"

/area/planet/moon/outpost/science/EVA
	name = "Research Outpost EVA"
	icon_state = "eva"

/area/planet/moon/outpost/science/hallway
	name = "Research Outpost Hallway"
	icon_state = "anohallway"

/area/planet/moon/outpost/science/lounge
	name = "Research Outpost Lounge"
	icon_state = "Sleep"

/area/planet/moon/outpost/science/chemistry
	name = "Research Outpost Chemistry Lab"
	icon_state = "chem"

/area/planet/moon/outpost/science/exotic
	name = "Research Outpost Exotic Particle Harvesting"
	icon_state = "anomaly"

/area/planet/moon/outpost/science/containment
	name = "Research Outpost Isolation"
	icon_state = "iso1"

/area/planet/moon/outpost/science/lab
	name = "Research Outpost Laboratory"
	icon_state = "anolab"

/area/planet/moon/outpost/science/anomaly
	name = "Research Outpost Anomaly Lab"
	icon_state = "anosample"

/area/planet/moon/outpost/science/spectromotry
	name = "Research Outpost Spectromotry"
	icon_state = "anospectro"

/area/planet/moon/outpost/science/substation
	name = "Research Outpost Substation"
	icon_state = "substation"

/area/planet/moon/outpost/science/tcomms
	name = "Research Outpost Telecomms"
	icon_state = "tcomsat"