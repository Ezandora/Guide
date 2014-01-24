
void QLevel12Init()
{
	//questL12War
	//fratboysDefeated, hippiesDefeated
	//sidequestArenaCompleted, sidequestFarmCompleted, sidequestJunkyardCompleted, sidequestLighthouseCompleted, sidequestNunsCompleted, sidequestOrchardCompleted
	//warProgress
	
	//Sidequests:
	//state_boolean["Lighthouse Finished"]
	//state_boolean["Orchard Finished"]
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL12War");
	state.quest_name = "Island War Quest";
	state.image_name = "island war";
	state.council_quest = true;
	
	state.state_boolean["Arena Finished"] = (get_property("sidequestArenaCompleted") != "none");
	state.state_boolean["Farm Finished"] = (get_property("sidequestFarmCompleted") != "none");
	state.state_boolean["Junkyard Finished"] = (get_property("sidequestJunkyardCompleted") != "none");
	state.state_boolean["Lighthouse Finished"] = (get_property("sidequestLighthouseCompleted") != "none");
	state.state_boolean["Nuns Finished"] = (get_property("sidequestNunsCompleted") != "none");
	state.state_boolean["Orchard Finished"] = (get_property("sidequestOrchardCompleted") != "none");
    
    state.state_int["hippies left on battlefield"] = 1000 - get_property_int("hippiesDefeated");
    state.state_int["frat boys left on battlefield"] = 1000 - get_property_int("fratboysDefeated");
	
	if (state.finished)
	{
		state.state_boolean["Arena Finished"] = true;
		state.state_boolean["Farm Finished"] =  true;
		state.state_boolean["Junkyard Finished"] = true;
		state.state_boolean["Lighthouse Finished"] = true;
		state.state_boolean["Nuns Finished"] = true;
		state.state_boolean["Orchard Finished"] = true;
	}
	
	if (false)
	{
		//Internal debugging:
		state.state_boolean["Arena Finished"] = false;
		state.state_boolean["Farm Finished"] =  false;
		state.state_boolean["Junkyard Finished"] = false;
		state.state_boolean["Lighthouse Finished"] = false;
		state.state_boolean["Nuns Finished"] = false;
		state.state_boolean["Orchard Finished"] = false;
	}
	
	if (my_level() >= 12 && $location[The Palindome].turnsAttemptedInLocation() > 0)
		state.startable = true;
    
	__quest_state["Level 12"] = state;
	__quest_state["Island War"] = state;
}

