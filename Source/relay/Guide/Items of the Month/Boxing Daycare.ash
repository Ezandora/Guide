RegisterTaskGenerationFunction("IOTMBoxingDaycareGenerateTasks");
void IOTMBoxingDaycareGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__iotms_usable[lookupItem("Boxing Day care package")]) return;
	//collect nap consumable
    ChecklistEntry entry;
    entry.url = "place.php?whichplace=town_wrong&action=townwrong_boxingdaycare";
    entry.image_lookup_name = "__item orange boxing gloves";
    entry.importance_level = 8;
	if (!get_property_boolean("_daycareNap"))
	{
        entry.subentries.listAppend(ChecklistSubentryMake("Take a daycare nap", "", "Gives a consumable."));
	}
	//scavenge once
	if (get_property_int("_daycareGymScavenges") == 0 && __misc_state["need to level"])
	{
        entry.subentries.listAppend(ChecklistSubentryMake("Scavenge for daycare equipment", "", "Statgain."));
	}
    else if (get_property_int("_daycareRecruits") < 1 && __misc_state["in run"] && $skill[Army of Toddlers].skill_is_usable() && __misc_state["need to level"] && my_meat() >= 100)
    {
        entry.subentries.listAppend(ChecklistSubentryMake("Recruit at the boxing daycare?", "", "100 meat, benefits army of toddlers statgain."));
    }
	if (entry.subentries.count() > 0)
	{
        optional_task_entries.listAppend(entry);
	}
}

RegisterResourceGenerationFunction("IOTMBoxingDaycareGenerateResource");
void IOTMBoxingDaycareGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__iotms_usable[lookupItem("Boxing Day care package")]) return;
	//buffs
	if (!get_property_boolean("_daycareSpa"))
	{
		string [int] description;
        if (in_ronin())
        {
        	description.listAppend("+200% muscle, +15 ML");
            description.listAppend("+200% moxie, +50% init");
            description.listAppend("+200% myst, +25% item");
            description.listAppend("+100 HP, +50 MP, +25 DR, +~8 MP regen, +~15 HP regen");
        }
        else
            description.listAppend("+200% myst, +25% item");
		resource_entries.listAppend(ChecklistEntryMake("__item orange boxing gloves", "place.php?whichplace=town_wrong&action=townwrong_boxingdaycare", ChecklistSubentryMake("Boxing daycare buff (100 turns)", description), 5).ChecklistEntryTagEntry("boxing daycare"));
	}
	if (hippy_stone_broken() && !get_property_boolean("_daycareFights") && !__misc_state["in run"])
	{
		string [int] description;
        description.listAppend("Costs one adventure. Spar.");
        if (get_property_int("daycareToddlers") <= 2)
        	description.listAppend("Should recruit first.");
        resource_entries.listAppend(ChecklistEntryMake("__item orange boxing gloves", "place.php?whichplace=town_wrong&action=townwrong_boxingdaycare", ChecklistSubentryMake("Boxing daycare PVP fights", description), 5).ChecklistEntryTagEntry("boxing daycare"));
		
	}
	if (__misc_state["in run"] && $skill[Army of Toddlers].skill_is_usable() && !get_property_boolean("_armyToddlerCast") && __misc_state["need to level"])
	{
		string [int] description;
        //is this mainstat or what
        float total_statgain = sqrt(get_property_int("daycareToddlers"));// * (1.0 + numeric_modifier(my_primestat() + " experience percent") / 100.0);
        float [stat] split_statgain = {$stat[muscle]:total_statgain * 0.25, $stat[mysticality]:total_statgain * 0.25, $stat[moxie]:total_statgain * 0.25};
        split_statgain[my_primestat()] = total_statgain * 0.5;
        foreach s, v in split_statgain
        {
        	split_statgain[s] = v * (1.0 + numeric_modifier(s + " experience percent") / 100.0);
        }
        string [int] stats_out;
        stats_out.listAppend(split_statgain[$stat[muscle]].roundForOutput(0));
        stats_out.listAppend(split_statgain[$stat[mysticality]].roundForOutput(0));
        stats_out.listAppend(split_statgain[$stat[moxie]].roundForOutput(0));
        
        description.listAppend("50 MP, gain " + stats_out.listJoinComponents(" / ") + " stats.");
        if (split_statgain[my_primestat()] < 3.0 || get_property_int("daycareToddlers") <= 2)
        	description.listAppend("Might want to recruit first.");
        resource_entries.listAppend(ChecklistEntryMake("__skill Army of Toddlers", "", ChecklistSubentryMake("Army of Toddlers castable", description), 5).ChecklistEntryTagEntry("boxing daycare"));
		
	}
}
