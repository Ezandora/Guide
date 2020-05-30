


string generateNinjaSafetyGuide(boolean show_colour)
{
	boolean can_survive = false;
	float init_needed = $monster[ninja snowman assassin].monster_initiative();
	init_needed = monster_initiative($monster[Ninja snowman assassin]);
	
	float damage_taken = calculateCurrentNinjaAssassinMaxDamage();
    float damage_taken_always = calculateCurrentNinjaAssassinMaxEnvironmentalDamage();
	
	string result;
	if (initiative_modifier() >= init_needed)
	{
        if (my_hp() >= ceil(damage_taken_always) + 2)
            can_survive = true;
		result += "Keep";
	}
	else
		result += "Need";
	result += " +" + ceil(init_needed) + "% init";
    
    if (damage_taken_always > my_hp())
        result += "/" + ceil(damage_taken_always) + " HP";
    
    result += " to survive ninja, or ";
    
    //FIXME warn about damage_taken_always WITH INIT
	
	int min_safe_damage = (ceil(damage_taken) + 2) + (ceil(damage_taken_always) + 2) ;
	if (my_hp() >= min_safe_damage)
	{
		result += "keep";
		can_survive = true;
	}
	else
		result += "need";
	result += " HP above " + min_safe_damage + ".";
    
    if (my_path_id() == PATH_CLASS_ACT_2 && monster_level_adjustment() > 50)
    {
        result += " Reduce ML to +50 to prevent elemental damage.";
        can_survive = false;
    }
	
	if (!can_survive && show_colour)
		result = HTMLGenerateSpanFont(result, "red");
	return result;
}


