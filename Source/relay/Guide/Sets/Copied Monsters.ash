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

string generateNinjaSafetyGuide(boolean show_color)
{
	boolean can_survive = false;
	float init_needed = $monster[ninja snowman assassin].monster_initiative();
	init_needed = monster_initiative($monster[Ninja snowman assassin]);
	
	float damage_taken = calculateCurrentNinjaAssassinMaxDamage();
	
	string result;
	if (initiative_modifier() >= init_needed)
	{
		can_survive = true;
		result += "Keep";
	}
	else
		result += "Need";
	result += " +" + ceil(init_needed) + "% init to survive ninja, or ";
	
	int min_safe_damage = (ceil(damage_taken) + 2);
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
		if (item_drop_modifier() < 150.0)
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
        int lfm_attack = 171 + 5 + monster_level_adjustment();
        string line = lfm_attack + " attack.";
        
		if (my_buffedstat($stat[moxie]) < lfm_attack)
			line = HTMLGenerateSpanFont(line, "red", "");
        description.listAppend(line);
    }
}

void generateCopiedMonstersEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task) //if from_task is false, assumed to be from resources
{
	string [int] description;
	boolean very_important = false;
	int show_up_in_tasks_turn_cutoff = 10;
	string title = "";
	int min_turns_until = -1;
	if (__misc_state_string["Romantic Monster turn range"] != "" || get_property_int("_romanticFightsLeft") > 0)
	{
		string [int] turn_range_string = split_string_mutable(__misc_state_string["Romantic Monster turn range"], ",");
        
        Vec2i turn_range = Vec2iMake(turn_range_string[0].to_int(), turn_range_string[1].to_int()); //if these are zero, then we're still accurate
        
        title = "Arrowed " + __misc_state_string["Romantic Monster Name"].to_lower_case() + " appears ";
        
        if (turn_range.y <= 0)
            title += "now or soon";
        else if (turn_range.x <= 0)
            title += "between now and " + turn_range.y + " turns.";
        else
            title += "in [" + turn_range_string.listJoinComponents(" to ") + "] turns.";
        
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
	
	string line = monster_name.capitalizeFirstLetter() + HTMLGenerateIndentedText(monster_description);
	
	available_resources_entries.listAppend(ChecklistEntryMake(shaking_object, url, ChecklistSubentryMake(shaking_shorthand_name.capitalizeFirstLetter() + " monster trapped!", "", line)));
}

void SCopiedMonstersGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    //Sources:
	int copies_used = get_property_int("spookyPuttyCopiesMade") + get_property_int("_raindohCopiesMade");
	int copies_available = MIN(6,5*MIN($item[spooky putty sheet].available_amount() + $item[Spooky Putty monster].available_amount(), 1) + 5*MIN($item[Rain-Doh black box].available_amount() + $item[rain-doh box full of monster].available_amount(), 1));
    int copies_left = copies_available - copies_used;
	if (copies_left > 0)
	{
		string [int] copy_source_list;
		if ($item[spooky putty sheet].available_amount() + $item[Spooky Putty monster].available_amount() > 0)
        copy_source_list.listAppend("spooky putty");
		if ($item[Rain-Doh black box].available_amount() + $item[rain-doh box full of monster].available_amount() > 0)
        copy_source_list.listAppend("rain-doh black box");
        
		string copy_sources = copy_source_list.listJoinComponents("/");
		string name = "";
		//FIXME make this possibly say which one in the case of 6 (does that matter? how does that mechanic work?)
		name = pluralize(copies_left, copy_sources + " copy", copy_sources + " copies") + " left";
		string [int] description;
		available_resources_entries.listAppend(ChecklistEntryMake(copy_source_list[0], "", ChecklistSubentryMake(name, "", description)));
	}
    
    if (!get_property_boolean("_cameraUsed") && $item[4-d camera].available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item 4-d camera", "", ChecklistSubentryMake("4-d camera copy available", "", "")));
    }
    if (!get_property_boolean("_iceSculptureUsed") && lookupItem("unfinished ice sculpture").available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item unfinished ice sculpture", "", ChecklistSubentryMake("Ice sculpture copy available", "", "")));
    }
    if (my_path_id() == PATH_BUGBEAR_INVASION && $item[crayon shavings].available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item crayon shavings", "", ChecklistSubentryMake(pluralize($item[crayon shavings].available_amount(), "crayon shaving copy", "crayon shaving copies") + " available", "", "Bugbears only.")));
    }
    if ($item[sticky clay homunculus].available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item sticky clay homunculus", "", ChecklistSubentryMake(pluralize($item[sticky clay homunculus].available_amount(), "sticky clay copy", "sticky clay copies") + " available", "", "Unlimited/day.")));
    }
    
    //Copies made:


	generateCopiedMonstersEntry(available_resources_entries, available_resources_entries, false);
	SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[Rain-Doh box full of monster], "rain doh", "rainDohMonster");
	SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[spooky putty monster], "spooky putty", "spookyPuttyMonster");
    if (!get_property_boolean("_cameraUsed"))
        SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[shaking 4-d camera], "shaking 4-d camera", "cameraMonster");
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