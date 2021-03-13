
void QLevel2Init()
{
	//questL02Larva
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questL02Larva");
	if (my_path_id() == PATH_COMMUNITY_SERVICE) QuestStateParseMafiaQuestPropertyValue(state, "finished"); 
	
	state.quest_name = "Spooky Forest Quest";
	state.image_name = "Spooky Forest";
	state.council_quest = true;
	
	if (my_level() >= 2 || my_path_id() == PATH_EXPLOSIONS)
		state.startable = true;
	
	if (state.in_progress)
	{
		if ($item[mosquito larva].available_amount() > 0)
		{
			state.state_boolean["have mosquito"] = true;
		}
	}
	else if (state.finished)
	{
		state.state_boolean["have mosquito"] = true;
	}
	
	__quest_state["Level 2"] = state;
	__quest_state["Spooky Forest"] = state;
}


void QLevel2GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Level 2"];
	if (!base_quest_state.in_progress)
		return;
    
    if (my_path_id() == PATH_COMMUNITY_SERVICE || __misc_state["in aftercore"])
        return;
		
	ChecklistSubentry subentry;
    string url = "place.php?whichplace=woods";
	
	subentry.header = base_quest_state.quest_name;
	
	
	if (base_quest_state.state_boolean["have mosquito"])
	{
		subentry.entries.listAppend("Finished, go chat with the council.");
        url = "place.php?whichplace=town";
	}
	else
	{
		string [int] modifiers;
		modifiers.listAppend("-combat");
		
		if (delayRemainingInLocation($location[the spooky forest]) > 0)
		{
            string hipster_text = "";
            if (__misc_state["have hipster"])
            {
                hipster_text = " (use " + __misc_state_string["hipster name"] + ")";
                modifiers.listAppend(__misc_state_string["hipster name"]);
            }
			string line = "Delay for " + pluralise(delayRemainingInLocation($location[the spooky forest]), "turn", "turns") + hipster_text + ".";
            subentry.entries.listAppend(line);
			subentry.entries.listAppend("Run -combat after that.");
		}
		else
			subentry.entries.listAppend("Run -combat");
		subentry.entries.listAppend("Explore the stream" + __html_right_arrow_character + "March to the marsh");
		
		
		if (!__quest_state["Manor Unlock"].state_boolean["ballroom song effectively set"])
			subentry.entries.listAppend("Possibly wait until -combat ballroom song set. (marginal)");
			
		if (__misc_state["free runs available"])
		{
			subentry.entries.listAppend("Free run from monsters (low stats)");
			modifiers.listAppend("free runs");
		}
			
			
		subentry.modifiers = modifiers;
	}
	
	task_entries.listAppend(ChecklistEntryMake(80, base_quest_state.image_name, url, subentry, $locations[the spooky forest]));
}