void CopiedMonstersGenerateDescriptionForMonster(string monster_name, string [int] description, boolean show_details, boolean from_copy)
{
    if (!__misc_state["in run"])
        return;
    monster_name = monster_name.to_lower_case();
	if (monster_name == "ninja snowman assassin")
	{
		description.listAppend(generateNinjaSafetyGuide(show_details));
        int components_missing = $items[ninja rope,ninja carabiner,ninja crampons].items_missing().count();
        if (components_missing > 0)
            description.listAppend("Need to fight " + components_missing.int_to_wordy() + " more.");
        else
            description.listAppend("Don't need to fight anymore.");
        
        if (from_copy && $familiar[obtuse angel].familiar_is_usable() && $familiar[reanimated reanimator].familiar_is_usable())
        {
            string line = "Make sure to copy with angel, not the reanimator.";
            if (my_familiar() == $familiar[reanimated reanimator])
                line = HTMLGenerateSpanFont(line, "red");
            description.listAppend(line);
        }
	}
	else if (monster_name == "quantum mechanic")
	{
		string line;
		boolean requirements_met = false;
		if (item_drop_modifier_ignoring_plants() < 150.0)
			line += "Need ";
		else
		{
			line += "Keep ";
			requirements_met = true;
		}
		line += "+150% item for large box";
		if (show_details && !requirements_met)
			line = HTMLGenerateSpanFont(line, "red");
		description.listAppend(line);
	}
    else if ($strings[bricko bat,bricko cathedral,bricko elephant,bricko gargantuchicken,bricko octopus,bricko ooze,bricko oyster,bricko python,bricko turtle,bricko vacuum cleaner] contains monster_name)
    {
        description.listAppend("Zero adventure cost, use to burn delay.");
    }
    else if (monster_name == "lobsterfrogman" && show_details)
    {
        string line;
    
        if (!__quest_state["Level 12"].state_boolean["Lighthouse Finished"] && $item[barrel of gunpowder].available_amount() < 5)
        {
            int number_to_fight = clampi(5 - $item[barrel of gunpowder].available_amount(), 0, 5);
            line += number_to_fight.int_to_wordy().capitaliseFirstLetter() + " more to defeat. ";
        }
        
        int lfm_attack = $monster[lobsterfrogman].base_attack + 5.0;
        string attack_text = lfm_attack + " attack.";
        
		if (my_buffedstat($stat[moxie]) < lfm_attack)
			attack_text = HTMLGenerateSpanFont(attack_text, "red");
        
        line += attack_text;
        description.listAppend(line);
    }
    else if (monster_name == "big swarm of ghuol whelps" || monster_name == "swarm of ghuol whelps" || monster_name == "giant swarm of ghuol whelps")
    {
        float monster_level = monster_level_adjustment_ignoring_plants();
    
        monster_level = MAX(monster_level, 0);
        
        float cranny_beep_beep_beep = MAX(3.0,sqrt(monster_level));
        description.listAppend("~" + cranny_beep_beep_beep.roundForOutput(1) + " cranny beeps.");
    }
    else if (monster_name == "writing desk")
    {
        /*if ($item[telegram from Lady Spookyraven].available_amount() > 0)
            description.listAppend(HTMLGenerateSpanFont("Read the telegram from Lady Spookyraven first.", "red"));
        int desks_remaining = clampi(5 - get_property_int("writingDesksDefeated"), 0, 5);
        if (desks_remaining > 0 && !get_property_ascension("lastSecondFloorUnlock") && $item[Lady Spookyraven's necklace].available_amount() == 0 && get_property("questM20Necklace") != "finished" && mafiaIsPastRevision(15244))
            description.listAppend(pluraliseWordy(desks_remaining, "desk", "desks").capitaliseFirstLetter() + " remaining.");*/
        description.listAppend("This doesn't work anymore.");

    }
    else if (monster_name == "skinflute" || monster_name == "camel's toe")
    {
        description.listAppend("Have " + pluralise($item[star]) + " and " + pluralise($item[line]) + ".");
		if (item_drop_modifier_ignoring_plants() < 234.0)
			description.listAppend(HTMLGenerateSpanFont("Need +234% item.", "red"));
    }
    else if (monster_name == "source agent")
    {
        if (monster_level_adjustment() > 0)
            description.listAppend("Possibly remove +ML.");
        string stat_description;
        
        if (get_property_int("sourceAgentsDefeated") > 0)
            stat_description += pluralise(get_property_int("sourceAgentsDefeated"), "agent", "agents") + " defeated so far. ";
        stat_description += $monster[Source Agent].base_attack + " attack.";
        float our_init = initiative_modifier();
        if ($skill[Overclocked].have_skill())
            our_init += 200;
        float agent_initiative = $monster[Source Agent].base_initiative;
        float chance_to_get_jump = clampf(100 - agent_initiative + our_init, 0.0, 100.0);
        boolean might_not_gain_init = false;
        boolean avoid_displaying_init_otherwise = false;
        if (my_thrall() == $thrall[spaghetti elemental] && my_thrall().level >= 5 && monster_level_adjustment() <= 150)
        {
            stat_description += "|Will effectively gain initiative on agent.";
            if (!__iotms_usable[$item[source terminal]] || get_property_int("_sourceTerminalPortscanUses") >= 3)
                avoid_displaying_init_otherwise = true;
        }
        if (avoid_displaying_init_otherwise)
        {
        }
        else if (chance_to_get_jump >= 100.0)
            stat_description += "|Will gain initiative on agent.";
        else if (chance_to_get_jump <= 0.0)
        {
            stat_description += "|Will not gain initiative on agent. Need " + round(agent_initiative - our_init) + "% more init.";
            might_not_gain_init = true;
        }
        else
        {
            stat_description += "|" + round(chance_to_get_jump) + "% chance to gain initiative on agent.";
            might_not_gain_init = true;
        }
        if (might_not_gain_init)
        {
            if (my_class() == $class[pastamancer] && $skill[bind spaghetti elemental].have_skill() && my_thrall() != $thrall[spaghetti elemental])
            {
                stat_description += " Or run ";
                if ($thrall[spaghetti elemental].level < 5)
                    stat_description += "and level up ";
                stat_description += "a spaghetti elemental to block the first attack.";
            }
        }
        description.listAppend(stat_description);
        if (__last_adventure_location == $location[the haunted bedroom])
            description.listAppend("Won't appear in the haunted bedroom, so may want to go somewhere else?");
        if ($skill[Humiliating Hack].have_skill())
        {
            string [int] delevelers;
            if ($skill[ruthless efficiency].have_skill() && $effect[ruthlessly efficient].have_effect() == 0)
            {
                delevelers.listAppend("cast ruthless efficiency");
            }
            if ($item[dark porquoise ring].available_amount() > 0 && $item[dark porquoise ring].equipped_amount() == 0 && $item[dark porquoise ring].can_equip())
            {
                delevelers.listAppend("equip dark porquoise ring");
            }
            if (delevelers.count() > 0)
            {
                description.listAppend("Possibly " + delevelers.listJoinComponents(", ", "or") + " for better deleveling.");
            }
        }
    }
    
    if (__misc_state["monsters can be nearly impossible to kill"] && monster_level_adjustment() > 0)
        description.listAppend(HTMLGenerateSpanFont("Possibly remove +ML to survive. (at +" + monster_level_adjustment() + " ML)", "red"));
}

void generateCopiedMonstersEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task) //if from_task is false, assumed to be from resources
{
	string [int] description;
	boolean very_important = false;
	int show_up_in_tasks_turn_cutoff = 10;
	string title = "";
	int min_turns_until = -1;
    string url = "";
    if (get_property_boolean("dailyDungeonDone"))
        url = $location[the daily dungeon].getClickableURLForLocation();
    Counter romantic_arrow_counter = CounterLookup("Romantic Monster", ErrorMake(), true);
	if (false && (romantic_arrow_counter.CounterIsRange() || get_property_int("_romanticFightsLeft") > 0))
	{
        Vec2i turn_range = romantic_arrow_counter.CounterGetWindowRange();
        
        title = "Arrowed " + __misc_state_string["Romantic Monster Name"].to_lower_case() + " appears ";
        
        if (turn_range.y <= 0)
            title += "now or soon";
        else if (turn_range.x <= 0)
            title += "between now and " + turn_range.y + " turns.";
        else
            title += "in [" + turn_range.x + " to " + turn_range.y + "] turns.";
        
        min_turns_until = turn_range.x;
        
        int fights_left = get_property_int("_romanticFightsLeft");
        if (fights_left > 1)
        {
            string line = fights_left + " fights left";
            
            Vec2i estimated_range = Vec2iMake(15 * (fights_left - 1), 25 * (fights_left - 1));
            estimated_range.x += turn_range.x;
            estimated_range.y += turn_range.y;
            
            line += " over ~" + (estimated_range.x + estimated_range.y) / 2 + " turns.";
            
            description.listAppend(line);
        }
        else if (fights_left == 1)
            description.listAppend("Last fight.");
        
        
        
        
        if (turn_range.x <= 0)
            very_important = true;
	}
	if (from_task && min_turns_until > show_up_in_tasks_turn_cutoff)
		return;
	if (!from_task && min_turns_until <= show_up_in_tasks_turn_cutoff)
		return;
		
	if (title != "")
	{
		CopiedMonstersGenerateDescriptionForMonster(__misc_state_string["Romantic Monster Name"], description, very_important, false);
	}
	
	if (title != "")
	{
		int importance = 4;
		if (very_important)
			importance = -11;
		ChecklistEntry entry = ChecklistEntryMake(__misc_state_string["obtuse angel name"], url, ChecklistSubentryMake(title, "", description), importance);
		if (very_important)
			task_entries.listAppend(entry);
		else
			optional_task_entries.listAppend(entry);
			
	}
}

