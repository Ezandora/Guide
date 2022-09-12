
void SCouncilGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__misc_state["in run"])
        return;
    if (my_path_id_legacy() == PATH_COMMUNITY_SERVICE)
        return;
	boolean council_probably_wants_to_speak_to_you = false;
	string [int] reasons;
    boolean [string] seen_quest_name;
	foreach quest_name in __quest_state
	{
		QuestState state = __quest_state[quest_name];
        if (state.quest_name == "Island War Quest" && my_path_id_legacy() == PATH_EXPLOSION) continue;
		if (state.startable && !state.in_progress && !state.finished && state.council_quest)
		{
            if (seen_quest_name[state.quest_name])
                continue;
            seen_quest_name[state.quest_name] = true;
			reasons.listAppend(state.quest_name);
			council_probably_wants_to_speak_to_you = true;
		}
	}
	if (!council_probably_wants_to_speak_to_you)
		return;
    
    string [int] description;
    
    description.listAppend("Start the " + reasons.listJoinComponents(", ", "and") + ".");
    
    if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues") && !have_outfit_components("Filthy Hippy Disguise") && __quest_state["Level 12"].startable && !__quest_state["Level 12"].in_progress && !__quest_state["Level 12"].finished && my_path_id_legacy() != PATH_EXPLOSIONS)
        description.listAppend(HTMLGenerateSpanFont("May want to wait", "red") + " until you've acquired a filthy hippy disguise for acquiring a war outfit?");
	if (my_path_id_legacy() == PATH_EXPLOSIONS)
		description.listAppend("You might need to visit your quest log afterwards, to update mafia's tracking.");
	task_entries.listAppend(ChecklistEntryMake(384, "council", "place.php?whichplace=town", ChecklistSubentryMake("Visit the Council of Loathing", "", description)));
}
