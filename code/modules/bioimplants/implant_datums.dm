/datum/implant/recipe
    var/name = "object"
    var/path
    var/hidden
    var/category
    var/desc
    var/cpu_required = 0
    var/memory_required = 0

//Brain implants
/datum/implant/recipe/camera
    name = "Remote Camera"
    category = "Brain"
    desc = "Grants access to any camera in your departments network     [derp]"
        [derp]
/datum/implant/recipe/camera/hacked
    name = "Advanced Remote Camera"
    desc = "Grants access to any camera on the station"
    memory_required = 1
    hidden = 1

/datum/implant/recipe/ram_basic
    name = "RAM Module"
    category = "Brain"
    desc = "Basic RAM module nessesary for advanced implants."

/datum/implant/recipe/cpu_basic
    name = "Basic CPU"
    category = "Brain"
    desc = "Basic CPU nessesary for advanced implants."

/datum/implant/recipe/wireless
    name = "Wireless Interactivity"
    category = "Brain"
    desc = "Allows you to wirelessly interact with computers and machinery within your vision"
    cpu_required = 1

/datum/implant/recipe/hacking
    name = "Cranial Hacking"
    category = "Brain"
    desc = "A neural implant that allows you to wirelessly hack doors open."
    cpu_required = 1
    hidden = 1

//Eye implants
/datum/implant/recipe/hud_medical
    name = "Medical HUD"
    category = "Eyes"
    desc = "A medical HUB implanted directly into your retina."
    memory_required = 1

/datum/implant/recipe/hud_security
    name = "Security HUD"
    category = "Eyes"
    desc = "A security HUD implanted directly into your retina"
    memory_required = 1

/datum/implant/recipe/hud_pda
    name = "PDA HUD"
    category = "Eyes"
    desc = "A PDA HUD implanted directly into your retina"
    memory_required = 1

/datum/implant/recipe/xray
    name = "Xray Vision"
    category = "Eyes"
    desc = "Allows you to see through walls by firing penetrating rays from your retina."
    memory_required = 1

/datum/implant/recipe/track
    name = "Mark and Track"
    category = "Eyes"
    desc = "Allows you to tag and track an object or crew member"
    memory_required = 1

/datum/implant/recipe/night
    name = "Night Vision"
    category = "Eyes"
    desc = "Allows you to see in the dark, spooky!"

/datum/implant/recipe/thermal
    name = "Thermal Vision"
    category = "Eyes"
    desc = "Thermal implants allowing you to see objects radiating heat through walls"
    memory_required = 1

/datum/implant/recipe/flash
    name = "Internal sunglasses"
    category = "Eyes"
    desc = "Protects you from bright lights and sudden flashes of light."

//Rest of the head implants
/datum/implant/recipe/radio
    name = "Internal Headset"
    category = "Head"
    desc = "A vibration sensitive headset implanted into the base of your skull."
    cpu_required = 1

/datum/implant/recipe/voice_changer
    name = "Larynx Modifier"
    category = "Head"
    desc = "Replaces your larynx allowing you to impersonate voices as if they were your own."
    cpu_required = 1
    memory_required = 1
    hidden = 1

/datum/implant/recipe/face_changer
    name = "Face Modifier"
    category = "Head"
    desc = "Replaces the skin on your face with a polymer that can mould and retain any shape"
    cpu_required = 1
    memory_required = 1
    hidden = 1

/datum/implant/recipe/mask
    name = "Internal Respirator"
    category = "Head"
    desc = "Filters harmful gasses and is compatable with canisters stored inside your cavity via implant."

//Arms
/datum/implant/recipe/electrical_resistance
    name = "Electrical Resistance"
    category = "Hand"
    desc = "A polymer implanted under the skin in your hands, absorbs deadly electric shocks"

/datum/implant/recipe/omni_hand
    name = "Omni-Tool Implant"
    category = "Hand"
    desc = "You become a walking toolbelt, the omnitool is implanted inside your finger and palm."
    memory_required = 1

/datum/implant/recipe/fingerprint
    name = "Fingerprint manipulator"
    category = "Hand"
    desc = "Replaces your fingertips with a polymer that can mould and retain any shape it touches."
    cpu_required = 1
    memory_required = 1
    hidden = 1

/datum/implant/recipe/strong_hand
    name = "Hydrolic Tendons"
    category = "Hand"
    desc = "Replaces the tendons in your hand with hydrolic versions, granting increased grip."
    cpu_required = 1

/datum/implant/recipe/strong_arm
    name = "Hydrolic Arm"
    category = "Arm"
    desc = "Adds hydrolics to your arm and forearm, increasing your offensive force."
    cpu_required = 1

/datum/implant/recipe/sword
    name = "Sword Hand"
    category = "Hand"
    desc = "Does what it says on the tin."
    memory_required = 1
    hidden = 1

//Chest
/datum/implant/recipe/storage
    name = "Cavity Implant"
    category = "Chest"
    desc = "Shifts the placement of some of your organs allowing for objects to be stored inside your chest."

/datum/implant/recipe/battery_pack
    name = "Battery Pack"
    category = "Chest"
    desc = "A battery pack to power all your gizmo's and gadgets"

/datum/implant/recipe/chemical_bag
    name = "Chemical Bag"
    category = "Heart"
    desc = "A chemical bag that stores up to the contents of one large beaker. Dispensed directly into your blood stream automatically or manually."
    cpu_required = 1

/datum/implant/recipe/blood_tox
    name = "Blood Filter"
    category = "Heart"
    desc = "An advanced filter installed directly onto the heart which aids in filtering toxins from the blood."

/datum/implant/recipe/blood_crit
    name = "Inaprovaline Drip"
    category = "Heart"
    desc = "A modified version of the chemical bag that keeps a supply of inaprovaline in your blood forever."

/datum/implant/recipe/antibody
    name = "Immuno-stimulator"
    category = "Heart"
    desc = "An advanced module that improves your bodies immune system"
    cpu_required = 1

/datum/implant/recipe/lung_oxygen
    name = "Elastic Lungs"
    category = "Lung"
    desc = "You inhale more oxygen with each breath, prolonging the time you can survive without an oxygen supply."

//Legs
/datum/implant/recipe/speed
    name = "Hydrolic Legs"
    category = "Legs"
    desc = "Adds hydrolics to your leg, increasing your running speed."
    cpu_required = 1

/datum/implant/recipe/hlock
    name = "Hyrdolic Lock"
    category = "Legs"
    desc = "A third-party addon to the popular Hydrolic Legs augment, automatically locking the hydrolics in place to help keep your balance"
    cpu_required = 1
    memory_required = 1

/datum/implant/recipe/hlock/plus
    name = "Experemental Hyrolic Lock"
    desc = "An experemental prototype with safety software disabled, stopping you from falling over. WARNING: Possible injuries may occur"

/datum/implant/recipe/magboot
    name = "Magnetic Foot"
    category = "Foot"
    desc = "An electromagnet implanted in the sole of your foot."

//Generic implants
/datum/implant/recipe/heatsink
    name = "Heatsink Skin"
    category = "Generic"
    desc = "Implanted deep under your skin, augmenting it to grow in a heatsink patern"
    cpu_required = 1

/datum/implant/recipe/rfid
    name = "RFID Tag"
    category = "Generic"
    desc = "Tired of losing your ID card? The RFID acts as your ID card and a tracking beacon in one."
    memory_required = 1