void SCopiedMonstersGenerateResourceForCopyType(ChecklistEntry [int] resource_entries, item shaking_object, string shaking_shorthand_name, string monster_name_property_name)
{
	if (shaking_object.available_amount() == 0 && shaking_object != $item[none])
		return;
    
    string url = "inventory.php?ftext=" + shaking_object;
	
	string [int] monster_description;
	string monster_name = get_property(monster_name_property_name).HTMLEscapeString();
	CopiedMonstersGenerateDescriptionForMonster(monster_name, monster_description, true, true);
    
    if (get_auto_attack() != 0)
    {
        url = "account.php?tab=combat";
        monster_description.listAppend("Auto attack is on, disable it?");
    }
	
	//string line = monster_name.capitaliseFirstLetter() + HTMLGenerateIndentedText(monster_description);
    string line = HTMLGenerateSpanOfClass(monster_name.capitaliseFirstLetter(), "r_bold");
    
    if (monster_description.count() > 0)
        line += "<hr>" + monster_description.listJoinComponents("|");
    
    string image_name = "__item " + shaking_object;
    if (shaking_shorthand_name == "chateau painting")
    {
        image_name = "__item fancy oil painting";
        url = "place.php?whichplace=chateau";
    }
	
	resource_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake(shaking_shorthand_name.capitaliseFirstLetter() + " monster trapped!", "", line)));
}

