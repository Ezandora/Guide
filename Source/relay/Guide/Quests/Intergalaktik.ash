void QGalaktikInit()
{
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM24Doc");
    
	
	state.quest_name = "What's Up, Doc?";
	state.image_name = "__item pretty flower";
	
	state.startable = true;
	
	__quest_state["Galaktik"] = state;
}


void QGalaktikGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Galaktik"];
	if (!base_quest_state.in_progress)
		return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string active_url = "place.php?whichplace=town_wrong";
    string image_name = base_quest_state.image_name;
    
    string [int] missing_item_descriptions;
    foreach it in $items[swindleblossom,fraudwort,shysterweed]
    {
        if (it.available_amount() >= 3)
            continue;
        missing_item_descriptions.listAppend(pluraliseWordy(3 - it.available_amount(), "more " + it, "more " + it.plural));
    }
    
    if (missing_item_descriptions.count() > 0)
    {
        subentry.entries.listAppend("Collect " + missing_item_descriptions.listJoinComponents(", ", "and") + " in the overgrown lot.");
        if (lookupItem("brown paper bag mask").available_amount() > 0 && lookupItem("brown paper bag mask").equipped_amount() == 0)
            subentry.entries.listAppend("Could equip the brown paper bag mask to meet the Lot's wife, if you haven't already.");
        
        if (__misc_state["In run"] && __last_adventure_location != lookupLocation("the overgrown lot") && !in_bad_moon())
            return;
    }
    else
    {
        //shop.php?whichshop=doc&action=talk
        active_url = "shop.php?whichshop=doc&action=talk";
        subentry.entries.listAppend("Return to Doc Galaktik.");
        //image_name = "__familiar o.a.f.";
    }
	
	optional_task_entries.listAppend(ChecklistEntryMake(image_name, active_url, subentry, lookupLocations("the overgrown lot")));
}