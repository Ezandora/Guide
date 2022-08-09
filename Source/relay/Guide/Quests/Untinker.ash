
void QUntinkerInit()
{
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM01Untinker");
	
	state.quest_name = "Untinker's Quest";
	state.image_name = "rusty screwdriver";
	
	state.startable = $location[the spooky forest].locationAvailable();
	
	__quest_state["Untinker"] = state;
}


void QUntinkerGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Untinker"];
	if (base_quest_state.finished || !base_quest_state.startable)
		return;
    
    if (my_path_id() == PATH_EXPLOSION) return;
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string url = "";
	
	if ($item[rusty screwdriver].available_amount() > 0 || base_quest_state.mafia_internal_step == 0)
	{
		subentry.entries.listAppend("Speak to the Untinker.");
		url = "place.php?whichplace=forestvillage&action=fv_untinker_quest";
	}
	else
	{
        //Acquire rusty screwdriver:
		if (knoll_available())
		{
			subentry.entries.listAppend("Speak to Innabox in Degrassi Knoll.");
			url = "place.php?whichplace=knoll_friendly";
		}
		else
		{
            url = "place.php?whichplace=knoll_hostile";
			subentry.entries.listAppend("Retrieve screwdriver from the Degrassi Knoll Garage.|(25% superlikely)");
			if (__misc_state["free runs available"])
			{
				subentry.modifiers.listAppend("free runs");
			}
			if (__misc_state["have hipster"])
			{
				subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			}
		}
	}
	
	optional_task_entries.listAppend(ChecklistEntryMake(29, base_quest_state.image_name, url, subentry, 8, $locations[the degrassi knoll garage]));
}
