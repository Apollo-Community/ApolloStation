/datum/fusionUpgradeTable
	var/list/rod = list()
	var/list/crystal = list()

/datum/fusionUpgradeTable/New()
	rod = list(\
	"iron"		= 0.5,\
	"silver" 	= 0.6,\
	"gold" 		= 0.7,\
	"platinum"	= 0.8,\
	"phoron" 	= 0.4,\
	"osmium"	= 0.3,\
	"tritium"	= 0.2)

	crystal = list(\
	"iron"		= 0.5,\
	"silver" 	= 0.4,\
	"gold" 		= 0.3,\
	"platinum"	= 0.2,\
	"phoron" 	= 0.6,\
	"osmium"	= 0.7,\
	"tritium"	= 0.8)

//1 = 100% heat, 0 = 100% neutrons
/datum/fusionUpgradeTable/proc/rod_coef(obj/item/weapon/neutronRod/rod)
	. = src.rod[rod.mineral]

//1 = 100% decay, 0 = 100% strengh
/datum/fusionUpgradeTable/proc/field_coef(obj/item/weapon/shieldCrystal/crystal)
	. = src.crystal[crystal.mineral]

//Coefs on the fusion event determening heat, neutron, conversion rate, and fuel coefs
/datum/fusionUpgradeTable/proc/gas_coef(datum/gas_mixture/plasma)
	var/const/max = 240
	//Gas propeties:
	//Hydrogen - Basic fuel need at least 120 moles for 100% reactivity
	//Phoron - Neutron and Heat releaser (super charge reaction)
	//Nitrogen - Neutron absorber (shield preserver).
	//Oxygen - Heat absorber.
	//CarbonDioxide	- Heat absorver, neutron releaser.
	//Nitrous Oxide - Neutron obsorber, heat releaser.
	var/fuel_coef = 1 * plasma.gas["hydrogen"]/(max/2)	//120 moles are needed for full reactivity
	var/heat_coef = 0.5 + plasma.gas["phoron"]/max - plasma.gas["oxygen"]/max
	var/neutron_coef = 0.5 + plasma.gas["phoron"]/max - plasma.gas["nitrogen"]/max
	var/heat_neutron_coef = plasma.gas["carbon_dioxide"]/max
	var/neutron_heat_coef = plasma.gas["sleeping_agent"]/max

	. = list(\
	"fuel" = fuel_coef,\
	"heat" = heat_coef,\
	"neutron" = neutron_coef,\
	"heat_neutron" = heat_neutron_coef,\
	"neutron_heat" = neutron_heat_coef\
	)


//Upgrade items for the fusion reactor
//The rod has an effect on heat/neutron production.
/obj/item/weapon/neutronRod
	name = "Neutron Absobtion Rod"
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
	icon_state = "smes_coil"			// Just few icons patched together. If someone wants to make better icon, feel free to do so!
	w_class = 4.0 						// It's LARGE (backpack size)
	var/mineral = "glass"

/obj/item/weapon/shieldCrystal/New(var/mineral)
	if(!isnull(mineral))
		src.mineral = mineral
	desc = "[mineral]" + desc
	..()