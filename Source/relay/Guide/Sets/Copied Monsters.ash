float calculateCurrentNinjaAssassinMaxDamage()
{
    
	//float assassin_ml = 155.0 + monster_level_adjustment();
    float assassin_ml = $monster[ninja snowman assassin].base_attack + 5.0;
	float damage_absorption = raw_damage_absorption();
	float damage_reduction = damage_reduction();
	float moxie = my_buffedstat($stat[moxie]);
	float cold_resistance = numeric_modifier("cold resistance");
	float v = 0.0;
	
	//spaded by yojimboS_LAW
	//also by soirana
    
	float myst_class_extra_cold_resistance = 0.0;
	if (my_class() == $class[pastamancer] || my_class() == $class[sauceror] || my_class() == $class[avatar of jarlsberg])
		myst_class_extra_cold_resistance = 0.05;
	//Direct from the spreadsheet:
	if (cold_resistance < 9)
		v = ((((MAX((assassin_ml - moxie), 0.0) - damage_reduction) + 120.0) * MAX(0.1, MIN((1.1 - sqrt((damage_absorption/1000.0))), 1.0))) * ((1.0 - myst_class_extra_cold_resistance) - ((0.1) * MAX((cold_resistance - 5.0), 0.0))));
	else
		v = ((((MAX((assassin_ml - moxie), 0.0) - damage_reduction) + 120.0) * MAX(0.1, MIN((1.1 - sqrt((damage_absorption/1000.0))), 1.0))) * (0.1 - myst_class_extra_cold_resistance + (0.5 * (powf((5.0/6.0), (cold_resistance - 9.0))))));
	
    
    
	return v;
}

float calculateCurrentNinjaAssassinMaxEnvironmentalDamage()
{
    float v = 0.0;
    int ml_level = monster_level_adjustment_ignoring_plants();
    if (ml_level >= 25)
    {
        float expected_assassin_damage = 0.0;
        
        expected_assassin_damage = ((150 + ml_level) * (ml_level - 25)).to_float() / 500.0;
        
        expected_assassin_damage = expected_assassin_damage + ceiling(expected_assassin_damage / 11.0); //upper limit
        
        //FIXME add in resists later
        //Resists don't work properly. They have an effect, but it's different. I don't know how much exactly, so for now, ignore this:
        //I think they're probably just -5 like above
        //expected_assassin_damage = damageTakenByElement(expected_assassin_damage, $element[cold]);
        
        expected_assassin_damage = ceil(expected_assassin_damage);
        
        v += expected_assassin_damage;
    }
    return v;
}


string generateNinjaSafetyGuide(boolean show_color)
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
	
	if (!can_survive && show_color)
		result = HTMLGenerateSpanFont(result, "red", "");
	return result;
}


void CopiedMonstersGenerateDescriptionForMonster(string monster_name, string [int] description, boolean show_details, boolean from_copy)
{
	if (monster_name == "Ninja snowman assassin")
	{
		description.listAppend(generateNinjaSafetyGuide(show_details));
        if (from_copy && $familiar[obtuse angel].familiar_is_usable() && $familiar[reanimated reanimator].familiar_is_usable())
        {
            string line = "Make sure to copy with angel, not the reanimator.";
            if (my_familiar() == $familiar[reanimated reanimator])
                line = HTMLGenerateSpanFont(line, "red", "");
            description.listAppend(line);
        }
	}
	else if (monster_name == "Quantum Mechanic")
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
			line = HTMLGenerateSpanFont(line, "red", "");
		description.listAppend(line);
	}
    else if ($strings[bricko bat,bricko cathedral,bricko elephant,bricko gargantuchicken,bricko octopus,bricko ooze,bricko oyster,bricko python,bricko turtle,bricko vacuum cleaner] contains monster_name)
    {
        description.listAppend("Zero adventure cost, use to burn delay.");
    }
    else if (monster_name == "Lobsterfrogman" && show_details)
    {
        int lfm_attack = $monster[lobsterfrogman].base_attack + 5.0;
        string line = lfm_attack + " attack.";
        
		if (my_buffedstat($stat[moxie]) < lfm_attack)
			line = HTMLGenerateSpanFont(line, "red", "");
        description.listAppend(line);
    }
    else if (monster_name == "Big swarm of ghuol whelps" || monster_name == "Swarm of ghuol whelps" || monster_name == "Giant swarm of ghuol whelps")
    {
        float monster_level = monster_level_adjustment_ignoring_plants();
    
        monster_level = MAX(monster_level, 0);
        
        float cranny_beep_beep_beep = MAX(3.0,sqrt(monster_level));
        description.listAppend("~" + cranny_beep_beep_beep.roundForOutput(1) + " cranny beeps.");
    }
    else if (monster_name == "Writing Desk")
    {
        if (lookupItem("telegram from Lady Spookyraven").available_amount() > 0)
            description.listAppend(HTMLGenerateSpanFont("Read the telegram from Lady Spookyraven first.", "red", ""));

    }
    else if (monster_name == "Skinflute" || monster_name == "Camel's Toe")
    {
        description.listAppend("Have " + pluralize($item[star]) + " and " + pluralize($item[line]) + ".");
		if (item_drop_modifier_ignoring_plants() < 234.0)
			description.listAppend(HTMLGenerateSpanFont("Need +234% item.", "red", ""));
    }
}

void generateCopiedMonstersEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task) //if from_task is false, assumed to be from resources
{
	string [int] description;
	boolean very_important = false;
	int show_up_in_tasks_turn_cutoff = 10;
	string title = "";
	int min_turns_until = -1;
    Counter romantic_arrow_counter = CounterLookup("Romantic Monster");
	if (romantic_arrow_counter.CounterIsRange() || get_property_int("_romanticFightsLeft") > 0)
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
            description.listAppend(fights_left + " fights left.");
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
		ChecklistEntry entry = ChecklistEntryMake(__misc_state_string["obtuse angel name"], "", ChecklistSubentryMake(title, "", description), importance);
		if (very_important)
			task_entries.listAppend(entry);
		else
			optional_task_entries.listAppend(entry);
			
	}
}

void SCopiedMonstersGenerateResourceForCopyType(ChecklistEntry [int] available_resources_entries, item shaking_object, string shaking_shorthand_name, string monster_name_property_name)
{
	if (shaking_object.available_amount() == 0)
		return;
    
    string url = "inventory.php?which=3";
	
	string [int] monster_description;
	string monster_name = get_property(monster_name_property_name).HTMLEscapeString();
	CopiedMonstersGenerateDescriptionForMonster(monster_name, monster_description, true, true);
    
    if (get_auto_attack() != 0)
    {
        url = "account.php?tab=combat";
        monster_description.listAppend("Auto attack is on, disable it?");
    }
	
	//string line = monster_name.capitalizeFirstLetter() + HTMLGenerateIndentedText(monster_description);
    string line = HTMLGenerateSpanOfClass(monster_name.capitalizeFirstLetter(), "r_bold") + "<hr>" + monster_description.listJoinComponents("|");
	
	available_resources_entries.listAppend(ChecklistEntryMake(shaking_object, url, ChecklistSubentryMake(shaking_shorthand_name.capitalizeFirstLetter() + " monster trapped!", "", line)));
}

void SCopiedMonstersGenerateResource(ChecklistEntry [int] available_resources_entries)
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
        if (!__quest_state["Level 11"].finished && !__quest_state["Level 11 Palindome"].finished && $item[talisman o' nam].available_amount() == 0 && $items[gaudy key,snakehead charrrm].available_amount() < 2)
            potential_copies.listAppend("Gaudy pirate - copy once for extra key.");
        //√baa'baa. astronomer? √nuns trick brigand
        //FIXME astronomer when we can calculate that
        if (__misc_state["need to level"])
            potential_copies.listAppend("Baa'baa'bu'ran - stone wool for cave bar leveling.");
        if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
            potential_copies.listAppend("Brigand - nuns trick.");
        //possibly less relevant:
        //√ghosts/skulls/bloopers...?
        //seems very marginal
        //if (!__quest_state["Level 13"].state_boolean["past keys"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0)
            //potential_copies.listAppend("Ghosts/morbid skulls/bloopers, for digital key. (marginal?)");
        //bricko bats, if they have bricko...?
        //if (__misc_state["bookshelf accessible"] && $skill[summon brickos].have_skill())
            //potential_copies.listAppend("Bricko bats...?");
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
		name = pluralize(copies_left, copy_sources + " copy", copy_sources + " copies") + " left";
		string [int] description = potential_copies;
        
		available_resources_entries.listAppend(ChecklistEntryMake(copy_source_list[0], "", ChecklistSubentryMake(name, "", description)));
	}
    
    if (!get_property_boolean("_cameraUsed") && $item[4-d camera].available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item 4-d camera", "", ChecklistSubentryMake("4-d camera copy available", "", potential_copies)));
    }
    if (!get_property_boolean("_iceSculptureUsed") && lookupItem("unfinished ice sculpture").available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item unfinished ice sculpture", "", ChecklistSubentryMake("Ice sculpture copy available", "", potential_copies)));
    }
    if (my_path_id() == PATH_BUGBEAR_INVASION && $item[crayon shavings].available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item crayon shavings", "", ChecklistSubentryMake(pluralize($item[crayon shavings].available_amount(), "crayon shaving copy", "crayon shaving copies") + " available", "", "Bugbears only.")));
    }
    if ($item[sticky clay homunculus].available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item sticky clay homunculus", "", ChecklistSubentryMake(pluralize($item[sticky clay homunculus].available_amount(), "sticky clay copy", "sticky clay copies") + " available", "", "Unlimited/day.")));
    }
    if (!get_property_boolean("_crappyCameraUsed") && $item[crappy camera].available_amount() > 0)
    {
        string [int] description = listCopy(potential_copies);
        description.listPrepend("50% success rate");
		available_resources_entries.listAppend(ChecklistEntryMake("__item crappy camera", "", ChecklistSubentryMake("Crappy camera copy available", "", description)));
    }
    
    //Copies made:


	generateCopiedMonstersEntry(available_resources_entries, available_resources_entries, false);
	SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[Rain-Doh box full of monster], "rain doh", "rainDohMonster");
	SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[spooky putty monster], "spooky putty", "spookyPuttyMonster");
    if (!get_property_boolean("_cameraUsed"))
        SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[shaking 4-d camera], "shaking 4-d camera", "cameraMonster");
    if (!get_property_boolean("_crappyCameraUsed"))
        SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[shaking crappy camera], "shaking crappy camera", "crappyCameraMonster");
	if (!get_property_boolean("_photocopyUsed"))
		SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[photocopied monster], "photocopied", "photocopyMonster");
	if (!get_property_boolean("_envyfishEggUsed"))
		SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[envyfish egg], "envyfish egg", "envyfishMonster");
	if (!get_property_boolean("_iceSculptureUsed"))
		SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, lookupItem("ice sculpture"), "ice sculpture", "iceSculptureMonster");
    
    SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[wax bugbear], "wax bugbear", "waxMonster");
    SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[crude monster sculpture], "crude sculpture", "crudeMonster");
}

void SCopiedMonstersGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	generateCopiedMonstersEntry(task_entries, optional_task_entries, true);
	
}