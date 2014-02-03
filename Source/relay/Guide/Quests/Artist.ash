
void QArtistInit()
{
	//questM02Artist
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM02Artist");
    
    if (!state.started && $items[pail of pretentious paint, pretentious paintbrush, pretentious palette].available_amount() > 0)
        QuestStateParseMafiaQuestPropertyValue(state, "started");
	
	state.quest_name = "Pretentious Artist's Quest";
	state.image_name = "__item pretentious palette";
	
	state.startable = true;
	
	__quest_state["Artist"] = state;
}


void QArtistGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Artist"];
	if (!base_quest_state.in_progress)
		return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string active_url = "";
	
	boolean output_modifiers = false;
	if ($item[pretentious palette].available_amount() == 0)
	{
		//haunted pantry
		subentry.entries.listAppend("Adventure in the haunted pantry for pretentious palette. (25% superlikely)");
		output_modifiers = true;
	}
	if ($item[pretentious paintbrush].available_amount() == 0)
	{
		//cobb's knob
		subentry.entries.listAppend("Adventure in the outskirts of Cobb's Knob for pretentious paintbrush. (25% superlikely)");
		output_modifiers = true;
	}
	if ($item[pail of pretentious paint].available_amount() == 0)
	{
		//sleazy back alley
		subentry.entries.listAppend("Adventure in the sleazy back alley for pail of pretentious paint. (25% superlikely)");
		output_modifiers = true;
	}
	
	if (output_modifiers)
	{
		if (__misc_state["free runs available"])
		{
			subentry.modifiers.listAppend("free runs");
		}
		if (__misc_state["have hipster"])
		{
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
		}
	}
	
	if ($item[pretentious palette].available_amount() > 0 && $item[pretentious paintbrush].available_amount() > 0 && $item[pail of pretentious paint].available_amount() > 0)
	{
		subentry.entries.listAppend("Talk to the pretentious artist.");
        active_url = "place.php?whichplace=town_wrong";
	}
	
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[the sleazy back alley, the outskirts of cobb's knob, the haunted pantry]));
}