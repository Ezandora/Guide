

RegisterTaskGenerationFunction("IOTMBastilleBattalionGenerateTasks");
void IOTMBastilleBattalionGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (lookupItem("Bastille Battalion control rig").available_amount() == 0) return;
	
	if (lookupItem("Draftsman's driving gloves").available_amount() > 0 || lookupItem("Nouveau nosering").available_amount() > 0 || lookupItem("Brutal brogues").available_amount() > 0) return;
	
	string [int] description;
	string url = "inv_use.php?pwd=" + my_hash() + "&whichitem=9928";
	
	//FIXME suggest the right configuration
	if (lookupItem("Bastille Battalion control rig").storage_amount() > 0)
	{
        url = "storage.php?which=3";
        description.listAppend("Free pull from Hagnk's.");
	}
	//FIXME in the future, we might want to suggest options for them. We haven't, because it's a lot of space, especially the equipment.
	string [int] suggested_configuration;
	if (__misc_state["need to level"])
	{
		int stats_gained = ceil(250 * (1.0 + numeric_modifier(my_primestat() + " experience percent") / 100.0));
		if (my_primestat() == $stat[muscle])
        {
            description.listAppend(HTMLGenerateSpanOfClass("Babar", "r_bold") + ": " + stats_gained + " muscle stats.");
            suggested_configuration.listAppend("Babar");
        }
        else if (my_primestat() == $stat[mysticality])
        {
        	description.listAppend(HTMLGenerateSpanOfClass("Barbarian Barbecue", "r_bold") + ": " + stats_gained + " mysticality stats.");
            suggested_configuration.listAppend("Barbarian Barbecue");
        }
        else if (my_primestat() == $stat[moxie])
        {
            description.listAppend(HTMLGenerateSpanOfClass("Barbershop", "r_bold") + ": " + stats_gained + " moxie stats.");
            suggested_configuration.listAppend("Barbershop");
        }
	}
	string [int] accessories;
	accessories.listAppend(HTMLGenerateSpanOfClass("Accessory:", "r_bold"));
    accessories.listAppend(HTMLGenerateSpanOfClass("Brutalist", "r_bold") + ": +50% muscle, +50% weapon damage, +8 familiar weight, +4 muscle stats/fight.");
    accessories.listAppend(HTMLGenerateSpanOfClass("Draftsman", "r_bold") + ": +50% myst, +50% spell damage, +8 adventures/day, +4 myst stats/fight.");
    accessories.listAppend(HTMLGenerateSpanOfClass("Art Nouveau", "r_bold") + ": +50% moxie, +25% item, +25 HP/MP, +4 moxie stats/fight.");
    description.listAppend(accessories.listJoinComponents("|*"));
    
    string [int] buffs;
    buffs.listAppend(HTMLGenerateSpanOfClass("Buff:", "r_bold") + " (100 turns)");
    buffs.listAppend(HTMLGenerateSpanOfClass("Cannon", "r_bold") + ": +25 muscle, +10% critical hit, ~15 HP/adventure.");
    buffs.listAppend(HTMLGenerateSpanOfClass("Catapult", "r_bold") + ": +25 myst, +10% spell critical hit, ~7.5 MP/adventure.");
    buffs.listAppend(HTMLGenerateSpanOfClass("Gesture", "r_bold") + ": +25 moxie, +25% init, +25% meat.");
    description.listAppend(buffs.listJoinComponents("|*"));
    
    if (!in_ronin())
    {
    	//+adventures in aftercore
        suggested_configuration.listAppend("Draftsman");
    }
    else if (my_primestat() == $stat[muscle])
    {
    	suggested_configuration.listAppend("Brutalist");
    }
    else if (my_primestat() == $stat[mysticality])
    {
        suggested_configuration.listAppend("Draftsman");
    }
    else if (my_primestat() == $stat[moxie])
    {
        suggested_configuration.listAppend("Art Nouveau");
    }
    
    if (!in_ronin())
        suggested_configuration.listAppend("Gesture");
    else
    	suggested_configuration.listAppend("Catapult");
    
    description.listAppend("Suggested configuration: " + HTMLGenerateSpanOfClass(suggested_configuration.listJoinComponents(" / "), "r_bold") + ".");
	
	optional_task_entries.listAppend(ChecklistEntryMake("__item Bastille Battalion control rig", url, ChecklistSubentryMake("Collect Bastille rewards", "", description), 8));
}
