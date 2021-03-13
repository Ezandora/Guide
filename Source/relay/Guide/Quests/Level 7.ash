
void QLevel7Init()
{
	//questL07Cyrptic
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL07Cyrptic");
    if (my_path_id() == PATH_COMMUNITY_SERVICE || my_path_id() == PATH_GREY_GOO) QuestStateParseMafiaQuestPropertyValue(state, "finished");
	state.quest_name = "Cyrpt Quest";
	state.image_name = "cyrpt";
	state.council_quest = true;
	
	if (my_level() >= 7 || my_path_id() == PATH_EXPLOSIONS)
		state.startable = true;
	
    if (state.started)
    {
        state.state_int["alcove evilness"] = get_property_int("cyrptAlcoveEvilness");
        state.state_int["cranny evilness"] = get_property_int("cyrptCrannyEvilness");
        state.state_int["niche evilness"] = get_property_int("cyrptNicheEvilness");
        state.state_int["nook evilness"] = get_property_int("cyrptNookEvilness");
	}
    else
    {
        //mafia won't track these properly until quest is started, I think?
        state.state_int["alcove evilness"] = 50;
        state.state_int["cranny evilness"] = 50;
        state.state_int["niche evilness"] = 50;
        state.state_int["nook evilness"] = 50;
    }
    
    if (state.finished)
    {
        //just in case:
        state.state_int["alcove evilness"] = 0;
        state.state_int["cranny evilness"] = 0;
        state.state_int["niche evilness"] = 0;
        state.state_int["nook evilness"] = 0;
    }
    
    foreach l in $strings[alcove,cranny,niche,nook]
    {
        boolean need_speeding_up = false;
        int evilness = state.state_int[l + " evilness"];
        
        if (l == "alcove" && get_property_monster("romanticTarget") == $monster[modern zmobie])
            evilness -= 5 * get_property_int("_romanticFightsLeft");
        
        if (evilness <= 26)
            need_speeding_up = false;
        else
            need_speeding_up = true;
        state.state_boolean[l + " needs speed tricks"] = need_speeding_up;
            
    }
    
	if (state.state_int["alcove evilness"] <= 0)
		state.state_boolean["alcove finished"] = true;
	if (state.state_int["cranny evilness"] <= 0)
		state.state_boolean["cranny finished"] = true;
	if (state.state_int["niche evilness"] <= 0)
		state.state_boolean["niche finished"] = true;
	if (state.state_int["nook evilness"] <= 0)
		state.state_boolean["nook finished"] = true;
		
		
	__quest_state["Level 7"] = state;
	__quest_state["Cyrpt"] = state;
}


