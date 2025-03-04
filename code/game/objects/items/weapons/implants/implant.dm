/obj/item/implant
	name = "implant"
	icon = 'icons/obj/implants.dmi'
	icon_state = "generic" //Shows up as the action button icon
	origin_tech = "materials=2;biotech=3;programming=2"

	actions_types = list(/datum/action/item_action/hands_free/activate)
	var/activated = 1 //1 for implant types that can be activated, 0 for ones that are "always on" like mindshield implants
	var/implanted = null
	var/mob/living/imp_in = null
	item_color = "b"
	var/allow_multiple = 0
	var/uses = -1
	flags = DROPDEL


/obj/item/implant/proc/trigger(emote, mob/source, force)
	return

/obj/item/implant/proc/activate()
	return

/obj/item/implant/ui_action_click()
	activate("action_button")


/**
 * Try to implant ourselves into a mob.
 *
 * * source - The person the implant is being administered to.
 * * user - The person who is doing the implanting.
 *
 * Returns
 * 	`TRUE` if the implant injects successfully
 *  `FALSE` if the implant fails to inject
 */
/obj/item/implant/proc/implant(mob/source, mob/user)
	var/obj/item/implant/imp_e = locate(src.type) in source
	if(!allow_multiple && imp_e && imp_e != src)
		if(imp_e.uses < initial(imp_e.uses)*2)
			if(uses == -1)
				imp_e.uses = -1
			else
				imp_e.uses = min(imp_e.uses + uses, initial(imp_e.uses)*2)
			qdel(src)
			return TRUE
		else
			return FALSE

	src.loc = source
	imp_in = source
	implanted = TRUE
	if(activated)
		for(var/X in actions)
			var/datum/action/A = X
			A.Grant(source)
	if(ishuman(source))
		var/mob/living/carbon/human/H = source
		H.sec_hud_set_implants()

	if(user)
		add_attack_logs(user, source, "Implanted with [src]")

	return TRUE


/obj/item/implant/proc/removed(mob/source)
	loc = null
	imp_in = null
	implanted = FALSE

	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(source)

	if(ishuman(source))
		var/mob/living/carbon/human/H = source
		H.sec_hud_set_implants()

	return TRUE


/obj/item/implant/Destroy()
	if(imp_in)
		removed(imp_in)
	return ..()


/obj/item/implant/proc/get_data()
	return "No information available"

/obj/item/implant/dropped(mob/user)
	. = 1
	..()
