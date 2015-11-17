import "relay/Guide/Support/Item Filter.ash"

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
    state.state_boolean["War started"] = (state.mafia_internal_step >= 2);
    state.state_boolean["War in progress"] = state.state_boolean["War started"] && !state.finished;
    
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
    int quests_completed_hippy = 0;
    int quests_completed_frat = 0;
    
    foreach s in $strings[sidequestArenaCompleted,sidequestFarmCompleted,sidequestJunkyardCompleted,sidequestLighthouseCompleted,sidequestNunsCompleted,sidequestOrchardCompleted]
    {
        string property_value = get_property(s);
        if (property_value == "hippy")
            quests_completed_hippy += 1;
        else if (property_value == "fratboy")
            quests_completed_frat += 1;
    }
    
    state.state_int["Quests completed for hippies"] = quests_completed_hippy;
    state.state_int["Quests completed for frat boys"] = quests_completed_frat;
    
    if (!state.finished)
    {
        //define state.state_string["Side seemingly fighting for"]
        //"hippy", "frat boys", "both", ""
        
        if (state.state_int["Quests completed for hippies"] > 0)
            state.state_string["Side seemingly fighting for"] = "hippy";
        if (state.state_int["Quests completed for frat boys"] > 0)
            state.state_string["Side seemingly fighting for"] = "frat boys";
        
        if (state.state_int["hippies left on battlefield"] == 1000 && state.state_int["frat boys left on battlefield"] != 1000)
            state.state_string["Side seemingly fighting for"] = "hippy";
        if (state.state_int["hippies left on battlefield"] != 1000 && state.state_int["frat boys left on battlefield"] == 1000)
            state.state_string["Side seemingly fighting for"] = "frat boys";
        if (state.state_int["hippies left on battlefield"] != 1000 && state.state_int["frat boys left on battlefield"] != 1000)
            state.state_string["Side seemingly fighting for"] = "both";
        if (state.state_int["Quests completed for hippies"] > 0 && state.state_int["Quests completed for frat boys"] > 0)
            state.state_string["Side seemingly fighting for"] = "both";
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
	
	if (my_level() >= 12)
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
	
        location next_location;
        monster pickpocket_monster = $monster[none];
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
            modifiers.listAppend("+meat");
			details.listAppend("Defeat the filthworm queen in the queen's chamber.");
            next_location = $location[the filthworm queen's chamber];
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
            pickpocket_monster = $monster[filthworm royal guard];
            next_location = $location[the royal guard chamber];
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
            pickpocket_monster = $monster[filthworm drone];
            next_location = $location[the feeding chamber];
		}
		else
		{
			details.listAppend("Adventure with +item in the hatching chamber.");
            need_gland = true;
            pickpocket_monster = $monster[larval filthworm];
            next_location = $location[the hatching chamber];
		}
        
        if (__misc_state["can pickpocket"] && pickpocket_monster != $monster[none])
        {
            int total_initiative_needed = pickpocket_monster.base_initiative;
            int initiative_needed = total_initiative_needed - initiative_modifier();
            if (initiative_needed > 0)
                details.listAppend("Need " + initiative_needed + "% more initiative to pickpocket every turn.");
        }
        
        if (need_gland)
        {
            float effective_item_drop = next_location.item_drop_modifier_for_location() / 100.0;
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
		string [int] modifiers;
        modifiers.listAppend("+meat");
        
        string [int] tasks;
        int ncs_seen = $location[McMillicancuddy's Barn].noncombatTurnsAttemptedInLocation();
        
        if (ncs_seen < 3)
        {
            tasks.listAppend("make a fence out of the barbed wire");
            tasks.listAppend("knock over the lantern");
            tasks.listAppend("dump out the drum");
            details.listAppend("Remember to use a chaos butterfly in combat before clearing the barn.|Then " + tasks.listJoinComponents(", ", "and") + ".");
            
            
            if (__misc_state["free runs available"])
                modifiers.listAppend("free runs in barn");
        }
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Farm", "bigisland.php?place=farm", ChecklistSubentryMake("Island War Farm Quest", modifiers, details), $locations[mcmillicancuddy's farm,mcmillicancuddy's barn,mcmillicancuddy's pond,mcmillicancuddy's back 40,mcmillicancuddy's other back 40,mcmillicancuddy's granary,mcmillicancuddy's bog,mcmillicancuddy's family plot,mcmillicancuddy's shady thicket]));
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
			details.listAppend(pluralise(turn_range.x, "turn", "turns") + " remaining");
		else
			details.listAppend("[" + turn_range.x + " to " + turn_range.y + "] turns remaining");
        
        if ($item[ice nine].available_amount() == 0 && __misc_state["can equip just about any weapon"] && $item[ice harvest].available_amount() >= 9 && $item[ice nine].is_unrestricted()) //is this safe? unfinished ice sculpture is really nice, and ice bucket in sneaky pete...
            details.listAppend("Possibly make and equip an ice nine. (+30% meat 1h weapon)");
                
        if ($effect[Sinuses For Miles].have_effect() > 0 && get_property_int("lastTempleAdventures") != my_ascensions() && $item[stone wool].available_amount() > 0 && get_property_int("lastTempleUnlock") == my_ascensions())
            details.listAppend("Potentially use stone wool and visit the hidden temple to extend Sinuses for Miles for 3 turns.");
        
        
        if (my_path_id() == PATH_HEAVY_RAINS && $skill[Make it Rain].skill_is_usable() && turn_range.y > 1)
            details.listAppend("Cast Make it Rain each fight. (+300%? meat)");
        if ($item[Sneaky Pete's leather jacket (collar popped)].equipped_amount() > 0 && turn_range.y > 1)
            details.listAppend("Could unpop your collar. (+20% meat)");
	
        if (__misc_state_int["pulls available"] > 0 && meat_drop_modifier() < 1000.0)
        {
            int limit = 100;
            if (meat_drop_modifier() < 600.0)
                limit = 50;
            boolean [item] blacklist = $items[uncle greenspan's bathroom finance guide,black snowcone];
            item [int] relevant_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Meat Drop", limit, blacklist);
            string [int] relevant_potions_output;
            foreach key, it in relevant_potions
            {
                relevant_potions_output.listAppend(it + " (" + it.to_effect().numeric_modifier("meat drop").roundForOutput(0) + "%)");
            }
            
            if (relevant_potions_output.count() > 0)
                details.listAppend("Could try pulling " + relevant_potions_output.listJoinComponents(", ", "or") + ".");
        }
        
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
			items_and_locations[$item[molybdenum pliers]] = $location[Near an Abandoned Refrigerator];
			items_and_locations[$item[molybdenum crescent wrench]] = $location[Over Where the Old Tires Are];
			items_and_locations[$item[molybdenum screwdriver]] = $location[Out By that Rusted-Out Car];
			boolean have_all = true;
            
            string [location][int] location_monsters;
            location_monsters[$location[Next to that Barrel with Something Burning in it]] = listMake("tool batwinged", "vegetable");
            location_monsters[$location[Out By that Rusted-Out Car]] = listMake("tool vegetable", "erudite");
            location_monsters[$location[Near an Abandoned Refrigerator]] = listMake("tool spider", "batwinged");
            location_monsters[$location[Over Where the Old Tires Are]] = listMake("tool erudite", "spider");
            
            location [int][monster] banishment_locations; //it's time we had a talk... about your hair! it's gone too far!
            banishment_locations[1][$monster[batwinged gremlin]] = $location[Near an Abandoned Refrigerator];
            banishment_locations[1][$monster[erudite gremlin]] = $location[Out By that Rusted-Out Car];
            banishment_locations[1][$monster[spider gremlin]] = $location[Over Where the Old Tires Are];
            banishment_locations[1][$monster[vegetable gremlin]] = $location[Next to that Barrel with Something Burning in it];
            
            
            banishment_locations[0][$monster[batwinged gremlin]] = $location[Next to that Barrel with Something Burning in it];
            banishment_locations[0][$monster[erudite gremlin]] = $location[Over Where the Old Tires Are];
            banishment_locations[0][$monster[spider gremlin]] = $location[Near an Abandoned Refrigerator];
            banishment_locations[0][$monster[vegetable gremlin]] = $location[Out By that Rusted-Out Car];
            
            foreach key in banishment_locations
            {
                foreach m in banishment_locations[key]
                {
                    if (!m.is_banished())
                        continue;
                    location l = banishment_locations[key][m];
                    
                    if (key == 0 && location_monsters[l][key].contains_text("tool "))
                        location_monsters[l][key] = "tool " + HTMLGenerateSpanFont(location_monsters[l][key].replace_string("tool ", ""), "grey", "");
                    else
                        location_monsters[l][key] = HTMLGenerateSpanFont(location_monsters[l][key], "grey");
                }
            }


            
            item [int] item_display_order = listMake($item[molybdenum hammer],$item[molybdenum pliers],$item[molybdenum crescent wrench],$item[molybdenum screwdriver]); //make a path
            string [int] areas_left_strings;
			//foreach it in items_and_locations
            
            string [location] location_shorthand_name;
            location_shorthand_name[$location[Next to that Barrel with Something Burning in it]] = "Barrel";
            location_shorthand_name[$location[Out By that Rusted-Out Car]] = "Car";
            location_shorthand_name[$location[Near an Abandoned Refrigerator]] = "Refrigerator";
            location_shorthand_name[$location[Over Where the Old Tires Are]] = "Tires";
            
            foreach key in item_display_order
			{
                item it = item_display_order[key];
				location loc = items_and_locations[it];
				if (it.available_amount() > 0)
				{
					continue;
				}
				else
					have_all = false;
                
                string location_display_name;
                if (location_shorthand_name contains loc)
                    location_display_name = location_shorthand_name[loc];
                else
                    location_display_name = loc.to_string().to_lower_case();
                    
                areas_left_strings.listAppend("<strong>" + location_display_name + "</strong> - " + location_monsters[loc].listJoinComponents(", "));
			}
            if (areas_left_strings.count() > 0)
                details.listAppend("Areas left:|*" + areas_left_strings.listJoinComponents("<hr>|*"));
			if (have_all)
				details.listAppend("Talk to Yossarian to complete quest.");
			else
            {
                if ($item[dictionary].available_amount() > 0)
                {
                    details.listAppend("Read from the dictionary to stasis gremlins.");
                }
                else if ($item[facsimile dictionary].available_amount() > 0)
                {
                    details.listAppend("Read from the facsimile dictionary to stasis gremlins.");
                }
                else if ($item[seal tooth].available_amount() > 0)
                {
                    details.listAppend("Use your seal tooth to stasis gremlins.");
                }
                else if ($skill[suckerpunch].skill_is_usable())
                {
                    details.listAppend("Cast suckerpunch to stasis gremlins.");
                }
                else
                    details.listAppend(HTMLGenerateSpanFont("Acquire a seal tooth", "red") + " to stasis gremlins. (from hermit)");
                if (!$monster[a.m.c. gremlin].is_banished())
                    details.listAppend("Potentially banish A.M.C. Gremlin.");
            }
		}
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Junkyard", "bigisland.php?place=junkyard", ChecklistSubentryMake("Island War Junkyard Quest", listMake("+DR", "+DA", "+HP", "+moxie"), details), $locations[next to that barrel with something burning in it,near an abandoned refrigerator,over where the old tires are,out by that rusted-out car]));
	}
	if (!base_quest_state.state_boolean["Lighthouse Finished"])
	{
		string [int] details;
	
        int gunpowder_needed = MAX(0, 5 - $item[barrel of gunpowder].available_amount());
        
        
        string [int] modifiers;
        if (gunpowder_needed > 0)
        {
            modifiers = listMake("+combat", "copies");
            if (gunpowder_needed == 1)
                details.listAppend("Need " + gunpowder_needed + " more barrel of gunpowder.");
            else
                details.listAppend("Need " + gunpowder_needed + " more barrels of gunpowder.");
            
            
            
            //this is an approximation:
            //off by a little over half a turn on average
            float effective_combat_rate = (11.0 / 12.0) * clampNormalf(0.1 + combat_rate_modifier() / 100.0) + (1.0 / 12.0) * 1.0;
            float turns_per_lobster = -1.0;
            if (effective_combat_rate != 0.0)
                turns_per_lobster = 1.0 / effective_combat_rate;
                
            
            float turns_to_complete = gunpowder_needed.to_float() * turns_per_lobster;
            
            //I had the data lying around, so why not?
            //misses <-10 and >30, but the estimate above will catch that
            float [int][int] lfm_simulation_data;
            lfm_simulation_data[5][-10] = 60.00; lfm_simulation_data[5][-5] = 40.02; lfm_simulation_data[5][0] = 29.92; lfm_simulation_data[5][5] = 23.84; lfm_simulation_data[5][10] = 19.76; lfm_simulation_data[5][15] = 16.84; lfm_simulation_data[5][20] = 14.66; lfm_simulation_data[5][25] = 13.00; lfm_simulation_data[4][-10] = 48.00; lfm_simulation_data[4][-5] = 32.27; lfm_simulation_data[4][0] = 24.20; lfm_simulation_data[4][5] = 19.29; lfm_simulation_data[4][10] = 16.00; lfm_simulation_data[4][15] = 13.68; lfm_simulation_data[4][20] = 11.96; lfm_simulation_data[4][25] = 10.63; lfm_simulation_data[3][-10] = 36.00; lfm_simulation_data[3][-5] = 24.53; lfm_simulation_data[3][0] = 18.47; lfm_simulation_data[3][5] = 14.78; lfm_simulation_data[3][10] = 12.34; lfm_simulation_data[3][15] = 10.59; lfm_simulation_data[3][20] = 9.26; lfm_simulation_data[3][25] = 8.20; lfm_simulation_data[2][-10] = 24.00; lfm_simulation_data[2][-5] = 16.79; lfm_simulation_data[2][0] = 12.84; lfm_simulation_data[2][5] = 10.38; lfm_simulation_data[2][10] = 8.68; lfm_simulation_data[2][15] = 7.40; lfm_simulation_data[2][20] = 6.40; lfm_simulation_data[2][25] = 5.60; lfm_simulation_data[1][-10] = 12.00; lfm_simulation_data[1][-5] = 9.19; lfm_simulation_data[1][0] = 7.17; lfm_simulation_data[1][5] = 5.72; lfm_simulation_data[1][10] = 4.66; lfm_simulation_data[1][15] = 3.87; lfm_simulation_data[1][20] = 3.29; lfm_simulation_data[1][25] = 2.84; lfm_simulation_data[5][26] = 12.71; lfm_simulation_data[5][27] = 12.44; lfm_simulation_data[5][28] = 12.18; lfm_simulation_data[5][29] = 11.93; lfm_simulation_data[5][30] = 11.69; lfm_simulation_data[4][26] = 10.40; lfm_simulation_data[4][27] = 10.17; lfm_simulation_data[4][28] = 9.96; lfm_simulation_data[4][29] = 9.75; lfm_simulation_data[4][30] = 9.56; lfm_simulation_data[3][26] = 8.01; lfm_simulation_data[3][27] = 7.83; lfm_simulation_data[3][28] = 7.65; lfm_simulation_data[3][29] = 7.48; lfm_simulation_data[3][30] = 7.32; lfm_simulation_data[2][26] = 5.46; lfm_simulation_data[2][27] = 5.33; lfm_simulation_data[2][28] = 5.20; lfm_simulation_data[2][29] = 5.07; lfm_simulation_data[2][30] = 4.96; lfm_simulation_data[1][26] = 2.76; lfm_simulation_data[1][27] = 2.69; lfm_simulation_data[1][28] = 2.62; lfm_simulation_data[1][29] = 2.56; lfm_simulation_data[1][30] = 2.50;
            
            if (lfm_simulation_data[gunpowder_needed] contains combat_rate_modifier().to_int())
            {
                turns_to_complete = lfm_simulation_data[gunpowder_needed][combat_rate_modifier().to_int()];
                if (gunpowder_needed != 0.0)
                    turns_per_lobster = turns_to_complete / gunpowder_needed.to_float();
            }
            
            details.listAppend("~" + roundForOutput(turns_to_complete, 1) + " turns to complete quest at " + combat_rate_modifier().floor() + "% combat.|~" + roundForOutput(turns_per_lobster, 1) + " turns per lobster.");
        }
        else
            details.listAppend("Talk to the lighthouse keeper to finish quest.");
	
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Lighthouse", "bigisland.php?place=lighthouse", ChecklistSubentryMake("Island War Lighthouse Quest", modifiers, details), $locations[sonofa beach]));
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
				details.listAppend("Acquire fliers.");
            details.listAppend(round(percent_done, 1) + "% ML completed, " + ml_remaining + " ML remains.");
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


void QLevel12GenerateBattlefieldDescription(ChecklistSubentry subentry, string side, int enemies_remaining, int enemies_defeated_per_combat, string enemy_name, string enemy_name_plural, string boss_name, string [int] sidequest_list, string [int] base_sidequest_list)
{
    if (enemies_defeated_per_combat == 0)
        return;
    
    int enemies_defeated = 1000 - enemies_remaining;
    string line;
    if (enemies_remaining > 0)
    {
        line = pluralise(enemies_remaining, enemy_name, enemy_name_plural) + " left.";
    }
    else
        line += "Fight " + boss_name + "!";
    
    string outfit_name;
    if (side == "hippy")
        outfit_name = "War Hippy Fatigues";
    if (side == "frat boy")
        outfit_name = "Frat Warrior Fatigues";
    
    if (outfit_name != "")
    {
        item [int] missing_outfit_components = missing_outfit_components(outfit_name);
        if (missing_outfit_components.count() > 0)
            line += "|*Missing outfit piece" + (missing_outfit_components.count() > 1 ? "s" : "") + " " + missing_outfit_components.listJoinComponents(", ", "and") + ".";
    }
    int turns_remaining = ceiling(enemies_remaining.to_float() / enemies_defeated_per_combat.to_float());
    if (turns_remaining > 0)
    {
        line += "|*" + pluralise(turns_remaining, "turn", "turns") + " remaining.";
        line += " " + pluralise(enemies_defeated_per_combat, enemy_name, enemy_name_plural) + " defeated per combat.";
    }
    int enemies_to_defeat_for_unlock = -1;
    string area_to_unlock = "";
    string [int] areas_unlocked_but_not_completed;
    
    foreach key in base_sidequest_list
    {
        if (!__quest_state["Level 12"].state_boolean[base_sidequest_list[key] + " Finished"])
        {
            areas_unlocked_but_not_completed.listAppend(base_sidequest_list[key]);
        }
    }
    
    if (my_path_id() != PATH_BUGBEAR_INVASION) //FIXME test against trendy bugbear chef being needed
    {
        if (side == "frat boy" && __misc_state["free runs usable"])
            subentry.modifiers.listAppend("possibly olfact Green Ops Soldier");
        else if (side == "hippy")
            subentry.modifiers.listAppend("possibly olfact Sorority Operator");
    }
    
    int [int] unlock_threshold;
    unlock_threshold[0] = 64;
    unlock_threshold[1] = 192;
    unlock_threshold[2] = 458;
    
    for i from 2 to 0 by -1
    {
        int threshold = unlock_threshold[i];
        if (!__quest_state["Level 12"].state_boolean[sidequest_list[i] + " Finished"])
        {
            if (enemies_defeated < threshold)
            {
                area_to_unlock = sidequest_list[i];
                enemies_to_defeat_for_unlock = threshold - enemies_defeated;
            }
            else
            {
                areas_unlocked_but_not_completed.listAppend(sidequest_list[i]);
            }
        }
    }
    
    if (enemies_to_defeat_for_unlock != -1)
    {
        int turns_to_reach = ceiling(enemies_to_defeat_for_unlock.to_float() / enemies_defeated_per_combat.to_float());
        line += "|*" + pluralise(turns_to_reach, "turn", "turns") + " (" + pluralise(enemies_to_defeat_for_unlock, enemy_name, enemy_name_plural) + ") to unlock " + area_to_unlock + ".";
    }
    
    if (areas_unlocked_but_not_completed.count() > 0)
        line += "|*Quests accessible: " + areas_unlocked_but_not_completed.listJoinComponents(", ", "and") + ".";
    
    subentry.entries.listAppend(line);
    
    if (enemies_remaining == 0)
    {
        string [int] items_to_turn_in_for;
        if (__quest_state["Level 13"].state_boolean["shadow will need to be defeated"])
        {
            if (side == "hippy")
                items_to_turn_in_for.listAppend("filthy poultices for shadow");
            else
                items_to_turn_in_for.listAppend("gauze garters for shadow");
        }
        
        string line2 = "Also, turn in gear to your home camp.";
        if (items_to_turn_in_for.count() > 0)
            line2 += " Acquire " + items_to_turn_in_for.listJoinComponents(", ", "and") + ", etc.";
        subentry.entries.listAppend(line2);
    }
}


void QLevel12GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 12"].in_progress)
		return;
	
	QuestState base_quest_state = __quest_state["Level 12"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	
	task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "island.php", subentry, $locations[the battlefield (frat uniform), the battlefield (hippy uniform), frat house, hippy camp, wartime frat house, wartime frat house (hippy disguise), wartime hippy camp, wartime hippy camp (frat disguise)]));
	if (base_quest_state.mafia_internal_step < 2)
	{
		subentry.modifiers.listAppend("-combat");
		subentry.entries.listAppend("Start the war!");
        
        float noncombat_rate = 1.0 - (.85 + combat_rate_modifier() / 100.0);
        float turns_remaining = -1.0;
        if (noncombat_rate != 0.0)
            turns_remaining = 3.0 / noncombat_rate;
        
        
		if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues"))
		{
            //FIXME suggest routes to doing both.
			subentry.entries.listAppend("Need either the war hippy fatigues or frat warrior fatigues outfit.");
            if ($familiar[slimeling].familiar_is_usable())
                subentry.modifiers.listAppend("slimeling?");
		}
		else
        {
            string [int] stats_needed;
            if (my_basestat($stat[moxie]) < 70)
                stats_needed.listAppend((70 - my_basestat($stat[moxie])) + " more moxie");
            if (my_basestat($stat[mysticality]) < 70)
                stats_needed.listAppend((70 - my_basestat($stat[mysticality])) + " more mysticality");
            if (stats_needed.count() == 0)
                subentry.entries.listAppend("Wear war outfit, run -combat, adventure in other side's camp.");
            else
                subentry.entries.listAppend("Acquire " + stats_needed.listJoinComponents(", ", "and") + " to wear war outfit.");
            
            
            //need 70 moxie, 70 myst
            
        }
        if ($item[talisman o' namsilat].available_amount() == 0 && !__quest_state["Level 11 Palindome"].finished)
        {
            subentry.entries.listAppend("May want to " + HTMLGenerateSpanFont("acquire the Talisman o' Nam", "red") + " first.");
        }
        
        subentry.entries.listAppend(generateTurnsToSeeNoncombat(85, 3, "start war"));
	}
	else
	{
		int sides_completed_hippy = base_quest_state.state_int["Quests completed for hippies"];
		int sides_completed_frat = base_quest_state.state_int["Quests completed for frat boys"];
		
        int frat_boys_left = base_quest_state.state_int["frat boys left on battlefield"];
		int hippies_left = base_quest_state.state_int["hippies left on battlefield"];
		
		int frat_boys_defeated_per_combat = powi(2, sides_completed_hippy);
		int hippies_defeated_per_combat = powi(2, sides_completed_frat);
        
        if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeCowling") == "Rocket Launcher")
        {
            frat_boys_defeated_per_combat += 3;
            hippies_defeated_per_combat += 3;
        }
        
        
        subentry.modifiers.listAppend("+item");
		if (hippies_left < 1000 || (frat_boys_left == 1000 && hippies_left == 1000) || sides_completed_frat > 0)
            QLevel12GenerateBattlefieldDescription(subentry, "frat boy", hippies_left, hippies_defeated_per_combat, "hippy", "hippies", "The Big Wisniewski", listMake("Orchard", "Nuns", "Farm"), listMake("Lighthouse", "Junkyard", "Arena"));
        //specific exception to deal with 151st cheating:
		if ((frat_boys_left < 1000 && !(frat_boys_left >= 998 && hippies_left < 1000)) || (frat_boys_left == 1000 && hippies_left == 1000) || sides_completed_hippy > 0)
            QLevel12GenerateBattlefieldDescription(subentry, "hippy", frat_boys_left, frat_boys_defeated_per_combat, "frat boy", "frat boys", "The Man", listMake("Lighthouse", "Junkyard", "Arena"), listMake("Orchard", "Nuns", "Farm"));
            
        
        if (frat_boys_left == 1 && hippies_left == 1)
		{
			if ($item[flaregun].available_amount() > 0)
				subentry.entries.listAppend("Wossname time! Adventure on battlefield, use a flaregun.");
			else if (!in_hardcore())
				subentry.entries.listAppend("Pull a flaregun for wossname.");
			else if (__misc_state["fax equivalent accessible"])
				subentry.entries.listAppend("Fax smarmy pirate, run +234% item (or YR) for flaregun for wossname.");
			else
				subentry.entries.listAppend("That almost was a wossname, but you needed more flare.");
		}
        
        item [int] items_to_closet_for_desert_hippy;
        foreach it in $items[reinforced beaded headband,round purple sunglasses,bullet-proof corduroys,beer helmet,distressed denim pants,bejeweled pledge pin]
        {
            if (it.available_amount() == 0)
                continue;
            items_to_closet_for_desert_hippy.listAppend(it);
        }
        
        if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues"))
        {
            string line = "Visit the Arid, Extra-Dry Desert to find a hippy uniform.";
            if (items_to_closet_for_desert_hippy.count() > 0)
                line += "|But first closet " + items_to_closet_for_desert_hippy.listJoinComponents(", ", "and");
            subentry.entries.listAppend(line);
        }
        //FIXME Add when spaded:
        /*else if (!have_outfit_components("War Hippy Fatigues"))
        {
            string line = "If you want a hippy uniform without visiting the battlefield, adventure in the Arid, Extra-Dry Desert.";
            if (items_to_closet_for_desert_hippy.count() > 0)
                line += "|But first closet " + items_to_closet_for_desert_hippy.listJoinComponents(", ", "and");
            subentry.entries.listAppend(line);
        }*/
        
		QLevel12GenerateTasksSidequests(task_entries, optional_task_entries, future_task_entries);
	}
	
}