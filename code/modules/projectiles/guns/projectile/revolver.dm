/obj/item/gun/projectile/revolver
	name = "\improper .357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo."
	icon_state = "revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/gunshots/1rev.ogg'

/obj/item/gun/projectile/revolver/New()
	..()
	if(!istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		verbs -= /obj/item/gun/projectile/revolver/verb/spin

/obj/item/gun/projectile/revolver/chamber_round(var/spin = 1)
	if(spin)
		chambered = magazine.get_round(1)
	else
		chambered = magazine.stored_ammo[1]
	return

/obj/item/gun/projectile/revolver/shoot_with_empty_chamber(mob/living/user as mob|obj)
	..()
	chamber_round(1)

/obj/item/gun/projectile/revolver/process_chamber()
	return ..(0, 1)

/obj/item/gun/projectile/revolver/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src].</span>")
		A.update_icon()
		update_icon()
		chamber_round(0)

/obj/item/gun/projectile/revolver/attack_self(mob/living/user)
	var/num_unloaded = 0
	chambered = null
	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		if(CB)
			CB.loc = get_turf(loc)
			CB.SpinAnimation(10, 1)
			CB.update_icon()
			playsound(get_turf(CB), "casingdrop", 60, 1)
			num_unloaded++
	if(num_unloaded)
		to_chat(user, "<span class='notice'>You unload [num_unloaded] shell\s from [src].</span>")
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")

