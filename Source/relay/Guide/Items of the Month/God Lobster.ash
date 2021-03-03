
RegisterResourceGenerationFunction("IOTMGodLobsterGenerateResource");
void IOTMGodLobsterGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (!$familiar[god lobster].familiar_is_usable()) return;
	int free_fights_left = clampi(3 - get_property_int("_godLobsterFights"), 0, 3);
	
	if (free_fights_left == 0) return;
	string url = "familiar.php";
	if ($familiar[god lobster] == my_familiar())
		url = "";
  
    string [int] description;
    //This is so complicated.
	
	item [int] equipment_order;
	equipment_order.listAppend($item[God Lobster's Scepter]);
    equipment_order.listAppend($item[God Lobster's Ring]);
    equipment_order.listAppend($item[God Lobster's Rod]);
    equipment_order.listAppend($item[God Lobster's Robe]);
    equipment_order.listAppend($item[God Lobster's Crown]);
    
    item [item] equipment_to_next_reward;
    equipment_to_next_reward[$item[none]] = $item[God Lobster's Scepter];
    equipment_to_next_reward[$item[God Lobster's Scepter]] = $item[God Lobster's Ring];
    equipment_to_next_reward[$item[God Lobster's Ring]] = $item[God Lobster's Rod];
    equipment_to_next_reward[$item[God Lobster's Rod]] = $item[God Lobster's Robe];
    equipment_to_next_reward[$item[God Lobster's Robe]] = $item[God Lobster's Crown];
    equipment_to_next_reward[$item[God Lobster's Crown]] = $item[none];
	
	string [item] equipment_to_boon_description;
	equipment_to_boon_description[$item[none]] = "40 mp/adv / +20 MP";
    equipment_to_boon_description[$item[God Lobster's Scepter]] = "+10 stats/fight";
    equipment_to_boon_description[$item[God Lobster's Ring]] = "-combat";
    equipment_to_boon_description[$item[God Lobster's Rod]] = "+combat";
    equipment_to_boon_description[$item[God Lobster's Robe]] = "+1 all res / +20 DA / +3 DR";
    equipment_to_boon_description[$item[God Lobster's Crown]] = "doubles food statgain";
    
    
    string [item] equipment_to_equipment_effect_description;
    equipment_to_equipment_effect_description[$item[God Lobster's Scepter]] = "half-weight fairy/leprechaun";
    equipment_to_equipment_effect_description[$item[God Lobster's Ring]] = "sombrero statgain";
    equipment_to_equipment_effect_description[$item[God Lobster's Rod]] = "restore HP/MP after combat";
    equipment_to_equipment_effect_description[$item[God Lobster's Robe]] = "blocking potato";
    equipment_to_equipment_effect_description[$item[God Lobster's Crown]] = "full-weight fairy";
    
    float [item] equipment_to_mainstat_multiplier;
    equipment_to_mainstat_multiplier[$item[none]] = 1.5;
    equipment_to_mainstat_multiplier[$item[God Lobster's Scepter]] = 1.65;
    equipment_to_mainstat_multiplier[$item[God Lobster's Ring]] = 1.85;
    equipment_to_mainstat_multiplier[$item[God Lobster's Rod]] = 2.17;
    equipment_to_mainstat_multiplier[$item[God Lobster's Robe]] = 2.62;
    equipment_to_mainstat_multiplier[$item[God Lobster's Crown]] = 3.0;
	
	
	item current_familiar_equipment = $familiar[god lobster].familiar_equipped_equipment();
	
	string [int] current_rewards;
	//[next equipment], [effect], [experience]
	
	current_rewards.listAppend(equipment_to_boon_description[current_familiar_equipment] + " effect (33 turns)");
	if (__misc_state["need to level"])
	{
        float statgain = equipment_to_mainstat_multiplier[current_familiar_equipment] * my_basestat(my_primestat()) * (1.0 + numeric_modifier(my_primestat() + " experience percent") / 100.0);
        current_rewards.listAppend(round(statgain) + " mainstat gain");
    }
    
    if (equipment_to_next_reward[current_familiar_equipment] != $item[none] && equipment_to_next_reward[current_familiar_equipment].available_amount() == 0)
         current_rewards.listAppend("a " + equipment_to_next_reward[current_familiar_equipment].replace_string("God Lobster's", "").to_lower_case());
	
	if (current_rewards.count() > 0)
		description.listAppend("Can choose between " + current_rewards.listJoinComponents(", ", "or") + ".");
	
	string [int] other_equipment_to_switch_to;
	foreach it in equipment_to_boon_description
	{
		if (it.available_amount() == 0) continue;
        if (it == current_familiar_equipment) continue;
        //FIXME write this
        other_equipment_to_switch_to.listAppend(it + " (" + equipment_to_equipment_effect_description[it] + " and " + equipment_to_boon_description[it] + " obtainable effect)");
	}
	
	if (other_equipment_to_switch_to.count() > 0)
		description.listAppend("Could switch equipment to " + other_equipment_to_switch_to.listJoinComponents(", ", "or") + ".");
	
    resource_entries.listAppend(ChecklistEntryMake("__familiar god lobster", url, ChecklistSubentryMake(pluralise(free_fights_left, "free God Lobster fight", "free God Lobster fights"), "", description)).ChecklistEntryTag("daily free fight"));
}
