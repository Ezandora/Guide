
int IOTMEmotionChipCastsLeft(string [skill] skill_property_names, skill s)
{
	string property_name = skill_property_names[s];
	if (property_name == "") return 0;
	
	string property_value = get_property(property_name);
	if (property_value == "") return 0; //unsupported
	
	return clampi(3 - property_value.to_int(), 0, 3);
}

RegisterGenerationFunction("IOTMEmotionChipGenerate");
void IOTMEmotionChipGenerate(ChecklistCollection checklists)
{
	if (my_path_id() == PATH_AVATAR_OF_BORIS) return; //probably a lot of these
	if (!lookupSkill("Emotionally Chipped").have_skill())
	{
		if (lookupItem("spinal-fluid-covered emotion chip").have())
        {
        	string [int] description;
            description.listAppend("Use spinal-fluid-covered emotion chip.");
            if (my_path_id() != PATH_NONE)
	            description.listAppend("Unless that's impossible this path. (needs spading?)");
        	checklists.add(C_OPTIONAL_TASKS, ChecklistEntryMake(452, "__item spinal-fluid-covered emotion chip", "inventory.php?which=3", ChecklistSubentryMake("Acquire Emotionally Chipped skill", "", description), 9));
        }
		return;
    }

	
	/*
	Buffs: (20 turns)
	Feel Lonely - -5% combat
	Feel Excitement - +25 all stats
	Feel Peaceful - +2 all res, +10DR, +100 DA
	
	
	Combat:
	Feel Envy - drop all items
	Feel Hatred - banish (50 turns)
	Feel Nostalgic - gives drops from last monster in next fight - feelNostalgicMonster (feelsNostalgicMonster is in defaults but it's not the one updated)
	Feel Pride - triple stat gains in fight
	Feel Superior - main use: +3 PVP fights/day deal damage, gives PVP fight if killing blow. easiest method: use against crates with +0 ML (thanks boesbert)
	
	Ignored by Guide:
	Feel Disappointed: I will never live with disappointment!
	Feel Lost: +30 stats/fight +60% item is nice but doesn't work in adventure.php
	Feel Nervous - passive damage
    */
	string [skill] skill_property_names = {
	//lookupSkill("Feel Disappointed"):"_feelDisappointedUsed",
	lookupSkill("Feel Lonely"):"_feelLonelyUsed",
	lookupSkill("Feel Excitement"):"_feelExcitementUsed",
	lookupSkill("Feel Peaceful"):"_feelPeacefulUsed",
	
	lookupSkill("Feel Envy"):"_feelEnvyUsed",
	lookupSkill("Feel Hatred"):"_feelHatredUsed",
	lookupSkill("Feel Nostalgic"):"_feelNostalgicUsed",
	lookupSkill("Feel Pride"):"_feelPrideUsed",
	lookupSkill("Feel Superior"):"_feelSuperiorUsed",
	//lookupSkill("Feel Lost"):"_feelLostUsed",
	//lookupSkill("Feel Nervous"):"_feelNervousUsed",
	};
	
	boolean [skill] skills_that_are_buffs
	{
	lookupSkill("Feel Lonely"):true,
	lookupSkill("Feel Excitement"):true,
	lookupSkill("Feel Peaceful"):true,
	};
	
	
	monster nostalgic_monster = get_property_monster("feelNostalgicMonster");
	string [skill] skill_descriptions
	{
	lookupSkill("Feel Lonely"):"-5% combat. (20 turns)",
	lookupSkill("Feel Excitement"):"+25 all stats. (20 turns)",
	lookupSkill("Feel Peaceful"):"+2 all res, +DR/DA. (20 turns)",
	
	
	lookupSkill("Feel Envy"):"Drop all items next combat.",
	lookupSkill("Feel Hatred"):"Free run/banish monster for fifty turns.",
	lookupSkill("Feel Nostalgic"):"Give all drops from the last " + nostalgic_monster + " fight.",
	lookupSkill("Feel Pride"):"Triple stat gains next fight",
	lookupSkill("Feel Superior"):"",
	};
	
	string [skill] skill_url;
	
	boolean [skill] skills_to_skip_output;
	
	if (!hippy_stone_broken())
		skills_to_skip_output[lookupSkill("Feel Superior")] = true;
    else
    {
    	string description;
        description = "Gives +1 PVP fight each, if used properly. (last 20% monster health)|Try it against crates in the noob cave"; //thanks boesbert
        if (numeric_modifier("Monster Level") > 0)
        {
        	description += ", after lowering your +monster level to zero";
        }
        description += ".";
        skill_descriptions[lookupSkill("Feel Superior")] = description;
        skill_url[lookupSkill("Feel Superior")] = $location[noob cave].getClickableURLForLocation();
    }
    
    if (nostalgic_monster == $monster[none])
    {
		skills_to_skip_output[lookupSkill("Feel Nostalgic")] = true;
    }
    if (!in_ronin())
    {
		skills_to_skip_output[lookupSkill("Feel Lonely")] = true;
		skills_to_skip_output[lookupSkill("Feel Excitement")] = true;
		skills_to_skip_output[lookupSkill("Feel Peaceful")] = true;
  
  		skills_to_skip_output[lookupSkill("Feel Pride")] = true;
    }
	
	
	//Buffs:
    foreach s in skill_descriptions
    {
        if (skills_to_skip_output[s]) continue;
        int casts_left = IOTMEmotionChipCastsLeft(skill_property_names, s);
        if (casts_left == 0) continue;
        string description = skill_descriptions[s];
        
        string url;
        if (skills_that_are_buffs[s])
        {
        	url = "skillz.php";
        }
        
        if (skill_url contains s)
        	url = skill_url[s];
        
        int priority = 1;
        if (s == lookupSkill("Feel Hatred"))
        	priority = 0;
        
        ChecklistEntry entry = ChecklistEntryMake(453, "__skill " + s, url, ChecklistSubentryMake(pluralise(casts_left, "cast", "casts") + " of " + s, "", description), priority);
        if (skills_that_are_buffs[s])
        {
        	entry.ChecklistEntrySetCategory("buff");
            entry.ChecklistEntryTag("emotion chip buff");
        }
        else if (s.combat)
        {
        	entry.ChecklistEntrySetCategory("combat skill");
            entry.ChecklistEntryTag("emotion chip combat");
        }
        else
        {
        	entry.ChecklistEntryTag("emotion chip");
        }
        
        if (s == lookupSkill("Feel Hatred"))
        {
        	entry.ChecklistEntryTag("free banish");
        	entry.ChecklistEntrySetCategory("free banish");
        }
        checklists.add(C_RESOURCES, entry);
    }

}
