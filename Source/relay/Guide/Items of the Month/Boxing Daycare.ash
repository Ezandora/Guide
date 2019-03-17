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
		resource_entries.listAppend(ChecklistEntryMake("__item orange boxing gloves", "place.php?whichplace=town_wrong&action=townwrong_boxingdaycare", ChecklistSubentryMake("Boxing daycare buff (100 turns)", description), 5));
	}
	if (hippy_stone_broken() && !get_property_boolean("_daycareFights") && !__misc_state["in run"])
	{
		string [int] description;
        description.listAppend("Costs one adventure. Spar.");
        if (get_property_int("daycareToddlers") <= 2)
        	description.listAppend("Should recruit first.");
        resource_entries.listAppend(ChecklistEntryMake("__item orange boxing gloves", "place.php?whichplace=town_wrong&action=townwrong_boxingdaycare", ChecklistSubentryMake("Boxing daycare PVP fights", description), 5));
		
	}
}
