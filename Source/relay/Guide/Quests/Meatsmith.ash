
void QMeatsmithInit()
{
	//questM23Meatsmith
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM23Meatsmith");
	
	state.quest_name = "Helping Make Ends Meat";
	state.image_name = "__item gnawed-up dog bone";
	
	state.startable = true;
	
	__quest_state["Meatsmith"] = state;
}


void QMeatsmithGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Meatsmith"];
    if (base_quest_state.finished)
        return;
    
    if (__last_adventure_location != $location[the skeleton store] || __last_adventure_location == $location[none])
        return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string active_url = "place.php?whichplace=town_market";
    
    boolean done = false;
    boolean have_reason_to_add = false;
    
	if (!base_quest_state.started)
    {
        have_reason_to_add = true;
        subentry.entries.listAppend("Go talk to the meatsmith to start the quest.");
    }
    else if (base_quest_state.mafia_internal_step == 1)
    {
        have_reason_to_add = true;
        if ($item[skeleton store office key].available_amount() == 0)
        {
            subentry.entries.listAppend("Check out the cash register at the NC.");
        }
        else
        {
            subentry.entries.listAppend("Head into the manager's office at the NC.");
        }
    }
    else if (base_quest_state.mafia_internal_step == 2)
    {
        have_reason_to_add = true;
        done = true;
        subentry.entries.listAppend("Return to the meatsmith.");
        active_url = "shop.php?whichshop=meatsmith";
    }
    
    if ($item[ring of telling skeletons what to do].item_amount() == 0)
    {
        if (!have_reason_to_add)
            subentry.header = "The Skeleton Store";
        string line = "Could acquire a ring of telling skeletons what to do, by opening the chest at the NC";
        if ($item[skeleton key].item_amount() == 0)
            line += HTMLGenerateSpanFont(" after acquiring a skeleton key", "red");
            
        line += ".";
        subentry.entries.listAppend(line);
        have_reason_to_add = true;
    }
    
    if (!done)
        subentry.entries.listAppend("Non-combat appears every fourth adventure."); //except the first time for some reason? needs spading
    
    boolean [location] relevant_locations;
    relevant_locations[$location[the skeleton store]] = true;
    
    if (have_reason_to_add)
        optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, relevant_locations));
}