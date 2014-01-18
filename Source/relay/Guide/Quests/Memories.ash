//Currently disabled. Complicated.

void QMemoriesInit()
{
    if (true)
        return;
    if (true)
    {
        QuestState state;
        QuestStateParseMafiaQuestProperty(state, "questF01Primordial");
        
        state.quest_name = "Primordial Fear Quest";
        state.image_name = "__item empty agua de vida bottle";
        
        
        __quest_state["Primordial Fear"] = state;
    }
    if (true)
    {
        QuestState state;
        QuestStateParseMafiaQuestProperty(state, "questF02Hyboria");
        
        state.quest_name = "Hyboria Quest";
        state.image_name = "__item empty agua de vida bottle";
        
        
        __quest_state["Hyboria"] = state;
    }
    if (true)
    {
        QuestState state;
        QuestStateParseMafiaQuestProperty(state, "questF03Future");
        
        state.quest_name = "Future Quest";
        state.image_name = "__item empty agua de vida bottle";
        
        
        __quest_state["Future"] = state;
    }
}


void QMemoriesPrimordialFearGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Primordial Fear"];
	if (!base_quest_state.in_progress)
		return;
    string active_url = "";
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    //FIXME implement this
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[the primordial soup]));
}

void QMemoriesHyboriaGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Hyboria"];
	if (!base_quest_state.in_progress)
		return;
    string active_url = "";
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    //FIXME implement this
    
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[the jungles of ancient loathing]));
}

void QMemoriesFutureGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Future"];
	if (!base_quest_state.in_progress)
		return;
    string active_url = "";
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    //FIXME implement this
    
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[seaside megalopolis]));
}

void QMemoriesGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (true)
        return;
    if (__quest_state["Primordial Fear"].in_progress)
    {
        QMemoriesPrimordialFearGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    else if (__quest_state["Hyboria"].in_progress)
    {
        QMemoriesHyboriaGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    else if (__quest_state["Future"].in_progress)
    {
        QMemoriesFutureGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
}