void QLevel12GenerateTasksSidequests(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Level 12"];
	if (!base_quest_state.state_boolean["Orchard Finished"])
	{
		string [int] details;
		string [int] modifiers;
	
        string url = "bigisland.php?place=orchard";
		modifiers.listAppend("+1000% item");
		if (__misc_state["yellow ray potentially available"])
			modifiers.listAppend("potential YR");
	
        boolean need_gland = false;
		if ($item[heart of the filthworm queen].available_amount() > 0)
		{
			modifiers.listClear();
			details.listAppend("Go talk to the hippies to complete quest.");
		}
		else if ($effect[Filthworm Guard Stench].have_effect() > 0 || $item[Filthworm royal guard scent gland].available_amount() > 0)
		{
			if ($effect[Filthworm Guard Stench].have_effect() == 0)
            {
                url = "inventory.php?which=3";
				details.listAppend("Use filthworm royal guard scent gland");
            }
			modifiers.listClear();
			details.listAppend("Defeat the filthworm queen in the queen's chamber.");
		}
		else if ($effect[Filthworm Drone Stench].have_effect() > 0 || $item[Filthworm drone scent gland].available_amount() > 0)
		{
			if ($effect[Filthworm Drone Stench].have_effect() == 0)
            {
                url = "inventory.php?which=3";
				details.listAppend("Use filthworm drone scent gland");
            }
			details.listAppend("Adventure with +item in the guards' chamber.");
            need_gland = true;
		}
		else if ($effect[Filthworm Larva Stench].have_effect() > 0 || $item[filthworm hatchling scent gland].available_amount() > 0)
		{
			if ($effect[Filthworm Larva Stench].have_effect() == 0)
            {
                url = "inventory.php?which=3";
				details.listAppend("Use filthworm hatchling scent gland");
            }
			details.listAppend("Adventure with +item in the feeding chamber.");
            need_gland = true;
		}
		else
		{
			details.listAppend("Adventure with +item in the hatching chamber.");
            need_gland = true;
		}
        
        if (need_gland)
        {
            float effective_item_drop = item_drop_modifier() / 100.0;
            //FIXME take into account pickpocketing, init, etc.
            float average_glands_found_per_combat = MIN(1.0, (effective_item_drop + 1.0) * 0.1);
            float turns_per_gland = -1.0;
            if (average_glands_found_per_combat != 0.0)
                turns_per_gland = 1.0 / average_glands_found_per_combat;
            details.listAppend("~" + roundForOutput(turns_per_gland, 1) + " turns per gland.");
        }
	
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Orchard", url, ChecklistSubentryMake("Island War Orchard Quest", modifiers, details), $locations[the hatching chamber, the feeding chamber, the royal guard chamber, the filthworm queen's chamber]));
	}
	if (!base_quest_state.state_boolean["Farm Finished"])
	{
		string [int] details;
		details.listAppend("Great flappin' beasts, with webbed feet and bills! dooks!");
        
        string [int] tasks;
        int ncs_seen = $location[McMillicancuddy's Barn].noncombatTurnsAttemptedInLocation();
        
        if (ncs_seen < 1)
            tasks.listAppend("make a fence out of the barbed wire");
        if (ncs_seen < 2)
            tasks.listAppend("knock over the lantern");
        if (ncs_seen < 3)
        {
            tasks.listAppend("dump out the drum");
            details.listAppend("Remember to use a chaos butterfly in combat before clearing the barn.|Then " + tasks.listJoinComponents(", ", "and") + ".");
        }
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Farm", "bigisland.php?place=farm", ChecklistSubentryMake("Island War Farm Quest", "+meat", details), $locations[mcmillicancuddy's farm,mcmillicancuddy's barn,mcmillicancuddy's pond,mcmillicancuddy's back 40,mcmillicancuddy's other back 40,mcmillicancuddy's granary,mcmillicancuddy's bog,mcmillicancuddy's family plot,mcmillicancuddy's shady thicket]));
	}
	if (!base_quest_state.state_boolean["Nuns Finished"])
	{
		string [int] details;
		int meat_gotten = get_property_int("currentNunneryMeat");
		int meat_remaining = 100000 - meat_gotten;
		details.listAppend(meat_remaining + " meat remaining");
	
		float meat_drop_multiplier = meat_drop_modifier() / 100.0 + 1.0;
		vec2i brigand_meat_drop_range = vec2iMake(800 * meat_drop_multiplier, 1200 * meat_drop_multiplier);
		vec2i turn_range;
		if (brigand_meat_drop_range.x != 0 && brigand_meat_drop_range.y != 0)
			turn_range = vec2iMake(ceil(to_float(meat_remaining) / to_float(brigand_meat_drop_range.y)),
			ceil(to_float(meat_remaining) / to_float(brigand_meat_drop_range.x)));
		
		//FIXME consider looking into tracking how long until the semi-rare item runs out, for turn calculation
		if (turn_range.x == turn_range.y)
			details.listAppend(pluralize(turn_range.x, "turn", "turns") + " remaining");
		else
			details.listAppend("[" + turn_range.x + " to " + turn_range.y + "] turns remaining");
            
        if ($effect[Sinuses For Miles].have_effect() > 0 && get_property_int("lastTempleAdventures") != my_ascensions() && $item[stone wool].available_amount() > 0)
            details.listAppend("Potentially use stone wool and visit the hidden temple to extend Sinuses for Miles for 3 turns.");
	
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Nuns", "bigisland.php?place=nunnery", ChecklistSubentryMake("Island War Nuns Quest", "+meat", details), $locations[the themthar hills]));
	}
	if (!base_quest_state.state_boolean["Junkyard Finished"])
	{
		string [int] details;
		if ($item[molybdenum magnet].available_amount() == 0)
		{
			details.listAppend("Talk to Yossarian first.");
		}
		else
		{
			location [item] items_and_locations;
			items_and_locations[$item[molybdenum hammer]] = $location[Next to that Barrel with Something Burning in it];
			items_and_locations[$item[molybdenum screwdriver]] = $location[Out By that Rusted-Out Car];
			items_and_locations[$item[molybdenum pliers]] = $location[Near an Abandoned Refrigerator];
			items_and_locations[$item[molybdenum crescent wrench]] = $location[Over Where the Old Tires Are];
			boolean have_all = true;
			foreach it in items_and_locations
			{
				location loc = items_and_locations[it];
				if (it.available_amount() > 0)
				{
					continue;
				}
				else
					have_all = false;
				details.listAppend("Adventure " + to_lower_case(to_string(loc)) + ".");
			}
			if (have_all)
				details.listAppend("Talk to Yossarian to complete quest.");
			else
            {
                if ($item[seal tooth].available_amount() == 0 && !$skill[suckerpunch].have_skill())
                    details.listAppend("Acquire a seal tooth to stasis gremlins. (from hermit)");
                if (!$monster[a.m.c. gremlin].is_banished())
                    details.listAppend("Potentially banish A.M.C. Gremlin.");
            }
		}
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Junkyard", "bigisland.php?place=junkyard", ChecklistSubentryMake("Island War Junkyard Quest", listMake("+DR", "+HP"), details), $locations[next to that barrel with something burning in it,near an abandoned refrigerator,over where the old tires are,out by that rusted-out car]));
	}
	if (!base_quest_state.state_boolean["Lighthouse Finished"])
	{
		string [int] details;
	
		details.listAppend($item[barrel of gunpowder].available_amount() + "/5 barrels of gunpowder found.");
        
        int gunpowder_needed = MAX(0, 5 - $item[barrel of gunpowder].available_amount());
        
        
        if (gunpowder_needed > 0)
        {
            float effective_combat_rate = clampNormalf(0.1 + combat_rate_modifier() / 100.0);
            float turns_per_lobster = -1.0;
            if (effective_combat_rate != 0.0)
                turns_per_lobster = 1.0 / effective_combat_rate;
            if (effective_combat_rate <= 0.0)
            {
                details.listAppend("Cannot complete at " + combat_rate_modifier().floor() + "% combat.");
            }
            else
            {
                float turns_to_complete = gunpowder_needed.to_float() * turns_per_lobster;
                details.listAppend("~" + roundForOutput(turns_to_complete, 1) + " turns to complete quest at " + combat_rate_modifier().floor() + "% combat.|~" + roundForOutput(turns_per_lobster, 1) + " turns per lobster.");
            }
            
        }
	
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Lighthouse", "bigisland.php?place=lighthouse", ChecklistSubentryMake("Island War Lighthouse Quest", listMake("+combat", "copies"), details), $locations[sonofa beach]));
	}
	if (!base_quest_state.state_boolean["Arena Finished"])
	{
		string [int] modifiers;
		modifiers.listAppend("+ML");
		float percent_done = clampf(get_property_int("flyeredML") / 10000.0 * 100.0, 0.0, 100.0);
		int ml_remaining = 10000 - get_property_int("flyeredML");
		string [int] details;
		if (percent_done >= 100.0)
		{
			modifiers.listClear();
			details.listAppend("Turn in quest.");
		}
		else
		{
			if ($item[jam band flyers].available_amount() == 0 && $item[rock band flyers].available_amount() == 0)
				details.listAppend("Acquire fliers");
			details.listAppend("Flyer places around the kingdom (" + round(percent_done, 1) + "% ML completed, " + ml_remaining + " ML remains)");
		}
	
        //Normally, this would be bigisland.php?place=concert
        //But that could theoretically complete the quest for the wrong side, if they're wearing the wrong uniform and misclick.
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Arena", "bigisland.php", ChecklistSubentryMake("Island War Arena Quest", modifiers, details)));
		
		if (ml_remaining > 0 && ($item[jam band flyers].available_amount() > 0 || $item[rock band flyers].available_amount() > 0))
		{
			item it = $item[jam band flyers];
			if ($item[rock band flyers].available_amount() > 0 && $item[jam band flyers].available_amount() == 0)
				it = $item[rock band flyers];
			task_entries.listAppend(ChecklistEntryMake(it, "", ChecklistSubentryMake("Flyer with " + it + " every combat", "+ML", details), -11));
		}
	}
}

void QLevel12GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 12"].in_progress)
		return;
	
	QuestState base_quest_state = __quest_state["Level 12"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	
	
	task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "island.php", subentry, $locations[the battlefield (frat uniform), the battlefield (hippy uniform), wartime frat house, wartime frat house (hippy disguise), wartime hippy camp, wartime hippy camp (frat disguise)]));
	if (base_quest_state.mafia_internal_step < 2)
	{
		subentry.modifiers.listAppend("-combat");
		subentry.entries.listAppend("Start the war!");
		if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues"))
		{
            //FIXME suggest routes to doing both.
			subentry.entries.listAppend("Need either the war hippy fatigues or frat warrior fatigues outfit.");
		}
		else
        {
            //FIXME point out they need to level myst or whatever if necessary
			subentry.entries.listAppend("Wear war outfit, run -combat, adventure in other side's camp.");
        }
	}
	else
	{
		int sides_completed_hippy = 0;
		int sides_completed_frat = 0;
		
		string [int] sidequest_properties = split_string_mutable("sidequestArenaCompleted,sidequestFarmCompleted,sidequestJunkyardCompleted,sidequestLighthouseCompleted,sidequestNunsCompleted,sidequestOrchardCompleted", ",");
		foreach key in sidequest_properties
		{
			string property_value = get_property(sidequest_properties[key]);
			if (property_value == "hippy")
				sides_completed_hippy += 1;
			else if (property_value == "fratboy")
				sides_completed_frat += 1;
		}
		int frat_boys_left = base_quest_state.state_int["frat boys left on battlefield"];
		int hippies_left = base_quest_state.state_int["hippies left on battlefield"];
		
		int frat_boys_defeated_per_combat = powi(2, sides_completed_hippy);
		int hippies_defeated_per_combat = powi(2, sides_completed_frat);
		
		if (frat_boys_left < 1000 || (frat_boys_left == 1000 && hippies_left == 1000))
		{
			string line;
			if (frat_boys_left == 0)
				line = "No frat boys";
			else
				line = pluralize(frat_boys_left, "frat boy", "frat boys");
			line += " left.";
			int turns_remaining = ceiling(frat_boys_left.to_float() / frat_boys_defeated_per_combat.to_float());
			if (turns_remaining > 0)
			{
				line += "|*" + pluralize(turns_remaining, "turn", "turns") + " remaining.";
				line += " " + pluralize(frat_boys_defeated_per_combat, "frat boy", "frat boys") + " defeated per combat.";
			}
			subentry.entries.listAppend(line);
		}
		if (hippies_left < 1000 || (frat_boys_left == 1000 && hippies_left == 1000))
		{
			string line;
			if (hippies_left == 0)
				line = "No hippies";
			else
				line = pluralize(hippies_left, "hippy", "hippies");
			line += " left.";
			int turns_remaining = ceiling(hippies_left.to_float() / hippies_defeated_per_combat.to_float());
			if (turns_remaining > 0)
			{
				line += "|*" + pluralize(turns_remaining, "turn", "turns") + " remaining.";
				line += " " + pluralize(hippies_defeated_per_combat, "hippy", "hippies") + " defeated per combat.";
			}
			subentry.entries.listAppend(line);
		}
		if (frat_boys_left == 1 && hippies_left == 1)
		{
			if ($item[flaregun].available_amount() > 0)
				subentry.entries.listAppend("Wossname time! Adventure on battlefield, use a flaregun.");
			else if (!in_hardcore())
				subentry.entries.listAppend("Pull a flaregun for wossname.");
			else if (__misc_state["fax accessible"])
				subentry.entries.listAppend("Fax smarmy pirate, run +234% item (or YR) for flaregun for wossname.");
			else
				subentry.entries.listAppend("That almost was a wossname, but you needed more flare.");
		}
		QLevel12GenerateTasksSidequests(task_entries, optional_task_entries, future_task_entries);
	}
	
}