void SCopiedMonstersGenerateResource(ChecklistEntry [int] resource_entries)
{
    //Sources:
    
    boolean have_spooky_putty = $items[Spooky Putty ball,Spooky Putty leotard,Spooky Putty mitre,Spooky Putty sheet,Spooky Putty snake,Spooky Putty monster].available_amount() > 0;
    
	int copies_used = get_property_int("spookyPuttyCopiesMade") + get_property_int("_raindohCopiesMade");
	int copies_available = MIN(6,5*MIN($items[Spooky Putty ball,Spooky Putty leotard,Spooky Putty mitre,Spooky Putty sheet,Spooky Putty snake,Spooky Putty monster].available_amount(), 1) + 5*MIN($item[Rain-Doh black box].available_amount() + $item[rain-doh box full of monster].available_amount(), 1));
    int copies_left = copies_available - copies_used;
    
    string [int] potential_copies;
    if (true)
    {
        //√ghuol whelps, √modern zmobies, √wine racks, √gaudy pirates, √lobsterfrogmen, √ninja assassin
        if (!__quest_state["Level 12"].state_boolean["Lighthouse Finished"] && $item[barrel of gunpowder].available_amount() < 5)
            potential_copies.listAppend("Lobsterfrogman.");
        if (__quest_state["Level 7"].state_boolean["cranny needs speed tricks"])
            potential_copies.listAppend("Swarm of ghuol whelps.");
        if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"])
            potential_copies.listAppend("Modern zmobies.");
        if (!__quest_state["Level 8"].state_boolean["Mountain climbed"] && $items[ninja rope,ninja carabiner,ninja crampons].available_amount() == 0 && !have_outfit_components("eXtreme Cold-Weather Gear"))
            potential_copies.listAppend("Ninja assassin.");
        //if (!__quest_state["Level 11"].finished && !__quest_state["Level 11 Palindome"].finished && $item[talisman o' namsilat].available_amount() == 0 && $items[gaudy key,snakehead charrrm].available_amount() < 2 && my_path_id() != PATH_G_LOVER)
            //potential_copies.listAppend("Gaudy pirate - copy once for extra key.");
        //√baa'baa. astronomer? √nuns trick brigand
        //FIXME astronomer when we can calculate that
        //if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
            //potential_copies.listAppend("Brigand - nuns trick.");
        //possibly less relevant:
        //√ghosts/skulls/bloopers...?
        //seems very marginal
        //if (!__quest_state["Level 13"].state_boolean["past keys"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0)
            //potential_copies.listAppend("Ghosts/morbid skulls/bloopers, for digital key. (marginal?)");
        //bricko bats, if they have bricko...?
        //if (__misc_state["bookshelf accessible"] && $skill[summon brickos].skill_is_usable())
            //potential_copies.listAppend("Bricko bats...?");
    }
    ChecklistEntry copy_source_entry;
    
    if (__misc_state["Chateau Mantegna available"] && !get_property_boolean("_chateauMonsterFought") && mafiaIsPastRevision(15115))
    {
        string url = "place.php?whichplace=chateau";
        string header = "Chateau painting copy";
        string [int] description;
        monster current_monster = get_property_monster("chateauMonster");
        
        if (current_monster == $monster[none])
            header += " available";
        else
            header += " fightable";
        
        if (__misc_state["in run"])
        {
            if ($item[alpine watercolor set].available_amount() == 0)
                description.listAppend("Acquire an alpine watercolor set to copy something else.");
            else
                description.listAppend("Copy something else with alpine watercolor set.");
            /*string line;
            if (current_monster == $monster[none])
                line += "Options:";
            else
                line += "Other options:";
            
            if ($item[alpine watercolor set].available_amount() == 0)
            {
                //url = "shop.php?whichshop=chateau";
                line += " (buy alpine watercolor set first)";
            }
            else
                line += " (copy with alpine watercolor set)";
        
            line += "|*" + potential_copies.listJoinComponents("|*");
            description.listAppend(line);*/
        }
        
        if (current_monster != $monster[none])
        {
            string [int] monster_description;
            CopiedMonstersGenerateDescriptionForMonster(current_monster, monster_description, true, true);
            string line = HTMLGenerateSpanOfClass("Currently have " + current_monster.to_string() + ".", "r_bold");
            if (monster_description.count() > 0)
                line += "|*" + monster_description.listJoinComponents("|*");
            description.listPrepend(line);
        }
		//resource_entries.listAppend(ChecklistEntryMake("__item fancy oil painting", url, ChecklistSubentryMake(header, "", description)));
        
        
        copy_source_entry.subentries.listAppend(ChecklistSubentryMake(header, "", description));
        if (copy_source_entry.image_lookup_name == "")
            copy_source_entry.image_lookup_name = "__item fancy oil painting";
        if (copy_source_entry.url == "")
            copy_source_entry.url = "place.php?whichplace=chateau";
    }
	if (copies_left > 0)
	{
		string [int] copy_source_list;
		if (have_spooky_putty)
            copy_source_list.listAppend("spooky putty");
		if ($item[Rain-Doh black box].available_amount() + $item[rain-doh box full of monster].available_amount() > 0)
            copy_source_list.listAppend("rain-doh black box");
        
		string copy_sources = copy_source_list.listJoinComponents("/");
		string name = "";
		//FIXME make this possibly say which one in the case of 6 (does that matter? how does that mechanic work?)
		name = pluralise(copies_left, copy_sources + " copy", copy_sources + " copies") + " left";
		string [int] description;// = potential_copies;
        
		//resource_entries.listAppend(ChecklistEntryMake(copy_source_list[0], "", ChecklistSubentryMake(name, "", description)));
        
        copy_source_entry.subentries.listAppend(ChecklistSubentryMake(name, "", description));
        if (copy_source_entry.image_lookup_name == "")
            copy_source_entry.image_lookup_name = copy_source_list[0];
	}
    
    if (!get_property_boolean("_cameraUsed") && $item[4-d camera].available_amount() > 0)
    {
		//resource_entries.listAppend(ChecklistEntryMake("__item 4-d camera", "", ChecklistSubentryMake("4-d camera copy available", "", potential_copies)));
        
        copy_source_entry.subentries.listAppend(ChecklistSubentryMake("4-d camera copy available", "", ""));
        if (copy_source_entry.image_lookup_name == "")
            copy_source_entry.image_lookup_name = "__item 4-d camera";
    }
    if (!get_property_boolean("_iceSculptureUsed") && $item[unfinished ice sculpture].available_amount() > 0)
    {
		//resource_entries.listAppend(ChecklistEntryMake("__item unfinished ice sculpture", "", ChecklistSubentryMake("Ice sculpture copy available", "", potential_copies)));
        
        copy_source_entry.subentries.listAppend(ChecklistSubentryMake("Ice sculpture copy available", "", ""));
        if (copy_source_entry.image_lookup_name == "")
            copy_source_entry.image_lookup_name = "__item unfinished ice sculpture";
    }
    if ($item[sticky clay homunculus].available_amount() > 0)
    {
		//resource_entries.listAppend(ChecklistEntryMake("__item sticky clay homunculus", "", ChecklistSubentryMake(pluralise($item[sticky clay homunculus].available_amount(), "sticky clay copy", "sticky clay copies") + " available", "", "Unlimited/day.")));
        
        copy_source_entry.subentries.listAppend(ChecklistSubentryMake(pluralise($item[sticky clay homunculus].available_amount(), "sticky clay copy", "sticky clay copies") + " available", "", "Unlimited/day."));
        if (copy_source_entry.image_lookup_name == "")
            copy_source_entry.image_lookup_name = "__item sticky clay homunculus";
    }
    if ($item[print screen button].available_amount() > 0)
    {
        copy_source_entry.subentries.listAppend(ChecklistSubentryMake(pluralise($item[print screen button].available_amount(), "print screen copy", "print screen copies") + " available", "", ""));
        if (copy_source_entry.image_lookup_name == "")
            copy_source_entry.image_lookup_name = "__item print screen button";
    }
    if ($item[LOV Enamorang].available_amount() > 0)
    {
        copy_source_entry.subentries.listAppend(ChecklistSubentryMake(pluralise($item[LOV Enamorang]), "", ""));
        if (copy_source_entry.image_lookup_name == "")
            copy_source_entry.image_lookup_name = "__item lov enamorang";
    }
    if (!get_property_boolean("_crappyCameraUsed") && $item[crappy camera].available_amount() > 0)
    {
        string [int] description;// = listCopy(potential_copies);
        description.listPrepend("50% success rate");
		//resource_entries.listAppend(ChecklistEntryMake("__item crappy camera", "", ChecklistSubentryMake("Crappy camera copy available", "", description)));
        
        
        copy_source_entry.subentries.listAppend(ChecklistSubentryMake("Crappy camera copy available", "", description));
        if (copy_source_entry.image_lookup_name == "")
            copy_source_entry.image_lookup_name = "__item crappy camera";
    }
    if (copy_source_entry.subentries.count() > 0)
    {
        ChecklistSubentry last_subentry = copy_source_entry.subentries[copy_source_entry.subentries.count() - 1];
        if (last_subentry.entries.count() > 0 && potential_copies.count() > 0)
        {
            copy_source_entry.subentries.listAppend(ChecklistSubentryMake("Potential targets:", "", potential_copies));
        }
        else
            last_subentry.entries.listAppendList(potential_copies);
        resource_entries.listAppend(copy_source_entry);
    }
    
    //Copies made:


	generateCopiedMonstersEntry(resource_entries, resource_entries, false);
	SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[Rain-Doh box full of monster], "rain doh", "rainDohMonster");
	SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[spooky putty monster], "spooky putty", "spookyPuttyMonster");
    if (!get_property_boolean("_cameraUsed"))
        SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[shaking 4-d camera], "shaking 4-d camera", "cameraMonster");
    if (!get_property_boolean("_crappyCameraUsed"))
        SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[shaking crappy camera], "shaking crappy camera", "crappyCameraMonster");
	if (!get_property_boolean("_photocopyUsed"))
		SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[photocopied monster], "photocopied", "photocopyMonster");
	if (!get_property_boolean("_envyfishEggUsed"))
		SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[envyfish egg], "envyfish egg", "envyfishMonster");
	if (!get_property_boolean("_iceSculptureUsed"))
		SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[ice sculpture], "ice sculpture", "iceSculptureMonster");
    SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[screencapped monster], "screencapped", "screencappedMonster");
        
	//if (__misc_state["Chateau Mantegna available"] && !get_property_boolean("_chateauMonsterFought") && mafiaIsPastRevision(15115))
		//SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[none], "chateau painting", "chateauMonster");
    
    SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[wax bugbear], "wax bugbear", "waxMonster");
    SCopiedMonstersGenerateResourceForCopyType(resource_entries, $item[crude monster sculpture], "crude sculpture", "crudeMonster");
}

void SCopiedMonstersGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	generateCopiedMonstersEntry(task_entries, optional_task_entries, true);
	
}
