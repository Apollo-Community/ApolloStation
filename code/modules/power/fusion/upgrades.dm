/datum/fusionUpgradeTable
	var/list/rod = list()
	var/list/crystal = list()
	var/list/rod_color = list()
	var/const/maxfuel = 240

/datum/fusionUpgradeTable/New()
	rod = list(\
	"iron"		= 0.1,\
	"silver" 	= 0.2,\
	"gold" 		= 0.4,\
	"platinum"	= 0.8,\
	"phoron" 	= 1.6,\
	"osmium"	= 3.2,\
	"tritium"	= 6.4)

	rod_color = list(\
	"iron"		= "#0067FF",\
	"silver" 	= "#00ccff",\
	"gold" 		= "#ffff00",\
	"platinum"	= "#00ff00",\
	"phoron" 	= "#a31aff",\
	"osmium"	= "#ff00ff",\
	"tritium"	= "#ff3300")

	crystal = list(\
	"iron"		= 0.1,\
	"silver" 	= 0.2,\
	"gold" 		= 0.4,\
	"platinum"	= 0.8,\
	"phoron" 	= 1.6,\
	"osmium"	= 3.2,\
	"tritium"	= 6.4)

//Neutron & heat upgrade
/datum/fusionUpgradeTable/proc/rod_coef(obj/item/weapon/neutronRod/rod)
	. = src.rod[rod.mineral]

//Returns a color asosiated with a rod
/datum/fusionUpgradeTable/proc/rod_color(obj/item/weapon/neutronRod/rod)
	. = src.rod_color[rod.mineral]

//Field upgrade
/datum/fusionUpgradeTable/proc/field_coef(obj/item/weapon/shieldCrystal/crystal)
	. = src.crystal[crystal.mineral]

//Coefs on the fusion event determening heat, neutron, conversion rate, and fuel coefs
/datum/fusionUpgradeTable/proc/gas_coef(datum/gas_mixture/plasma)
	//Gas propeties:
	//Hydrogen - Basic fuel need at least 120 moles for 100% reactivity
	//Phoron - Shield vitalizer, enhance shield regen rate
	//Nitrogen - Stops reaction when more then 100 moles are present. dempense if less.
	//Oxygen - Neutron releaser.
	//CarbonDioxide	- Heat absorver, neutron releaser.
	//Nitrous Oxide - Neutron obsorber, heat releaser.
	var/fuel_coef = Clamp(plasma.gas["hydrogen"]/(maxfuel/2), 0, 2)	//120 moles are needed for full reactivity
	var/dampening = 1 - Clamp(plasma.gas["nitrogen"]/100, 0, 1)
	var/neutron_coef = 1 + Clamp(plasma.gas["oxygen"]/maxfuel, 0, 1)
	var/heat_neutron_coef = plasma.gas["carbon_dioxide"]/maxfuel
	var/neutron_heat_coef = plasma.gas["sleeping_agent"]/maxfuel
	var/shield_coef = 1 + Clamp(plasma.gas["phoron"]/maxfuel, 0 ,1)
	var/explosive = 0
	if(plasma.gas["phoron"] > 0 && plasma.gas["oxygen"] > 0)
		explosive = 1

	. = list(\
	"fuel" = fuel_coef,\
	"dampening" = dampening,\
	"neutron" = neutron_coef,\
	"shield" = shield_coef,\
	"heat_neutron" = heat_neutron_coef,\
	"neutron_heat" = neutron_heat_coef,\
	"explosive" = explosive\
	)


//Upgrade items for the fusion reactor
//The rod has an effect on heat/neutron production.
/obj/item/weapon/neutronRod
	name = "Neutron Focusing Rod"
	desc = " neutron absorbtion rod."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "smes_coil"			// Just few icons patched together. If someone wants to make better icon, feel free to do so!
	w_class = 4.0 						// It's LARGE (backpack size)
	var/mineral = "iron"

/obj/item/weapon/neutronRod/New(var/mineral)
	if(!isnull(mineral))
		src.mineral = mineral
	..()

//The crystal has an effect on the decay/strengh of plasma/shields
/obj/item/weapon/shieldCrystal
	name = "Field Amplification Crystal"
	desc = " field amplification crystal."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "ansible_crystal"			// Just few icons patched together. If someone wants to make better icon, feel free to do so!
	w_class = 4.0 						// It's LARGE (backpack size)
	var/mineral = "glass"

/obj/item/weapon/shieldCrystal/New(var/mineral)
	if(!isnull(mineral))
		src.mineral = mineral
	desc = "[mineral]" + desc
	..()