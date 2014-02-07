
void QLevel6Init()
{
	//questL06Friar
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL06Friar");
	state.quest_name = "Deep Fat Friars' Quest";
	state.image_name = "forest friars";
	state.council_quest = true;
	
	if (my_level() >= 6)
		state.startable = true;
	
	__quest_state["Level 6"] = state;
	__quest_state["Friars"] = state;
}

float QLevel6TurnsToCompleteArea(location place)
{
    //FIXME not sure how accurate these calculations are.
    //First NC will always happen at 5, second at 10, third at 15.
    int turns_spent_in_zone = turnsAttemptedInLocation(place); //not always accurate
    int ncs_found = noncombatTurnsAttemptedInLocation(place);
    if (ncs_found == 3)
        return 0.0;
    float turns_remaining = 0.0;
    int ncs_remaining = MAX(0, 3 - ncs_found);
    
    float combat_rate = 0.85 + combat_rate_modifier() / 100.0;
    float noncombat_rate = 1.0 - combat_rate;
    
    if (noncombat_rate != 0.0)
        turns_remaining = ncs_remaining / noncombat_rate;
    
    return MIN(turns_remaining, MAX(0, 15.0 - turns_spent_in_zone.to_float()));
}


void QLevel6GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 6"].in_progress)
		return;
	boolean want_hell_ramen = false;
	if (have_skill($skill[pastamastery]) && have_skill($skill[Advanced Saucecrafting]))
		want_hell_ramen = true;
	boolean hot_wings_relevant = __quest_state["Pirate Quest"].state_boolean["hot wings relevant"];
	boolean need_more_hot_wings = __quest_state["Pirate Quest"].state_boolean["need more hot wings"];
	
	QuestState base_quest_state = __quest_state["Level 6"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	if (want_hell_ramen && __misc_state["have olfaction equivalent"])
		subentry.modifiers.listAppend("olfact hellions");
	
	string [int] sources_need_234;
	if (want_hell_ramen)
		sources_need_234.listAppend("hell ramen");
	if (need_more_hot_wings)
		sources_need_234.listAppend("hot wings");
	if (sources_need_234.count() > 0)
		subentry.modifiers.listAppend("+234% item");
    
    boolean need_minus_combat = false;
	if ($item[dodecagram].available_amount() == 0)
    {
		subentry.entries.listAppend("Adventure in " + HTMLGenerateSpanOfClass("Dark Neck of the Woods", "r_bold") + ", acquire dodecagram.|~" + roundForOutput(QLevel6TurnsToCompleteArea($location[the dark neck of the woods]), 1) + " average turns remain at " + combat_rate_modifier().floor() + "% combat.");
        need_minus_combat = true;
    }
	if ($item[box of birthday candles].available_amount() == 0)
    {
		subentry.entries.listAppend("Adventure in " + HTMLGenerateSpanOfClass("Dark Heart of the Woods", "r_bold") + ", acquire box of birthday candles.|~" + roundForOutput(QLevel6TurnsToCompleteArea($location[the Dark Heart of the Woods]), 1) + " turns remain at " + combat_rate_modifier().floor() + "% combat.");
        need_minus_combat = true;
    }
	if ($item[Eldritch butterknife].available_amount() == 0)
    {
		subentry.entries.listAppend("Adventure in " + HTMLGenerateSpanOfClass("Dark Elbow of the Woods", "r_bold") + ", acquire Eldritch butterknife.|~" + roundForOutput(QLevel6TurnsToCompleteArea($location[the Dark Elbow of the Woods]), 1) + " turns remain at " + combat_rate_modifier().floor() + "% combat.");
        need_minus_combat = true;
    }
	
    string [int] needed_modifiers;
    if (need_minus_combat)
    {
        subentry.modifiers.listAppend("-combat");
        needed_modifiers.listAppend("-combat");
    }
	if (sources_need_234.count() > 0)
        needed_modifiers.listAppend("+234% item for " + listJoinComponents(sources_need_234, "/"));
    if (needed_modifiers.count() > 0)
        subentry.entries.listAppend("Run " + needed_modifiers.listJoinComponents(", ", "and") + ".");
    
	if ($item[dodecagram].available_amount() + $item[box of birthday candles].available_amount() + $item[Eldritch butterknife].available_amount() == 3 && !(hot_wings_relevant && $item[hot wing].available_amount() <3))
		subentry.entries.listAppend("Go to the cairn stones!"); //FIXME suggest this only if we've gotten everything else?
	
	if (__misc_state_int["ruby w needed"] > 0)
		subentry.entries.listAppend("Potentially find ruby W, if not clovering (w imp, dark neck, 30% drop)");
	if (hot_wings_relevant)
    {
        if ($item[hot wing].available_amount() <3 )
            subentry.entries.listAppend((MIN(3, $item[hot wing].available_amount())) + "/3 hot wings for pirate quest. (optional, 30% drop)");
        else
            subentry.entries.listAppend((MIN(3, $item[hot wing].available_amount())) + "/3 hot wings for pirate quest.");
    }
	boolean should_delay = false;
	if (__misc_state_string["ballroom song"] != "-combat")
	{
		subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
		should_delay = true;
	}
	
	if (should_delay)
		future_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "friars.php", subentry, $locations[the dark neck of the woods, the dark heart of the woods, the dark elbow of the woods]));
	else
		task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "friars.php", subentry, $locations[the dark neck of the woods, the dark heart of the woods, the dark elbow of the woods]));
}