void QLevel7GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 7"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 7"];
	
	ChecklistEntry entry = ChecklistEntryMake(72);
	entry.url = "crypt.php";
	entry.image_lookup_name = base_quest_state.image_name;
	entry.should_indent_after_first_subentry = true;
	entry.subentries.listAppend(ChecklistSubentryMake(base_quest_state.quest_name));
    entry.should_highlight = $locations[the defiled nook, the defiled cranny, the defiled alcove, the defiled niche, haert of the cyrpt] contains __last_adventure_location;
	
	string [int] evilness_properties = split_string_alternate("cyrptAlcoveEvilness,cyrptCrannyEvilness,cyrptNicheEvilness,cyrptNookEvilness", ",");
	string [string] evilness_text;
	
	float universal_evilness_removed_per_adventure = 0.0;
	string superhero_cape_suggestions;
	boolean superhero_cape_active = false;
	if (lookupItem("unwrapped knock-off retro superhero cape").have())
	{
		string [int] tasks;
        if (!lookupItem("unwrapped knock-off retro superhero cape").equipped())
        {
        	tasks.listAppend("equip the retro superhero cape");
            entry.url = "inventory.php?which=2&ftext=unwrapped+knock-off+retro+superhero+cape";
        }
        if ($slot[weapon].equipped_item().item_type() != "sword")
        {
        	tasks.listAppend("equip a sword in mainhand");
        }
        if ($effect[Iron Palms].have_effect() != 0)
        {
        	tasks.listAppend("cast iron palm technique");
        }
		if (!(get_property("retroCapeSuperhero") == "vampire" && get_property("retroCapeWashingInstructions") == "kill"))
        {
        	string line = "switch";
            if (tasks.count() == 0)
            {
            	line += " the retro superhero cape";
                entry.url = "inventory.php?action=hmtmkmkm";
            }
            line += " to Vampire Slicer/Kill Me";
        	tasks.listAppend(line);
        }
        if (tasks.count() > 0)
        {
        	superhero_cape_suggestions = HTMLGenerateSpanFont(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".", "red");
        }
        else
        {
        	superhero_cape_active = true;
            superhero_cape_suggestions = "Cast Slay the Dead every combat.";
            universal_evilness_removed_per_adventure += 1.0;
        }
	}
	foreach key in evilness_properties
	{
		string property = evilness_properties[key];
		int evilness = get_property_int(property);
		string text;
		if (evilness == 0)
			text = "Finished";
		else if (evilness <= 25)
			text = HTMLGenerateSpanFont("At boss", "red");
		else
			text = (evilness - 25) + " evilness to boss.";
		evilness_text[property] = text;
	}
	
	if (!base_quest_state.state_boolean["nook finished"])
	{
		int evilness = base_quest_state.state_int["nook evilness"];
		ChecklistSubentry subentry;
		subentry.header = "Defiled Nook";
		
		subentry.entries.listAppend(evilness_text["cyrptNookEvilness"]);
		
		if (evilness > 26 && my_path_id() != PATH_G_LOVER)
		{
            subentry.modifiers.listAppend("+400% item");
            float item_drop = (100.0 + $location[the defiled nook].item_drop_modifier_for_location()) / 100.0;
            
			float eyes_per_adventure = MIN(1.0, (item_drop) * 0.2);
            float eyes_value = 3.0;
            if (evilness < 29)
                eyes_value = clampi(evilness - 25 - 1, 0, 3);
			float evilness_per_adventure = 1.0;
            if ($item[gravy boat].equipped_amount() > 0)
                evilness_per_adventure += 1.0;
            evilness_per_adventure += universal_evilness_removed_per_adventure;
            evilness_per_adventure = MAX(evilness_per_adventure, evilness_per_adventure + eyes_per_adventure * eyes_value);
			
			if ($item[evil eye].available_amount() > 0)
            {
                if ($item[evil eye].available_amount() == 1)
                    subentry.entries.listAppend("Use your evil eye.");
                else
                    subentry.entries.listAppend("Use your evil eyes.");
            }
            if (__iotms_usable[$item[haunted doghouse]] && !$location[the defiled nook].noncombat_queue.contains_text("Seeing-Eyes Dog") && $location[the defiled nook].turns_spent >= 5)// && evilness <= 25 + 9)
            {
                //haunted doghouse adventures are a percentage chance, and the NC is skippable. more NCs, more chances, less turns spent
                subentry.modifiers.listAppend("-combat");
            }
            if (my_path_id() == PATH_EXPLOSIONS)
            	subentry.entries.listAppend("Ignore this area until the end of the run; wandering astronauts drop evil eyes. Lure them to delay-burning areas; keep signal jammer equipped otherwise.");
		
			float evilness_remaining = evilness - 25;
			evilness_remaining -= $item[evil eye].available_amount() * 3;
			if (evilness_remaining > 0)
			{
				float average_turns_remaining = (evilness_remaining / evilness_per_adventure);
				int theoretical_best_turns_remaining = ceil(evilness_remaining / 4.0);
				if (average_turns_remaining < theoretical_best_turns_remaining) //not sure about this. +344.91% item, 38 evilness, 4 optimal, 3.something not-optimal, what does it mean?
					average_turns_remaining = theoretical_best_turns_remaining;
		
				subentry.entries.listAppend(roundForOutput(eyes_per_adventure * 100.0, 0) + "% chance of evil eyes.");
				subentry.entries.listAppend("~" + roundForOutput(average_turns_remaining, 1) + " turns remain to boss. (theoretical best: " + theoretical_best_turns_remaining + ")");
                if (superhero_cape_suggestions.length() > 0)
                	subentry.entries.listAppend(superhero_cape_suggestions);
			}
		}
		
		
		entry.subentries.listAppend(subentry);
	}
	if (!base_quest_state.state_boolean["niche finished"])
	{
		int evilness = base_quest_state.state_int["niche evilness"];
		ChecklistSubentry subentry;
		subentry.header = "Defiled Niche";
		
		subentry.entries.listAppend(evilness_text["cyrptNicheEvilness"]);
        
        float [monster] appearance_rates = $location[the defiled niche].appearance_rates_adjusted_cancel_nc();
        float evilness_removed_per_adventure = 0.0;
        evilness_removed_per_adventure += 1.0 * appearance_rates[$monster[slick lihc]] / 100.0;
        evilness_removed_per_adventure += 1.0 * appearance_rates[$monster[senile lihc]] / 100.0;
        evilness_removed_per_adventure += 3.0 * appearance_rates[$monster[dirty old lihc]] / 100.0;
        evilness_removed_per_adventure += universal_evilness_removed_per_adventure;
        
        float turns_remaining = MAX(0, evilness - 25);
        
        if (evilness_removed_per_adventure != 0.0)
            turns_remaining = MAX(1, turns_remaining / evilness_removed_per_adventure);
        
        if (floor(turns_remaining) * 3 < evilness)
            turns_remaining = ceiling(turns_remaining);
        
        
		if (evilness > 26 && (appearance_rates[$monster[slick lihc]] > 0.0 || appearance_rates[$monster[senile lihc]] > 0.0))
        {
            subentry.modifiers.listAppend("olfact dirty old lihc");
            subentry.modifiers.listAppend("banish");
        }
		if (evilness > 25)
            subentry.entries.listAppend("~" + turns_remaining.roundForOutput(1) + " turns remaining to boss.");
        if (evilness > 26 && superhero_cape_suggestions.length() > 0)
            subentry.entries.listAppend(superhero_cape_suggestions);
		
		
		entry.subentries.listAppend(subentry);
	}
	if (!base_quest_state.state_boolean["cranny finished"])
	{
		ChecklistSubentry subentry;
		subentry.header = "Defiled Cranny";
		subentry.entries.listAppend(evilness_text["cyrptCrannyEvilness"]);
		
		if (base_quest_state.state_int["cranny evilness"] > 26)
		{
            subentry.modifiers.listAppend("-combat");
            subentry.modifiers.listAppend("+ML");
            float monster_level = monster_level_adjustment_for_location($location[the defiled cranny]);
            
            monster_level = MAX(monster_level, 0);
            
			float cranny_beep_beep_beep = MAX(3.0,sqrt(monster_level));
			int beep_boop_lookup = floor(cranny_beep_beep_beep) - 3;
            
            float area_combat_rate = clampNormalf(0.85 + combat_rate_modifier() / 100.0);
            float area_nc_rate = 1.0 - area_combat_rate;
            
            float average_beeps_per_turn = cranny_beep_beep_beep * area_nc_rate + 1.0 * area_combat_rate;
            average_beeps_per_turn += universal_evilness_removed_per_adventure;
            float average_turns_remaining = ((base_quest_state.state_int["cranny evilness"] - 25) / average_beeps_per_turn);
            
            average_turns_remaining = MAX(1, average_turns_remaining);
			
			subentry.entries.listAppend("~" + cranny_beep_beep_beep.roundForOutput(1) + " beeps per ghuol swarm. ~" + average_turns_remaining.roundForOutput(1) + " turns remain to boss.");
   
   			if (superhero_cape_suggestions.length() > 0)
                	subentry.entries.listAppend(superhero_cape_suggestions);
		}
        else if (base_quest_state.state_int["cranny evilness"] <= 25)
            subentry.modifiers.listAppend("+meat");
		
		entry.subentries.listAppend(subentry);
	}
	if (!base_quest_state.state_boolean["alcove finished"])
	{
		ChecklistSubentry subentry;
		int evilness = base_quest_state.state_int["alcove evilness"];
		subentry.header = "Defiled Alcove";
		subentry.entries.listAppend(evilness_text["cyrptAlcoveEvilness"]);
        
        
        int evilness_after_arrow = evilness;
        if (get_property_monster("romanticTarget") == $monster[modern zmobie])
            evilness_after_arrow -= 5 * get_property_int("_romanticFightsLeft");
        
        if (evilness_after_arrow <= 25 && evilness > 25)
        {
            subentry.entries.listAppend("Wait for modern zmobie arrows.");
        }
		else if (evilness > 26)
		{
            subentry.modifiers.listAppend("+850% init");
            subentry.modifiers.listAppend("-combat");
            
			int zmobies_needed = ceil((evilness.to_float() - 26.0) / (5.0 + universal_evilness_removed_per_adventure));
			float zmobie_chance = min(100.0, 15.0 + initiative_modifier_for_location($location[the defiled alcove]) / 10.0);
			
			subentry.entries.listAppend(pluralise(zmobies_needed, "modern zmobie", "modern zmobies") + " needed (" + roundForOutput(zmobie_chance, 0) + "% chance of appearing)");
            
            //float combat_rate = clampNormalf(0.85 + combat_rate_modifier() / 100.0);
            //float nc_rate = 1.0 - combat_rate;
            
            if ($familiar[oily woim].familiar_is_usable() && !(($familiars[oily woim,happy medium] contains my_familiar())))
            {
                if (!(my_familiar() == $familiar[Xiblaxian Holo-Companion] && my_familiar() != $familiar[none]))
                    subentry.entries.listAppend("Run " + $familiar[oily woim] + ($familiar[happy medium].familiar_is_usable() ? "/medium" : "") + ($familiar[Xiblaxian Holo-Companion].familiar_is_usable() ? "/holo-companion" : "") + " for +init.");
            }
			if (superhero_cape_suggestions.length() > 0)
                	subentry.entries.listAppend(superhero_cape_suggestions);
            
		}
        else if (evilness <= 25)
            subentry.modifiers.listAppend("+meat");
		entry.subentries.listAppend(subentry);
	}
	if (base_quest_state.mafia_internal_step == 2)
	{
		entry.subentries[0].entries.listAppend("Go talk to the council to finish the quest.");
        entry.url = "place.php?whichplace=town";
	}
	else if (base_quest_state.state_boolean["alcove finished"] && base_quest_state.state_boolean["cranny finished"] && base_quest_state.state_boolean["niche finished"] && base_quest_state.state_boolean["nook finished"])
	{
        float bonerdagon_attack = (90 + monster_level_adjustment());
        
        string line = "Fight bonerdagon!";
        if (my_path_id() == PATH_HEAVY_RAINS)
            line = "Fight auqadargon!";
        if (my_basestat($stat[moxie]) < bonerdagon_attack)
            line += " (attack: " + bonerdagon_attack.round() + ")";
		entry.subentries[0].entries.listAppend(line);
	}
	task_entries.listAppend(entry);
}