/obj/item/gun/projectile/revolver/verb/spin()
	set name = "Spin Chamber"
	set category = "Object"
	set desc = "Click to spin your revolver's chamber."

	var/mob/M = usr

	if(M.stat || !in_range(M,src))
		return

	if(istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
		C.spin()
		chamber_round(0)
		playsound(loc, 'sound/weapons/revolver_spin.ogg', 50, 1)
		usr.visible_message("[usr] spins [src]'s chamber.", "<span class='notice'>You spin [src]'s chamber.</span>")
	else
		verbs -= /obj/item/gun/projectile/revolver/verb/spin

/obj/item/gun/projectile/revolver/can_shoot()
	return get_ammo(0,0)

/obj/item/gun/projectile/revolver/get_ammo(countchambered = 0, countempties = 1)
	var/boolets = 0 //mature var names for mature people
	if(chambered && countchambered)
		boolets++
	if(magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/gun/projectile/revolver/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[get_ammo(0,0)] of those are live rounds.</span>"

/obj/item/gun/projectile/revolver/detective
	desc = "A cheap Martian knock-off of a classic law enforcement firearm. Uses .38-special rounds."
	name = ".38 Mars Special"
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38
	fire_sound = 'sound/weapons/gunshots/1rev38.ogg'
	unique_rename = TRUE
	unique_reskin = TRUE

/obj/item/gun/projectile/revolver/detective/New()
	..()
	options["The Original"] = "detective"
	options["Leopard Spots"] = "detective_leopard"
	options["Black Panther"] = "detective_panther"
	options["White Gold "] = "detective_gold"
	options["The Peacemaker"] = "detective_peacemaker"
	options["Gold Wood"] = "detective_gold_alt"
	options["Silver"] = "detective_silver"
	options["Cancel"] = null


/obj/item/gun/projectile/revolver/fingergun //Summoned by the Finger Gun spell, from advanced mimery traitor item
	name = "\improper finger gun"
	desc = "Bang bang bang!"
	icon_state = "fingergun"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible
	origin_tech = ""
	flags = ABSTRACT | NODROP | DROPDEL
	slot_flags = null
	fire_sound = null
	fire_sound_text = null
	lefthand_file = null
	righthand_file = null
	can_holster = FALSE // Get your fingers out of there!
	clumsy_check = FALSE //Stole your uplink! Honk!
	needs_permit = FALSE //go away beepsky
	var/obj/effect/proc_holder/spell/mime/fingergun/parent_spell


/obj/item/gun/projectile/revolver/fingergun/fake
	desc = "Pew pew pew!"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible/fake


/obj/item/gun/projectile/revolver/fingergun/New(loc, new_parent_spell)
	..()
	parent_spell = new_parent_spell
	verbs -= /obj/item/gun/projectile/revolver/verb/spin


/obj/item/gun/projectile/revolver/fingergun/Destroy()
	if(parent_spell)
		parent_spell.current_gun = null
		parent_spell.UnregisterSignal(parent_spell.action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		parent_spell = null
	return ..()


/obj/item/gun/projectile/revolver/fingergun/shoot_with_empty_chamber(/*mob/living/user as mob|obj*/)
	to_chat(usr, "<span class='warning'>You are out of ammo! You holster your fingers.</span>")
	qdel(src)
	return

/obj/item/gun/projectile/revolver/fingergun/afterattack(atom/target, mob/living/user, flag, params)
	if(!user.mind.miming)
		to_chat(usr, "<span class='warning'>You must dedicate yourself to silence first. Use your fingers if you wish to holster them.</span>")
		return
	..()

/obj/item/gun/projectile/revolver/fingergun/attackby(obj/item/A, mob/user, params)
	return

/obj/item/gun/projectile/revolver/fingergun/attack_self(mob/living/user)
	to_chat(usr, "<span class='notice'>You holster your fingers. Another time.</span>")
	qdel(src)
	return

/obj/item/gun/projectile/revolver/mateba
	name = "\improper Unica 6 auto-revolver"
	desc = "A retro high-powered autorevolver typically used by officers of the New Russia military. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"

/obj/item/gun/projectile/revolver/ga12
	name = "\improper Tkach Ya-Sui GA 12 revolver"
	desc = "An outdated sidearm rarely seen in use by certain PMCs that operate throughout the frontier systems, featuring a three-shell cylinder. Thats right, shell, this one shoots twelve gauge."
	icon_state = "12garevolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/ga12
	fire_sound = 'sound/weapons/gunshots/1rev12.ogg'
	spread = 15
	recoil = 1
	fire_delay = 5

/obj/item/gun/projectile/revolver/golden
	name = "\improper Golden revolver"
	desc = "This ain't no game, ain't never been no show, And I'll gladly gun down the oldest lady you know. Uses .357 ammo."
	icon_state = "goldrevolver"
	fire_sound = 'sound/weapons/resonator_blast.ogg'
	recoil = 8

/obj/item/gun/projectile/revolver/nagant
	name = "nagant revolver"
	desc = "An old model of revolver that originated in Russia. Able to be suppressed. Uses 7.62x38mmR ammo."
	icon_state = "nagant"
	origin_tech = "combat=3"
	can_suppress = 1
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev762

/obj/item/gun/projectile/revolver/c36
	name = ".36 revolver"
	desc = "An old fashion .36 chambered revolver."
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev36
	fire_sound = 'sound/weapons/gunshots/1rev38.ogg'

// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/gun/projectile/revolver/russian
	name = "\improper Russian Revolver"
	desc = "A Russian-made revolver for drinking games. Uses .357 ammo, and has a mechanism that spins the chamber before each trigger pull."
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/rus357
	var/spun = 0


/obj/item/gun/projectile/revolver/russian/New()
	..()
	Spin()
	update_icon()

/obj/item/gun/projectile/revolver/russian/proc/Spin()
	chambered = null
	var/random = rand(1, magazine.max_ammo)
	if(random <= get_ammo(0,0))
		chamber_round()
	spun = 1

/obj/item/gun/projectile/revolver/russian/attackby(obj/item/A, mob/user, params)
	var/num_loaded = ..()
	if(num_loaded)
		user.visible_message("[user] loads a single bullet into the revolver and spins the chamber.", "<span class='notice'>You load a single bullet into the chamber and spin it.</span>")
	else
		user.visible_message("[user] spins the chamber of the revolver.", "<span class='notice'>You spin the revolver's chamber.</span>")
	if(get_ammo() > 0)
		Spin()
	update_icon()
	A.update_icon()
	return

/obj/item/gun/projectile/revolver/russian/attack_self(mob/user)
	if(!spun && can_shoot())
		user.visible_message("[user] spins the chamber of the revolver.", "<span class='notice'>You spin the revolver's chamber.</span>")
		Spin()
	else
		var/num_unloaded = 0
		while(get_ammo() > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round()
			chambered = null
			CB.loc = get_turf(loc)
			CB.update_icon()
			playsound(get_turf(CB), "casingdrop", 60, 1)
			num_unloaded++
		if(num_unloaded)
			to_chat(user, "<span class='notice'>You unload [num_unloaded] shell\s from [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/item/gun/projectile/revolver/russian/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params)
	if(flag)
		if(!(target in user.contents) && ismob(target))
			if(user.a_intent == INTENT_HARM) // Flogging action
				return

	if(isliving(user))
		if(!can_trigger_gun(user))
			return
	if(target != user)
		if(ismob(target))
			to_chat(user, "<span class='warning'>A mechanism prevents you from shooting anyone but yourself!</span>")
		return

	if(ishuman(user))
		if(!spun)
			to_chat(user, "<span class='warning'>You need to spin the revolver's chamber first!</span>")
			return

		spun = 0

		if(chambered)
			var/obj/item/ammo_casing/AC = chambered
			if(AC.fire(user, user))
				playsound(user, fire_sound, 50, 1)
				var/zone = check_zone(user.zone_selected)
				if(zone == "head" || zone == "eyes" || zone == "mouth")
					shoot_self(user, zone)
				else
					user.visible_message("<span class='danger'>[user.name] cowardly fires [src] at [user.p_their()] [zone]!</span>", "<span class='userdanger'>You cowardly fire [src] at your [zone]!</span>", "<span class='italics'>You hear a gunshot!</span>")
				return

		user.visible_message("<span class='danger'>*click*</span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)

/obj/item/gun/projectile/revolver/russian/proc/shoot_self(mob/living/carbon/human/user, affecting = "head")
	user.apply_damage(300, BRUTE, affecting)
	user.visible_message("<span class='danger'>[user.name] fires [src] at [user.p_their()] head!</span>", "<span class='userdanger'>You fire [src] at your head!</span>", "<span class='italics'>You hear a gunshot!</span>")

/obj/item/gun/projectile/revolver/russian/soul
	name = "cursed Russian revolver"
	desc = "To play with this revolver requires wagering your very soul."

/obj/item/gun/projectile/revolver/russian/soul/shoot_self(mob/living/user)
	..()
	var/obj/item/soulstone/anybody/SS = new /obj/item/soulstone/anybody(get_turf(src))
	if(!SS.transfer_soul("FORCE", user)) //Something went wrong
		qdel(SS)
		return
	user.visible_message("<span class='danger'>[user.name]'s soul is captured by \the [src]!</span>", "<span class='userdanger'>You've lost the gamble! Your soul is forfeit!</span>")

/obj/item/gun/projectile/revolver/capgun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up."
	origin_tech = null
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/cap

/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/gun/projectile/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	force = 10
	flags = CONDUCT
	slot_flags = SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	fire_sound = 'sound/weapons/gunshots/1shotgun_old.ogg'
	sawn_desc = "Omar's coming!"
	can_holster = FALSE
	unique_rename = TRUE
	unique_reskin = TRUE

/obj/item/gun/projectile/revolver/doublebarrel/New()
	..()
	options["Default"] = "dshotgun"
	options["Dark Red Finish"] = "dshotgun-d"
	options["Ash"] = "dshotgun-f"
	options["Faded Grey"] = "dshotgun-g"
	options["Maple"] = "dshotgun-l"
	options["Rosewood"] = "dshotgun-p"
	options["Cancel"] = null

/obj/item/gun/projectile/revolver/doublebarrel/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()
	if(istype(A, /obj/item/melee/energy))
		var/obj/item/melee/energy/W = A
		if(W.active)
			sawoff(user)
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)
	else
		return ..()

/obj/item/gun/projectile/revolver/doublebarrel/sawoff(mob/user)
    . = ..()
    weapon_weight = WEAPON_MEDIUM

/obj/item/gun/projectile/revolver/doublebarrel/attack_self(mob/living/user)
	var/num_unloaded = 0
	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(loc)
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		playsound(get_turf(CB), 'sound/weapons/gun_interactions/shotgun_fall.ogg', 70, 1)
		num_unloaded++
	if(num_unloaded)
		to_chat(user, "<span class = 'notice'>You break open \the [src] and unload [num_unloaded] shell\s.</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")

// IMPROVISED SHOTGUN //

/obj/item/gun/projectile/revolver/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	fire_sound = 'sound/weapons/gunshots/1shotgunpipe.ogg'
	sawn_desc = "I'm just here for the gasoline."
	unique_rename = FALSE
	unique_reskin = FALSE
	var/slung = 0

/obj/item/gun/projectile/revolver/doublebarrel/improvised/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_state)
		var/obj/item/stack/cable_coil/C = A
		if(C.use(10))
			slot_flags = SLOT_BACK
			icon_state = "ishotgunsling"
			to_chat(user, "<span class='notice'>You tie the lengths of cable to the shotgun, making a sling.</span>")
			slung = 1
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need at least ten lengths of cable if you want to make a sling.</span>")
			return
	else
		return ..()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/update_icon()
	..()
	if(slung && (slot_flags & SLOT_BELT) )
		slung = 0
		icon_state = "ishotgun-sawn"

/obj/item/gun/projectile/revolver/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(get_turf(src), 10)
		slung = 0
		update_icon()

//caneshotgun

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane
	name = "cane"
	desc = "A cane used by a true gentleman. Or a clown."
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "cane"
	item_state = "stick"
	sawn_state = SAWN_OFF
	w_class = WEIGHT_CLASS_SMALL
	force = 10
	can_unsuppress = 0
	slot_flags = null
	origin_tech = "" // NO GIVAWAYS
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised/cane
	sawn_desc = "I'm sorry, but why did you saw your cane in the first place?"
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")
	fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
	suppressed = 1
	needs_permit = 0 //its just a cane beepsky.....

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/is_crutch()
	return 1

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/update_icon()
	return

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/stack/cable_coil))
		return
	else
		return ..()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/examine(mob/user) // HAD TO REPEAT EXAMINE CODE BECAUSE GUN CODE DOESNT STEALTH
	var/f_name = "\a [src]."
	if(blood_DNA && !istype(src, /obj/effect/decal))
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		f_name += "<span class='danger'>blood-stained</span> [name]!"

	. = list("[bicon(src)] That's [f_name]")

	if(desc)
		. += desc
